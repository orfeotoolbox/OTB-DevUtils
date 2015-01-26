#!/bin/bash

DASHBOARD_ROOT=/home/otbval/Dashboard
DEVUTILS=$DASHBOARD_ROOT/src/OTB-DevUtils/Scripts/modularization
OTB_TRUNK=$DASHBOARD_ROOT/src/OTB
OTB_MODULAR_RESULT=$DASHBOARD_ROOT/src/Modularity
OTB_MODULAR_BUILD=$DASHBOARD_ROOT/build/Modularity/OTB_Modular
OTB_MODULAR_INSTALL=$DASHBOARD_ROOT/install/Modularity/OTB_Modular

# Inputs in repository
CODE_MANIFEST=$DEVUTILS/Manifest.csv
CODE_DEPENDS=$DEVUTILS/module-depends.csv
APP_MANIFEST=$DEVUTILS/otb_app_manifest.csv

# Inputs to generate
APP_DEPENDS=$OTB_MODULAR_RESULT/otb_app_depends.csv
TEST_MANIFEST=$OTB_MODULAR_RESULT/TestManifest.csv
TEST_DEPENDS=$OTB_MODULAR_RESULT/test-depends.csv
CODE_APPS_DEPENDS=$OTB_MODULAR_RESULT/code_apps_depends.csv
FULL_MANIFEST=$OTB_MODULAR_RESULT/full-manifest.csv

# clean result directory
rm -rf $OTB_MODULAR_RESULT/*

# Create test manifest and specific dependencies
python $DEVUTILS/createTestManifest.py $CODE_MANIFEST $CODE_DEPENDS $OTB_TRUNK $TEST_MANIFEST $TEST_DEPENDS
cat $CODE_MANIFEST $TEST_MANIFEST $APP_MANIFEST > $FULL_MANIFEST

# Create dependencies for application modules
python $DEVUTILS/analyseAppManifest.py $CODE_MANIFEST $CODE_DEPENDS $OTB_TRUNK $APP_MANIFEST $APP_DEPENDS

cat $CODE_DEPENDS $APP_DEPENDS > $CODE_APPS_DEPENDS

# Call modulizer script
python $DEVUTILS/modulizer.py $OTB_TRUNK $OTB_MODULAR_RESULT \
  $FULL_MANIFEST  $CODE_APPS_DEPENDS $TEST_DEPENDS $DEVUTILS/module-descriptions.csv

# Build and test modular OTB
ctest -S $DASHBOARD_ROOT/src/OTB-DevUtils/Config/hulk/hulk-Nightly-OTB-Modular.cmake -V >$DASHBOARD_ROOT/build/Modularity/log.txt 2>&1

