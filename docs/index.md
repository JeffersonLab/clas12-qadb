# QADB Documentation

<img src="logo.png" width=50%/>

**Q**uality **A**ssurance **D**ata**b**ase

The QADB provides storage of and access to the QA monitoring results for the CLAS12 experiment at Jefferson Lab.

Some general information is below; see the links to the left for more guidance.

## Setup
The QADB is available on `ifarm` as the `qadb` module:
```bash
module avail qadb
```
then `module load` the one you want; otherwise, see [the setup guide](setup.md) for more guidance.

## General Usage

The QADB is used to _filter_ data based on Quality Assurance (QA) observations.
The database stores information about the "defects" of each run: each run is
subdivided into "QA bins", and for each bin, a set of "defect bits" may or may
not be assigned.

- The user must decide which defect bits should be filtered out of their analysis; see [the table of defect bits](bitdefs.md) and decide which bits to use in the filter.
- See the [table of available datasets](datasets.md) for which data are included in the QADB.
- See the [Usage Guide](usage.md) for how to use QADB with your analysis.

!!! note
    Special care must be taken for the `Misc` defect bit, which is assigned for
    runs (or part of runs) that have abnormal conditions, whether found on the
    timelines or documented in the log book:

    - Each QA bin that has the `Misc` defect bit set includes a _comment_ in the
      QADB, explaining _why_ the bit was set
    - The analyzer must decide whether or not data with the `Misc` defect bit
      should be excluded from their analysis
    - To help with this decision-making
        - use the `qadb-info misc` command; see [the Usage Guide](usage.md) for more information
        - see the `Misc` bit tables, linked for each dataset in the [List of Available Datasets](datasets.md)
