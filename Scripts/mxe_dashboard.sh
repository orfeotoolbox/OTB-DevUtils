#!/bin/bash

if [ $# -eq 1 ]; then
MXE_TARGETS=$1
else
MXE_TARGETS='all'
echo 'No or invalid options. Building both 32bit and 64 bit'
fi

SOURCES_DIR="/home/otbtesting/sources/orfeo"
LOGS_DIR="/home/otbtesting/logs"

#UPDATE Dev-Utils
DEVUTILS_DIRECTORY=$SOURCES_DIR"/OTB-DevUtils"
cd $DEVUTILS_DIRECTORY
##hg pull --rebase
##hg update

DEVUTILS_CONFIG_DIR="${DEVUTILS_DIRECTORY}/Config/pc-christophe"

MXE_BUILD_SCRIPT=${DEVUTILS_DIRECTORY}/Scripts/mxe_build.sh
# # OTB Nightly MXE Cross Compile
$MXE_BUILD_SCRIPT $HOME/win-sources/mxe "yes" "$MXE_TARGETS"
#> $LOGS_DIR/mxe_build.log
if [ "$?" -eq "0" ]; then
echo 'MXE is up-to-date.'
#64bit
ctest -S $DEVUTILS_CONFIG_DIR/mxe/64bit/pc-christophe-OTB-MinGW64_MXE_CROSS_COMPILE.cmake

#32bit
ctest -S $DEVUTILS_CONFIG_DIR/mxe/32bit/pc-christophe-OTB-MinGW32_MXE_CROSS_COMPILE.cmake
ctest -S $DEVUTILS_CONFIG_DIR/mxe/32bit/pc-christophe-Ice-MinGW32_MXE_CROSS_COMPILE.cmake
ctest -S $DEVUTILS_CONFIG_DIR/mxe/32bit/pc-christophe-Monteverdi-MinGW32_MXE_CROSS_COMPILE.cmake
ctest -S $DEVUTILS_CONFIG_DIR/mxe/32bit/pc-christophe-Monteverdi2-MinGW32_MXE_CROSS_COMPILE.cmake

else
echo 'MXE build failed..'
fi
