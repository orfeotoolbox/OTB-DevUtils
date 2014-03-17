#!/bin/bash

if [ $# -ne 3 ]; then
 echo 'Usage: $0 <source-dir> <package-name> <install-dir>'
 echo 'Usage: $0 /home/user/sources/ opencv_trunk /home/user/local'
 exit;
fi

SOURCEROOT=$1
PACKAGE=$2
INSTALLROOT=$3

PACKAGE_SRC=$SOURCEROOT'/'$PACKAGE
PACKAGE_BUILD=$SOURCEROOT'/build-'$PACKAGE
PACKAGE_INSTALL=$INSTALLROOT'/'$PACKAGE'-install'

#update src
cd $PACKAGE_SRC
git pull

if [ -d "$PACKAGE_BUILD" ]; then
    # clean up build dir
    command="rm -fr $PACKAGE_BUILD"
    echo $command
else
    mkdir $PACKAGE_BUILD
fi
if [ -d "$PACKAGE_INSTALL" ]; then
    # clean up install dir
    command="rm -f $PACKAGE_INSTALL"
    echo $command
else
    mkdir $PACKAGE_INSTALL
fi

echo 'PACKAGE_SRC='$PACKAGE_SRC
echo 'PACKAGE_BUILD='$PACKAGE_BUILD
echo 'PACKAGE_INSTALL='$PACKAGE_INSTALL
#configure opencv
cd $PACKAGE_BUILD
cmake $PACKAGE_SRC \
    -DCMAKE_INSTALL_PREFIX:STRING=$PACKAGE_INSTALL \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DBUILD_PACKAGE:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON

#build
make -j8

#install to $PACKAGE_INSTALL
make install
