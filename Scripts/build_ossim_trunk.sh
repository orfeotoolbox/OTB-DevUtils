#!/bin/bash

if [ $# -ne 2 ]; then
 echo 'Usage: '$0' <path/to/source>  <type>'
 echo 'Usage: '$0' /home/user/sources/ trunk'
 exit;
fi

SRCROOT=$1 #default is /home/otbtesting/sources
TYPE=$2 #default: trunk

SOURCEDIR=$SRCROOT/ossim/$TYPE
BUILDDIR=$HOME/build/ossim/$TYPE
INSTALLROOT=$HOME/install

cd $SOURCEDIR/ossim
svn up

cd $SOURCEDIR/ossim_package_support
svn up


if [ -d "$BUILDDIR" ]; then
    # clean up build dir
    /bin/rm -fr $BUILDDIR/*
else
    mkdir $BUILDDIR
fi

#configure. all ossimplanet and gui related are disabled
#mpi support is also disabled
cd $BUILDDIR
cmake $SOURCEDIR/ossim \
    -DCMAKE_MODULE_PATH=$SOURCEDIR/ossim_package_support/cmake/CMakeModules \
    -DCMAKE_INSTALL_PREFIX:STRING=$INSTALLROOT/ossim/$TYPE \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DBUILD_OSSIM_FRAMEWORKS:BOOL=ON \
    -DBUILD_OSSIM_FREETYPE_SUPPORT:BOOL=ON \
    -DBUILD_OSSIM_ID_SUPPORT:BOOL=ON \
    -DBUILD_OSSIM_MPI_SUPPORT:BOOL=OFF \
    -DBUILD_OSSIM_TEST_APPS:BOOL=ON \
    -DBUILD_SHARED_LIBS:BOOL=ON

#build
make -j8

#install to $INSTALLROOT
make install
