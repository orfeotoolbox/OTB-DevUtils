#!/bin/bash

TSOCKS=tsocks
TSOCKS=

DEVUTILS=/home/jmalik/dev/src/OTB-DevUtils/Scripts/modularization
OTB_TRUNK=/home/jmalik/dev/src/OTB
OTB_MODULAR_BASE=/home/jmalik/dev/src/OTB-modular
OTB_MODULAR_RESULT=/home/jmalik/dev/src/OTB-modular-test
OTB_MODULAR_BUILD=/home/jmalik/dev/build/OTB-modular-test

APP_MANIFEST=$DEVUTILS/otb_app_manifest.csv
APP_DEPENDS=$DEVUTILS/otb_app_depends.csv
TEST_MANIFEST=$DEVUTILS/TestManifest.csv
TEST_DEPENDS=$DEVUTILS/test-depends.csv

CODE_APPS_DEPENDS=$DEVUTILS/code_apps_depends.csv
FULL_MANIFEST=$DEVUTILS/full-manifest.csv

$TSOCKS $DEVUTILS/createTestManifest.py $DEVUTILS/Manifest.csv $DEVUTILS/module-depends.csv $OTB_TRUNK $TEST_MANIFEST $TEST_DEPENDS
cat $DEVUTILS/Manifest.csv $TEST_MANIFEST $APP_MANIFEST > $FULL_MANIFEST

$DEVUTILS/analyseAppManifest.py $DEVUTILS/Manifest.csv $DEVUTILS/module-depends.csv $OTB_TRUNK $APP_MANIFEST $APP_DEPENDS

cat $DEVUTILS/module-depends.csv $APP_DEPENDS > $CODE_APPS_DEPENDS

rm -rf $OTB_MODULAR_RESULT

$TSOCKS $DEVUTILS/modulizer.py $OTB_TRUNK $OTB_MODULAR_RESULT \
  $FULL_MANIFEST  $CODE_APPS_DEPENDS $DEVUTILS/test-depends.csv $DEVUTILS/module-descriptions.csv

rm -rf $OTB_MODULAR_BUILD/*
mkdir -p $OTB_MODULAR_BUILD

cd $OTB_MODULAR_BUILD
cmake $OTB_MODULAR_RESULT/OTB_Modular \
 -DMUPARSERX_LIBRARY:PATH=/home/jmalik/dev/build/muparserx-read-only/InstallTest/lib/libmuparserx.so \
 -DMUPARSERX_INCLUDE_DIR:PATH=/home/jmalik/dev/build/muparserx-read-only/InstallTest/include/muparserx \
 -DITK_DIR=/home/jmalik/dev/build/ITK-RelWithDebInfo \
 -DMAXIMUM_NUMBER_OF_HEADERS=1 \
 -DCMAKE_INSTALL_PREFIX:PATH=/home/jmalik/dev/build/OTB-modular-test/InstallTest \
 -DOTB_WRAP_PYTHON:BOOL=ON \
 -DOTB_WRAP_JAVA:BOOL=ON \
 -DOTB_DATA_ROOT:BOOL=/home/jmalik/dev/src/OTB-Data

