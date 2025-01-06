![QADB](/doc/logo.png)

# CLAS12 Quality Assurance Database
Provides storage of and access to the QA monitoring results for the
CLAS12 experiment at Jefferson Lab

### Table of Contents
1. [How to Use the QADB in Your Analysis](#use)
1. [QA Information](#info)
    - [Available Data Sets](#datasets)
    - [Defect Bit Definitions](#bitdefs)
1. [How to Access the QADB](#access)
    - [Software Access](#software)
    - [Data Storage Details](#storage)
1. [How to Access the Faraday Cup Charge](#charge)
1. [Database Maintenance](#dev)
1. [Contributions](#contributions)

<a name="use"></a>
# How to Use the QADB in Your Analysis

The QADB is used to _filter_ data based on Quality Assurance (QA) observations.
The database stores information about the "defects" of each run: each run is
subdivided into "QA bins", and for each bin, a set of "defect bits" may or may
not be assigned. See the [table of available data sets](#datasets) for which
data are included in the QADB.

The user must decide which defect bits should be filtered out of their
analysis. See [the table of defect bits](#bitdefs) to decide; special care must
be taken for the `Misc` defect bit, which is assigned for runs (or part of
runs) that have abnormal conditions, whether found on the timelines or
documented in the log book.
- Each QA bin that has the `Misc` defect bit set includes a _comment_ in the
  QADB, explaining _why_ the bit was set
- The analyzer must decide whether or not data with the `Misc` defect bit
  should be excluded from their analysis
- To help with this decision-making, [`Misc` summary tables are provided](#storage),
  which contain the comment(s) for each run

<a name="info"></a>
# QA Information

## QA Ground Rules

> [!IMPORTANT]
> The following rules are enforced for the QA procedure and the resulting QADB:
> 1. The QA procedure runs on the data as they are and does not fix any of their problems.
> 2. The QADB only provides defect identification and does not provide analysis-specific decisions.
> 3. At least two people independently perform the "manual QA" part of the QA procedure, and the results are cross checked and merged.

<a name="datasets"></a>
## Available Data Sets
The following tables describe the available data sets in the QADB. The columns are:
- **Pass**: the Pass number of the data set (higher is newer)
- **Data Set Name**: a unique name for the data-taking period; click it to see the corresponding QA timelines
  - Typically `[RUN_GROUP]_[RUN_PERIOD]`
  - `[RUN_PERIOD]` follows the convention `[SEASON(sp/su/fa/wi)]_[YEAR]`, and sometimes includes an additional keyword
- **Run range**: the run numbers in this data set
- **Status**:
  - _Up-to-Date_: this is the most recent Pass of these data, and the QADB has been updated for it
  - _Deprecated_: a newer Pass exists for these data, but the QADB for this version is still preserved
  - _TO DO_: the Pass for these data exist, but the QADB has not yet been updated for it
- **Data files**: the input data files used for the QA

> [!CAUTION]
> The QADB for older data sets may have some issues, and may even violate the
> above ground rules. It is **HIGHLY recommended** to
> [check the known important issues](/doc/issues.md) to see if any issues impact your analysis.

### Run Group A

| Pass | Data Set Name and Timelines Link                                                           | Run Range   | Status       | Data Files                                                                  |
| ---  | ---                                                                                        | ---         | ---          | ---                                                                         |
| 2    | `rga_fa18_inbending`                                                                       | 5032 - 5419 | _TO DO_      |                                                                             |
| 2    | `rga_fa18_outbending`                                                                      | 5422 - 5666 | _TO DO_      |                                                                             |
| 2    | [`rga_sp19`](https://clas12mon.jlab.org/rga/pass2/sp19/qa/rga_sp19_nSidis/tlsummary)       | 6616 - 6783 | _Up-to-Date_ | `/cache/clas12/rg-a/production/recon/spring2019/torus-1/pass2/dst/recon`    |
| 1    | [`rga_fa18_inbending`](https://clas12mon.jlab.org/rga/pass1/qa/fa18_inbending/tlsummary)   | 5032 - 5419 | _Up-to-Date_ | `/cache/clas12/rg-a/production/recon/fall2018/torus-1/pass1/v0/dst/recon`   |
| 1    | [`rga_fa18_outbending`](https://clas12mon.jlab.org/rga/pass1/qa/fa18_outbending/tlsummary) | 5422 - 5666 | _Up-to-Date_ | `/cache/clas12/rg-a/production/recon/fall2018/torus+1/pass1/v0/dst/recon`   |
| 1    | [`rga_sp19`](https://clas12mon.jlab.org/rga/pass1/qa/sp19/tlsummary)                       | 6616 - 6783 | _Deprecated_ | `/cache/clas12/rg-a/production/recon/spring2019/torus-1/pass1/v0/dst/recon` |

### Run Group B

| Pass | Data Set Name and Timelines Link                                     | Run Range     | Status       | Data Files                                                                   |
| ---  | ---                                                                  | ---           | ---          | ---                                                                          |
| 2    | `rgb_sp19`                                                           | 6156 - 6603   | _TO DO_      | `/cache/clas12/rg-b/production/recon/spring2019/torus-1/pass2/v0/dst/recon/` |
| 2    | `rgb_fa19`                                                           | 11093 - 11300 | _TO DO_      |                                                                              |
| 2    | `rgb_wi20`                                                           | 11323 - 11571 | _TO DO_      |                                                                              |
| 1    | [`rgb_sp19`](https://clas12mon.jlab.org/rgb/pass1/qa/sp19/tlsummary) | 6156 - 6603   | _Up-to-Date_ | `/cache/clas12/rg-b/production/recon/spring2019/torus-1/pass1/v0/dst/recon`  |
| 1    | [`rgb_fa19`](https://clas12mon.jlab.org/rgb/pass1/qa/fa19/tlsummary) | 11093 - 11300 | _Up-to-Date_ | `/cache/clas12/rg-b/production/recon/fall2019/torus+1/pass1/v1/dst/recon`    |
| 1    | [`rgb_wi20`](https://clas12mon.jlab.org/rgb/pass1/qa/wi20/tlsummary) | 11323 - 11571 | _Up-to-Date_ | `/cache/clas12/rg-b/production/recon/spring2020/torus-1/pass1/v1/dst/recon`  |

### Run Group C

| Pass | Data Set Name and Timelines Link                                                              | Run Range     | Status       | Data Files                                     |
| ---  | ---                                                                                           | ---           | ---          | ---                                            |
| 1    | [`rgc_su22`](https://clas12mon.jlab.org/rgc/Summer2022/qa-physics/pass1-sidisdvcs/tlsummary/) | 16042 - 16771 | _Up-to-Date_ | `/cache/clas12/rg-c/production/summer22/pass1` |

### Run Group F

| Pass | Data Set Name and Timelines Link | Run Range     | Status  | Data Files                                                                                  |
| ---  | ---                              | ---           | ---     | ---                                                                                         |
| 1    | `rgf_sp20_torusM1`               | 12210 - 12329 | _TO DO_ | `/cache/clas12/rg-f/production/recon/spring2020/torus-1_solenoid-0.8/pass1v0/dst/recon`     |
| 1    | `rgf_su20_torusPh`               | 12389 - 12434 | _TO DO_ | `/cache/clas12/rg-f/production/recon/summer2020/torus+0.5_solenoid-0.745/pass1v0/dst/recon` |
| 1    | `rgf_su20_torusMh`               | 12436 - 12443 | _TO DO_ | `/cache/clas12/rg-f/production/recon/summer2020/torus-0.5_solenoid-0.745/pass1v0/dst/recon` |
| 1    | `rgf_su20_torusM1`               | 12447 - 12951 | _TO DO_ | `/cache/clas12/rg-f/production/recon/summer2020/torus-1_solenoid-0.745/pass1v0/dst/recon`   |

### Run Group K

| Pass | Data Set Name and Timelines Link                                                   | Run Range   | Status       | Data Files                                                                        |
| ---  | ---                                                                                | ---         | ---          | ---                                                                               |
| 2    | `rgk_fa18_7.5GeV`                                                                  | 5674 - 5870 | _TO DO_      |                                                                                   |
| 2    | `rgk_fa18_6.5GeV`                                                                  | 5875 - 6000 | _TO DO_      |                                                                                   |
| 1    | [`rgk_fa18_7.5GeV`](https://clas12mon.jlab.org/rgk/pass1/qa/fa18_7.5GeV/tlsummary) | 5674 - 5870 | _Up-to-Date_ | `/cache/clas12/rg-k/production/recon/fall2018/torus+1/7546MeV/pass1/v0/dst/recon` |
| 1    | [`rgk_fa18_6.5GeV`](https://clas12mon.jlab.org/rgk/pass1/qa/fa18_6.5GeV/tlsummary) | 5875 - 6000 | _Up-to-Date_ | `/cache/clas12/rg-k/production/recon/fall2018/torus+1/6535MeV/pass1/v0/dst/recon` |

### Run Group M

| Pass | Data Set Name and Timelines Link                                                     | Run Range     | Status       | Data Files                                                  |
| ---  | ---                                                                                  | ---           | ---          | ---                                                         |
| 1    | [`rgm_fa21`](https://clas12mon.jlab.org/rgm/pass1_finalqadb/rgm_fall2021/tlsummary/) | 15019 - 15884 | _Up-to-Date_ | `/cache/clas12/rg-m/production/pass1/allData_forTimelines/` |


<a name="bitdefs"></a>
## Defect Bit Definitions

* QA information is stored for each **QA bin**, in the form of **defect bits**
  * the user needs only the run number and event number to query the QADB
* A **QA bin** is:
  * the set of events between a fixed number of scaler readouts (roughly a time bin, although
    there are fluctuations in a bin's duration)
  * for older QADBs, Run Groups A, B, K, and M of Pass 1 data, the QA bins were DST 5-files
* A **defect bit** is:
  * a bit (of a binary number) that is `1` if the QA bin exhibits the corresponding defect or `0` if not
  * each defect bit corresponds to a different defect, as shown in the table below
  * many defects check the value of N/F, defined as the trigger electron yield N, normalized by the DAQ-gated Faraday Cup charge F

### Table of Defect Bits


| Bit | Name | Description | Additional Notes |
| --- | --- | --- | --- |
| 0 | `TotalOutlier` | Outlier FD electron N/F, but not `TerminalOutlier` or `MarginalOutlier` |  |
| 1 | `TerminalOutlier` | Outlier FD electron N/F of first or last QA bin of run |  |
| 2 | `MarginalOutlier` | Marginal FD electron outlier N/F, within one standard deviation of cut line |  |
| 3 | `SectorLoss` | FD electron N/F diminished for several consecutive QA bins | For older datasets (RG-A,B,K,M pass 1), this bit _replaced_ the assignment of `TotalOutlier`, `TerminalOutlier`, and `MarginalOutlier`; newer datasets only add the `SectorLoss` bit and do not remove the outlier bits. |
| 4 | `LowLiveTime` | Live time < 0.9 | This assignment of this bit may be correlated with a low fraction of events with a defined (nonzero) helicity. |
| 5 | `Misc` | Miscellaneous defect, documented as comment | This bit is often assigned to all QA bins within a run, but in some cases, may only be assigned to the relevant QA bins. The analyzer must decide whether data assigned with the `Misc` bit should be excluded from their analysis; the comment is provided for this purpose. Analyzers are also encouraged to check the Hall B log book for further details. |
| 6 | `TotalOutlierFT` | Outlier FT electron N/F, but not `TerminalOutlierFT` or `MarginalOutlierFT` | _cf_. `TotalOutlier`. |
| 7 | `TerminalOutlierFT` | Outlier FT electron N/F of first or last QA bin of run | _cf_. `TerminalOutlier`. |
| 8 | `MarginalOutlierFT` | Marginal FT electron outlier N/F, within one standard deviation of cut line | _cf_. `MarginalOutlier`. |
| 9 | `LossFT` | FT electron N/F diminished for several consecutive QA bins | _cf_. `SectorLoss`. |
| 10 | `BSAWrong` | Beam Spin Asymmetry is the wrong sign | This bit is assigned per run. The asymmetry is significant, but the sign is opposite than expected; analyzers must therefore _flip_ the helicity sign. |
| 11 | `BSAUnknown` | Beam Spin Asymmetry is unknown, likely because of low statistics | This bit is assigned per run. There are not enough data to determine if the helicity sign is correct for this run. |
| 12 | `TSAWrong` | Target Spin Asymmetry is the wrong sign | __Not yet used.__ |
| 13 | `TSAUnknown` | Target Spin Asymmetry is unknown, likely because of low statistics | __Not yet used.__ |
| 14 | `DSAWrong` | Double Spin Asymmetry is the wrong sign | __Not yet used.__ |
| 15 | `DSAUnknown` | Double Spin Asymmetry is unknown, likely because of low statistics | __Not yet used.__ |
| 16 | `ChargeHigh` | FC Charge is abnormally high | NOTE: the assignment criteria of this bit are still under study. |
| 17 | `ChargeNegative` | FC Charge is negative | The FC charge is calculated from the charge readout at QA bin boundaries. Normally the later charge readout is higher than the earlier; this bit is assigned when the opposite happens. |
| 18 | `ChargeUnknown` | FC Charge is unknown; the first and last time bins _always_ have this defect | QA bin boundaries are at scaler charge readouts. The first QA bin, before any readout, has no initial charge; the last QA bin, after all scaler readouts, has no final charge. Therefore, the first and last QA bins have an unknown, but likely _very small_ charge accumulation. |
| 19 | `PossiblyNoBeam` | Both N and F are low, indicating the beam was possibly off | NOTE: the assignment criteria of this bit are still under study. |
<!-- NOTE: do not update this table manually; instead, use `util/makeDefectMarkdown.rb` -->

<a name="access"></a>
# How to Access the QADB

You may access the QADB in many ways:

## Text Access
* human-readable tables are stored in `qadb/*/qaTree.json.table`; see
  the section *QA data storage, Table files* below for details for how
  to read these files
* QADB JSON files are stored in `qadb/*/qaTree.json`

<a name="software"></a>
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

> [!IMPORTANT]
> C++ access needs [`rapidjson`](https://github.com/Tencent/rapidjson/), provided as a
> submodule of this repository in `srcC/rapidjson`. If this directory
> is empty, you can clone the submodule by running
> ```bash
> git submodule update --init --recursive
> ```
<!--`-->

<a name="storage"></a>
## Data Storage Details

The QADB is stored in the [`qadb/` subdirectory](/qadb):
- within `qadb/`, the `pass*/` directories are for each cook (`pass1`, `pass2`, _etc_.)
  - within each `pass*/` directory are subdirectories for each dataset
- the `latest/` directory contains symbolic links to the _latest_ cook of each data set with a QADB

In each dataset's directory, there are a few files:
- Summary tables regarding the `Misc` defect bit assignment are stored in `miscTable.md`;
  use these to help decide which runs' `Misc` bits you want to omit from your analysis
- A human-readable table of the full QADB is stored in `qaTree.json.table`, a "Table File";
  see below for how to interpret this file
- The QADB itself is stored in `json` files, meant for programmatic access

### Table Files

Human-readable format of QA result, stored in `qaTree.json.table`
* each run begins with the keyword `RUN:`; lines below are for each of that
  run's QA bins and their QA results, with the following syntax:
  * `run_number bin_number defect_bits :: comment`
    * defect bits have the following form: `bit_number-defect_name[list_of_sectors]`,
      and `[all]` means that all 6 sectors have this defect
    * comments are usually associated with `Misc` defects, but not always


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


<a name="charge"></a>
# How to Access the Faraday Cup Charge
* the charge is stored in the QADB for each QA bin, so that it is possible to
  determine the amount of accumulated charge for data that satisfy your
  specified QA criteria.
* see [`chargeSum.groovy`](/src/examples/chargeSum.groovy) or [`chargeSum.cpp`](/srcC/examples/chargeSum.cpp)
  for usage example in an analysis event loop; basically:
  * call `QADB::AccumulateCharge()` within your event loop, after your QA cuts
    are satisfied; the QADB instance will keep track of the accumulated charge
    you analyzed (accumulation performed per QA bin)
  * at the end of your event loop, the total accumulated charge you analyzed is
    given by `QADB::GetAccumulatedCharge()`

> [!CAUTION]
> For Pass 1 QA results for Run Groups A, B, K, and M, we find some
> evidence that the charge from bin to bin may slightly overlap,
> or there may be gaps in the accumulated charge between each bin; the former leads to
> a slight over-counting and the latter leads to a slight under-counting
> * this issue is why we transitioned from using DST files as QA bins to using
>   nth scaler readouts as bin boundaries
> * corrections of this issue to these older QADBs will not be applied

<a name="dev"></a>
# QADB Maintenance

Documentation for QADB maintenance and revision

## Adding to or revising the QADB
* the QADB files are produced by [`clas12-timeline`](https://github.com/JeffersonLab/clas12-timeline)
* if you have produced QA results for a new data set, and would like to add
  them to the QADB, or if you would like to update results for an existing
  dataset, follow the following procedure:
  * [ ] `mkdir qadb/pass${pass}/${dataset}/`, then copy the final `qaTree.json` and
    `chargeTree.json` to that directory
  * [ ] add/update a symlink to this dataset in `qadb/latest`, if this is a new Pass
  * [x] ~~run `util/makeTables.sh`~~ a pre-commit hook will take care of this
  * [x] ~~update customized QA criteria sets, such as `OkForAsymmetry`~~ this function is no longer maintained
  * [ ] update the above table of data sets
  * [ ] submit a pull request

## Adding new defect bits
* defect bits must be added in the following places:
  * Groovy:
    * `src/clasqa/Tools.groovy` (copy from `clasqa` repository version)
    * `src/clasqa/QADB.groovy`
    * `src/examples/dumpQADB.groovy` (optional)
  * C++:
    * `srcC/include/QADB.h`
    * `srcC/examples/dumpQADB.cpp` (optional)
  * Documentation:
    * `qadb/defect_definitions.json`, then use `util/makeDefectMarkdown.rb` to generate
      Markdown table for `README.md`


<a name="contributions"></a>
# Contributions

All contributions are welcome, whether to the code, examples, documentation, or
the QADB itself. You are welcome to open an issue and/or a pull request. If the
maintainer(s) do not respond in a reasonable time, send them an email.
