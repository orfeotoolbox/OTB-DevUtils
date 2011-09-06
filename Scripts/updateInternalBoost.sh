#!/bin/bash

# Requirements :
# - get the last boost tar.gz and unzip it
# - run the bootstrap script (it creates an executable called b2, the boost build tool)
# - build the bcp tool ( cd BOOST_ROOT/tools/bcp; BOOST_ROOT/b2 )
# - customize the following variables :
BOOST_ROOT=/home/otbval/tools/src/boost_1_47_0
BOOST_VER=1.47.0
OTB_ROOT=/home/otbval/Dashboard/src/OTB
MVD_ROOT=/home/otbval/Dashboard/src/Monteverdi


TMP1=/tmp/boost_subpart1
TMP2=/tmp/boost_subpart2
BOOST_SUBPARTROOT=/tmp/boost_subparts

mkdir $BOOST_SUBPARTROOT

echo 'Saving CMakeLists'
cp $OTB_ROOT/Utilities/BGL/boost/CMakeLists.txt  $BOOST_SUBPARTROOT

echo 'Extract what we need from Code'
grep -r "#include <boost/" $OTB_ROOT/Code | cut -d ' ' -f 2 | sed 's/<boost/boost/' | sed 's/.hpp>/.hpp/' > $TMP1

echo 'Extract what we need from Utilities/otbliblas'
grep -r "#include <boost/" $OTB_ROOT/Utilities/otbliblas | cut -d ' ' -f 2 | sed 's/<boost/boost/' | sed 's/.hpp>/.hpp/' >> $TMP1

echo 'Extract what we need from Utilities/otbkml'
grep -r "#include \"boost/" $OTB_ROOT/Utilities/otbkml | cut -d ' ' -f 2 | sed 's/\"//'  | sed 's/\"//' >> $TMP1

echo 'Extract what we need for Monteverdi'
grep -r "#include <boost/" $MVD_ROOT/Code | cut -d ' ' -f 2 | sed 's/<boost/boost/' | sed 's/.hpp>/.hpp/' >> $TMP1

echo 'Remove duplicates'
awk ' { arr[$1]=$0 } END { for ( key in arr ) { print arr[key] } } ' $TMP1 > $TMP2
cat $TMP2

for l in `cat $TMP2`
do
  echo $l
  $BOOST_ROOT/dist/bin/bcp --boost=$BOOST_ROOT $l $BOOST_SUBPARTROOT
done


rm -rf $OTB_ROOT/Utilities/BGL/boost
cp -r  $BOOST_SUBPARTROOT/boost $OTB_ROOT/Utilities/BGL

# Add new files in mercurial, remove the old one.
cd $OTB_ROOT
hg st Utilities/BGL

hg revert $OTB_ROOT/Utilities/BGL/boost/CMakeLists.txt
hg st Utilities/BGL | grep '^! ' | sed -e 's/^! //' | xargs hg rm
hg st Utilities/BGL | grep '^? ' | sed -e 's/^? //' | xargs hg add

hg commit -m "ENH: update Boost to $BOOST_VER"


