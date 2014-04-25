#!/bin/bash

if [ $# -ne 1 ]; then
 echo 'Usage: '$0' <source-dir>'
 echo 'Usage: '$0' /home/user/sources/opencv_trunk'
 exit;
fi

SOURCEROOT=$1
INSTALLROOT=$HOME/install
PACKAGE_BUILD=$HOME'/build/opencv_'

#update src
cd $SOURCEROOT
git pull

if [ -d "$PACKAGE_BUILD" ]; then
    # clean up build dir
    /bin/rm -fr $PACKAGE_BUILD
else
    mkdir $PACKAGE_BUILD
fi

echo 'PACKAGE_SRC='$SOURCEROOT
echo 'PACKAGE_BUILD='$PACKAGE_BUILD
echo 'PACKAGE_INSTALL='$INSTALLROOT

#configure opencv
cd $PACKAGE_BUILD
cmake $PACKAGE_SRC \
    -DCMAKE_INSTALL_PREFIX:STRING=$INSTALLROOT \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DBUILD_PACKAGE:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON

#build
make -j8

#install to $INSTALLROOT
make install
