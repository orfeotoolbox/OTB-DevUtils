#!/bin/bash


OPENJPEG_INSTALL_DIR=$HOME/Dashboard/install/openjpeg_trunk
GDAL_TRUNK_SRC_DIR=$HOME/Dashboard/src/gdal-trunk
OUTPUT_DIR=$HOME/Dashboard/install/gdal-openjpeg-plugin

g++ -fPIC -g -Wall $GDAL_TRUNK_SRC_DIR/frmts/openjpeg/openjpegdataset.cpp -shared -o $OUTPUT_DIR/gdal_JP2OpenJPEG.so -I/usr/include/gdal -I$OPENJPEG_INSTALL_DIR/include/openjpeg-2.0 -L. -lgdal -L$OPENJPEG_INSTALL_DIR/lib -lopenjp2

