# QADB Documentation

<img src="logo_large.png"/>

**Q**uality **A**ssurance **D**ata**B**ase

:arrow_upper_left: See links to the left for guidance

## Quick Start
The QADB is available on `ifarm` as the `qadb` module:
```bash
module avail qadb
```
then `module load` the one you want; otherwise, see [the setup guide](setup.md) for more guidance.

The QADB is used to _filter_ data based on Quality Assurance (QA) observations.
The database stores information about the "defects" of each run: each run is
subdivided into "QA bins", and for each bin, a set of "defect bits" may or may
not be assigned.

- See the [Table of Available Datasets](datasets.md) for which data are included in the QADB.
- See the [Usage Guide](usage.md) for how to use QADB with your analysis.
- The user must decide which defect bits should be filtered out of their analysis.
    - See [the Table of Defect Bits](bitdefs.md) and decide which bits to use in the filter.
    - Special care must be taken for the `Misc` defect bit, which is assigned for runs (or part of runs) that have abnormal conditions, whether found on the timelines or documented in the log book:
        - Each QA bin that has the `Misc` defect bit set includes a _comment_ in the
          QADB, explaining _why_ the bit was set; the analyzer must decide whether or
          not those data should be excluded in their analysis.
        - To help with this decision-making:
            - Use the `qadb-info misc` command; see [the Usage Guide](usage.md) for more information.
            - See the `Misc` bit tables, linked for each dataset in the [List of Available Datasets](datasets.md).
