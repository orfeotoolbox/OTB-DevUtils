#!/bin/sh
# 07-10-2014: merge commits from parent
# ** clean mxe
# ** disable pull
# 08-10-2014: resume routine build with pull
# **
# 25-10-2014: update mxe sources.
# ** use mingw-w64 toolchain for x86 target
# ** clean mxe. rebuild all 

MXE_DIR='/home/otbtesting/win-sources/mxe'
if [ $# -eq 3 ]; then
MXE_DIR=$1
MXE_TARGET=$2
DO_PULL=$3
else
echo 'Usage: '$0' <path/to/mxe> <mxe-target> <git-pull>'
echo 'Ex: '$0' ~/win-sources/mxe/ i686-w64-mingw32.shared yes'
exit 1
fi

cd $MXE_DIR
if [ "$DO_PULL" == "yes" ]; then
   GIT_PULL_MASTER='git pull origin master'
$GIT_PULL_MASTER
fi;

echo 'MXE_TARGET='$MXE_TARGET
echo 'Sarting build of mxe and dependencies right now.'
#now start building
echo 'LIST OF GOALS=gdal ossim itk qt opencv glfw3 glew freeglut boost qwt5_qt4 fltk'
make MXE_TARGETS="$MXE_TARGET" gdal ossim itk qt opencv glfw3 glew freeglut boost qwt5_qt4 fltk tinyxml muparser
