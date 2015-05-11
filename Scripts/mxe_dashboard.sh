#!/bin/bash

if [ $# -gt 2 ]; then
DEVUTILS_DIRECTORY=$1
MXE_SOURCE_DIR=$2
MXE_TARGET=$3
#default
DASHBOARD_SITE='pc-christophe'
else
echo 'Usage: '$0'<OTB-DevUtils-dir> <mxe-dir> <mxe-target>'
echo 'Ex: '$0' /home/rashad/sources/orfeo/OTB-DevUtils /home/rashad/sources/mxe i686-w64-mingw32.shared'
exit 1
fi

if [ $# -eq 4 ]; then
DASHBOARD_SITE=$4
fi

#hack to use ctest 3.3 git
if [ -z ${CTEST33+x} ]; then
CTEST=`which ctest`
else
CTEST=$CTEST33
fi

#we moved on to mingw-w64 project. why?.
#seems like mingw64 has better support than mingw
#and it has both 32bit and 64bit targets.

if [ "$MXE_TARGET" == "i686-pc-mingw32.shared" ]; then
   MXE_TARGET='i686-w64-mingw32.shared'
fi;

LOG_DIR=$HOME"/logs"

if [ -d "$DEVUTILS_DIRECTORY" ]; then
echo 'Assuming OTB-DevUtils is cloned into '$DEVUTILS_DIRECTORY
else
echo $DEVUTILS_DIRECTORY' does not exists.Exiting..'
exit 1
fi

if [ -d "$MXE_SOURCE_DIR" ]; then
echo 'Assuming mxe is cloned into '$MXE_SOURCE_DIR
else
echo $MXE_SOURCE_DIR' does not exists.Exiting..'
exit 1
fi

if [ -d "$LOG_DIR" ]; then
echo 'Using '$LOG_DIR 'for saving log files'
else
echo 'Creating '$LOG_DIR
mkdir -p $LOG_DIR
fi

LOG_FILE=${LOG_DIR}/'mxe_'$MXE_TARGET'_build.log'
DEVUTILS_CONFIG_DIR="${DEVUTILS_DIRECTORY}/Config/${DASHBOARD_SITE}"
MXE_BUILD_SCRIPT=${DEVUTILS_DIRECTORY}/Scripts/mxe_build.sh
echo "DEVUTILS_CONFIG_DIR=${DEVUTILS_CONFIG_DIR}"
echo "CTEST=$CTEST"

cd $DEVUTILS_DIRECTORY
#save status and diff to log file for check if hg pull was just fine.
hg status > $LOG_FILE
hg diff >> $LOG_FILE

#UPDATE Dev-Utils
hg pull --rebase
hg update -C

echo "Launching $MXE_BUILD_SCRIPT $MXE_SOURCE_DIR $MXE_TARGET yes"
$MXE_BUILD_SCRIPT "$MXE_SOURCE_DIR" "$MXE_TARGET" "yes" >> $LOG_FILE 2>&1

#if [ "$?" -eq "0" ]; then
echo 'MXE is up-to-date.'
#32bit
if [ "$MXE_TARGET" == "i686-w64-mingw32.shared" ]; then
    $CTEST -VV -S ${DEVUTILS_CONFIG_DIR}/mxe/OTB-MinGW32_MXE.cmake
    $CTEST -VV -S ${DEVUTILS_CONFIG_DIR}/mxe/Ice-MinGW32_MXE.cmake
    $CTEST -VV -S ${DEVUTILS_CONFIG_DIR}/mxe/Monteverdi-MinGW32_MXE.cmake
    $CTEST -VV -S ${DEVUTILS_CONFIG_DIR}/mxe/Monteverdi2-MinGW32_MXE.cmake
fi
#64bit
if [ "$MXE_TARGET" == "x86_64-w64-mingw32.shared" ]; then
    $CTEST -VV -S ${DEVUTILS_CONFIG_DIR}/mxe/OTB-MinGW64_MXE.cmake
    $CTEST -VV -S ${DEVUTILS_CONFIG_DIR}/mxe/Ice-MinGW64_MXE.cmake
    $CTEST -VV -S ${DEVUTILS_CONFIG_DIR}/mxe/Monteverdi-MinGW64_MXE.cmake
    $CTEST -VV -S ${DEVUTILS_CONFIG_DIR}/mxe/Monteverdi2-MinGW64_MXE.cmake
fi

# else
#     echo 'MXE build failed..'
#     exit 1
# fi
