# Requirements :
# - get the last boost tar.gz and unzip it
# - run the bootstrap script (it creates an executable called b2, the boost build tool)
# - build the bcp tool ( cd BOOST_ROOT/tools/bcp; BOOST_ROOT/b2 )
# - customize the following variables :

# BOOST_ROOT=/home2/lhermitte/dev/cots/boost/boost_1_49_0
# BOOST_VER=1.49.0
# OTB_ROOT=/home2/lhermitte/OTB/OTB-HEAD
# MVD_ROOT=/home2/lhermitte/OTB/Monteverdi-HEAD
BOOST_ROOT=/home/otbval/tools/src/boost_1_49_0
BOOST_VER=1.49.0
OTB_ROOT=/home/otbval/Dashboard/src/OTB
MVD_ROOT=/home/otbval/Dashboard/src/Monteverdi

TMP1=/tmp/boost_subpart1
TMP2=/tmp/boost_subpart2
BOOST_SUBPARTROOT=/tmp/boost_subparts

mkdir $BOOST_SUBPARTROOT

echo 'Extract what we need from Code'
grep -r "^#include <boost/" $OTB_ROOT/Code | cut -d ' ' -f 2 | sed 's/<\(.*\)>/\1/' > $TMP1

echo 'Extract what we need from Utilities/otbliblas'
grep -r "^#include <boost/" $OTB_ROOT/Utilities/otbliblas | cut -d ' ' -f 2 | sed 's/<\(.*\)>/\1/' >> $TMP1

echo 'Extract what we need from Utilities/otbkml'
grep -r "^#include \"boost/" $OTB_ROOT/Utilities/otbkml | cut -d ' ' -f 2 | sed 's/\"\(.*\)\"/\1/' >> $TMP1

echo 'Extract what we need for Monteverdi'
grep -r "^#include <boost/" $MVD_ROOT/Code | cut -d ' ' -f 2 | sed 's/<\(.*\)>/\1/' >> $TMP1

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
files_to_remove=$(hg st Utilities/BGL | grep '^! ' | sed -e 's/^! //')
need_to_commit=0
if [ -n "$files_to_remove" ] ; then
    xargs hg rm $files_to_remove
    need_to_commit=1
else
    echo "No deprecated dependencies/files to remove"
fi
files_to_add=$(hg st Utilities/BGL | grep '^? ' | sed -e 's/^? //')
if [ -n "$files_to_add" ] ; then
    xargs hg add $files_to_add
    need_to_commit=1
else
    echo "No new files"
fi
if [ $need_to_commit -gt 0 ] ; then
    echo hg commit -m "ENH: update Boost to $BOOST_VER" $OTB_ROOT/Utilities/BGL
fi
