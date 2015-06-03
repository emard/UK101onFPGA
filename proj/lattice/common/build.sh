#!/bin/bash

DIAMOND_BINDIR=$(dirname $(which diamond))
DIAMOND_ROOT=$(dirname $(dirname ${DIAMOND_BINDIR}))
DIAMOND_TCLTK=$(find ${DIAMOND_ROOT} -type d -name tcltk)
DIAMOND_TCL_LIBRARY=$(dirname $(find ${DIAMOND_TCLTK} -type f -name package.tcl))
echo "DIAMOND_BINDIR=${DIAMOND_BINDIR}"
echo "DIAMOND_TCL_LIBRARY=${DIAMOND_TCL_LIBRARY}"
#DIAMOND_BINDIR=/usr/local/diamond/3.2/bin/lin
#DIAMOND_TCL_LIBRARY=/usr/local/diamond/3.2/tcltk/lib/tcl8.5
export TEMP=/tmp
export LSC_INI_PATH=""
export LSC_DIAMOND=true
export TCL_LIBRARY=${DIAMOND_TCL_LIBRARY}
diamondc build.tcl
