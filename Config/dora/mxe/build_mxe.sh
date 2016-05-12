#!/bin/bash

print_usage () {
    echo "Usage   : '$0' <absolute-path-where-you-cloned-mxe> <perform-git-pull-for-mxe-sources: yes/no>"
    echo "Example : '$0' /home/rashad/sources/mxe yes"
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
PKG_LIST="gdal ossim itk glfw3 glew freeglut boost tinyxml muparser muparserx libsvm"
echo "LIST OF PACKAGES=$PKG_LIST"
make $PKG_LIST

PKG_PLUGINS_LIST="qt opencv"
echo "LIST OF PLUGIN PACKAGES=$PKG_PLUGINS_LIST"
make qt MXE_PLUGIN_DIRS='plugins/qt4'
make opencv MXE_PLUGIN_DIRS='plugins/opencv'

#why here?. build only after qt4
make qwt5_qt4
