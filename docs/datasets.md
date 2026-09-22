# Available Datasets
The following tables describe the available datasets in the _latest_ version of the QADB; click on a dataset to expand the table.

Here is an example table, to show what information is provided for each dataset:

!!! info "example cook"
    ??? success "example dataset"
        | **Status:**            | the current status of the QADB for these data               |
        | ---                    | ---                                                         |
        | **Links:**             | links to timelines, `Misc` bit table, and QADB text file    |
        | **Data:**              | location of the data on disk                                |
        | **Files Used for QA:** | which files were used, _e.g._, DSTs or a specific train     |
        | **Runs:**              | run number range                                            |
        | **Issues with QADB:**  | links to any specific issue(s) with the QADB for these data |
        | **Cross Check:**       | who cross checked the QADB production                       |
        | **FC Charge Method:**  | any corrections or details about the Faraday Cup charge     |
        | **Cook:** `recharge`   | whether or not the `recharge` option was used for cooking   |
        | **Cook:** `coatjava`   | the version of `coatjava` used to cook                      |

## Run Group A

??? info "Spring 2018 --- Pass 1"

    ??? success "`rga_sp18_inbending` (pass 1, 10.6 GeV beam)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                                                                   |
        | ---                    | ---                                                                                                         |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rga/pass1/sp18/qa/rga_sp18_inbending_nSidis/tlsummary/){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rga_sp18_inbending/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rga_sp18_inbending/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-a/production/recon/spring2018/10.59gev/torus-1/pass1/dst`                                 |
        | **Files Used for QA:** | `nSidis` train                                                                                              |
        | **Runs:**              | 3306 - 3817, 4003 - 4325                                                                                    |
        | **Issues with QADB:**  | :bangbang: [#92](https://github.com/JeffersonLab/clas12-qadb/issues/92)                                     |
        | **Cross Check:**       | Bhawani Singh                                                                                               |
        | **FC Charge Method:**  | Reheated: ran `rebuild-scalers` with clock-rollover corrections, then `postprocess`; used `coatjava` 13.3.0 |
        | **Cook:** `recharge`   | `false` (but `true` for runs less than 4000)                                                                |
        | **Cook:** `coatjava`   | 11.1.1                                                                                                      |

    ??? success "`rga_sp18_outbending` (pass 1, 10.6 GeV beam)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                                                                   |
        | ---                    | ---                                                                                                         |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rga/pass1/sp18/qa/rga_sp18_outbending_nSidis/tlsummary/){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rga_sp18_outbending/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rga_sp18_outbending/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-a/production/recon/spring2018/10.59gev/torus+1/pass1/dst`                                 |
        | **Files Used for QA:** | `nSidis` train                                                                                              |
        | **Runs:**              | 3211 - 3293, 3863 - 3987                                                                                    |
        | **Issues with QADB:**  | :bangbang: [#92](https://github.com/JeffersonLab/clas12-qadb/issues/92)                                     |
        | **Cross Check:**       | Bhawani Singh                                                                                               |
        | **FC Charge Method:**  | Reheated: ran `rebuild-scalers` with clock-rollover corrections, then `postprocess`; used `coatjava` 13.3.0 |
        | **Cook:** `recharge`   | `false` (but `true` for runs less than 4000)                                                                |
        | **Cook:** `coatjava`   | 11.1.1                                                                                                      |

    ??? failure "`rga_sp18_6.4GeV` (pass 1, 6.4 GeV beam)"
        | **Status:**           | :x: QADB not produced; reason: [high/unknown scaler clock frequency + low analysis demand](https://clasweb.jlab.org/wiki/index.php/File:Fc-charge-issues-RG-A.pdf) |
        | ---                   | ---                                                                                                                                                                |
        | **Data:**             | `/cache/clas12/rg-a/production/recon/spring2018/6.42gev/_____`                                                                                                     |
        | **FC Charge Method:** | Requires reheating, but with a higher clock frequency (likely 125 MHz)                                                                                             |
        | **Cook:** `recharge`  | `true`                                                                                                                                                             |
        | **Cook:** `coatjava`  | 11.1.1                                                                                                                                                             |

??? info "Fall 2018 & Spring 2019 --- Pass 2"

    ??? success "`rga_fa18_inbending` (pass 2)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                                           |
        | ---                    | ---                                                                                 |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rga/pass2/fa18/qa/rga_fa18_inbending_nSidis/tlsummary/){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass2/rga_fa18_inbending/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass2/rga_fa18_inbending/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-a/production/recon/fall2018/torus-1/pass2/main`                   |
        | **Files Used for QA:** | `nSidis` train                                                                      |
        | **Runs:**              | 5032 - 5419                                                                         |
        | **Issues with QADB:**  | :white_check_mark: None                                                             |
        | **Cross Check:**       | Krishna Neupane                                                                     |
        | **FC Charge Method:**  | Used as is                                                                          |
        | **Cook:** `recharge`   | `true`                                                                              |
        | **Cook:** `coatjava`   | 10.0.4                                                                              |

    ??? success "`rga_fa18_outbending` (pass 2)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                                            |
        | ---                    | ---                                                                                  |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rga/pass2/fa18/qa/rga_fa18_outbending_nSidis/tlsummary/){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass2/rga_fa18_outbending/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass2/rga_fa18_outbending/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-a/production/recon/fall2018/torus+1/pass2`                         |
        | **Files Used for QA:** | `nSidis` train                                                                       |
        | **Runs:**              | 5422 - 5666                                                                          |
        | **Issues with QADB:**  | :white_check_mark: None                                                              |
        | **Cross Check:**       | Krishna Neupane                                                                      |
        | **FC Charge Method:**  | Used as is                                                                           |
        | **Cook:** `recharge`   | `true`                                                                               |
        | **Cook:** `coatjava`   | 10.0.4                                                                               |

    ??? success "`rga_sp19` (pass 2)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                                |
        | ---                    | ---                                                                      |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rga/pass2/sp19/qa/rga_sp19_nSidis/tlsummary){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass2/rga_sp19/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass2/rga_sp19/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-a/production/recon/spring2019/torus-1/pass2/dst`       |
        | **Files Used for QA:** | `nSidis` train                                                           |
        | **Runs:**              | 6616 - 6783                                                              |
        | **Issues with QADB:**  | :white_check_mark: None                                                  |
        | **Cross Check:**       | Krishna Neupane                                                          |
        | **FC Charge Method:**  | Used as is                                                               |
        | **Cook:** `recharge`   | `true`                                                                   |
        | **Cook:** `coatjava`   | 9.0.1                                                                    |

??? info "Fall 2018 & Spring 2019 --- Pass 1"

    !!! danger
        The QADB for older datasets may have some issues, and may even violate the
        [QA ground rules](rules.md). It is **HIGHLY recommended** to also
        check the known issues to see if any impact your analysis.

    ??? warning "`rga_fa18_inbending` (pass 1)"
        | **Status:**            | :warning: QADB for Newer Cook is also Available                                                                                                                                                                                                                 |
        | ---                    | ---                                                                                                                                                                                                                                                             |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rga/pass1/qa/fa18_inbending/tlsummary){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rga_fa18_inbending/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rga_fa18_inbending/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-a/production/recon/fall2018/torus-1/pass1`                                                                                                                                                                                                    |
        | **Files Used for QA:** | full DST files                                                                                                                                                                                                                                                  |
        | **Runs:**              | 5032 - 5419                                                                                                                                                                                                                                                     |
        | **Issues with QADB:**  | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#12](https://github.com/JeffersonLab/clas12-qadb/issues/12), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |
        | **Cross Check:**       | :x: None                                                                                                                                                                                                                                                        |
        | **FC Charge Method:**  | Used as is                                                                                                                                                                                                                                                      |
        | **Cook:** `recharge`   | TODO: obtain from `README.json`                                                                                                                                                                                                                                 |
        | **Cook:** `coatjava`   | TODO: obtain from `README.json`                                                                                                                                                                                                                                 |

    ??? warning "`rga_fa18_outbending` (pass 1)"
        | **Status:**            | :warning: QADB for Newer Cook is also Available                                                                                                                                                   |
        | ---                    | ---                                                                                                                                                                                               |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rga/pass1/qa/fa18_outbending/tlsummary){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rga_fa18_outbending/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rga_fa18_outbending/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-a/production/recon/fall2018/torus+1/pass1`                                                                                                                                      |
        | **Files Used for QA:** | full DST files                                                                                                                                                                                    |
        | **Runs:**              | 5422 - 5666                                                                                                                                                                                       |
        | **Issues with QADB:**  | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |
        | **Cross Check:**       | :x: None                                                                                                                                                                                          |
        | **FC Charge Method:**  | Used as is                                                                                                                                                                                        |
        | **Cook:** `recharge`   | TODO: obtain from `README.json`                                                                                                                                                                   |
        | **Cook:** `coatjava`   | TODO: obtain from `README.json`                                                                                                                                                                   |

    ??? warning "`rga_sp19` (pass 1)"
        | **Status:**            | :warning: QADB for Newer Cook is also Available                                                                                                                                                   |
        | ---                    | ---                                                                                                                                                                                               |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rga/pass1/qa/sp19/tlsummary){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rga_sp19/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rga_sp19/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-a/production/recon/spring2019/torus-1/pass1`                                                                                                                                    |
        | **Files Used for QA:** | full DST files                                                                                                                                                                                    |
        | **Runs:**              | 6616 - 6783                                                                                                                                                                                       |
        | **Issues with QADB:**  | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |
        | **Cross Check:**       | :x: None                                                                                                                                                                                          |
        | **FC Charge Method:**  | Used as is, except for run 6724, where `<livetime> x ungated_charge` was used                                                                                                                     |
        | **Cook:** `recharge`   | TODO: obtain from `README.json`                                                                                                                                                                   |
        | **Cook:** `coatjava`   | TODO: obtain from `README.json`                                                                                                                                                                   |

## Run Group B

??? info "2019 - 2020 --- Pass 2"

    ??? success "`rgb_sp19` (pass 2)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                                    |
        | ---                    | ---                                                                          |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgb/pass2/qa/sp19/rgb_sp19_sidisdvcs/tlsummary/){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass2/rgb_sp19/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass2/rgb_sp19/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-b/production/recon/spring2019/torus-1/pass2/v0/dst`        |
        | **Files Used for QA:** | `sidisdvcs` train                                                            |
        | **Runs:**              | 6156 - 6603                                                                  |
        | **Issues with QADB:**  | :bangbang: [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89)      |
        | **Cross Check:**       | Derek Holmberg                                                               |
        | **FC Charge Method:**  | Used as is                                                                   |
        | **Cook:** `recharge`   | `true`                                                                       |
        | **Cook:** `coatjava`   | 9.0.1                                                                        |

    ??? success "`rgb_fa19` (pass 2)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                                    |
        | ---                    | ---                                                                          |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgb/pass2/qa/fa19/rgb_fa19_sidisdvcs/tlsummary/){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass2/rgb_fa19/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass2/rgb_fa19/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-b/production/recon/fall2019/torus{+,-}1/pass2/v1/dst`      |
        | **Files Used for QA:** | `sidisdvcs` train                                                            |
        | **Runs:**              | 11093 - 11300                                                                |
        | **Issues with QADB:**  | :bangbang: [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89)      |
        | **Cross Check:**       | Derek Holmberg                                                               |
        | **FC Charge Method:**  | Used as is                                                                   |
        | **Cook:** `recharge`   | `true`                                                                       |
        | **Cook:** `coatjava`   | 10.0.3                                                                       |

    ??? success "`rgb_wi20` (pass 2)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                                    |
        | ---                    | ---                                                                          |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgb/pass2/qa/wi20/rgb_wi20_sidisdvcs/tlsummary/){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass2/rgb_wi20/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass2/rgb_wi20/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-b/production/recon/spring2020/torus-1/pass2/v1/dst`        |
        | **Files Used for QA:** | `sidisdvcs` train                                                            |
        | **Runs:**              | 11323 - 11571                                                                |
        | **Issues with QADB:**  | :bangbang: [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89)      |
        | **Cross Check:**       | Derek Holmberg                                                               |
        | **FC Charge Method:**  | Used as is                                                                   |
        | **Cook:** `recharge`   | `true`                                                                       |
        | **Cook:** `coatjava`   | 10.0.3                                                                       |

??? info "2019 - 2020 --- Pass 1"

    !!! danger
        The QADB for older datasets may have some issues, and may even violate the
        [QA ground rules](rules.md). It is **HIGHLY recommended** to also
        check the known issues to see if any impact your analysis.

    ??? warning "`rgb_sp19` (pass 1)"
        | **Status:**            | :warning: QADB for Newer Cook is also Available                                                                                                                                                   |
        | ---                    | ---                                                                                                                                                                                               |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgb/pass1/qa/sp19/tlsummary){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rgb_sp19/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rgb_sp19/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-b/production/recon/spring2019/torus-1/pass1/v0/dst`                                                                                                                             |
        | **Files Used for QA:** | full DST files                                                                                                                                                                                    |
        | **Runs:**              | 6156 - 6603                                                                                                                                                                                       |
        | **Issues with QADB:**  | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |
        | **Cross Check:**       | Silvia Niccolai                                                                                                                                                                                   |
        | **FC Charge Method:**  | Used as is, except for runs 6263, 6350, 6599, 6601, where `<livetime> x ungated_charge` was used                                                                                                  |
        | **Cook:** `recharge`   | TODO: obtain from `README.json`                                                                                                                                                                   |
        | **Cook:** `coatjava`   | TODO: obtain from `README.json`                                                                                                                                                                   |

    ??? warning "`rgb_fa19` (pass 1)"
        | **Status:**            | :warning: QADB for Newer Cook is also Available                                                                                                                                                   |
        | ---                    | ---                                                                                                                                                                                               |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgb/pass1/qa/fa19/tlsummary){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rgb_fa19/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rgb_fa19/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-b/production/recon/fall2019/torus{+,-}1/pass1/v1/dst`                                                                                                                           |
        | **Files Used for QA:** | full DST files                                                                                                                                                                                    |
        | **Runs:**              | 11093 - 11300                                                                                                                                                                                     |
        | **Issues with QADB:**  | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |
        | **Cross Check:**       | Silvia Niccolai                                                                                                                                                                                   |
        | **FC Charge Method:**  | Used as is, except for run 11119, where `<livetime> x ungated_charge` was used                                                                                                                    |
        | **Cook:** `recharge`   | TODO: obtain from `README.json`                                                                                                                                                                   |
        | **Cook:** `coatjava`   | TODO: obtain from `README.json`                                                                                                                                                                   |

    ??? warning "`rgb_wi20` (pass 1)"
        | **Status:**            | :warning: QADB for Newer Cook is also Available                                                                                                                                                   |
        | ---                    | ---                                                                                                                                                                                               |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgb/pass1/qa/wi20/tlsummary){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rgb_wi20/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rgb_wi20/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-b/production/recon/spring2020/torus-1/pass1/v1/dst`                                                                                                                             |
        | **Files Used for QA:** | full DST files                                                                                                                                                                                    |
        | **Runs:**              | 11323 - 11571                                                                                                                                                                                     |
        | **Issues with QADB:**  | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |
        | **Cross Check:**       | Silvia Niccolai                                                                                                                                                                                   |
        | **FC Charge Method:**  | Used as is                                                                                                                                                                                        |
        | **Cook:** `recharge`   | TODO: obtain from `README.json`                                                                                                                                                                   |
        | **Cook:** `coatjava`   | TODO: obtain from `README.json`                                                                                                                                                                   |

## Run Group C

??? info "2022 - 2023 --- Pass 1"

    ??? success "`rgc_su22` (pass 1)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                                         |
        | ---                    | ---                                                                               |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgc/Summer2022/qa-physics/pass1-sidisdvcs/tlsummary/){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rgc_su22/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rgc_su22/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-c/production/summer22/pass1`                                    |
        | **Files Used for QA:** | `sidisdvcs` train                                                                 |
        | **Runs:**              | 16042 - 16786                                                                     |
        | **Issues with QADB:**  | :white_check_mark: None                                                           |
        | **Cross Check:**       | Krishna Neupane                                                                   |
        | **FC Charge Method:**  | Used as is                                                                        |
        | **Cook:** `recharge`   | `false`                                                                           |
        | **Cook:** `coatjava`   | 10.0.9                                                                            |

    ??? success "`rgc_fa22` (pass 1)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                                       |
        | ---                    | ---                                                                             |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgc/Fall2022/qa-physics/pass1-sidisdvcs/tlsummary/){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rgc_fa22/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rgc_fa22/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-c/production/fall22/pass1`                                    |
        | **Files Used for QA:** | `sidisdvcs` train                                                               |
        | **Runs:**              | 16843 - 17408                                                                   |
        | **Issues with QADB:**  | :white_check_mark: None                                                         |
        | **Cross Check:**       | Derek Holmberg                                                                  |
        | **FC Charge Method:**  | Used as is                                                                      |
        | **Cook:** `recharge`   | `false`                                                                         |
        | **Cook:** `coatjava`   | 11.0.1                                                                          |

    ??? success "`rgc_sp23` (pass 1)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                                         |
        | ---                    | ---                                                                               |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgc/Spring2023/qa-physics/pass1-sidisdvcs/tlsummary/){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rgc_sp23/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rgc_sp23/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-c/production/spring23/pass1`                                    |
        | **Files Used for QA:** | `sidisdvcs` train                                                                 |
        | **Runs:**              | 17482 - 17811                                                                     |
        | **Issues with QADB:**  | :white_check_mark: None                                                           |
        | **Cross Check:**       | Derek Holmberg                                                                    |
        | **FC Charge Method:**  | Used as is                                                                        |
        | **Cook:** `recharge`   | Unknown, since `README.json` file not on tape                                     |
        | **Cook:** `coatjava`   | Likely 11.1.0, but `README.json` file not on tape                                 |

## Run Group D

??? info "2023 --- Pass 1"

    ??? failure "`rgd`"
        | **Status:** | :x: QADB not produced; reason: FC issue |
        | ---         | ---                                     |
        |             |                                         |

## Run Group E

??? info "2024 --- Pass 1"

    ??? example "`rge_sp24.5GeV` (pass 1)"
        | **Status:**            | :x: QADB not yet produced |
        | ---                    | ---                       |
        | **Timelines:**         |                           |
        | **Data:**              |                           |
        | **Files Used for QA:** |                           |
        | **Runs:**              |                           |
        | **Issues with QADB:**  |                           |
        | **Cross Check:**       |                           |
        | **FC Charge Method:**  |                           |
        | **Cook:** `recharge`   |                           |
        | **Cook:** `coatjava`   |                           |

## Run Group F

??? info "2020 --- Pass 1"

    ??? failure "`rgf_sp20_torusM1` (pass 1)"
        | **Status:**         | :x: QADB is unwanted for these data                                                         |
        | ---                 | ---                                                                                         |
        | **Data:**           | `/cache/clas12/rg-f/production/recon/spring2020/torus-1_solenoid-0.8/pass1v0/dst/recon`     |
        | **Runs:**           | 12210 - 12329                                                                               |

    ??? failure "`rgf_su20_torusPh` (pass 1)"
        | **Status:**         | :x: QADB is unwanted for these data                                                         |
        | ---                 | ---                                                                                         |
        | **Data:**           | `/cache/clas12/rg-f/production/recon/summer2020/torus+0.5_solenoid-0.745/pass1v0/dst/recon` |
        | **Runs:**           | 12389 - 12434                                                                               |

    ??? failure "`rgf_su20_torusMh` (pass 1)"
        | **Status:**         | :x: QADB is unwanted for these data                                                         |
        | ---                 | ---                                                                                         |
        | **Data:**           | `/cache/clas12/rg-f/production/recon/summer2020/torus-0.5_solenoid-0.745/pass1v0/dst/recon` |
        | **Runs:**           | 12436 - 12443                                                                               |

    ??? failure "`rgf_su20_torusM1` (pass 1)"
        | **Status:**         | :x: QADB is unwanted for these data                                                         |
        | ---                 | ---                                                                                         |
        | **Data:**           | `/cache/clas12/rg-f/production/recon/summer2020/torus-1_solenoid-0.745/pass1v0/dst/recon`   |
        | **Runs:**           | 12447 - 12951                                                                               |

## Run Group K

??? info "Fall 2023 & Spring 2024 --- Pass 1"

    ??? success "`rgk_fa23_6.4GeV` (pass 1)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                            |
        | ---                    | ---                                                                  |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgk/pass1/qa/rgk_fa23_6.4GeV/tlsummary/){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rgk_fa23_6.4GeV/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rgk_fa23_6.4GeV/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-k/production/recon/fall2023/pass1/6395MeV/dst`     |
        | **Files Used for QA:** | full DST files                                                       |
        | **Runs:**              | 19204 - 19260                                                        |
        | **Issues with QADB:**  | :white_check_mark: None                                              |
        | **Cross Check:**       | Bhawani Singh                                                        |
        | **FC Charge Method:**  | Used as is                                                           |
        | **Cook:** `recharge`   | `false` (note: `README.json` file not on tape)                       |
        | **Cook:** `coatjava`   | 13.8.2 (note: `README.json` file not on tape)                        |

    ??? success "`rgk_sp24_6.4GeV` (pass 1)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                            |
        | ---                    | ---                                                                  |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgk/pass1/qa/rgk_sp24_6.4GeV/tlsummary/){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rgk_sp24_6.4GeV/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rgk_sp24_6.4GeV/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-k/production/recon/spring2024/pass1/6395MeV/dst`   |
        | **Files Used for QA:** | full DST files                                                       |
        | **Runs:**              | 19308 - 19659                                                        |
        | **Issues with QADB:**  | :white_check_mark: None                                              |
        | **Cross Check:**       | Bhawani Singh                                                        |
        | **FC Charge Method:**  | Used as is                                                           |
        | **Cook:** `recharge`   | `false` (note: `README.json` file not on tape)                       |
        | **Cook:** `coatjava`   | 13.8.2 (note: `README.json` file not on tape)                        |

    ??? success "`rgk_sp24_8.5GeV` (pass 1)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                            |
        | ---                    | ---                                                                  |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgk/pass1/qa/rgk_sp24_8.5GeV/tlsummary/){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rgk_sp24_8.5GeV/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rgk_sp24_8.5GeV/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-k/production/recon/spring2024/pass1/8477MeV/dst`   |
        | **Files Used for QA:** | full DST files                                                       |
        | **Runs:**              | 19660 - 19893                                                        |
        | **Issues with QADB:**  | :white_check_mark: None                                              |
        | **Cross Check:**       | Bhawani Singh                                                        |
        | **FC Charge Method:**  | Used as is                                                           |
        | **Cook:** `recharge`   | `false` (note: `README.json` file not on tape)                       |
        | **Cook:** `coatjava`   | 13.8.2 (note: `README.json` file not on tape)                        |

??? info "Fall 2018 --- Pass 2"

    ??? example "`rgk_fa18_6.5GeV` (pass 2)"
        | **Status:**            | :x: QADB not yet produced                                                   |
        | ---                    | ---                                                                         |
        | **Timelines:**         |                                                                             |
        | **Data:**              | `/cache/clas12/rg-k/production/recon/fall2018/torus+1/7546MeV/pass2/v0/dst` |
        | **Files Used for QA:** |                                                                             |
        | **Runs:**              | 5875 - 6000                                                                 |
        | **Issues with QADB:**  |                                                                             |
        | **Cross Check:**       | Lucilla Lanza and Mike Wood                                                 |
        | **FC Charge Method:**  |                                                                             |
        | **Cook:** `recharge`   | `false`                                                                     |
        | **Cook:** `coatjava`   | 10.0.2                                                                      |

    ??? example "`rgk_fa18_7.5GeV` (pass 2)"
        | **Status:**            | :x: QADB not yet produced                                                   |
        | ---                    | ---                                                                         |
        | **Timelines:**         |                                                                             |
        | **Data:**              | `/cache/clas12/rg-k/production/recon/fall2018/torus+1/6535MeV/pass2/v0/dst` |
        | **Files Used for QA:** |                                                                             |
        | **Runs:**              | 5674 - 5870                                                                 |
        | **Issues with QADB:**  |                                                                             |
        | **Cross Check:**       | Lucilla Lanza and Mike Wood                                                 |
        | **FC Charge Method:**  |                                                                             |
        | **Cook:** `recharge`   | `false`                                                                     |
        | **Cook:** `coatjava`   | 10.0.2                                                                      |

??? info "Fall 2018 --- Pass 1"

    !!! danger
        The QADB for older datasets may have some issues, and may even violate the
        [QA ground rules](rules.md). It is **HIGHLY recommended** to also
        check the known issues to see if any impact your analysis.

    ??? success "`rgk_fa18_6.5GeV` (pass 1)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                                                                                                                                                         |
        | ---                    | ---                                                                                                                                                                                               |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgk/pass1/qa/fa18_6.5GeV/tlsummary){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rgk_fa18_6.5GeV/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rgk_fa18_6.5GeV/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-k/production/recon/fall2018/torus+1/6535MeV/pass1/v0/dst/recon`                                                                                                                 |
        | **Files Used for QA:** | full DST files                                                                                                                                                                                    |
        | **Runs:**              | 5875 - 6000                                                                                                                                                                                       |
        | **Issues with QADB:**  | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |
        | **Cross Check:**       | Lucilla Lanza and Anna Golubenko                                                                                                                                                                  |
        | **FC Charge Method:**  | Used `<livetime> x ungated_charge` for the gated charge                                                                                                                                           |
        | **Cook:** `recharge`   | TODO: obtain from `README.json`                                                                                                                                                                   |
        | **Cook:** `coatjava`   | TODO: obtain from `README.json`                                                                                                                                                                   |

    ??? success "`rgk_fa18_7.5GeV` (pass 1)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                                                                                                                                                         |
        | ---                    | ---                                                                                                                                                                                               |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgk/pass1/qa/fa18_7.5GeV/tlsummary){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rgk_fa18_7.5GeV/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rgk_fa18_7.5GeV/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-k/production/recon/fall2018/torus+1/7546MeV/pass1/v0/dst/recon`                                                                                                                 |
        | **Files Used for QA:** | full DST files                                                                                                                                                                                    |
        | **Runs:**              | 5674 - 5870                                                                                                                                                                                       |
        | **Issues with QADB:**  | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |
        | **Cross Check:**       | Lucilla Lanza and Anna Golubenko                                                                                                                                                                  |
        | **FC Charge Method:**  | Used `<livetime> x ungated_charge` for the gated charge                                                                                                                                           |
        | **Cook:** `recharge`   | TODO: obtain from `README.json`                                                                                                                                                                   |
        | **Cook:** `coatjava`   | TODO: obtain from `README.json`                                                                                                                                                                   |

## Run Group L

??? info "2025 --- Pass 1"

    ??? failure "`rgl`"
        | **Status:** | :x: QADB not produced; reason: FC issue |
        | ---         | ---                                     |
        |             |                                         |

## Run Group M

??? info "2021 --- Pass 1"

    ??? success "`rgm_fa21` (pass 1)"
        | **Status:**            | :green_circle: Latest Cook and Up to Date                                                                                                                                                         |
        | ---                    | ---                                                                                                                                                                                               |
        | **Links:**             | [Timelines](https://clas12mon.jlab.org/rgm/pass1_finalqadb/rgm_fall2021/tlsummary/){ target="_blank" rel="noopener" } \| [`Misc` Bit Table](tables/pass1/rgm_fa21/miscTable.md){ target="_blank" rel="noopener" } \| [QADB Text File](tables/pass1/rgm_fa21/qaTree.txt){ target="_blank" rel="noopener" } |
        | **Data:**              | `/cache/clas12/rg-m/production/pass1/allData_forTimelines/`                                                                                                                                       |
        | **Files Used for QA:** | full DST files                                                                                                                                                                                    |
        | **Runs:**              | 15019 - 15884                                                                                                                                                                                     |
        | **Issues with QADB:**  | :bangbang: [#9](https://github.com/JeffersonLab/clas12-qadb/issues/9), [#48](https://github.com/JeffersonLab/clas12-qadb/issues/48), [#89](https://github.com/JeffersonLab/clas12-qadb/issues/89) |
        | **Cross Check:**       | Justin Estee                                                                                                                                                                                      |
        | **FC Charge Method:**  | Used as is, except for runs 15015 to 15199 where `REC::Event:beamCharge` was used (according to notes, but timeline values are zero)                                                              |
        | **Cook:** `recharge`   | `false`                                                                                                                                                                                           |
        | **Cook:** `coatjava`   | 10.0.1                                                                                                                                                                                            |
