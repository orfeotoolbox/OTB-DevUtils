#!/bin/bash

if [ $# -ne 2 ]; then
 echo 'Usage: $0 <path/to/ossim_trunk> <install-dir>'
 echo 'Usage: $0 /home/user/sources/ /home/rashad/'
 exit;
fi


OSSIM_REPOSITORY_ROOT=$1'/ossim_trunk'
INSTALLROOT=$2
OSSIM_BUILD=$1/build-ossim
OSSIM_INSTALL=$INSTALLROOT/ossim-install

OSSIM_SRC=$OSSIM_REPOSITORY_ROOT/ossim

#update src
cd $OSSIM_REPOSITORY_ROOT
svn update

if [ -d "$OSSIM_BUILD" ]; then
    # clean up build dir
    command="rm -f $OSSIM_BUILD/CMakeCache.txt;rm -fr $OSSIM_BUILD/CMakeFiles"
    echo $command
else
    mkdir $OSSIM_BUILD
fi
if [ -d "$OSSIM_INSTALL" ]; then
    # clean up install dir
    command="rm -f $OSSIM_INSTALL/include; rm -fr $OSSIM_INSTALL/lib"
    echo $command
else
    mkdir $OSSIM_INSTALL
fi

#configure. all ossimplanet and gui related are disabled
#mpi support is also disabled
cd $OSSIM_BUILD
cmake $OSSIM_SRC \
    -DCMAKE_MODULE_PATH=$OSSIM_REPOSITORY_ROOT/ossim_package_support/cmake/CMakeModules \
    -DCMAKE_INSTALL_PREFIX:STRING=$OSSIM_INSTALL \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DBUILD_OSSIM_FRAMEWORKS:BOOL=ON \
    -DBUILD_OSSIM_FREETYPE_SUPPORT:BOOL=ON \
    -DBUILD_OSSIM_ID_SUPPORT:BOOL=ON \
    -DBUILD_OSSIM_MPI_SUPPORT:BOOL=OFF \
    -DBUILD_OSSIM_TEST_APPS:BOOL=ON \
    -DBUILD_SHARED_LIBS:BOOL=ON

#build
make -j8

#install to $OSSIM_INSTALL
make install
