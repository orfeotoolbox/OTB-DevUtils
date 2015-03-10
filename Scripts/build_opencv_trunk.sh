#!/bin/bash
##07-oct-2014: checkout 2.4 branch instead of trunk 
###ref mantis bug #956
### http://bugs.orfeo-toolbox.org/view.php?id=956

if [ $# -ne 2 ]; then
 echo 'Usage: '$0' <path/to/source>  <type>'
 echo 'Usage: '$0' /home/user/sources/ trunk'
 exit;
fi

SRCROOT=$1 #default is /home/otbtesting/sources
TYPE=$2 #default: trunk

SOURCEDIR=$SRCROOT/opencv/$TYPE
BUILDDIR=$HOME/build/opencv/$TYPE
INSTALLROOT=$HOME/install

cd $SOURCEDIR
#git pull origin master
git checkout -b 2.4
rm -fr $INSTALLROOT/opencv/$TYPE

if [ -d "$BUILDDIR" ]; then
    # clean up build dir
    /bin/rm -fr $BUILDDIR
else
    mkdir $BUILDDIR
fi

echo 'Source Dir='$SOURCEDIR
echo 'Build Dir='$BUILDDIR
echo 'Install Dir='$INSTALLROOT

#configure opencv
cd $BUILDDIR
cmake $SOURCEDIR \
    -DCMAKE_INSTALL_PREFIX:STRING=$INSTALLROOT/opencv/$TYPE \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DBUILD_PACKAGE:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON

#build
make -j8

#install to $INSTALLROOT
make install
