#!/bin/sh

DIR=diamond
PROJECT=project
TOP_LEVEL_ENTITY="main"
# file list to copy
COPY=""
# file list to symlink
SYMLINK="${SYMLINK} \
  ulx2s.lpf \
  ../common/build.sh ../common/build.tcl \
  ../../../lattice/lattice_pll_25M_50M.vhd \
  ../../../lattice/pll_25M_50M.vhd \
  ../../../lattice/lattice_DisplayRam8K.vhd \
  ../../../lattice/DisplayRam8K.vhd \
  ../../../lattice/lattice_ProgRam.vhd \
  ../../../lattice/ProgRam.vhd \
  ../../../lattice/ProgSRam.vhd \
  ../../../lattice/lattice_OraoCRT13.vhd \
  ../../../lattice/OraoCRT.vhd \
  ../../../lattice/main_orao.vhd \
  ../../../orao/orao.vhd \
  ../../../orao/bas13.vhex \
  ../../../orao/crt13.vhex \
  ../../../generic/ROMgeneric.vhd \
  ../../../generic/rom_generic.v \
  ../../../generic/bram_2port.vhd \
  ../../../Components/M6502/T65_ALU.vhd \
  ../../../Components/M6502/T65.vhd \
  ../../../Components/M6502/T65_MCode.vhd \
  ../../../Components/M6502/T65_Pack.vhd \
  ../../../Components/TV/OraoGraphDisplay8K.vhd \
  ../../../Components/PS2KB/ps2_intf.vhd \
  ../../../Components/PS2KB/orao_keyboard_buttons.vhd \
  ../../../Components/UART/bufferedUART.vhd \
  "
#  ../../../lattice/lattice_OraoBAS13.vhd \
#  ../../../lattice/OraoBAS.vhd \

#  ../../../Components/PS2KB/UK101keyboard.vhd \
#  ../../../Components/PS2KB/UK101keyboard_buttons.vhd \

echo "COPY=${COPY}"
echo "SYMLINK=${SYMLINK}"

RM=rm
MKDIR=mkdir
BUGGYNAME=$(echo "${PROJECT}" | sed -e "s/\(.*\)\(...\)/\1_\1\2\2/g")

$RM -rf ${DIR}
$MKDIR -p ${DIR}
cd ${DIR}
for name in ${COPY}
do
  echo "copying $name"
  cp ../$name .  
done
for name in ${SYMLINK}
do
  echo "symlinking $name"
  ln -s ../$name .  
done
echo "create bugfix symlink"
mkdir -p ${PROJECT}
cd ${PROJECT}
ln -s "${PROJECT}_${PROJECT}.p2t" "${BUGGYNAME}.p2t"

# create file list for including into project
cd ..
FILELIST_VHDL=$(find . -type l -name "*.vhd")
FILELIST_VHDL="${FILELIST_VHDL} $(find . -type l -name '*.VHD')"
FILELIST_VERILOG=$(find . -type l -name "*.v")
(
cat ../../common/project.ldf.first
echo "        <Options def_top=\"${TOP_LEVEL_ENTITY}\"/>"
#for file in $(ls *.vhd)
for file in $FILELIST_VHDL
do
  if [ "${file}" = "${TOP_LEVEL_ENTITY}.vhd"  ]
  then
    OPTIONS=" top_module=\"${TOP_LEVEL_ENTITY}\""
  else
    OPTIONS=""
  fi
  echo "        <Source name=\"${file}\" type=\"VHDL\" type_short=\"VHDL\"><Options${OPTIONS}/></Source>"
done
for file in $FILELIST_VERILOG
do
  if [ "${file}" = "${TOP_LEVEL_ENTITY}.v"  ]
  then
    OPTIONS=" top_module=\"${TOP_LEVEL_ENTITY}\""
  else
    OPTIONS=""
  fi
  echo "        <Source name=\"${file}\" type=\"Verilog\" type_short=\"Verilog\"><Options${OPTIONS}/></Source>"
done
cat ../../common/project.ldf.last
) > project.ldf
