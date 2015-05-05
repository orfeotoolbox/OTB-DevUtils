#!/bin/bash

if [ $# -lt 2 ]; then
 echo 'Usage: '$0' <path/to/source>  <type>'
 echo 'Usage: '$0' /home/user/sources/ trunk'
 exit;
fi

BRANCH='trunk' #default
SRCROOT=$1 #ossim trunk sources will be sourceroot/ossim-$branch

if [ $# -gt 1 ]; then
    BRANCH=$2
fi

if [ $# -gt 2 ]; then
    BUILDROOT=$3
fi

#default on pc-christophe. because we cant modify cronjob there
INSTALLROOT=$HOME/install
if [ $# -gt 3 ]; then
    INSTALLROOT=$4
fi

#hulk
#OSSIM_VERSION=dev
SOURCEDIR=$SRCROOT/ossim-$BRANCH
BUILDDIR=$BUILDROOT/ossim-$BRANCH
INSTALLDIR=$INSTALLROOT/ossim-$BRANCH

if [ -d "$SOURCEDIR" ]; then
    # update sources
    cd $SOURCEDIR/ossim
    svn up

    cd $SOURCEDIR/ossim_package_support
    svn up
else
    #create source dir.
    mkdir -p $SOURCEDIR
    cd $SOURCEDIR
    svn co http://svn.osgeo.org/ossim/trunk/ossim
    svn co http://svn.osgeo.org/ossim/trunk/ossim_package_support
fi

if [ -d "$BUILDDIR" ]; then
    # clean up build dir
    /bin/rm -fr $BUILDDIR
else
    mkdir -p $BUILDDIR
fi

if [ -d "$INSTALLDIR" ]; then
    # clean up install dir
    /bin/rm -fr $INSTALLDIR
else
    mkdir -p $INSTALLDIR
fi

echo "SOURCEDIR=$SOURCEDIR"
echo "BUILDDIR=$BUILDDIR"
echo "INSTALLDIR=$INSTALLDIR"

#configure. all ossimplanet and gui related are disabled
#mpi support is also disabled
cd $BUILDDIR
cmake $SOURCEDIR/ossim \
    -DCMAKE_MODULE_PATH=$SOURCEDIR/ossim_package_support/cmake/CMakeModules \
    -DCMAKE_INSTALL_PREFIX:STRING=$INSTALLDIR \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DBUILD_OSSIM_FRAMEWORKS:BOOL=ON \
    -DBUILD_OSSIM_FREETYPE_SUPPORT:BOOL=ON \
    -DBUILD_OSSIM_ID_SUPPORT:BOOL=ON \
    -DBUILD_OSSIM_MPI_SUPPORT:BOOL=OFF \
    -DBUILD_OSSIM_TEST_APPS:BOOL=ON \
    -DBUILD_SHARED_LIBS:BOOL=ON

#build
make -j8

#install to $INSTALLDIR
make install
