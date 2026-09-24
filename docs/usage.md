# How to Use the QADB

You may access the QADB in many ways; see the table of contents on the right :arrow_right:

If you'd rather code than read, skip ahead to [the Software Access Section](#machine-access-software).

## Interactive Access: `qadb-info`

The `qadb-info` command may be used to get information about the QADB, including:
- Available datasets
- Defect bits
- FC charge, filtered by QA defects chosen by the user
- Query the QADB by run number, event number, and/or QA bin number

For usage guidance, just run:
```bash
qadb-info
```

??? tip "Click here if `qadb-info` is not found..."

    Either:

    - it's at `./bin/qadb-info`, so type the full path to it
    - add `bin/` to your `$PATH`, which you can do with
    ```bash
    source environ.sh   # for bash, zsh
    source environ.csh  # for csh, tcsh
    ```

!!! warning
    Do not call `qadb-info` in an analysis event loop, since it will run too slowly.
    Instead, use the provided software (see below) or operate on the QADB files directly.

## Human Access: Plain Text
Human-readable tables are provided in "QADB Text Files", which you may find for each dataset
in either

- [Table of Available Datasets](datasets.md)
- [Index of QADB Text Files](tables/index_txt.md)

These files are provided for quickly looking up QADB information for a run, and they are not
intended to be parsed programmatically; see the [Software Access Section](#machine-access-software) for programmatic access.

??? info "Click here for how to read these text files..."

    Each run begins with the keyword `RUN:`, followed by some information pulled from RCDB, such
    as target type and beam current. Lines below that are for each of that run's QA bins and their QA
    results, with the following syntax:
    ```
    run_number  bin_number  defect_bits...
    ```
    There may be multiple defect bits; if there are none, the symbol `|` is written instead.

    Some QA bins include a comment (usually when the `Misc` defect bit is assigned), surrounded by
    `::` symbols; the syntax is then:
    ```
    run_number  bin_number  :: comment ::  defect_bits...
    ```

    The defect bits have the following form:
    ```
    bit_number-defect_name[list_of_sectors]
    ```
    The list of sectors is not delimited, _e.g._, `125` means sectors 1, 2, and 5;
    the word `all` is used in place of `123456`.

## Machine Access: Software

Classes in both C++ and Groovy (for Java) are provided, for access to the QADB within analysis code.
In either case, you need environment variables; if you are using an `ifarm` build, they
have already been set for you, otherwise:
```bash
source environ.sh   # for bash, zsh
source environ.csh  # for csh, tcsh
```
Then:

- for Java/Groovy, follow [`src/README.md`](https://github.com/JeffersonLab/clas12-qadb/blob/main/src/README.md)
- for C++, follow [`srcC/README.md`](https://github.com/JeffersonLab/clas12-qadb/blob/main/srcC/README.md)

### Example Code

There are examples within those aforementioned `src` and `srcC` directories, but here's some C++ code to demonstrate
general QADB usage; Java/Groovy usage is very similar.

!!! warning
    This example code is not tested, and might even be broken! Please report any issues...

#### Before Event Processing

Setup the QADB criteria

- Choose which defect bits to accept or reject
- Choose which `Misc` bit assignments to accept or reject

```cpp
// instantiate QADB
QADB qa("latest"); // use "latest" for the latest cook, "pass1" for pass 1, etc.

// decide which defects you want to check for; an event will not pass the QA
// cut if the associated QA bin has any of the specified defects
qa.CheckForDefect("TotalOutlier");
qa.CheckForDefect("TerminalOutlier");
qa.CheckForDefect("MarginalOutlier");
qa.CheckForDefect("SectorLoss");
qa.CheckForDefect("Misc");

// decide which runs for which you care about the 'Misc' defect bit or not;
// you can generate this following code using `qadb-info`, see the TIP below
std::vector<int> allow_these_misc_assignments = {
  5875,       // N/q low, gradually decreasing with file number
  // 5877,    // N/q is high for the whole run
  // 5878,    // N/q is high for the whole run
  5884,       // Ended run: mvt1/mvt2 crashed.
  5885,       // slightly low value of N/q
};

// tell `qa` to allow these data if ONLY the 'Misc' defect bit is assigned
for(auto run : allow_these_misc_assignments)
  qa.AllowMiscBit(run);
```

??? tip "TIP: to generate code for listing runs with `Misc` defect bits..."

    Use `qadb-info`, for example, for RG-K Fall 2018 datasets; first,
    get the list of dataset names:

    ```bash
    qadb-info print --list --run-group k --latest
    ```
    ```
    rgk_fa18_6.5GeV  ->  refers to pass1/rgk_fa18_6.5GeV
    rgk_fa18_7.5GeV  ->  refers to pass1/rgk_fa18_7.5GeV
    ```

    Then, for these datasets, get the list of RG-K runs with 'Misc' defect bit, with QADB comments;
    we want C++ code, so we use `'//'` for the `--code` option:
    ```bash
    qadb-info misc --datasets rgk_fa18_6.5GeV,rgk_fa18_7.5GeV --code '//'
    ```
    ```
    misc_qa_runs = [
      5875,    // N/q low, gradually decreasing with file number
      5877,    // N/q is high for the whole run
      ...
    ]
    ```
    Then you can copy-paste that list into your analysis code.


#### For Each Event

Check if the event's QADB bin passes your criteria
```cpp
// get event-level info
auto runnum   = /* get the run number */
auto evnum    = /* get the event number */

// if you need helicity, be sure to correct it,
// since for some runs it is flipped!
auto helicity = /* get the beam helicity */
helicity *= qa.CorrectHelicitySign(runnum, evnum);

// apply QA cuts
if(qa.Pass(runnum, evnum)) {

  // accumulate DAQ-gated FC charge;
  // it will only accumulate once per QA bin you analyzed
  qa.AccumulateCharge();

  // similarly if you want helicity-latched (HL) charge
  qa.AccumulateChargeHL();

  /* continue your analysis here */
}
```

#### After Event Processing

If you need FC charge, you can get it summed over the QA bins which passed your QA cuts.
See also the [How to Access the FC Charge](#how-to-access-the-fc-charge) section for more info.

```cpp
// the total DAQ-gated FC charge, filtered by the QA
auto total_charge = qa.GetAccumulatedCharge();

// or the helicity-latched charge
auto total_charge_for_positive_helicity  = qa.GetAccumulatedChargeHL(1);
auto total_charge_for_negative_helicity  = qa.GetAccumulatedChargeHL(-1);
auto total_charge_for_undefined_helicity = qa.GetAccumulatedChargeHL(0);
```

## Machine Access: Files

### JSON Files

The QADB files are organized by dataset: one subdirectory of [`qadb/`](https://github.com/JeffersonLab/clas12-qadb/tree/main/qadb) per dataset.
Each directory contains the QADB itself, stored in `json` files, meant for programmatic access.

The dataset directories are organized by cook number (pass):

- within `qadb/`, the `pass*/` directories are for each cook (`pass1`, `pass2`, _etc_.)
  - within each `pass*/` directory are subdirectories for each dataset
- the `latest/` directory contains symbolic links to the _latest_ cook of each dataset with a QADB

The QADB defects are stored as JSON files in `qaTree.json`; the format is a tree:
```
qaTree.json ─┬─ run number 1
             ├─ run number 2 ─┬─ bin number 1
             │                ├─ bin number 2
             │                ├─ bin number 3 ─┬─ evnumMin
             │                │                ├─ evnumMax
             │                │                ├─ sectorDefects
             │                │                ├─ defect
             │                │                └─ comment
             │                ├─ bin number 4
             │                └─ bin number 5
             ├─ run number 3
             └─ run number 4
```
For each bin, the following variables are defined:

- `evnumMin` and `evnumMax` represent the range of event numbers associated with this bin; use this to map a particular event number to a bin number
- `sectorDefects` is a map with sector number keys paired with lists of associated defect bits
- `defect` is a decimal representation of the `OR` of each sector's defect bits, for example, `11=0b1011` means that the `OR` of the defect bit lists is `[0,1,3]`
- `comment` stores an optional comment regarding the QA result

The charge is also stored in JSON files in `chargeTree.json`, with a similar format:
```
chargeTree.json ─┬─ run number 1
                 ├─ run number 2 ─┬─ bin number 1
                 │                ├─ bin number 2
                 │                ├─ bin number 3 ─┬─ fcChargeMin
                 │                │                ├─ fcChargeMax
                 │                │                ├─ ufcChargeMin
                 │                │                ├─ ufcChargeMax
                 │                │                └─ nElec ─┬─ sector 1
                 │                │                          ├─ sector 2
                 │                │                          ├─ sector 3
                 │                │                          ├─ sector 4
                 │                │                          ├─ sector 5
                 │                │                          └─ sector 6
                 │                ├─ bin number 4
                 │                └─ bin number 5
                 ├─ run number 3
                 └─ run number 4
```
For each bin, the following variables are defined:

- `fcChargeMin` and `fcChargeMax` represent the minimum and maximum DAQ-gated Faraday cup charge, in nC
- `ufcChargeMin` and `ufcChargeMax` represent the minimum and maximum FC charge, but not gated by the DAQ
- the difference between the maximum and minimum charge is the accumulated charge in that bin
- `nElec` lists the number of electrons from each sector

### Raw ASCII Tables

Raw ASCII tables, with all of the QADB information (except for comments) are available for reading the QADB without a JSON parser.

See the [Index of Raw Tables](tables/index_raw.md) to download them.


## How to Access the FC Charge
The charge is stored in the QADB for each QA bin, so that it is possible to
determine the amount of accumulated charge for data that satisfy your specified
QA criteria. To calculate the charge, you'll need to add up the charge from each
bin that you include in your analysis. To help, you can either:

- use the command `qadb-info charge`; use its options to specify:
    - the dataset and/or list of runs
    - which defect bits that you want to allow or reject
    - of the runs which only have the `Misc` bit, choose those that you want to allow or reject
    - the output format
- use the software: see [`chargeSum.groovy`](https://github.com/JeffersonLab/clas12-qadb/blob/main/src/examples/chargeSum.groovy)
  or [`chargeSum.cpp`](https://github.com/JeffersonLab/clas12-qadb/blob/main/srcC/examples/chargeSum.cpp) for usage example in an analysis event loop; basically:
    - call `QADB::AccumulateCharge()` within your event loop, after your QA cuts are satisfied; the QADB instance will keep track of the accumulated DAQ-gated charge you analyzed (accumulation performed per QA bin)
    - at the end of your event loop, the total accumulated DAQ-gated charge you analyzed is given by `QADB::GetAccumulatedCharge()`

!!! note
    Helicity-latched charge is accessed using similar methods:

    - `QADB::AccumulateChargeHL()`, for each event
    - `QADB::GetAccumulatedChargeHL(int state)` at the end, where `state` is the helicity: `1` or `-1` (or `0` for undefined helicity).

    Helicity-latched charge is not available for all datasets' QADBs; if you need it for a certain dataset where
    it is not available, request it from the QADB maintainers.

!!! warning
    For Pass 1 QA results for Run Groups A, B, K, and M, we find some
    evidence that the charge from bin to bin may slightly overlap,
    or there may be gaps in the accumulated charge between each bin; the former leads to
    a slight over-counting and the latter leads to a slight under-counting

    - this issue is why we transitioned from using DST files as QA bins to using nth scaler readouts as bin boundaries
    - corrections of this issue to these older QADBs will not be applied
