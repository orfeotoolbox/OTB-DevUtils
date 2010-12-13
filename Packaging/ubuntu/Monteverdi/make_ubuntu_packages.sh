#!/bin/bash
# Script to automate the Orfeo Toolbox library packaging for Ubuntu.
#
# Copyright (C) 2010 CNES - Centre National d'Etudes Spatiales
# by Sebastien DINOT <sebastien.dinot@c-s.fr>
#
# Monteverdi OTB is distributed under the CeCILL license version 2. See files
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

This script is used to automate the Monteverdi workshop packaging for
Ubuntu. Source packages are created in ${TMPDIR} directory.

Usage:
  ./make_ubuntu_packages.sh [options]

Options:
  -h            Display this short help message.

  -v            Display version and copyright informations.

  -d directory  Top directory of the local repository clone

  -r tag        Revision to extract.

  -m version    Version value of Monteverdi

  -o version    Version value of OTB

Example:
  ./make_ubuntu_packages.sh -d ~/otb/src/Monteverdi -r 1551 -m 1.6-RC1 -o 3.8-RC1

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


check_external_version ()
{
    if [ -z "$monteverdi_version_full" ] ; then
        echo "*** ERROR: missing version number of Monteverdi (option -m)"
        echo "*** Use ./make_ubuntu_packages.sh -h to show command line syntax"
        exit 3
    fi
    if [ "`echo $monteverdi_version_full | sed -e 's/^[0-9]\+\.[0-9]\+\(\.[0-9]\+\|-RC[0-9]\+\)$/OK/'`" != "OK" ] ; then
        echo "*** ERROR: Monteverdi version ($monteverdi_version_full) has an unexpected format"
        exit 3
    fi
    if [ -z "$otb_version_full" ] ; then
        echo "*** ERROR: missing version number of OTB (option -o)"
        echo "*** Use ./make_ubuntu_packages.sh -h to show command line syntax"
        exit 3
    fi
    if [ "`echo $otb_version_full | sed -e 's/^[0-9]\+\.[0-9]\+\(\.[0-9]\+\|-RC[0-9]\+\)$/OK/'`" != "OK" ] ; then
        echo "*** ERROR: Monteverdi version ($otb_version_full) has an unexpected format"
        exit 3
    fi

    monteverdi_version_major=`echo $monteverdi_version_full | sed -e 's/^\([0-9]\+\)\..*$/\1/'`
    monteverdi_version_minor=`echo $monteverdi_version_full | sed -e 's/^[^\.]\+\.\([0-9]\+\)[\.-].*$/\1/'`
    monteverdi_version_patch=`echo $monteverdi_version_full | sed -e 's/^.*[\.-]\(\(RC\)\?[0-9]\+\)$/\1/'`

    otb_version_major=`echo $otb_version_full | sed -e 's/^\([0-9]\+\)\..*$/\1/'`
    otb_version_minor=`echo $otb_version_full | sed -e 's/^[^\.]\+\.\([0-9]\+\)[\.-].*$/\1/'`
    otb_version_patch=`echo $otb_version_full | sed -e 's/^.*[\.-]\(\(RC\)\?[0-9]\+\)$/\1/'`
    otb_version_soname="${otb_version_major}.${otb_version_minor}"
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


while getopts ":r:d:m:o:hv" option
do
    case $option in
        d ) topdir=$OPTARG
            ;;
        r ) revision=$OPTARG
            ;;
        m ) monteverdi_version_full=$OPTARG
            ;;
        o ) otb_version_full=$OPTARG
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

echo "Command line checking..."
check_src_top_dir
check_src_revision
check_external_version

# echo "Debian templates directory: $DEBDIR"
# echo "Working copy directory:     $topdir"
# echo "Monteverdi version:  $monteverdi_version_full"
# echo "- Major version number:  $monteverdi_version_major"
# echo "- Minor version number:  $monteverdi_version_minor"
# echo "- Patch version number:  $monteverdi_version_patch"
# echo "OTB version:  $otb_version_full"
# echo "- Soname version number: $otb_version_soname"
# echo "- Major version number:  $otb_version_major"

echo "Archive export..."
cd "$topdir"
hg archive -r "$revision" -t tgz "$TMPDIR/monteverdi-$monteverdi_version_full.tar.gz"

echo "Archive extraction..."
cd "$TMPDIR"
tar xzf "monteverdi-$monteverdi_version_full.tar.gz"
mv "monteverdi-$monteverdi_version_full.tar.gz" "monteverdi_$monteverdi_version_full.orig.tar.gz"

echo "Debian scripts import..."
cd "$TMPDIR/monteverdi-$monteverdi_version_full"
cp -a "$DEBDIR" .
cd debian
for f in control rules ; do
    sed -e "s/@MONTEVERDI_VERSION_MAJOR@/$monteverdi_version_major/g" \
        -e "s/@MONTEVERDI_VERSION_MINOR@/$monteverdi_version_minor/g" \
        -e "s/@MONTEVERDI_VERSION_PATCH@/$monteverdi_version_parch/g" \
        -e "s/@MONTEVERDI_VERSION_FULL@/$monteverdi_version_full/g" \
        -e "s/@OTB_VERSION_MAJOR@/$otb_version_major/g" \
        -e "s/@OTB_VERSION_SONAME@/$otb_version_soname/g" \
        -e "s/@OTB_VERSION_FULL@/$otb_version_full/g" \
        < "$f.in" > "$f"
    rm -f "$f.in"
done

echo "Source package generation..."
cd "$TMPDIR/monteverdi-$monteverdi_version_full"
# for target in maverick lucid karmic ; do
for target in lucid ; do
    set_ubuntu_code_name "$target"
    echo "Package for $ubuntu_codename ($ubuntu_version)"
    cp -f "$DEBDIR/changelog" debian
    dch --force-distribution --distribution "$target" \
        -v "${monteverdi_version_full}-0ppa~${target}" "Automated update for $ubuntu_codename ($ubuntu_version)."
    debuild -k0x46047121 -S -sa --lintian-opts -i
done
