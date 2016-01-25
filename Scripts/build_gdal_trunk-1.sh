#!/bin/bash
##gdal build script for pc-christophe.
##this is done weekly

if [ $# -ne 2 ]; then
 echo 'Usage: '$0' <path/to/source> <type>'
 echo 'Usage: '$0' /home/user/sources/ trunk'
 exit;
fi

SRCROOT=$1 #default is /home/otbtesting/sources
BRANCH='trunk' #default: trunk

if [ $# -gt 1 ]; then
    BRANCH=$2
fi

SOURCEDIR=$SRCROOT/gdal/$BRANCH
INSTALLROOT=$HOME/install

cd $SOURCEDIR/gdal
svn update

INSTALLDIR=$INSTALLROOT/gdal/$BRANCH

if [ -d "$INSTALLDIR" ]; then
    # clean up install dir
    /bin/rm -fr $INSTALLDIR/*
else
    mkdir -p $INSTALLDIR
fi

svn info > $INSTALLDIR/gdal_svn_info.txt

make distclean
./configure --prefix=$INSTALLDIR \
    --with-openjpeg=$INSTALLROOT/openjpeg/stable/ \

###start build
make -j3

##install to INSTALLROOT
make install

#go back home.
cd $HOME

