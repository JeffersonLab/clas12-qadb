#!/bin/tcsh
set this_cmd=($_)
set this_dir=`dirname ${this_cmd[2]}`
setenv QADB `cd ${this_dir} && pwd -P`

# path for executables
set bin_dir=${QADB}/bin
if (! $?PATH) then
  setenv PATH $bin_dir
else
  if ("$PATH" == "") then
    setenv PATH $bin_dir
  else
    setenv PATH $bin_dir\:$PATH
  endif
endif

# class path for groovy
set src_dir=${QADB}/src/
if (! $?JYPATH) then
  setenv JYPATH $src_dir
else
  if ("$JYPATH" == "") then
    setenv JYPATH $src_dir
  else
    setenv JYPATH $src_dir\:$JYPATH
  endif
endif

# cleanup
unset this_cmd
unset this_dir
unset bin_dir
unset src_dir
