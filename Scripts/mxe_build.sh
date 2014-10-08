#!/bin/sh
# 07-10-2014: merge commits from parent
# ** clean mxe
# ** disable pull
#08-10-2014:resume routine build with pull
# **

MXE_DIR='/home/otbtesting/win-sources/mxe'
if [ $# -eq 3 ]; then
MXE_DIR=$1
MXE_TARGET=$2
DO_PULL=$3
else
echo 'Usage: '$0' <path/to/mxe> <mxe-target> <git-pull>'
echo 'Ex: '$0' ~/win-sources/mxe/ i686-pc-mingw32.shared yes'
exit 1
fi

cd $MXE_DIR
#clean mxe due to merge(parent)-push
if [ "$DO_PULL" == "yes" ]; then
   GIT_PULL_MASTER='git pull origin master'
$GIT_PULL_MASTER
fi;
echo 'MXE_TARGET='$MXE_TARGET
echo 'Sarting build of mxe and dependencies right now.'
#now start building
echo 'LIST OF GOALS=expat zlib libpng jpeg xz tiff openjpeg gdal openthreads geos ossim itk qt opencv glfw3 glew freeglut boost qwt_qt4 fltk'
make MXE_TARGETS="$MXE_TARGET" expat zlib libpng jpeg xz tiff openjpeg gdal openthreads geos ossim itk qt opencv glfw3 glew freeglut boost qwt_qt4 fltk
