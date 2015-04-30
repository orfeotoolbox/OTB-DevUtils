#!/bin/bash
##gdal build script for pc-christophe.
##this is done weekly

if [ $# -ne 2 ]; then
 echo 'Usage: '$0' <path/to/source> <type>'
 echo 'Usage: '$0' /home/user/sources/ trunk'
 exit;
fi

SRCROOT=$1 #default is /home/otbtesting/sources
TYPE=$2 #default: trunk

SOURCEDIR=$SRCROOT/gdal/$TYPE
INSTALLROOT=$HOME/install

cd $SOURCEDIR/gdal
#FIXME: update to gdal trunk. Why branch 1.11? Refer mantis:937
svn switch http://svn.osgeo.org/gdal/branches/1.11/gdal/

make distclean
./configure --prefix=$INSTALLROOT/gdal/$TYPE \
    --with-openjpeg=$INSTALLROOT/openjpeg/stable/ \
    --with-libkml=/usr/local
    --with-libkml-inc=/usr/local/include \
    --with-libkml-lib=-L/usr/local

###start build
make -j3

##install to INSTALLROOT
make install

#go back home.
cd $HOME

