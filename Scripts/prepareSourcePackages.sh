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

#for project in OTB Monteverdi Monteverdi2 Ice ; do
for project in OTB Ice Monteverdi2; do
  cd $CLONE_DIR/$project
  
  # Extract last tagged version identifier
  full_version=$(git tag | grep -E '[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1)
  #echo "$project : $full_version"

  case $project in
    OTB)
      pkg_name=OTB
      ;;
    Monteverdi2)
      pkg_name=Monteverdi
      ;;
    Ice)
      pkg_name=Ice
      ;;
  esac
  
  echo Generating $OUT_DIR/$pkg_name-$full_version.zip
  git archive --format=zip -o $OUT_DIR/$pkg_name-$full_version.zip --prefix=$pkg_name-$full_version/ $full_version
  echo Generating $OUT_DIR/$pkg_name-$full_version.tar.gz
  git archive --format=tgz -o $OUT_DIR/$pkg_name-$full_version.tar.gz --prefix=$pkg_name-$full_version/ $full_version

  git config tar.tar.xz.command "xz -c"
  echo Generating $OUT_DIR/$pkg_name-$full_version.tar.xz
  git archive --format=tar.xz -o $OUT_DIR/$pkg_name-$full_version.tar.xz --prefix=$pkg_name-$full_version/ $full_version
done
