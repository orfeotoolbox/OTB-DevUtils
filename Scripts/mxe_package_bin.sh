#!/bin/bash
# 24-07-2014
# ** THIS IS A WORK IN PROGRESS. A better way to find the only needed files is needed deployed
# 08-10-2014
# ** Using copydlls.py script from -
# ** https://github.com/performous/performous/blob/master/win32/mxe/copydlls.py

if [ $# -eq 3 ]; then
    MXE_SOURCE_DIR=$1
    MXE_TARGET_ARCH=$2
    OTB_BIN_DIR=$3
else
echo 'Usage: '$0' <path-to-mxe-sources> <mxe-target> <path-to-OTB-binaries>'
echo 'Ex: '$0' /home/otbtesting/win-sources/mxe x86|x86_64 /home/otbtesting/build/OTB-mingw'
exit 1
fi

MXE_TARGET_DIR='i686-w64-mingw32.shared'
if [ "$MXE_TARGET_ARCH" == "x86_64" ]; then
   MXE_TARGET_DIR='x86_64-w64-mingw32.shared'
fi;


CP="`which cp` -r"
RM="`which rm` -f"
MV=`which mv`
MKDIR="`which mkdir` -p"
COMPRESS_COMMAND="`which zip` -r"
PYTHON_INTREP=`which python`
COPYDLLS_SCRIPT=$MXE_SOURCE_DIR/tools/copydlldeps.py
OUTPUT_ARCHIVE_NAME=OTB-Windows-MinGW-$MXE_TARGET_ARCH-bin

#temp dirs
COPYDLLS_CHECK_DIR=/tmp/OTB-MinGW-$MXE_TARGET_ARCH-CHECK

COPYDLLS_TARGET_DIR=$OTB_BIN_DIR/$OUTPUT_ARCHIVE_NAME
OUTPUT_ARCHIVE_FILE=$COPYDLLS_TARGET_DIR.zip
MXE_TARGET_BIN_DIR=$MXE_SOURCE_DIR/usr/$MXE_TARGET_DIR

if [ -d "$MXE_TARGET_BIN_DIR" ]; then
    # error
    echo "MXE_TARGET_BIN_DIR check - OK"
else
    echo "MXE_TARGET_BIN_DIR does not exist. cannot continue.."
    exit -1
fi

if [ -f "$COPYDLLS_SCRIPT" ]; then
    # error
    echo "COPYDLLS_SCRIPT check - OK"
else
    echo "COPYDLLS_SCRIPT does not exist. cannot continue.."
    exit -1
fi

echo "PYTHON_INTREP=$PYTHON_INTREP"
echo "COPYDLLS_SCRIPT=$COPYDLLS_SCRIPT"
echo "MXE_TARGET_BIN_DIR=$MXE_TARGET_BIN_DIR"
echo "OTB_BIN_DIR=$OTB_BIN_DIR"
echo "COPYDLLS_CHECK_DIR=$COPYDLLS_CHECK_DIR"
echo "COPYDLLS_TARGET_DIR=$COPYDLLS_TARGET_DIR"
echo "OUTPUT_ARCHIVE_FILE=$OUTPUT_ARCHIVE_FILE"

#create temp dirs
$MKDIR $COPYDLLS_CHECK_DIR

#This directory contains all files needed to start OTB
$MKDIR $COPYDLLS_TARGET_DIR

#create bin, lib, share
$MKDIR $COPYDLLS_TARGET_DIR/{bin,lib,share}

#create dir for applications
$MKDIR $COPYDLLS_TARGET_DIR/lib/otb/applications

#qt plugins
$MKDIR $COPYDLLS_TARGET_DIR/lib/qt4/plugins/sqldrivers
#qt translations
$MKDIR $COPYDLLS_TARGET_DIR/share/qt4/translations
#gdal data
$MKDIR $COPYDLLS_TARGET_DIR/share/gdal


#Copy otb dll and .exe to a temp directory for copydlls.py script
echo "Copy OTB dlls and exe to $COPYDLLS_CHECK_DIR"
$CP $OTB_BIN_DIR/lib/otb/applications/otbapp_*.dll $COPYDLLS_CHECK_DIR
$CP $OTB_BIN_DIR/bin/otbApplicationLauncher* $COPYDLLS_CHECK_DIR
$CP $OTB_BIN_DIR/bin/otbTestDriver.exe* $COPYDLLS_CHECK_DIR

#copy ice dlls
$CP $OTB_BIN_DIR/bin/*ICE*dll $COPYDLLS_CHECK_DIR
#copy iceviewer
$CP $OTB_BIN_DIR/bin/otbiceviewer.exe $COPYDLLS_CHECK_DIR

#copy monteverdi dlls
$CP $$OTB_BIN_DIR/bin/libMonteverdi2_*.dll $COPYDLLS_CHECK_DIR
#copy monteverdi executable
$CP $$OTB_BIN_DIR/bin/montever*.exe $COPYDLLS_CHECK_DIR

#execute copydlls script
echo "Running mxe/tools/copydlls.py"
$PYTHON_INTREP $COPYDLLS_SCRIPT $COPYDLLS_TARGET_DIR/bin -C $COPYDLLS_CHECK_DIR -L $MXE_TARGET_BIN_DIR/bin $OTB_BIN_DIR/bin $MXE_TARGET_BIN_DIR/qt/bin

echo "Start deploying OTB binaries for Windows"
#copy otb*.bat -
$CP $OTB_BIN_DIR/bin/*.bat $COPYDLLS_TARGET_DIR/bin/

#move otbapp_*.dll to lib/otb/applications
$MV $COPYDLLS_CHECK_DIR/*otbapp_*.dll $COPYDLLS_TARGET_DIR/lib/otb/applications

#move previously needed exe to bin
$MV $COPYDLLS_CHECK_DIR/*.exe $COPYDLLS_TARGET_DIR/bin/

# #/usr/share/gdal
$CP $MXE_TARGET_BIN_DIR/share/gdal $COPYDLLS_TARGET_DIR/share/gdal


# #copy translation and sqlite.dll for monteverdi2
# $CP $MXE_TARGET_DIR/share/otb/i18n $DEPLOY_DIR/share/qt4/translations/
# $CP $MXE_TARGET_DIR/qt/plugins/sqldrivers/qsqlite4.dll $DEPLOY_DIR/lib/qt4/plugins/sqldrivers/

# #copy qt.conf and monteverdi2.bat
# $CP $MVD2_SRC_DIR/Packaging/Windows/qt.conf $DEPLOY_DIR/bin/
# $CP $MVD2_SRC_DIR/Packaging/Windows/monteverdi2.bat $DEPLOY_DIR/bin/



# #copy gdal binaries
# $CP $MXE_TARGET_DIR/bin/gdal*.exe $COPYDLLS_DIR



#echo 'Binaries are ready in ' $COPYDLLS_TARGET_DIR
echo 'Compressing files...'
$RM $OUTPUT_ARCHIVE_FILE

cd $OTB_BIN_DIR

$COMPRESS_COMMAND "$OUTPUT_ARCHIVE_FILE" "$OUTPUT_ARCHIVE_NAME"

echo "OTB mingw package is ready! : $COMPRESSED_FILE"

echo "cleaning up.."

#cleanup temp
if [ -d "$COPYDLLS_CHECK_DIR" ]; then
 $RM -r $COPYDLLS_CHECK_DIR
fi

if [ -d "$COPYDLLS_TARGET_DIR" ]; then
 $RM -r $COPYDLLS_TARGET_DIR
fi
