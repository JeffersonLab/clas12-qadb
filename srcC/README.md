# C++ access to QADB

This directory contains the C++ source code to access the QA database

- first, make sure you have the
  [`rapidjson`](https://github.com/Tencent/rapidjson/) library;
  it is a submodule of this repository and can be obtained by
  ```
  git clone --recurse-submodules https://github.com/JeffersonLab/clas12-qadb.git
  ```
- be sure the `$QADB` environment variable points to the `clas12-qadb` repository
  - this can be done with `source ../environ.sh`
- in your analysis code, add the following directories to your project's include path:
  - `srcC/include`
  - `srcC/rapidjson/include`
  - you may need to specify these as "absolute paths" (i.e., not relative paths); see
    `examples/Makefile` macro `DEPS` for an example
- see the `examples/` directory for example QADB usage in analysis loops
  - a standard usage of QA cuts is demonstrated in
    [`examples/cutCustom.cpp`](examples/cutCustom.cpp)
- usage notes:
  - include the `QADB.h` header, then instantiate
    - `QADB` is in the `QA` namespace, so you will either need to add
      `using namespace QA` or use specifiers, such as `QA::QADB *q`
  - the `QADB` class provides several methods for accessing the QA info;
    you only need to provide it a run number and event number
  - database lookups are only performed as needed, so it is safe to
    use any accessor method in a standard analysis event loop
- **NOTE** `QADB` has been tested with compiled analysis code, but some users
  encounter problems when interpreting analysis code with ROOT Cling; it is
  recommended to compile your analysis code
