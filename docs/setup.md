# Setup

The QADB is available on `ifarm` as the `qadb` module:
```bash
module avail qadb
```
then `module load` the one you want.

Alternatively, you may download and use this repository locally:
```bash
git clone --recurse-submodules https://github.com/JeffersonLab/clas12-qadb.git
cd clas12-qadb
./install.sh
source clas12-qadb/environ.sh  # or environ.csh, if using csh
```
This will install everything within the source code directory.
