# Instruction to update the ossim internal version in OTB
# You just have to provide the location of two directories:
# - ossim svn repository
# - otb hg repository

# You can execute this script directly, but you'll be better served if you check
# step by step that all is going well. The only manual step is merging the
# patches that failed.

# Parameters
OSSIM_SOURCES=full-path-to-the-ossim-svn/ossim-read-only
OTB_SOURCES=full-path-to-the-otb-repository/OTB

# Find out previous ossim sync number
cd $OTB_SOURCES
PREVIOUS_OSSIM_SYNC=`grep 'SET(OSSIM_SVN_REVISION' Utilities/otbossim/CMakeLists.txt | sed -e 's/SET(OSSIM_SVN_REVISION "\([0-9]*\)")/\1/'`
echo "Previous ossim sync was on r$PREVIOUS_OSSIM_SYNC"

# Files in use
INCLUDE_PATCH=$OTB_SOURCES/ossim-include-$PREVIOUS_OSSIM_SYNC.patch
SRC_PATCH=$OTB_SOURCES/ossim-src-$PREVIOUS_OSSIM_SYNC.patch
SHARE_PATCH=$OTB_SOURCES/ossim-share-$PREVIOUS_OSSIM_SYNC.patch

# Clean up OTB_SOURCES from previous merge.
cd $OTB_SOURCES
find . -name '*.rej' | xargs rm

# Update ossim source to the previous sync.
cd $OSSIM_SOURCES
svn update -r$PREVIOUS_OSSIM_SYNC

# Produce OTB patch.
# TODO: use relative patch to fix the -pN argument of the patch command below.
diff -urw $OSSIM_SOURCES/ossim/include/ossim $OTB_SOURCES/Utilities/otbossim/include/ossim > $INCLUDE_PATCH
diff -urw $OSSIM_SOURCES/ossim/src/ossim $OTB_SOURCES/Utilities/otbossim/src/ossim > $SRC_PATCH
diff -urw $OSSIM_SOURCES/ossim/share/ossim $OTB_SOURCES/Utilities/otbossim/src/ossim > $SHARE_PATCH

# Update ossim to the latest revision.
cd $OSSIM_SOURCES
svn up
export LC_ALL=C
NEW_OSSIM_SYNC=`svn info | grep '^Revision:' | sed -e 's/^Revision: //'`
echo "We are going to sync on r$NEW_OSSIM_SYNC"

# Replace ossim in OTB.
cd $OTB_SOURCES
rm -rf Utilities/otbossim/include/ossim
rm -rf Utilities/otbossim/src/ossim
rm -rf Utilities/otbossim/share/ossim

cp -r $OSSIM_SOURCES/ossim/include/ossim Utilities/otbossim/include
cp -r $OSSIM_SOURCES/ossim/src/ossim Utilities/otbossim/src
cp -r $OSSIM_SOURCES/ossim/share/ossim Utilities/otbossim/share

# Some cleanup.
find Utilities/otbossim -name '.svn' | xargs rm -rf
find Utilities/otbossim -name '.cvsignore' | xargs rm -rf
find Utilities/otbossim -name 'makefile.vc' | xargs rm -rf
rm Utilities/otbossim/include/ossim/ossimConfig.h

# Add new files in mercurial, remove the old one.
hg st Utilities/otbossim

hg st Utilities/otbossim | grep '^! ' | sed -e 's/^! //' | xargs hg rm
hg st Utilities/otbossim | grep '^? ' | sed -e 's/^? //' | xargs hg add

hg commit -m "OSSIM: update ossim to r$NEW_OSSIM_SYNC"

# Apply OTB patch.
# You might need to tweak the -pN setting to fit your environment
patch -p6 < $INCLUDE_PATCH
patch -p6 < $SRC_PATCH
patch -p6 < $SHARE_PATCH

# Here you have to fix the conflict manually. Find out what they are:
find . -name '*.rej'
# Check them all, it can be:
# 1. change in OTB that have been integrated in ossim => nothing to do
# 2. change in ossim that we patched in OTB => nothing to do
# 3. too much ossim change around an OTB fix => reapply manually
# If we sync often enough, most of these problem will not appear.

# Once fixed, update ossim version number and commit.
sed -i "s/$PREVIOUS_OSSIM_SYNC/$NEW_OSSIM_SYNC/g" Utilities/otbossim/CMakeLists.txt
hg commit -m "OSSIM: apply otb patch"

# Rebuild OTB and check that all is well, then push.
