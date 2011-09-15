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
#APPLI_FILE=Projections/otbBundleToPerfectSensor.cxx
APPLI_FILE=Simulation/otbImageSimulator.cxx

# Some necessary paths to give (should not change much)
OTB_APP_SOURCES=$HOME/Projets/otb/src/OTB-Applications
OUTPUT_REPO_ROOT=/tmp/convertOTBapp





#############################
# CONVERSION SCRIPT
#############################

# Exit as soon as there is an error
set -e

# Be sure the OTB-Applications repository is up-to-date
cd $OTB_APP_SOURCES
hg pull -u
hg update -r tip -C

#
# Extract the name of the app
# "Projections/otbBundleToPerfectSensor.cxx" will give "BundleToPerfectSensor"
#
APPLI_NAME=`echo $APPLI_FILE | sed 's/[a-zA-Z]*\/otb\([a-zA-Z]*\).cxx/\1/'`
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

# check ! check ! check !
hg view


echo
echo 'Converted repository for '$APPLI_NAME' is in '$OUTPUT_REPO
echo 'If you are happy with it, then cd into your OTB sources and run "hg pull -f '$OUTPUT_REPO'" and merge'



