#!/bin/bash

if [ $# -ne 1 ]; then
 echo 'Usage: '$0' <path/to/ossim_trunk>'
 echo 'Usage: '$0' /home/user/sources/ossim'
 exit;
fi


OSSIM_REPOSITORY_ROOT=$1
INSTALLROOT=$HOME/install
BUILDROOT=$HOME/build
OSSIM_BUILD=$BUILDROOT/ossim_
OSSIM_SRC=$OSSIM_REPOSITORY_ROOT/ossim

#update src
cd $OSSIM_REPOSITORY_ROOT
svn update

if [ -d "$OSSIM_BUILD" ]; then
    # clean up build dir
    /bin/rm -fr $OSSIM_BUILD/*
else
    mkdir $OSSIM_BUILD
fi
echo 'OSSIM_SRC='$OSSIM_SRC
echo 'OSSIM_BUILD='$OSSIM_BUILD
echo 'OSSIM_INSTALL='$INSTALLROOT


#configure. all ossimplanet and gui related are disabled
#mpi support is also disabled
cd $OSSIM_BUILD
cmake $OSSIM_SRC \
    -DCMAKE_MODULE_PATH=$OSSIM_REPOSITORY_ROOT/ossim_package_support/cmake/CMakeModules \
    -DCMAKE_INSTALL_PREFIX:STRING=$INSTALLROOT \
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
