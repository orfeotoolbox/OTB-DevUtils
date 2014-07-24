#!/bin/bash

SOURCES_DIR="/home/otbtesting/sources/orfeo"
LOGS_DIR="/home/otbtesting/logs"

#UPDATE Dev-Utils
DEVUTILS_DIRECTORY=$SOURCES_DIR"/OTB-DevUtils"
cd $DEVUTILS_DIRECTORY
hg pull --rebase
hg update

DEVUTILS_CONFIG_DIR="${DEVUTILS_DIRECTORY}/Config/pc-christophe"

MXE_BUILD_SCRIPT=${DEVUTILS_DIRECTORY}/Scripts/mxe_build.sh
# # OTB Nightly MXE Cross Compile
$MXE_BUILD_SCRIPT $HOME/win-sources/mxe > $LOGS_DIR/mxe_build.log
if [ "$?" -eq "0" ]; then
echo 'MXE is up-to-date.'
 ctest -S $DEVUTILS_CONFIG_DIR/pc-christophe-OTB-MinGW32_MXE_CROSS_COMPILE.cmake
 ctest -S $DEVUTILS_CONFIG_DIR/pc-christophe-Ice-MinGW32_MXE_CROSS_COMPILE.cmake
 ctest -S $DEVUTILS_CONFIG_DIR/pc-christophe-Monteverdi-MinGW32_MXE_CROSS_COMPILE.cmake
 ctest -S $DEVUTILS_CONFIG_DIR/pc-christophe-Monteverdi2-MinGW32_MXE_CROSS_COMPILE.cmake

else
echo 'MXE build failed..'
fi
