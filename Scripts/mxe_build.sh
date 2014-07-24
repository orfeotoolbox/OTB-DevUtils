#!/bin/sh

MXE_DIR='/home/otbtesting/win-sources/mxe'
if [ $# -eq 1 ]; then
MXE_DIR=$1;
fi

cd $MXE_DIR
#TODO try to pull from github ?
#git pull origin master
make gdal openthreads geos ossim itk qt opencv glfw3 glew freeglut boost expat qwt_qt4
