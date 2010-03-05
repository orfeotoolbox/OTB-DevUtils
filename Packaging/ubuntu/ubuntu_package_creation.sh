#!/bin/bash

# variables

otb_version=$1
otb_source_tgz=OrfeoToolbox-$otb_version.tgz
cd /home/grizonnetm/OTB/Dev/Packages/OTB_$otb_version

# the directory architecture needed is :
#Process --the directory where all pbuilder and dhmake configuration are done
#Src source of otb (from sourceforge)
#Results --the result packages 
#Config_Files -- cmake configuration rules, control - base files for packaging (that's here where we define the configuration)

#remove all the process files
rm -rf Process/*

#Go to the source directory and make a copy of the otb tgz source 
cd Src/ 
cp -r $otb_source_tgz ../Process/orfeotoolbox-$otb_version.tar.gz
#tar -czvf orfeotoolbox-$otb_version.tar.gz orfeotoolbox-$otb_version/*

#Let's begin the process of packaging
#create first a src.orig.tar.gz to follow linux convention
cd ../Process
cp orfeotoolbox-$otb_version.tar.gz orfeotoolbox_$otb_version.orig.tar.gz 
tar -xzvf orfeotoolbox_$otb_version.orig.tar.gz 

#rename the directory (remove upper case) - follow paul novotny method #TODO do this during release packaging on sourceforge 
mv OrfeoToolbox-$otb_version orfeotoolbox-$otb_version
cd orfeotoolbox-$otb_version/


#dh_make execution with GNU encryption GPASS
#need to create first a encryption password (see doc). The dh_majke is going to ask for a passphrase to sign package
dh_make -e manuel.grizonnet@cnes.fr

#TODO change the changelog file in the debian directory!!!
#Need to concatenate  the otb changelog 

#cp RELEASE_NOTES.txt ../../Config_Files
#cd ../../Config_Files
#cat RELEASE_NOTES.txt changelog_base > changelog

# Gg to config file directory to copy control,rule,copyright and makefile to the package
cd ../../Config_Files
cp rules control copyright CMakeCache.txt.debian ../Process/orfeotoolbox-$otb_version/debian
#after that , we are able to update the package and try to compile it with 
#building all

#Need to add multiverse component to pbuilder
#TODO : insert this step in the script
#add universe to repository!!!
#COMPONENTS="main restricted universe multiverse"


#Begin the building from scratch (see th eguide for packageion on ubuntu documentation)
cd ../Process/
cd orfeotoolbox-$otb_version/
debuild -S
sudo pbuilder update --override-config
sudo pbuilder build ../*.dsc

#copy packages (if exist) to the result directory
cd ../Results/
res_dir=Res_Pbuilder_$DATE
mkdir $res_dir
cd $res_dir
cp -r /var/cache/pbuilder/result/* .

#exit now
#result of the packaging are in /var/cache/pbuilder/result/ and in Results
cd ../..

exit 0
