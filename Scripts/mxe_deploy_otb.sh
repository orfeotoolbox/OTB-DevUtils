#!/bin/bash

# 24-07-2014
# ** THIS IS A WORK IN PROGRESS. A better way to find the only needed files is needed deployed

if [ $# -eq 2 ]; then
MXE_TARGET_DIR=$1
COMPRESSED_FILE=$2
else
echo 'Usage: '$0' <path/to/mxe/usr/TARGET-dir> <zip-file-name>'
echo 'Ex: '$0' /home/otbtesting/win-sources/mxe/usr/i686-pc-mingw32 ~/OTB-Windows-MinGW32.zip'
exit 1;
fi

if [ -d "$MXE_TARGET_DIR" ]; then
echo 'Using ' $MXE_TARGET_DIR' as mxe target directory.'
else
echo $MXE_TARGET_DIR' does not exists.Exiting..'
exit 1;
fi

DEPOLY_DIR='/tmp/OTB-mingw32'
echo 'Create '$DEPOLY_DIR

mkdir -p $DEPOLY_DIR
if [ -d "$DEPOLY_DIR" ]; then
rm -fr $DEPOLY_DIR/bin
rm -fr $DEPOLY_DIR/lib
echo 'Using ' $DEPOLY_DIR' as temp directory.'
else
echo $DEPOLY_DIR' does not exists.Exiting..'
exit 1;
fi

echo 'Start deploying OTB 32bit binaries for Windows with MinGW'
mkdir -p $DEPOLY_DIR/bin
mkdir -p $DEPOLY_DIR/share
mkdir -p $DEPOLY_DIR/lib/otb/applications

CP='/bin/cp -rv'
RM='/bin/rm -f'
$CP $MXE_TARGET_DIR/bin/*.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/lib/glfw3.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/lib/libboost*mt.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/lib/icu*.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/qt/bin/QtGui4.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/qt/bin/QtCore4.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/qt/bin/QtNetwork4.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/qt/bin/QtOpenGL4.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/qt/bin/QtXml4.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/qt/bin/QtSql4.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/qt/plugins/sqldrivers $DEPOLY_DIR/bin/sqldrivers
$CP $MXE_TARGET_DIR/qwt-5.2.2/lib/*.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/x86/mingw/bin/*.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/bin/otb*.exe $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/bin/montever*.exe $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/binaries/lib/otb/libotbopenjpeg.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/lib/otb/applications/*.dll $DEPOLY_DIR/lib/otb/applications/

##TODO:
##remove SOME unwanted .dlls or donot copy them
##avcodec-55.dll avdevice-55.dll avfilter-4.dll avformat-55.dll avresample-1.dll avutil-52.dll FFMPEG
###SDL.dll  SDL lib
##swresample-0.dll swscale-2.dll xvidcore.dll FFMPEG

##add otb.conf and qt.conf?

echo 'Deployed binaries in '$DEPOLY_DIR
ls $DEPOLY_DIR
echo 'Compressing files...'
rm -f $COMPRESSED_FILE
cd /tmp
COMPRESS='zip -r '$COMPRESSED_FILE' OTB-mingw32'
$COMPRESS
echo 'Good to Go zip file: ' $COMPRESSED_FILE
