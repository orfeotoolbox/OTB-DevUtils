#!/bin/sh

MXE_DIR='/home/otbtesting/win-sources/mxe'
if [ $# -eq 1 ]; then
MXE_DIR=$1;
fi

if [ $# -eq 2 ]; then
DO_PULL=$2;
fi

cd $MXE_DIR

if [ "$DO_PULL" == "yes" ]; then
  echo 'Pull from git master'
  GIT_PULL_MASTER='git pull origin master'
  $GIT_PULL_MASTER
fi;

#now start building
make gdal openthreads geos ossim itk qt opencv glfw3 glew freeglut boost expat qwt_qt4
