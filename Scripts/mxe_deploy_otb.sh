#!/bin/bash

# 24-07-2014
# *THIS IS A WORK IN PROGRESS. A better way to find the only needed files is needed 
deloyed
if [ $# -eq 3 ]; then
MXE_TARGET_DIR=$1
DEPOLY_DIR=$2
COMPRESSED_FILE=$3
else
echo 'Usage: '$0' <path/to/mxe/usr/TARGET-dir> </path/to/deploy-root-dir> <zip-file-name>' 
exit 1;
fi

if [ -d "$MXE_TARGET_DIR" ]; then
echo $MXE_TARGET_DIR' does not exists.Exiting...'
exit 1;
fi


echo 'Create '$DEPOLY_DIR
mkdir -p $DEPOLY_DIR/bin
mkdir -p $DEPOLY_DIR/share
mkdir -p $DEPOLY_DIR/lib/otb/applications

CP='/bin/cp -r'
RM='/bin/rm -f'
$CP $MXE_TARGET_DIR/bin/*.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/qt/bin/*.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/qt/plugins/sqldrivers $DEPOLY_DIR/bin/sqldrivers
$CP $MXE_TARGET_DIR/qwt-5.2.2/lib/*.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/x86/mingw/bin/*.dll $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/bin/otb*.exe $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/bin/montever*.exe $DEPOLY_DIR/bin/
$CP $MXE_TARGET_DIR/lib/otb/*.dll $DEPOLY_DIR/lib/otb/
$CP $MXE_TARGET_DIR/lib/otb/applications/*.dll $DEPOLY_DIR/lib/otb/applications/

##TODO:
##remove SOME unwanted .dlls or donot copy them
##avcodec-55.dll avdevice-55.dll avfilter-4.dll avformat-55.dll avresample-1.dll avutil-52.dll FFMPEG
###SDL.dll  SDL lib
##swresample-0.dll swscale-2.dll xvidcore.dll FFMPEG

##add otb.conf and qt.conf?

echo 'Deployed binaries in '$DEPOLY_DIR
ls $DEPLOY_DIR
echo 'Compressing files...'
rm -f $COMPRESSED_FILE
COMPRESS='zip -r '$COMPRESSED_FILE' '$DEPOLY_DIR
$COMPRESS
echo 'Good to Go zip file: ' $COMPRESSED_FILE
