#!/bin/bash


SRCROOT=/home/otbval/Dashboard/src
BUILDROOT=/home/otbval/Dashboard/build
INSTALLROOT=/home/otbval/Dashboard/install

GDAL_SRC=$SRCROOT/gdal-trunk
GDAL_BUILD=$BUILDROOT/gdal-trunk
GDAL_INSTALL=$INSTALLROOT/gdal-trunk

cd $GDAL_SRC
svn update
#svn switch http://svn.osgeo.org/gdal/branches/1.11/gdal/

# clean up build dir
rm -Rf $GDAL_BUILD
rm -Rf $GDAL_INSTALL/*

#extract sources
cd $BUILDROOT
cp -a $GDAL_SRC $GDAL_BUILD

cd $GDAL_BUILD
./configure --prefix=$GDAL_INSTALL \
--with-libtiff=internal \
--with-geotiff=internal \
--with-hide-internal-symbols=yes \
--with-rename-internal-libtiff-symbols=yes \
--with-rename-internal-libgeotiff-symbols=yes \
--without-ogdi \
--without-jasper


#build
make -j8

#install
make install

