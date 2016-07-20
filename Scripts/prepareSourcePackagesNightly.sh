#!/bin/bash
# Script to produce source archives of the following repositories:
#   OTB , Monteverdi
# The branch used are develop and the latest release branch.
# Input : 
#     - CLONES_ROOT_DIR : a directory containg clones of all the above listed projects
#     - OUTPUT_DIR : a directory to place the generated archives.
# In addition, the OTB-Data repository is used to generate the OTB-Data-Example archive
# using the latest release branch

if [ $# -lt 2 ] ; then
  echo "Usage : $0 CLONES_ROOT_DIR  OUTPUT_DIR"
  exit 0
fi

CLONE_DIR=`readlink -f $1`
OUT_DIR=`readlink -f $2`

for project in OTB Monteverdi2; do
  cd $CLONE_DIR/$project
  # update
  git fetch
  
  # Extract latest release branch
  latest_release=$(git branch -r | grep -E -o 'release-[0-9]+\.[0-9]+$' | tail -n 1)
  # extract abbreviated commit id
  hash_develop=$(git log -1 --format=format:%h origin/develop)
  hash_release=$(git log -1 --format=format:%h origin/${latest_release})
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

  # configure for tar.xz
  git config tar.tar.xz.command "xz -c"

  for format in zip tar.gz tar.xz; do
    # develop
    echo Generating $OUT_DIR/$pkg_name-develop-$hash_develop.$format
    git archive --format=$format -o $OUT_DIR/$pkg_name-develop-$hash_develop.$format --prefix=$pkg_name-develop/ origin/develop
    # latest release
    echo Generating $OUT_DIR/$pkg_name-$latest_release-$hash_release.$format
    git archive --format=$format -o $OUT_DIR/$pkg_name-$latest_release-$hash_release.$format --prefix=$pkg_name-$latest_release/ origin/$latest_release
  done
  
done

# Generate OTB-Data-Example
cd $CLONE_DIR/OTB-Data
# Extract latest release branch
latest_release=$(git branch -r | grep -E -o 'release-[0-9]+\.[0-9]+$' | tail -n 1)
for format in zip tgz; do
  # latest release
  echo Generating $OUT_DIR/OTB-Data-Examples.$format
  git archive --format=$format -o $OUT_DIR/OTB-Data-Examples.$format origin/$latest_release Examples
done
