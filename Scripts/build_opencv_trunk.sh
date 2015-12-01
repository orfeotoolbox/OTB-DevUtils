#!/bin/bash

set -o nounset

# Right now we consider that
#    stable = 2.4
#    trunk  = master
# because OTB is not yet compatible with opencv 3.0
# See mantis bug #956 at
# http://bugs.orfeo-toolbox.org/view.php?id=956

if [ $# -ne 3 ]; then
 echo 'Usage: '$0' <path/to/source>  <branch> <buildtype>'
 echo 'Usage: '$0' /home/user/sources/ 2.4 stable'
 exit;
fi

SRCROOT=$1 # Location of source dir, e.g. /home/otbtesting/sources
BRANCH=$2 # Branch, e.g master or 2.4
BUILDTYPE=$3 # trunk or stable

SOURCEDIR=$SRCROOT/opencv/$BUILDTYPE
BUILDDIR=$HOME/build/opencv/$BUILDTYPE
INSTALLROOT=$HOME/install

echo "Building OpenCV."
echo 'Source Dir='$SOURCEDIR
echo 'Build Dir='$BUILDDIR
echo 'Install Dir='$INSTALLROOT

cd $SOURCEDIR
git pull origin $BRANCH
rm -fr $INSTALLROOT/opencv/$BUILDTYPE

# Clean up build dir
if [ -d "$BUILDDIR" ]; then
    /bin/rm -fr $BUILDDIR
fi

mkdir -p $BUILDDIR
mkdir -p $INSTALLROOT

# Configure, build and install
cd $BUILDDIR
cmake $SOURCEDIR \
    -DCMAKE_INSTALL_PREFIX:STRING=$INSTALLROOT/opencv/$BUILDTYPE \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DBUILD_PACKAGE:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON

make -j4
make install
