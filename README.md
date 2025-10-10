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
    - [Example Code](#example)
    - [QADB Files and Tables](#files)
1. [How to Access the Faraday Cup Charge](#charge)
1. [Database Maintenance](#dev)
1. [QA Ground Rules](#rules)
1. [Contributions](#contributions)

<a name="use"></a>
# How to Use the QADB in Your Analysis

The QADB is used to _filter_ data based on Quality Assurance (QA) observations.
The database stores information about the "defects" of each run: each run is
subdivided into "QA bins", and for each bin, a set of "defect bits" may or may
not be assigned. See the [table of available data sets](#datasets) for which
data are included in the QADB.

The user must decide which defect bits should be filtered out of their
analysis. See [the table of defect bits](#bitdefs) and decide which
bits to use in the filter.

> [!IMPORTANT]
> Special care must be taken for the `Misc` defect bit, which is assigned for
> runs (or part of runs) that have abnormal conditions, whether found on the
> timelines or documented in the log book:
> - Each QA bin that has the `Misc` defect bit set includes a _comment_ in the
>   QADB, explaining _why_ the bit was set
> - The analyzer must decide whether or not data with the `Misc` defect bit
>   should be excluded from their analysis
> - To help with this decision-making, use the `qadb-info misc` command, or use the
>   [`Misc` summary tables are found in each dataset's directory](#files),
>   which provide the comment(s) for each run

The QADB is available on `ifarm` as the `qadb` module:
```bash
module avail qadb
# then 'module load' the one you want
```
Alternatively, you may download and use this repository locally:
```bash
git clone --recurse-submodules https://github.com/JeffersonLab/clas12-qadb.git
source clas12-qadb/environ.sh  # or environ.csh, if using csh
```

<a name="info"></a>
# QA Information

## Information from `qadb-info`

The program `qadb-info` may be used to get information about the QADB, including:
- available data sets
- defect bits
- FC charge, filtered by QA defects chosen by the user
- query the QADB by run number, event number, and/or QA bin number

For usage guidance, just run:
```bash
qadb-info
```

> [!TIP]
> If `qadb-info` is not found, either:
> - it's at `./bin/qadb-info`, so type the full path to it
> - add `bin/` to your `$PATH`, which you can do with
> ```bash
> source environ.sh   # for bash, zsh
> source environ.csh  # for csh, tcsh
> ```
<!--`-->

> [!CAUTION]
> Do not call `qadb-info` in an analysis event loop, since it will run too slowly.
> Instead, use [the provided software](#software) or operate on the QADB files directly.

<a name="datasets"></a>
## Available Data Sets
The following tables describe the available data sets in the _latest_ version of the QADB; click on a run group to expand the table. The columns are:
- **Pass**: the Pass number of the data set (higher is newer)
- **Data Set Name**: a unique name for the data-taking period; click it to see the corresponding QA timelines
  - Typically `[RUN_GROUP]_[RUN_PERIOD]`
  - `[RUN_PERIOD]` follows the convention `[SEASON(sp/su/fa/wi)]_[YEAR]`, and sometimes includes an additional keyword
- **Run range**: the run numbers in this data set
- **Status**:
  - :green_circle: _Up-to-Date_: this is the most recent Pass of these data, and the QADB has been updated for it
  - :warning: _Deprecated_: a newer Pass exists for these data, but the QADB for this version is still preserved
  - :x: _TO DO_: the Pass for these data exist, but the QADB has not yet been updated for it
- **Notes**:
  - **Data**: the input data used for the QA; this is the top level directory, where trains (skim files) and full DSTs are stored
  - **Analyzed Files**: the specific files (_e.g._ train) used for the QA
  - **Issues**: links to any known issues with this QADB

> [!CAUTION]
> The QADB for older data sets may have some issues, and may even violate the
> [QA ground rules](#rules). It is **HIGHLY recommended** to also
> [check the known important issues](/doc/issues.md) to see if any issues impact your analysis.

### Run Groups

Click on a run group to see its table.

<details>
<summary>Run Group A</summary>

| Pass | Data Set Name and Timelines Link                                                                            | Run Range    | Status         | Notes          |                                                                                                                                                                                                                                                                 |
| ---  | ---                                                                                                         | ---          | ---            | ---            | ---                                                                                                                                                                                                                                                             |
| 1    | `rga_sp18_inbending` (TODO: add link)                                                                       | 3306 - 3817, | :green_circle: | Data           | `/cache/clas12/rg-a/production/recon/spring2018/10.59gev/torus-1/pass1/dst`                                                                                                                                                                                     |
|      |                                                                                                             | 4003 - 4325  |                | Analyzed Files | `nSidis` train                                                                                                                                                                                                                                                  |
|      |                                                                                                             |              |                | Issues         | :bangbang: [#92](https://github.com/JeffersonLab/clas12-qadb/issues/92)                                                                                                                                                                                         |
| 1    | `rga_sp18_outbending` (TODO: add link)                                                                      | 3211 - 3293, | :green_circle: | Data           | `/cache/clas12/rg-a/production/recon/spring2018/10.59gev/torus+1/pass1/dst`                                                                                                                                                                                     |
|      |                                                                                                             | 3863 - 3987  |                | Analyzed Files | `nSidis` train                                                                                                                                                                                                                                                  |
|      |                                                                                                             |              |                | Issues         | :bangbang: [#92](https://github.com/JeffersonLab/clas12-qadb/issues/92)                                                                                                                                                                                         |
| 2    | [`rga_fa18_inbending`](https://clas12mon.jlab.org/rga/pass2/fa18/qa/rga_fa18_inbending_nSidis/tlsummary/)   | 5032 - 5419  | :green_circle: | Data           | `/cache/clas12/rg-a/production/recon/fall2018/torus-1/pass2/main`                                                                                                                                                                                               |
|      |                                                                                                             |              |                | Analyzed Files | `nSidis` train                                                                                                                                                                                                                                                  |
|      |                                                                                                             |              |                | Issues         | None                                                                                                                                                                                                                                                            |
| 2    | [`rga_fa18_outbending`](https://clas12mon.jlab.org/rga/pass2/fa18/qa/rga_fa18_outbending_nSidis/tlsummary/) | 5422 - 5666  | :green_circle: | Data           | `/cache/clas12/rg-a/production/recon/fall2018/torus+1/pass2`                                                                                                                                                                                                    |
|      |                                                                                                             |              |                | Analyzed Files | `nSidis` train                                                                                                                                                                                                                                                  |
|      |                                                                                                             |              |                | Issues         | None                                                                                                                                                                                                                                                            |
| 2    | [`rga_sp19`](https://clas12mon.jlab.org/rga/pass2/sp19/qa/rga_sp19_nSidis/tlsummary)                        | 6616 - 6783  | :green_circle: | Data           | `/cache/clas12/rg-a/production/recon/spring2019/torus-1/pass2/dst`                                                                                                                                                                                              |
|      |                                                                                                             |              |                | Analyzed Files | `nSidis` train                                                                                                                                                                                                                                                  |
|      |                                                                                                             |              |                | Issues         | None                                                                                                                                                                                                                                                            |
| 1    | [`rga_fa18_inbending`](https://clas12mon.jlab.org/rga/pass1/qa/fa18_inbending/tlsummary)                    | 5032 - 5419  | :warning:      | Data           | `/cache/clas12/rg-a/production/recon/fall2018/torus-1/pass1`                                                                                                                                                                                                    |
|      |                                                                                                             |              |                | Analyzed Files | full DST files                                                                                                                                                                                                                                                  |
|      |                                                                                                             |              |                | Issues         | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#12](https://github.com/JeffersonLab/clas12-qadb/issues/12), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |
| 1    | [`rga_fa18_outbending`](https://clas12mon.jlab.org/rga/pass1/qa/fa18_outbending/tlsummary)                  | 5422 - 5666  | :warning:      | Data           | `/cache/clas12/rg-a/production/recon/fall2018/torus+1/pass1`                                                                                                                                                                                                    |
|      |                                                                                                             |              |                | Analyzed Files | full DST files                                                                                                                                                                                                                                                  |
|      |                                                                                                             |              |                | Issues         | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89)                                                               |
| 1    | [`rga_sp19`](https://clas12mon.jlab.org/rga/pass1/qa/sp19/tlsummary)                                        | 6616 - 6783  | :warning:      | Data           | `/cache/clas12/rg-a/production/recon/spring2019/torus-1/pass1`                                                                                                                                                                                                  |
|      |                                                                                                             |              |                | Analyzed Files | full DST files                                                                                                                                                                                                                                                  |
|      |                                                                                                             |              |                | Issues         | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89)                                                               |

</details>

<details>
<summary>Run Group B</summary>

| Pass | Data Set Name and Timelines Link                                                         | Run Range     | Status         | Notes          |                                                                                                                                                                                                   |
| ---  | ---                                                                                      | ---           | ---            | ---            | ---                                                                                                                                                                                               |
| 2    | [`rgb_sp19`](https://clas12mon.jlab.org/rgb/pass2/qa/sp19/rgb_sp19_sidisdvcs/tlsummary/) | 6156 - 6603   | :green_circle: | Data           | `/cache/clas12/rg-b/production/recon/spring2019/torus-1/pass2/v0/dst`                                                                                                                             |
|      |                                                                                          |               |                | Analyzed Files | `sidisdvcs` train                                                                                                                                                                                 |
|      |                                                                                          |               |                | Issues         | :bangbang: [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89)                                                                                                                           |
| 2    | [`rgb_fa19`](https://clas12mon.jlab.org/rgb/pass2/qa/fa19/rgb_fa19_sidisdvcs/tlsummary/) | 11093 - 11300 | :green_circle: | Data           | `/cache/clas12/rg-b/production/recon/fall2019/torus{+,-}1/pass2/v1/dst`                                                                                                                           |
|      |                                                                                          |               |                | Analyzed Files | `sidisdvcs` train                                                                                                                                                                                 |
|      |                                                                                          |               |                | Issues         | :bangbang: [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89)                                                                                                                           |
| 2    | [`rgb_wi20`](https://clas12mon.jlab.org/rgb/pass2/qa/wi20/rgb_wi20_sidisdvcs/tlsummary/) | 11323 - 11571 | :green_circle: | Data           | `/cache/clas12/rg-b/production/recon/spring2020/torus-1/pass2/v1/dst`                                                                                                                             |
|      |                                                                                          |               |                | Analyzed Files | `sidisdvcs` train                                                                                                                                                                                 |
|      |                                                                                          |               |                | Issues         | :bangbang: [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89)                                                                                                                           |
| 1    | [`rgb_sp19`](https://clas12mon.jlab.org/rgb/pass1/qa/sp19/tlsummary)                     | 6156 - 6603   | :warning:      | Data           | `/cache/clas12/rg-b/production/recon/spring2019/torus-1/pass1/v0/dst`                                                                                                                             |
|      |                                                                                          |               |                | Analyzed Files | full DST files                                                                                                                                                                                    |
|      |                                                                                          |               |                | Issues         | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |
| 1    | [`rgb_fa19`](https://clas12mon.jlab.org/rgb/pass1/qa/fa19/tlsummary)                     | 11093 - 11300 | :warning:      | Data           | `/cache/clas12/rg-b/production/recon/fall2019/torus{+,-}1/pass1/v1/dst`                                                                                                                           |
|      |                                                                                          |               |                | Analyzed Files | full DST files                                                                                                                                                                                    |
|      |                                                                                          |               |                | Issues         | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |
| 1    | [`rgb_wi20`](https://clas12mon.jlab.org/rgb/pass1/qa/wi20/tlsummary)                     | 11323 - 11571 | :warning:      | Data           | `/cache/clas12/rg-b/production/recon/spring2020/torus-1/pass1/v1/dst`                                                                                                                             |
|      |                                                                                          |               |                | Analyzed Files | full DST files                                                                                                                                                                                    |
|      |                                                                                          |               |                | Issues         | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |

</details>

<details>
<summary>Run Group C</summary>

| Pass | Data Set Name and Timelines Link                                                              | Run Range     | Status         | Notes          |                                                |
| ---  | ---                                                                                           | ---           | ---            | ---            | ---                                            |
| 1    | [`rgc_su22`](https://clas12mon.jlab.org/rgc/Summer2022/qa-physics/pass1-sidisdvcs/tlsummary/) | 16042 - 16786 | :green_circle: | Data           | `/cache/clas12/rg-c/production/summer22/pass1` |
|      |                                                                                               |               |                | Analyzed Files | `sidisdvcs` train                              |
|      |                                                                                               |               |                | Issues         | None                                           |
| 1    | [`rgc_fa22`](https://clas12mon.jlab.org/rgc/Fall2022/qa-physics/pass1-sidisdvcs/tlsummary/)   | 16843 - 17408 | :green_circle: | Data           | `/cache/clas12/rg-c/production/fall22/pass1`   |
|      |                                                                                               |               |                | Analyzed Files | `sidisdvcs` train                              |
|      |                                                                                               |               |                | Issues         | None                                           |
| 1    | [`rgc_sp23`](https://clas12mon.jlab.org/rgc/Spring2023/qa-physics/pass1-sidisdvcs/tlsummary/) | 17482 - 17811 | :green_circle: | Data           | `/cache/clas12/rg-c/production/spring23/pass1` |
|      |                                                                                               |               |                | Analyzed Files | `sidisdvcs` train                              |
|      |                                                                                               |               |                | Issues         | None                                           |

</details>

<details>
<summary>Run Group F</summary>

| Pass | Data Set Name and Timelines Link | Run Range     | Status | Notes |                                                                                             |
| ---  | ---                              | ---           | ---    | ---   | ---                                                                                         |
| 1    | `rgf_sp20_torusM1`               | 12210 - 12329 | :x:    | Data  | `/cache/clas12/rg-f/production/recon/spring2020/torus-1_solenoid-0.8/pass1v0/dst/recon`     |
| 1    | `rgf_su20_torusPh`               | 12389 - 12434 | :x:    | Data  | `/cache/clas12/rg-f/production/recon/summer2020/torus+0.5_solenoid-0.745/pass1v0/dst/recon` |
| 1    | `rgf_su20_torusMh`               | 12436 - 12443 | :x:    | Data  | `/cache/clas12/rg-f/production/recon/summer2020/torus-0.5_solenoid-0.745/pass1v0/dst/recon` |
| 1    | `rgf_su20_torusM1`               | 12447 - 12951 | :x:    | Data  | `/cache/clas12/rg-f/production/recon/summer2020/torus-1_solenoid-0.745/pass1v0/dst/recon`   |

</details>

<details>
<summary>Run Group K</summary>

| Pass | Data Set Name and Timelines Link                                                   | Run Range   | Status         | Notes          |                                                                                                                                                                                                   |
| ---  | ---                                                                                | ---         | ---            | ---            | ---                                                                                                                                                                                               |
| 2    | `rgk_fa18_7.5GeV`                                                                  | 5674 - 5870 | :x:            | Data           | `/cache/clas12/rg-k/production/recon/fall2018/torus+1/6535MeV/pass2/v0/dst`                                                                                                                       |
|      |                                                                                    |             |                | Analyzed Files |                                                                                                                                                                                                   |
|      |                                                                                    |             |                | Issues         |                                                                                                                                                                                                   |
| 2    | `rgk_fa18_6.5GeV`                                                                  | 5875 - 6000 | :x:            | Data           | `/cache/clas12/rg-k/production/recon/fall2018/torus+1/7546MeV/pass2/v0/dst`                                                                                                                       |
|      |                                                                                    |             |                | Analyzed Files |                                                                                                                                                                                                   |
|      |                                                                                    |             |                | Issues         |                                                                                                                                                                                                   |
| 1    | [`rgk_fa18_7.5GeV`](https://clas12mon.jlab.org/rgk/pass1/qa/fa18_7.5GeV/tlsummary) | 5674 - 5870 | :green_circle: | Data           | `/cache/clas12/rg-k/production/recon/fall2018/torus+1/7546MeV/pass1/v0/dst/recon`                                                                                                                 |
|      |                                                                                    |             |                | Analyzed Files | full DST files                                                                                                                                                                                    |
|      |                                                                                    |             |                | Issues         | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |
| 1    | [`rgk_fa18_6.5GeV`](https://clas12mon.jlab.org/rgk/pass1/qa/fa18_6.5GeV/tlsummary) | 5875 - 6000 | :green_circle: | Data           | `/cache/clas12/rg-k/production/recon/fall2018/torus+1/6535MeV/pass1/v0/dst/recon`                                                                                                                 |
|      |                                                                                    |             |                | Analyzed Files | full DST files                                                                                                                                                                                    |
|      |                                                                                    |             |                | Issues         | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |

</details>

<details>
<summary>Run Group M</summary>

| Pass | Data Set Name and Timelines Link                                                     | Run Range     | Status         | Notes          |                                                                                                                                                                                                   |
| ---  | ---                                                                                  | ---           | ---            | ---            | ---                                                                                                                                                                                               |
| 1    | [`rgm_fa21`](https://clas12mon.jlab.org/rgm/pass1_finalqadb/rgm_fall2021/tlsummary/) | 15019 - 15884 | :green_circle: | Data           | `/cache/clas12/rg-m/production/pass1/allData_forTimelines/`                                                                                                                                       |
|      |                                                                                      |               |                | Analyzed Files | full DST files                                                                                                                                                                                    |
|      |                                                                                      |               |                | Issues         | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |

</details>


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

<!-- THE TABLE BELOW WAS GENERATED BY util/makeDefectMarkdown.rb -->
| Bit | Name | Description | Additional Notes |
| --- | --- | --- | --- |
| 0 | `TotalOutlier` | Outlier FD electron N/F, but not `TerminalOutlier` or `MarginalOutlier` |  |
| 1 | `TerminalOutlier` | Outlier FD electron N/F of first or last QA bin of run |  |
| 2 | `MarginalOutlier` | Marginal FD electron outlier N/F, within one standard deviation of cut line |  |
| 3 | `SectorLoss`<sup>1</sup> | FD electron N/F is an outlier and is diminished for several consecutive QA bins | For older datasets (RG-A,B,K,M pass 1), this bit _replaced_ the assignment of `TotalOutlier`, `TerminalOutlier`, and `MarginalOutlier`; newer datasets only add the `SectorLoss` bit and do not remove the outlier bits. |
| 4 | `LowLiveTime` | Live time < 0.9 | This assignment of this bit may be correlated with a low fraction of events with a defined (nonzero) helicity. |
| 5 | `Misc` | Miscellaneous defect, documented as comment | This bit is often assigned to all QA bins within a run, but in some cases, may only be assigned to the relevant QA bins. The analyzer must decide whether data assigned with the `Misc` bit should be excluded from their analysis; the comment is provided for this purpose. Analyzers are also encouraged to check the Hall B log book for further details. Note that special runs, such as empty target or low luminosity runs, also typically have this bit set; for such runs, the other defect bits may be meaningless, namely the outlier bits. |
| 6 | `TotalOutlierFT` | Outlier FT electron N/F, but not `TerminalOutlierFT` or `MarginalOutlierFT` | _cf_. `TotalOutlier`. |
| 7 | `TerminalOutlierFT` | Outlier FT electron N/F of first or last QA bin of run | _cf_. `TerminalOutlier`. |
| 8 | `MarginalOutlierFT` | Marginal FT electron outlier N/F, within one standard deviation of cut line | _cf_. `MarginalOutlier`. |
| 9 | `LossFT`<sup>1</sup> | FT electron N/F is an outlier and is diminished for several consecutive QA bins | _cf_. `SectorLoss`. |
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

> 1. this bit may not be reliably defined in later datasets; use the other outlier bits instead
<!-- THE TABLE ABOVE WAS GENERATED BY util/makeDefectMarkdown.rb -->

<a name="access"></a>
# How to Access the QADB

You may access the QADB in many ways:

## Text Access
* human-readable tables are stored in `qadb/*/qaTree.json.table`; see
  the section **Table Files** below for details on how
  to read these files
* QADB JSON files are stored in `qadb/*/qaTree.json`; these are text files,
  but they are meant to be used by **Software**, described in the next section

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

<a name="example"></a>
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

  // accumulate FC charge (it will only accumulate once per QA bin you analyzed)
  qa.AccumulateCharge();

  // if you want helicity-latched charge (from HEL::scaler), there is a similar method
  qa.AccumulateChargeHL();

  /* continue your analysis here */
}
```

**After Processing Events**
```cpp
// the total FC charge, filtered by the QA
auto total_charge = qa.GetAccumulatedCharge();

// or the helicity-latched charge
auto total_charge_for_positive_helicity  = qa.GetAccumulatedChargeHL(1);
auto total_charge_for_negative_helicity  = qa.GetAccumulatedChargeHL(-1);
auto total_charge_for_undefined_helicity = qa.GetAccumulatedChargeHL(0);
```

> [!CAUTION]
> The above example code is not tested, and might be broken! You may need to refer
> to the other examples in `srcC/` and `src/`.

<a name="files"></a>
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
- the `latest/` directory contains symbolic links to the _latest_ cook of each data set with a QADB


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


<a name="charge"></a>
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
    are satisfied; the QADB instance will keep track of the accumulated charge
    you analyzed (accumulation performed per QA bin)
  * at the end of your event loop, the total accumulated charge you analyzed is
    given by `QADB::GetAccumulatedCharge()`

> [!NOTE]
> Helicity-latched charge is accessed using similar methods:
> - `QADB::AccumulateChargeHL()`, for each event
> - `QADB::GetAccumulatedChargeHL(int state)` at the end, where `state` is the helicity: `1` or `-1` (or `0` for undefined helicity).
>
> Helicity-latched charge is not available for all datasets' QADBs; if you need it for a certain dataset where
> it is not available, request it from the QADB maintainers.

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

<a name="rules"></a>
# QA Ground Rules

> [!IMPORTANT]
> The following rules are enforced for the QA procedure and the resulting QADB:
> 1. The QA procedure runs on the data as they are and does not fix any of their problems.
> 2. The QADB only provides defect identification and does not provide analysis-specific decisions.
> 3. At least two people independently perform the "manual QA" part of the QA procedure, and the results are cross checked and merged.

<a name="contributions"></a>
# Contributions

All contributions are welcome, whether to the code, examples, documentation, or
the QADB itself. You are welcome to open an issue and/or a pull request. If the
maintainer(s) do not respond in a reasonable time, send them an email.
