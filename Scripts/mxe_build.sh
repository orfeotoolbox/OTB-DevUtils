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

#we moved on to mingw-w64 project. why?.
#seems like mingw64 has better support and mingw
#and it has both 32bit and 64bit targets. Things are good and
#easier in mingw64

if [ "$MXE_TARGET" == "i686-pc-mingw32.shared" ]; then
   MXE_TARGET='i686-w64-mingw32.shared'
fi;

cd $MXE_DIR
#clean mxe due to merge(parent)-push
#temp setup to clean mxe targets on otbtesting?
make clean
git pull origin master

if [ "$DO_PULL" == "yes" ]; then
   GIT_PULL_MASTER='git pull origin master'
$GIT_PULL_MASTER
fi;

echo 'MXE_TARGET='$MXE_TARGET
echo 'Sarting build of mxe and dependencies right now.'
#now start building
echo 'LIST OF GOALS=gdal ossim itk qt opencv glfw3 glew freeglut boost qwt5_qt4 fltk'
make MXE_TARGETS="$MXE_TARGET" gdal ossim itk qt opencv glfw3 glew freeglut boost qwt5_qt4 fltk
