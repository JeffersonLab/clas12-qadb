# How to Use the QADB

You may access the QADB in many ways:

## `qadb-info` Command

The `qadb-info` command may be used to get information about the QADB, including:
- available datasets
- defect bits
- FC charge, filtered by QA defects chosen by the user
- query the QADB by run number, event number, and/or QA bin number

For usage guidance, just run:
```bash
qadb-info
```

!!! tip
    If `qadb-info` is not found, either:
    - it's at `./bin/qadb-info`, so type the full path to it
    - add `bin/` to your `$PATH`, which you can do with
    ```bash
    source environ.sh   # for bash, zsh
    source environ.csh  # for csh, tcsh
    ```

!!! warning
    Do not call `qadb-info` in an analysis event loop, since it will run too slowly.
    Instead, use the provided software (see below) or operate on the QADB files directly.

## Text Access
* human-readable tables are stored in `qadb/*/qaTree.json.table`; see
  the section **Table Files** below for details on how
  to read these files
* QADB JSON files are stored in `qadb/*/qaTree.json`; these are text files,
  but they are meant to be used by **Software**, described in the next section

## Software Access

Classes in both C++ and Groovy are provided, for access to the QADB within analysis code.
In either case, you need environment variables; if you are using an `ifarm` build, they
have already been set for you, otherwise:
```bash
source environ.sh   # for bash, zsh
source environ.csh  # for csh, tcsh
```
Then:
- for Groovy, follow [`src/README.md`](/src/)
- for C++, follow [`srcC/README.md`](/srcC/)

## Example Code

The following C++ code demonstrates general QADB usage. The usage is very similar in Groovy.

**Before Processing Events:** Setup the QADB criteria
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

// decide which runs for which you care about the 'Misc' defect bit or not
std::vector<int> allow_these_misc_assignments = {
  5875,    // N/F low, gradually decreasing with file number
  // 5877,    // N/F is high for the whole run
  // 5878,    // N/F is high for the whole run
  5884,    // Ended run: mvt1/mvt2 crashed.
  5885,    // slightly low value of N/F
};
/* TIP: you can generate this list and comments using `qadb-info`,
   e.g., for RG-K datasets:

   # get the list of RG-K datasets
   >>> qadb-info print --list --run-group k --latest

       rgk_fa18_6.5GeV  ->  refers to pass1/rgk_fa18_6.5GeV
       rgk_fa18_7.5GeV  ->  refers to pass1/rgk_fa18_7.5GeV

   # get the list of RG-K runs with 'Misc' defect bit, with QADB comments
   >>> qadb-info misc --datasets rgk_fa18_6.5GeV,rgk_fa18_7.5GeV --code '//'

       misc_qa_runs = [
         5875,    // N/F low, gradually decreasing with file number
         5877,    // N/F is high for the whole run
         ...
       ]
 */

// tell `qa` to allow these data if ONLY the 'Misc' defect bit is assigned
for(auto run : allow_these_misc_assignments)
  qa.AllowMiscBit(run);
```

**For Each Event:** Check if the event's QADB bin passes your criteria
```cpp
// get event-level info
auto runnum   = /* get the run number */
auto evnum    = /* get the event number */
auto helicity = /* get the beam helicity */

// correct the helicity sign
helicity *= qa.CorrectHelicitySign(runnum, evnum);

// apply QA cuts
if(qa.Pass(runnum, evnum)) {

  // accumulate DAQ-gated FC charge (it will only accumulate once per QA bin you analyzed)
  qa.AccumulateCharge();

  // if you want helicity-latched charge (from HEL::scaler), there is a similar method
  qa.AccumulateChargeHL();

  /* continue your analysis here */
}
```

**After Processing Events**
```cpp
// the total DAQ-gated FC charge, filtered by the QA
auto total_charge = qa.GetAccumulatedCharge();

// or the helicity-latched charge
auto total_charge_for_positive_helicity  = qa.GetAccumulatedChargeHL(1);
auto total_charge_for_negative_helicity  = qa.GetAccumulatedChargeHL(-1);
auto total_charge_for_undefined_helicity = qa.GetAccumulatedChargeHL(0);
```

!!! warning
    The above example code is not tested, and might be broken! You may need to refer
    to the other examples in `srcC/` and `src/`.

## QADB Files and Tables

The QADB files are organized by dataset: one subdirectory of [`qadb/`](/qadb) per dataset.
Each directory contains:
- Summary tables regarding the `Misc` defect bit assignment are stored in `miscTable.md`;
  **use these to help decide which runs' `Misc` bits you want to omit from your analysis**
- A human-readable table of the full QADB is stored in `qaTree.json.table`, a "Table File";
  see below for how to interpret this file
- The QADB itself is stored in `json` files, meant for programmatic access

The dataset directories are organized by cook number (pass):
- within `qadb/`, the `pass*/` directories are for each cook (`pass1`, `pass2`, _etc_.)
  - within each `pass*/` directory are subdirectories for each dataset
- the `latest/` directory contains symbolic links to the _latest_ cook of each dataset with a QADB


### Table Files

These files are a human-readable form of the QADB, stored as
`qaTree.json.table` within each dataset directory. Each run begins with the
keyword `RUN:`; lines below are for each of that run's QA bins and their QA
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


### JSON files

#### `qaTree.json`
* The QADB itself is stored as JSON files in `qaTree.json`
* the format is a tree:
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
* for each bin, the following variables are defined:
  * `evnumMin` and `evnumMax` represent the range of event numbers associated
    with this bin; use this to map a particular event number to a bin number
  * `sectorDefects` is a map with sector number keys paired with lists of associated
    defect bits
  * `defect` is a decimal representation of the `OR` of each sector's defect bits, for
    example, `11=0b1011` means that the `OR` of the defect bit lists is `[0,1,3]`
  * `comment` stores an optional comment regarding the QA result

#### `chargeTree.json`
* the charge is also stored in JSON files in `chargeTree.json`, with
  a similar format:
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
* for each bin, the following variables are defined:
  * `fcChargeMin` and `fcChargeMax` represent the minimum and maximum DAQ-gated
    Faraday cup charge, in nC
  * `ufcChargeMin` and `ufcChargeMax` represent the minimum and maximum FC charge,
    but not gated by the DAQ
  * the difference between the maximum and minimum charge is the accumulated charge
    in that bin
  * `nElec` lists the number of electrons from each sector


# How to Access the Faraday Cup Charge
The charge is stored in the QADB for each QA bin, so that it is possible to
determine the amount of accumulated charge for data that satisfy your specified
QA criteria. To calculate the charge, you'll need to add up the charge from each
bin that you include in your analysis. To help, you can either:
* use the command `qadb-info charge`; use its options to specify:
  * the dataset and/or list of runs
  * which defect bits that you want to allow or reject
  * of the runs which only have the `Misc` bit, choose those that you want to
    allow or reject
  * the output format
* use the software: see [`chargeSum.groovy`](/src/examples/chargeSum.groovy)
  or [`chargeSum.cpp`](/srcC/examples/chargeSum.cpp) for usage example in an
  analysis event loop; basically:
  * call `QADB::AccumulateCharge()` within your event loop, after your QA cuts
    are satisfied; the QADB instance will keep track of the accumulated DAQ-gated charge
    you analyzed (accumulation performed per QA bin)
  * at the end of your event loop, the total accumulated DAQ-gated charge you analyzed is
    given by `QADB::GetAccumulatedCharge()`

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
    * this issue is why we transitioned from using DST files as QA bins to using
      nth scaler readouts as bin boundaries
    * corrections of this issue to these older QADBs will not be applied

