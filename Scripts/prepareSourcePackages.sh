#!/bin/bash
# Script to produce source archives of the following repositories:
#   OTB , Monteverdi , OTB-Wrapping , OTB-Applications
# The last tag  will be used.
# Input : 
#     - CLONES_ROOT_DIR : a directory containg clones of all the above listed projects
#     - OUTPUT_DIR : a directory to place the generated archives.

if [ $# -lt 2 ] ; then
  echo "Usage : $0 CLONES_ROOT_DIR  OUTPUT_DIR"
  exit 0
fi

CLONE_DIR=`readlink -f $1`
OUT_DIR=`readlink -f $2`

for project in OTB Monteverdi Monteverdi2 OTB-Applications OTB-Wrapping ; do
  cd $CLONE_DIR/$project
  
  hg pull -u
  
  # Extract last tagged version identifier
  full_version=$(hg tags | head -n 2 | tail -n 1 | cut -d ' ' -f 1)
  #echo "$project : $full_version"
  
  case $project in
    OTB)
      pkg_name=OTB
      ;;
    Monteverdi)
      pkg_name=Monteverdi
      ;;
    Monteverdi2)
      pkg_name=Monteverdi2
      ;;
    OTB-Applications)
      pkg_name=OTB-Applications
      ;;
    OTB-Wrapping)
      pkg_name=OTB-Wrapping
      ;;
  esac
  
  hg archive -t zip -r $full_version $OUT_DIR/$pkg_name-$full_version.zip
  hg archive -t tgz -r $full_version $OUT_DIR/$pkg_name-$full_version.tgz

done
