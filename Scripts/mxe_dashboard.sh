#!/bin/bash

if [ $# -eq 3 ]; then
DEVUTILS_DIRECTORY=$1
MXE_SOURCE_DIR=$2
MXE_TARGET=$3
else
echo 'Usage: '$0'<OTB-DevUtils-dir> <mxe-dir> <mxe-target>'
echo 'Ex: '$0' /home/rashad/sources/orfeo/OTB-DevUtils /home/rashad/sources/mxe i686-pc-mingw32.shared'
exit 1
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

LOG_FILE=$LOG_DIR/'mxe_'$MXE_TARGET'_build.log'

#UPDATE Dev-Utils
cd $DEVUTILS_DIRECTORY
hg pull --rebase
hg update

#save status to log file for check if hg pull was just fine.
hg status > $LOG_FILE

DEVUTILS_CONFIG_DIR="${DEVUTILS_DIRECTORY}/Config/pc-christophe"

MXE_BUILD_SCRIPT=${DEVUTILS_DIRECTORY}/Scripts/mxe_build.sh
# # OTB Nightly MXE Cross Compile
$MXE_BUILD_SCRIPT "$MXE_SOURCE_DIR" "$MXE_TARGET" "yes" >> $LOG_FILE
if [ "$?" -eq "0" ]; then
  echo 'MXE is up-to-date.'
  #32bit
  if [ "$MXE_TARGET" == "i686-w64-mingw32.shared" ]; then
     ctest -VV -S $DEVUTILS_CONFIG_DIR/mxe/pc-christophe-OTB-MinGW32_MXE_CROSS_COMPILE.cmake
     ctest -VV -S $DEVUTILS_CONFIG_DIR/mxe/pc-christophe-Ice-MinGW32_MXE_CROSS_COMPILE.cmake
     ctest -VV -S $DEVUTILS_CONFIG_DIR/mxe/pc-christophe-Monteverdi-MinGW32_MXE_CROSS_COMPILE.cmake
     ctest -VV -S $DEVUTILS_CONFIG_DIR/mxe/pc-christophe-Monteverdi2-MinGW32_MXE_CROSS_COMPILE.cmake
  fi
  #64bit
  if [ "$MXE_TARGET" == "x86_64-w64-mingw32.shared" ]; then
     ctest -VV -S $DEVUTILS_CONFIG_DIR/mxe/pc-christophe-OTB-MinGW64_MXE_CROSS_COMPILE.cmake
     ctest -VV -S $DEVUTILS_CONFIG_DIR/mxe/pc-christophe-Ice-MinGW64_MXE_CROSS_COMPILE.cmake
     ctest -VV -S $DEVUTILS_CONFIG_DIR/mxe/pc-christophe-Monteverdi-MinGW64_MXE_CROSS_COMPILE.cmake
     ctest -VV -S $DEVUTILS_CONFIG_DIR/mxe/pc-christophe-Monteverdi2-MinGW64_MXE_CROSS_COMPILE.cmake
  fi
else
echo 'MXE build failed..'
exit 1
fi
