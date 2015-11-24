#!/bin/bash

if [ $# -lt 2 ]; then
 echo 'Usage: '$0' <path/to/source>  <type>'
 echo 'Usage: '$0' /home/user/sources/ trunk'
 exit;
fi

#OLD_BRANCH_NAME=trunk
BRANCH='dev' #default value
SRCROOT=$1 #ossim trunk sources will be sourceroot/ossim-$branch

if [ $# -gt 1 ]; then
    BRANCH=$2
fi

if [ "$BRANCH" == "trunk" ]; then
    echo "Sorry. trunk is now called dev"

    BRANCH="dev"
fi;

if [ $# -gt 2 ]; then
    BUILDROOT=$3
    BUILDDIR=$BUILDROOT/ossim-$BRANCH
    SOURCEDIR=$SRCROOT/ossim-$BRANCH
else
    BUILDROOT=$HOME/build
    BUILDDIR=$BUILDROOT/ossim/$BRANCH
    SOURCEDIR=$SRCROOT/ossim/$BRANCH
fi

#default on pc-christophe. because we cant modify cronjob on that pc

if [ $# -gt 3 ]; then
    INSTALLROOT=$4
    INSTALLDIR=$INSTALLROOT/ossim-$BRANCH
else
    INSTALLROOT=$HOME/install
    INSTALLDIR=$INSTALLROOT/ossim/$BRANCH
fi

if [ -d "$SOURCEDIR" ]; then
    # clean up source dir
    /bin/rm -frv $SOURCEDIR
fi

if [ -d "$BUILDDIR" ]; then
    # clean up build dir
    /bin/rm -frv $BUILDDIR
fi

if [ -d "$INSTALLDIR" ]; then
    # clean up install dir
    /bin/rm -frv $INSTALLDIR
fi

if [ -d "$SOURCEDIR" ]; then
    # clean up install dir
    /bin/rm -frv $SOURCEDIR
fi

mkdir -pv $SOURCEDIR
mkdir -pv $BUILDDIR
mkdir -pv $INSTALLDIR

echo "Cloning branch: $BRANCH"
git clone --depth=50 --branch=$BRANCH https://github.com/ossimlabs/ossim $SOURCEDIR
cd $SOURCEDIR
git fetch
git pull
git ls-remote https://github.com/ossimlabs/ossim HEAD > $BUILDDIR/ossim_svn_info.txt

#configure. all ossimplanet and gui related are disabled
#mpi support is also disabled
cd $BUILDDIR
cmake $SOURCEDIR \
    -DCMAKE_MODULE_PATH=$SOURCEDIR/cmake/CMakeModules \
    -DCMAKE_INSTALL_PREFIX:STRING=$INSTALLDIR \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DBUILD_OSSIM_FRAMEWORKS:BOOL=OFF \
    -DBUILD_OSSIM_FREETYPE_SUPPORT:BOOL=ON \
    -DBUILD_OSSIM_ID_SUPPORT:BOOL=ON \
    -DBUILD_OSSIM_MPI_SUPPORT:BOOL=OFF \
    -DBUILD_OSSIM_APPS:BOOL=OFF \
    -DBUILD_OSSIM_TESTS:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON

#build
make -j8

#install to $INSTALLDIR
make install

#just echo
echo "SOURCEDIR=$SOURCEDIR"
echo "BUILDDIR=$BUILDDIR"
echo "INSTALLDIR=$INSTALLDIR"
