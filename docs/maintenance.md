# QADB Maintenance

Documentation for QADB maintenance and revision

## Adding to or revising the QADB
- the QADB files are produced by [`clas12-timeline`](https://github.com/JeffersonLab/clas12-timeline)
- if you have produced QA results for a new dataset, and would like to add
  them to the QADB, or if you would like to update results for an existing
  dataset, follow the following procedure:
    - [ ] `mkdir qadb/pass${pass}/${dataset}/`, then copy the final `qaTree.json` and `chargeTree.json` to that directory
    - [ ] add/update a symlink to this dataset in `qadb/latest`, if this is a new Pass
    - [ ] update the above table of datasets
    - [ ] submit a pull request

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
