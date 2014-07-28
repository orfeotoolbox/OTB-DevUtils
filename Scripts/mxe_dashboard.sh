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
$MXE_BUILD_SCRIPT $HOME/win-sources/mxe "yes" > $LOGS_DIR/mxe_build.log
if [ "$?" -eq "0" ]; then
echo 'MXE is up-to-date.'
ctest -S $DEVUTILS_CONFIG_DIR/pc-christophe-OTB-MinGW32_MXE_CROSS_COMPILE.cmake
ctest -S $DEVUTILS_CONFIG_DIR/pc-christophe-Ice-MinGW32_MXE_CROSS_COMPILE.cmake
ctest -S $DEVUTILS_CONFIG_DIR/pc-christophe-Monteverdi-MinGW32_MXE_CROSS_COMPILE.cmake

## ATTENTION !!!!!
##Below we appliced a local patch for Monteverdi2 cross compilation. 
##The thing is simply to use relative paths for mvdWin32.rc
## ##
##+++ b/Code/Application/Monteverdi2/CMakeLists.txt
##-    set( Monteverdi2_Catalogue_WIN32_RC_FILE ${CMAKE_CURRENT_BINARY_DIR}/mvdWin32.rc )
##+    set( Monteverdi2_Catalogue_WIN32_RC_FILE mvdWin32.rc )
## ##
## CMake verbose says during build it switches the directory so relative path seems not harmful.
## However this hack is needed only for cross compilation. 
## The actual problem seems to be from parsing of cmakelists.txt by cmake 
##in a cross compile environment

##For the record. I hate to do this kind of hacks but unfortunately the build must go fine 
##and I dont have any options right now.. 
${DEVUTILS_DIRECTORY}/Scripts/mvd2_mxe_patch.sh 'patch'
ctest -S $DEVUTILS_CONFIG_DIR/pc-christophe-Monteverdi2-MinGW32_MXE_CROSS_COMPILE.cmake
${DEVUTILS_DIRECTORY}/Scripts/mvd2_mxe_patch.sh 'revert'
else
echo 'MXE build failed..'
fi
