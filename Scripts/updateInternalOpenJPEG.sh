# Instruction to update the openjpeg internal version in OTB
# You just have to provide the location of two directories:
# - openjpeg svn repository
# - otb hg repository

# You can execute this script directly, but you'll be better served if you check
# step by step that all is going well. The only manual step is merging the
# patches that failed.

# Parameters
OPJ_SOURCES=~/dev/src/OpenJPEG/svn-ref-src/opj-trunk
OTB_SOURCES=~/dev/src/OTB

# Find out previous openjpeg sync svn rev number
cd $OTB_SOURCES
PREVIOUS_OPJ_SYNC=`grep 'SET(OPENJPEG_SVN_REVISION' Utilities/otbopenjpeg/CMakeLists.txt | sed -e 's/SET(OPENJPEG_SVN_REVISION "\([0-9]*\)")/\1/'`
echo "Previous openjpeg sync was on r$PREVIOUS_OPJ_SYNC"

# Files in use
OPJ_PATCH=$OTB_SOURCES/opjpatch-$PREVIOUS_OPJ_SYNC.patch

# Clean up OTB_SOURCES from previous merge.
cd $OTB_SOURCES
find . -name '*.rej' | xargs rm

# Update openjpeg source to the previous sync.
cd $OPJ_SOURCES
svn update -r$PREVIOUS_OPJ_SYNC

# Produce OTB patch.
# TODO: use relative patch to fix the -pN argument of the patch command below.
diff -urw $OPJ_SOURCES $OTB_SOURCES/Utilities/otbopenjpeg > $OPJ_PATCH

# Update openjpeg to the latest revision.
cd $OPJ_SOURCES
svn update
NEW_OPJ_SYNC=`LC_ALL=C svn info | grep '^Revision:' | sed -e 's/^Revision: //'`
echo "We are going to sync on r$NEW_OPJ_SYNC"

# Replace openjpeg in OTB.
cd $OTB_SOURCES
rm -rf Utilities/otbopenjpeg/*

cp -r $OPJ_SOURCES/CMake Utilities/otbopenjpeg/
cp -r $OPJ_SOURCES/libopenjpeg Utilities/otbopenjpeg/
cp $OPJ_SOURCES/* Utilities/otbopenjpeg/

# Some cleanup.
find Utilities/otbopenjpeg -name '.svn' | xargs rm -rf
rm Utilities/otbopenjpeg/Makefile.am
rm Utilities/otbopenjpeg/bootstrap.sh
rm Utilities/otbopenjpeg/configure.ac
rm Utilities/otbopenjpeg/libopenjpeg-jpwl.pc.in
rm Utilities/otbopenjpeg/libopenjpeg1.pc.in

# Add new files in mercurial, remove the old one.
hg status Utilities/otbopenjpeg

# Should be remove when openjpeg add the support for mangling in the opj-trunk
hg revert Utilities/otbopenjpeg/openjpeg_mangle.h.cmake.in
hg revert Utilities/otbopenjpeg/openjpeg_mangle_private.h.cmake.in

hg status Utilities/otbopenjpeg | grep '^! ' | sed -e 's/^! //' | xargs hg rm
hg status Utilities/otbopenjpeg | grep '^? ' | sed -e 's/^? //' | xargs hg add

# if the last command returns nothing, then "hg add" is called without arguments,
# and the OPJ_PATCH file is then added
# revert it (does not harm if file is not managed)
hg revert $OPJ_PATCH

hg commit -m "UTIL: update openjpeg to r$NEW_OPJ_SYNC"

# Apply OTB patch.
patch -p6 < $OPJ_PATCH

# Here you have to fix the conflict manually. Find out what they are:
find . -name '*.rej'
# Check them all, it can be:
# 1. change in OTB that have been integrated in openjpeg => nothing to do
# 2. change in openjpeg that we patched in OTB => nothing to do
# 3. too much openjpeg change around an OTB fix => reapply manually
# If we sync often enough, most of these problem will not appear.

# Once fixed, update openjpeg version number and commit.
sed -i "s/$PREVIOUS_OPJ_SYNC/$NEW_OPJ_SYNC/g" Utilities/otbopenjpeg/CMakeLists.txt
hg commit -m "UTIL: apply otb patch"

# Rebuild OTB and check that all is well, then push.
# It is advised to rm bin/* in the OTB build dir since the .so libraries will change
# Don't forget to update the mangling files !
