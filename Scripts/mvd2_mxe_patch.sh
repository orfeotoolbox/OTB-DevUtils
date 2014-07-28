#!/bin/sh

MVD2_SRC_DIR="/home/otbtesting/sources/orfeo/trunk/Monteverdi2"
cd $MVD2_SRC_DIR

if [ $1 == "patch" ]; then
echo 'Patching Code/Application/Monteverdi2/CMakeLists.txt'
cd Code/Application/Monteverdi2
sed -i '/\Monteverdi2_Catalogue_WIN32_RC_FILE /s%\Monteverdi2_Catalogue_WIN32_RC_FILE .*%Monteverdi2_Catalogue_WIN32_RC_FILE mvdWin32.rc )%g' 'CMakeLists.txt'
else
echo 'Reverting Code/Application/Monteverdi2/CMakeLists.txt'
hg revert Code/Application/Monteverdi2/CMakeLists.txt
fi
