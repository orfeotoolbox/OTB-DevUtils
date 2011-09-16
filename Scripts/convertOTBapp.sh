#
# This script will prepare an application in OTB-Applications for inclusion into OTB
#
# You need:
# - the latest clone of OTB-Applications
# - enable the 'mq' (for strip) and 'convert' extensions
# 
#

#############################
# PARAMETERS
#############################

# This is the 'main' parameter: the file containing the application
APPLI_FILE=Projections/otbBundleToPerfectSensor.cxx
#APPLI_FILE=Simulation/otbImageSimulator.cxx

# Some necessary paths to give (should not change much)
OTB_APP_SOURCES=$HOME/dev/src/OTB-Applications
OUTPUT_REPO_ROOT=/tmp/convertOTBapp




#############################
# CONVERSION SCRIPT
#############################

# Exit as soon as there is an error
set -e

# Create the root dir if it does not exists
if [ ! -d $OUTPUT_REPO_ROOT ]
then
  mkdir $OUTPUT_REPO_ROOT
fi

# Be sure the OTB-Applications repository is up-to-date
cd $OTB_APP_SOURCES
hg pull -u
hg update -r tip -C

#
# Extract the name of the app
# "Projections/otbBundleToPerfectSensor.cxx" will give "BundleToPerfectSensor"
#
APPLI_NAME=`echo $APPLI_FILE | sed 's/[a-zA-Z]*\/otb\([a-zA-Z]*\).cxx/\1/'`
APPLI_SUBDIR=`echo $APPLI_FILE | sed 's/\([a-zA-Z]*\)\/otb[a-zA-Z]*.cxx/\1/'`
echo include $APPLI_FILE > $OUTPUT_REPO_ROOT/$APPLI_NAME.filemap

OUTPUT_REPO=$OUTPUT_REPO_ROOT/$APPLI_NAME

# launch the conversion
hg convert --filemap $OUTPUT_REPO_ROOT/$APPLI_NAME.filemap $OTB_APP_SOURCES $OUTPUT_REPO

cd $OUTPUT_REPO

# get the latest changeset description
LATEST_CHANGESET=`hg log --template "{desc}\n" -r tip`

# if this application was released, then a special tag commit is done by 'hg convert'
if [ "$LATEST_CHANGESET" = "update tags" ]
then
  # remove the tag conversion commit
  hg strip tip
fi

# update to the latest rev
hg update -r tip

# rename to its final location
hg rename $APPLI_FILE Applications/$APPLI_FILE
hg commit -m "ENH: move $APPLI_NAME to proper location before merge"

# create a CMakeLists to test the app externally
cat > Applications/$APPLI_SUBDIR/CMakeLists.txt << EOF
cmake_minimum_required(VERSION 2.8)

if(COMMAND CMAKE_POLICY)
  cmake_policy(SET CMP0003 NEW)
endif(COMMAND CMAKE_POLICY)

project( $APPLI_NAME )

find_package(OTB REQUIRED)
include(\${OTB_USE_FILE})

OTB_CREATE_APPLICATION(NAME           $APPLI_NAME
                       SOURCES        otb$APPLI_NAME.cxx
                       LINK_LIBRARIES OTBBasicFilters)

EOF




# check ! check ! check !
hg view


echo
echo 'Converted repository for '$APPLI_NAME' is in '$OUTPUT_REPO
echo ''
echo 'A CmakeLists.txt has been created but not committed, so the application can be converted to the new framework before merging to OTB'
echo 'When you are happy with it, "cd" into your OTB sources and run "hg pull -f '$OUTPUT_REPO'", then " hg merge"'



