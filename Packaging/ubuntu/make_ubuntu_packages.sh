#!/bin/bash
# Script to automate the Orfeo Toolbox library packaging for Ubuntu.
#
# Copyright (C) 2010 CNES - Centre National d'Etudes Spatiales
# Author: Sebastien DINOT <sebastien.dinot@c-s.fr>
#
# The OTB is distributed under the CeCILL license version 2. See files
# Licence_CeCILL_V2-en.txt (english version) or Licence_CeCILL_V2-fr.txt
# (french version) in 'Copyright' directory for details. This licenses are
# also available online:
# http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
# http://www.cecill.info/licences/Licence_CeCILL_V2-fr.txt


SCRIPT_VERSION="1.0"

export DEBFULLNAME="OTB Team"
export DEBEMAIL="contact@orfeo-toolbox.org"

TMPDIR="/tmp"
CMDDIR=`pwd`/`dirname $0`
DEBDIR=`echo $CMDDIR | sed -e 's,^\./,,;s,/\.\?$,,;s,/\./,/,g'`/debian


display_version ()
{
    cat <<EOF

make_ubuntu_packages.sh, version ${SCRIPT_VERSION}
Copyright (C) 2010 CNES (Centre National d'Etudes Spatiales)
by Sebastien DINOT <sebastien.dinot@c-s.fr>

EOF
}


display_help ()
{
    cat <<EOF

This script is used to automate the Orfeo Toolbox library packaging for
Ubuntu.

Usage:
  ./make_ubuntu_packages.sh [options]

Options:
  -h            Display this short help message.

  -v            Display version and copyright informations.

  -d directory  Top directory of the local repository clone

  -r tag        Revision to extract.

EOF
}


check_src_top_dir ()
{
    if [ -z "$topdir" ] ; then
        echo "*** ERROR: missing top directory of the Mercurial working copy (option -d)"
        echo "*** Use ./make_ubuntu_packages.sh -h to show command line syntax"
        exit 3
    fi
    if [ ! -d "$topdir" ] ; then
        echo "*** ERRROR: directory '$topdir' doesn't exist"
        exit 2
    fi
    if [ ! -d "$topdir/.hg" ] ; then
        echo "*** ERRROR: No Mercurial working copy found in '$topdir' directory"
        exit 2
    fi
    if [ "`hg identify $topdir`" == "000000000000 tip" ] ; then
        echo "*** ERROR: Mercurial failed to identify a valid repository in '$topdir'"
        exit 2
    fi
    topdir=`( cd $topdir ; pwd )`
}


check_src_revision ()
{
    if [ -z "$revision" ] ; then
        echo "*** ERROR: missing revision identifier of the repository (option -r)"
        echo "*** Use ./make_ubuntu_packages.sh -h to show command line syntax"
        exit 3
    fi
    olddir=`pwd`
    cd "$topdir"
    if ! hg log -r "$revision" &>/dev/null ; then
        echo "*** ERROR: Revision $revision unknown"
        exit 2
    fi
    cd "$olddir"
}


check_otb_version ()
{
    if [ -z "$version_major" ] ; then
        echo "*** ERROR: missing major version number of OTB (option -m)"
        echo "*** Use ./make_ubuntu_packages.sh -h to show command line syntax"
        exit 3
    fi
    if [ -z "$version_minor" ] ; then
        echo "*** ERROR: missing minor version number of OTB (option -n)"
        echo "*** Use ./make_ubuntu_packages.sh -h to show command line syntax"
        exit 3
    fi
    if [ -z "$version_patch" ] ; then
        echo "*** ERROR: missing patch version number of OTB (option -p)"
        echo "*** Use ./make_ubuntu_packages.sh -h to show command line syntax"
        exit 3
    fi
    version_soname="${version_major}.${version_minor}"
    if [ "`echo $version_patch | sed -e 's/^RC.*$/RC/'`" == "RC" ] ; then
        version_full="${version_major}.${version_minor}-${version_patch}"
    else
        version_full="${version_major}.${version_minor}.${version_patch}"
    fi
    if [ "`echo $version_full | sed -e 's/^[0-9]\+\.[0-9]\+\(\.[0-9]\+\|-RC[0-9]\+\)$/OK/'`" != "OK" ] ; then
        echo "*** ERROR: OTB full version ($version_full) has an unexpected format"
        exit 3
    fi
}


set_ubuntu_code_name ()
{
    case "$1" in
        "natty" )
            ubuntu_codename="Natty Narwhal"
            ubuntu_version="11.04"
            ;;
        "maverick" )
            ubuntu_codename="Maverick Meerkat"
            ubuntu_version="10.10"
            ;;
        "lucid" )
            ubuntu_codename="Lucid Lynx"
            ubuntu_version="10.04 LTS"
            ;;
        "karmic" )
            ubuntu_codename="Karmic Koala"
            ubuntu_version="9.10"
            ;;
        "hardy" )
            ubuntu_codename="Hardy Heron"
            ubuntu_version="08.04 LTS"
            ;;
        * )
            echo "*** ERROR: Unknown Ubuntu version name"
            exit 4
            ;;
    esac
}


echo "Command line checking..."
while getopts ":r:d:m:n:p:hv" option
do
    case $option in
        d ) topdir=$OPTARG
            ;;
        r ) revision=$OPTARG
            ;;
        m ) version_major=$OPTARG
            ;;
        n ) version_minor=$OPTARG
            ;;
        p ) version_patch=$OPTARG
            ;;
        v ) display_version
            exit 0
            ;;
        h ) display_help
            exit 0
            ;;
        * ) echo "*** ERROR: Unknown option -$OPTARG (arg #"$(($OPTIND - 1))")"
            display_help
            exit 0
            ;;
    esac
done

if [ "$OPTIND" -eq 1 ] ; then
    display_help
    exit 1
fi

check_src_top_dir
check_src_revision
check_otb_version

# echo "Debian templates directory: $DEBDIR"
# echo "Working copy directory:     $topdir"
# echo "Major version number:  $version_major"
# echo "Minor version number:  $version_minor"
# echo "Patch version number:  $version_patch"
# echo "Soname version number: $version_soname"
# echo "Full version number:   $version_full"

echo "Archive export..."
cd "$topdir"
hg archive -r "$revision" -t tgz "$TMPDIR/otb-$version_full.tar.gz"

echo "Archive extraction..."
cd "$TMPDIR"
tar xzf "otb-$version_full.tar.gz"
mv "otb-$version_full.tar.gz" "otb_$version_full.orig.tar.gz"

echo "Debian scripts import..."
cd "$TMPDIR/otb-$version_full"
cp -a "$DEBDIR" .
cd debian
for f in control rules ; do
    sed -e "s/@VERSION_MAJOR@/$version_major/g" \
        -e "s/@VERSION_MINOR@/$version_minor/g" \
        -e "s/@VERSION_PATCH@/$version_parch/g" \
        -e "s/@VERSION_SONAME@/$version_soname/g" \
        -e "s/@VERSION_FULL@/$version_full/g" \
        < "$f.in" > "$f"
    rm -f "$f.in"
done
for f in *VERSION_MAJOR* ; do
    g=`echo $f | sed -e "s/VERSION_MAJOR/$version_major/g"`
    mv "$f" "$g"
done
for f in *VERSION_SONAME* ; do
    g=`echo $f | sed -e "s/VERSION_SONAME/$version_soname/g"`
    mv "$f" "$g"
done

echo "Source package generation..."
cd "$TMPDIR/otb-$version_full"
for target in maverick lucid karmic ; do
    set_ubuntu_code_name "$target"
    echo "Package for $ubuntu_codename ($ubuntu_version)"
    cp -f "$DEBDIR/changelog" debian
    dch --force-distribution --distribution "$target" \
        -v "${version_full}-0ppa~${target}" "Automated update for $ubuntu_codename ($ubuntu_version)."
    debuild -k0x46047121 -S -sa --lintian-opts -i
done
