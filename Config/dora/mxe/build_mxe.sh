#!/bin/bash

CURDIR=`pwd`
print_usage () {
    echo "Usage   : '$CURDIR/$0' <absolute-path-where-you-cloned-mxe> <perform-git-pull-for-mxe-sources: yes/no>"
    echo "Example : '$CURDIR/$0' /home/rashad/sources/mxe yes"
    exit 1;
    }

if [ $# -eq 1 ]; then
    MXE_DIR=$1
    DO_PULL="yes"
elif [ $# -eq 2 ]; then
    MXE_DIR=$1
    DO_PULL="$2"
else
    print_usage;
fi

echo "CURDIR=$CURDIR"
echo "MXE_DIR=$MXE_DIR"

if [ -d "$MXE_DIR" ]; then
echo 'Assuming mxe is cloned into '$MXE_DIR
else
echo $MXE_DIR' does not exists. Cannot continue...'
exit 1
fi

cd $MXE_DIR
if [ "$DO_PULL" == "yes" ]; then
    echo "sync with https://github.com/rashadkm/mxe"
   GIT_PULL_MASTER='git pull origin master'
   $GIT_PULL_MASTER
fi;

#force clean
#make clean

rm -f /tmp/mxe_build_dora.log
echo 'Sarting build of mxe and dependencies right now.'
#now start building
PKG_LIST="gdal ossim itk qt opencv glfw3 glew freeglut boost qwt_qt4 tinyxml muparser muparserx"
echo "LIST OF PACKAGES="$PKG_LIST
make $PKG_LIST
