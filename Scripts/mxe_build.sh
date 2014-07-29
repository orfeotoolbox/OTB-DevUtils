#!/bin/sh

MXE_DIR='/home/otbtesting/win-sources/mxe'
if [ $# -eq 3 ]; then
MXE_DIR=$1
DO_PULL=$2
MXE_TARGETS=$3
elif [ $# -eq 2 ]; then
MXE_DIR=$1
DO_PULL=$2
MXE_TARGETS='i686-pc-mingw32.shared x86_64-w64-mingw32.shared'
else
echo 'Usage: '$0' <path/to/mxe> <git-pull> <mxe-target>'
echo 'Ex: '$0' ~/win-sources/mxe yes i686-pc-mingw32'
fi

if [ "$MXE_TARGETS" == "all" ]; then
  MXE_TARGETS='i686-pc-mingw32.shared x86_64-w64-mingw32.shared'
fi;

cd $MXE_DIR

if [ "$DO_PULL" == "yes" ]; then
   GIT_PULL_MASTER='git pull origin master'
  $GIT_PULL_MASTER
fi;
echo 'MXE_TARGETS='$MXE_TARGETS
echo 'Sarting build of mxe and dependencies right now.'
#now start building
make MXE_TARGETS="$MXE_TARGETS" gdal openthreads geos ossim itk qt opencv glfw3 glew freeglut boost expat qwt_qt4
