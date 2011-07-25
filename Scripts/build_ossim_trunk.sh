#!/bin/bash

SRCROOT=/home/otbval/Dashboard/src
BUILDROOT=/home/otbval/Dashboard/build
INSTALLROOT=/home/otbval/Dashboard/install

OSIM_VER=dev
OSSIM_SRC=$SRCROOT/ossim-trunk
OSSIM_BUILD=$BUILDROOT/ossim-trunk
OSSIM_INSTALL=$INSTALLROOT/ossim-trunk
OSSIM_DEV_HOME=$OSSIM_SRC

#update src
cd $OSSIM_SRC
svn update

# clean up build dir
rm -Rf $OSSIM_BUILD/*
rm -Rf $OSSIM_INSTALL/*

#configure
cd $OSSIM_BUILD
cmake $OSSIM_SRC/ossim_package_support/cmake \
      -DOSSIM_DEV_HOME:STRING=$OSSIM_DEV_HOME \
      -DCMAKE_INSTALL_PREFIX:STRING=$OSSIM_INSTALL \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DBUILD_CSMAPI:BOOL=OFF \
      -DBUILD_OSSIMCSM_PLUGIN:STRING=OFF \
      -DCMAKE_CXX_FLAGS:STRING=-D__STDC_CONSTANT_MACROS \
      -DWMS_INCLUDE_DIR:STRING=$OSSIM_SRC/libwms/include \
      -DBUILD_OSSIMPREDATOR:BOOL=OFF

#build
make -j8

#install
make install
