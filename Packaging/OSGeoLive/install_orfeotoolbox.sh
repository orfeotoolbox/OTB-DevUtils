#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".

# About:
# =====
# This script will install orfeo toolbox

# Running:
# =======
# sudo ./install_orfeotoolbox.sh

# Install orfeo toolbox
sudo aptitude -y install add-apt-repository  
sudo add-apt-repository ppa:otb/orfeotoolbox-stable

sudo aptitude -y update  
sudo aptitude install -y otb otbapp monteverdi

# live disc's username is "user"
DATA_DIR=$USER_HOME/gisvm/app-data/orfeotoolbox
ORFEO_DATA=/usr/local/share/orfeotoolbox

# Download OrfeoToolBox data
[ -d $DATA_DIR ] || mkdir $DATA_DIR
[ -f $DATA_DIR/OTBSoftwareGuide.pdf ] || \
   wget -c "http://www.orfeo-toolbox.org/packages/OTBSoftwareGuide.pdf" \
     -O $DATA_DIR/OTBSoftwareGuide.pdf
[ -f $DATA_DIR/OTB-Data-Examples.tgz ] || \
   wget -c "http://www.orfeo-toolbox.org/packages/OTB-Data-Examples.tgz" \
     -O $DATA_DIR/OTB-Data-Examples.tgz

# Install docs and demos
if [ ! -d $ORFEO_DATA ]; then
    mkdir -p $ORFEO_DATA/demos
    echo -n "Extracting MapServer html doc in $MAPSERVER_DATA/....."
    mv $DATA_DIR/OTBSoftwareGuide.pdf $MAPSERVER_DATA/

    echo -n "Done\nExtracting orfeo data examples $MAPSERVER_DATA/demos/..."
    tar -xzvf -q $DATA_DIR/OTB-Data-Examples.tgz -d $ORFEO_DATA/demos/ 
    echo -n "Done\n"
fi

#TODO
#Add Launch icon to desktop
#What Icon should be used?
