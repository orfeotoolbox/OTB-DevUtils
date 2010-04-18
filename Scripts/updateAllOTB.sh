#! /bin/sh
# Usage: updateAllOTB.sh OTB_trunk

TRUNK_DIR=$1

for REP in "OTB" "OTB-Applications" "OTB-Data" "OTB-DevUtils" "OTB-Documents" "Monteverdi" "OTB-Wrapping"
do
  cd $TRUNK_DIR/$REP
  hg pull -u
done

