#!/bin/bash
# 24-07-2014
# ** THIS IS A WORK IN PROGRESS. A better way to find the only needed files is needed deployed
# 08-10-2014
# ** Using copydlls.py script from -
# ** https://github.com/performous/performous/blob/master/win32/mxe/copydlls.py

if [ $# -eq 2 ]; then
MXE_TARGET_DIR=$1
COMPRESSED_FILE=$2
else
echo 'Usage: '$0' <path/to/mxe/usr/TARGET-dir> <zip-file-name>'
echo 'Ex: '$0' /home/otbtesting/win-sources/mxe/usr/i686-pc-mingw32 ~/OTB-Windows-MinGW32.zip'
exit 1
fi

CP='/bin/cp -rv'
RM='/bin/rm -f'
MKDIR='/bin/mkdir -p'
PYTHON='/usr/bin/python'

COPYDLLS_SCRIPT='/home/otbtesting/sources/orfeo/OTB-DevUtils/Scripts/copydlls.py'
MVD2_SRC_DIR='/home/otbtesting/sources/orfeo/trunk/Monteverdi2'
DEPLOY_DIR='/tmp/OTB-mingw32'
COPYDLLS_DIR='/tmp/OTB-mingw32-copydlls/'

if [ -d "$MXE_TARGET_DIR" ]; then
echo 'Using ' $MXE_TARGET_DIR' as mxe target directory.'
else
echo $MXE_TARGET_DIR' does not exists.Exiting..'
exit 1
fi

echo 'Create '$DEPLOY_DIR
$MKDIR $DEPLOY_DIR

if [ -d "$DEPLOY_DIR" ]; then
$RM -r $DEPLOY_DIR/bin
$RM -r $DEPLOY_DIR/lib
echo 'Using ' $DEPLOY_DIR' as temp directory.'
else
echo $DEPLOY_DIR' does not exists.Exiting..'
exit 1
fi

echo 'Create '$COPYDLLS_DIR
$MKDIR $COPYDLLS_DIR

if [ -d "$COPYDLLS_DIR" ]; then
$RM -r $COPYDLLS_DIR/*
echo 'Using ' $COPYDLLS_DIR' as copydlls directory.'
fi

##hack - qt and qwt goes $MXE_TARGET_DIR/qt to needs to cleaned
$CP $MXE_TARGET_DIR/qt/bin/Qt*.dll $MXE_TARGET_DIR/bin/
$CP $MXE_TARGET_DIR/qwt/lib/qwt5.dll $MXE_TARGET_DIR/bin/
$CP $MXE_TARGET_DIR/lib/glfw3.dll $MXE_TARGET_DIR/bin/
$CP $MXE_TARGET_DIR/x86/mingw/bin/libopencv_*.dll $MXE_TARGET_DIR/bin/

echo 'Prepare deploy directory for copydlls.py script'
$CP $MXE_TARGET_DIR/lib/otb/applications/otbapp_*.dll $COPYDLLS_DIR
$CP $MXE_TARGET_DIR/bin/libOTB*.dll $COPYDLLS_DIR
$CP $MXE_TARGET_DIR/bin/otbTestDriver.exe $COPYDLLS_DIR
$CP $MXE_TARGET_DIR/bin/otbApplicationLauncher* $COPYDLLS_DIR
$CP $MXE_TARGET_DIR/bin/libMonteverdi2_*.dll $COPYDLLS_DIR
#copy monteverdi executable
$CP $MXE_TARGET_DIR/bin/montever*.exe $COPYDLLS_DIR
#copy iceviewer executable
$CP $MXE_TARGET_DIR/bin/otbiceviewer.exe $COPYDLLS_DIR
#copy gdal binaries
$CP $MXE_TARGET_DIR/bin/gdal*.exe $COPYDLLS_DIR

#run copydlls
$PYTHON $COPYDLLS_SCRIPT $MXE_TARGET_DIR/bin/ $COPYDLLS_DIR

echo 'Start deploying OTB binaries for Windows'
$MKDIR $DEPLOY_DIR/bin/
$MKDIR $DEPLOY_DIR/lib/otb/applications/
$MKDIR $DEPLOY_DIR/lib/qt4/plugins/sqldrivers/
$MKDIR $DEPLOY_DIR/share/qt4/translations/
$MKDIR $DEPLOY_DIR/share/gdal/

/bin/mv $COPYDLLS_DIR/otbapp_*.dll $DEPLOY_DIR/lib/otb/applications/
$CP $COPYDLLS_DIR/*.dll $DEPLOY_DIR/bin/
$CP $COPYDLLS_DIR/otbApplicationLauncher* $DEPLOY_DIR/bin/
$CP $COPYDLLS_DIR/montever*.exe $DEPLOY_DIR/bin/
$CP $COPYDLLS_DIR/gdal*.exe $DEPLOY_DIR/bin/
$CP $COPYDLLS_DIR/otbiceviewer.exe $DEPLOY_DIR/bin/


#copy translation and sqlite.dll for monteverdi2
$CP $MXE_TARGET_DIR/share/otb/i18n $DEPLOY_DIR/share/qt4/translations/
$CP $MXE_TARGET_DIR/qt/plugins/sqldrivers/qsqlite4.dll $DEPLOY_DIR/lib/qt4/plugins/sqldrivers/

#copy qt.conf and monteverdi2.bat
$CP $MVD2_SRC_DIR/Packaging/Windows/qt.conf $DEPLOY_DIR/bin/
$CP $MVD2_SRC_DIR/Packaging/Windows/monteverdi2.bat $DEPLOY_DIR/bin/

#/usr/share/gdal
$CP $MXE_TARGET_DIR/share/gdal $DEPLOY_DIR/share/gdal

#otb*.bat
$CP $MXE_TARGET_DIR/bin/*.bat $DEPLOY_DIR/bin/

echo 'Deployed binaries in '$DEPLOY_DIR
/bin/ls $DEPLOY_DIR
echo 'Compressing files...'
$RM $COMPRESSED_FILE
cd /tmp
COMPRESS='zip -r '$COMPRESSED_FILE' OTB-mingw32'
$COMPRESS


if [ -d "$DEPLOY_DIR" ]; then
echo 'Cleanup deploy dir'
$RM $MXE_TARGET_DIR/bin/Qt*.dll
$RM $MXE_TARGET_DIR/bin/qwt5.dll
$RM $MXE_TARGET_DIR/bin/glfw3.dll
$RM $MXE_TARGET_DIR/bin/libopencv_*.dll
$RM -r $DEPLOY_DIR
fi

if [ -d "$COPYDLLS_DIR" ]; then
$RM -r $COPYDLLS_DIR
echo 'Cleanup temp dir for copydlls'
fi

echo 'Good to Go zip file: ' $COMPRESSED_FILE
