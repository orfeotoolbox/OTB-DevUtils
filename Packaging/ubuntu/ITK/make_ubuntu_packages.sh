#!/bin/bash
# Script to automate the ITK library packaging for Ubuntu.
#
# Copyright (C) 2010-2014 CNES - Centre National d'Etudes Spatiales
# by Sebastien DINOT <sebastien.dinot@c-s.fr>
# adapted by Guillaume PASERO <guillaume.pasero@c-s.fr>
#
# The OTB is distributed under the CeCILL license version 2. See files
# Licence_CeCILL_V2-en.txt (english version) or Licence_CeCILL_V2-fr.txt
# (french version) in 'Copyright' directory for details. This licenses are
# also available online:
# http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
# http://www.cecill.info/licences/Licence_CeCILL_V2-fr.txt


SCRIPT_VERSION="2.0"

if [ -z "$DEBFULLNAME" ]; then
  DEBFULLNAME="OTB Team"
fi

if [ -z "$DEBEMAIL" ]; then
  DEBEMAIL="contact@orfeo-toolbox.org"
fi

export DEBFULLNAME
export DEBEMAIL

TMPDIR=$(mktemp -d /tmp/itk-otb.XXXXXX)
DIRNAME=$(dirname $0)
if [ "${DIRNAME:0:1}" == "/" ] ; then
    CMDDIR=$DIRNAME
elif [ "${DIRNAME:0:1}" == "." ] ; then
    CMDDIR=$(pwd)/${DIRNAME:2}
else
    CMDDIR=$(pwd)/$DIRNAME
fi
DEBDIR=$CMDDIR/debian-4.7.1
DEFAULT_GPGKEYID=0xAEB3D22F


display_version ()
{
    cat <<EOF

make_ubuntu_packages.sh, version ${SCRIPT_VERSION}
Copyright (C) 2010-2014 CNES (Centre National d'Etudes Spatiales)
by Sebastien DINOT <sebastien.dinot@c-s.fr>

EOF
}


display_help ()
{
    cat <<EOF

This script is used to automate the ITK library packaging for
Ubuntu. The package is adpated to work with Orfeo ToolBox
library. Source packages are created in ${TMPDIR} directory.

Usage:
  ./make_ubuntu_packages.sh [options]

Options:
  -h            Display this short help message.

  -v            Display version and copyright informations.

  -a archive    Archive containing ITK orig sources

  -p version    Version of the package (ex. 2)

  -g id         GnuPG key id used for signing (default ${DEFAULT_GPGKEYID})

Example:
  ./make_ubuntu_packages.sh -d ~/src/InsightToolkit-4.6.0 -p 2

EOF
}


check_src_archive ()
{
    if [ ! -f "$source_archive" ] ; then
        echo "*** ERROR: archive '$source_archive' doesn't exist"
        exit 2
    fi
    extract_cmd="tar -xf"
    if [ -n "$(echo "${source_archive}" | grep -E -e '\.tar\.gz$')" ] ; then
      extract_cmd="tar -xzf"
    fi
    if [ -n "$(echo "${source_archive}" | grep -E -e '\.tgz$')" ] ; then
      extract_cmd="tar -xzf"
    fi
    if [ -n "$(echo "${source_archive}" | grep -E -e '\.tar\.xz$')" ] ; then
      extract_cmd="tar -xJf"
    fi
    if [ -n "$(echo "${source_archive}" | grep -E -e '\.tar\.bz2$')" ] ; then
      extract_cmd="tar -xjf"
    fi
}


check_gpgkeyid ()
{
    if [ -z "$gpgkeyid" ] ; then
        gpgkeyid=$DEFAULT_GPGKEYID
    fi
    gpg --list-secret-keys $gpgkeyid &>/dev/null
    if [ "$?" -ne 0 ] ; then
        echo "*** ERROR: Secret part of the GnuPG key $gpgkeyid is unavailable, packages can't be signed"
        exit 4
    fi
}


set_ubuntu_code_name ()
{
    case "$1" in
        "xenial" )
            ubuntu_codename="Xenial Xerus"
            ubuntu_version="16.04"
            ;;
        "wily" )
            ubuntu_codename="Wily Werewolf"
            ubuntu_version="15.10"
            ;;
        "vivid" )
            ubuntu_codename="Vivid Vervet"
            ubuntu_version="15.04"
            ;;
        "trusty" )
            ubuntu_codename="Trusty Tahr"
            ubuntu_version="14.04"
            ;;
        "saucy" )
            ubuntu_codename="Saucy Salamander"
            ubuntu_version="13.10"
            ;;
        "raring" )
            ubuntu_codename="Raring Ringtail"
            ubuntu_version="13.04"
            ;;
        "quantal" )
            ubuntu_codename="Quantal Quetzal"
            ubuntu_version="12.10"
            ;;
        "precise" )
            ubuntu_codename="Precise Pangolin"
            ubuntu_version="12.04"
            ;;
        * )
            echo "*** ERROR: Unknown or too old Ubuntu version"
            exit 4
            ;;
    esac
}


while getopts ":a:p:g:hv" option
do
    case $option in
        a ) source_archive=$OPTARG
            ;;
        p ) pkg_version=$OPTARG
            ;;
        g ) gpgkeyid=$OPTARG
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

# find last version in changelog.in
changelog_version=`grep -E -e 'insighttoolkit4 \(.+-.+\)' "$DEBDIR/changelog.in" | head -n 1 | cut -d '(' -f 2 | cut -d '-' -f 1`

echo "Command line checking..."
check_src_archive

check_gpgkeyid

echo "Archive extraction..."
cp "$source_archive" "$TMPDIR"
cd "$TMPDIR"
$extract_cmd `basename "$source_archive"`

echo "Debian scripts import..."
cd "$TMPDIR/InsightToolkit-${changelog_version}"
cp -a "$DEBDIR" debian

echo "Source package generation..."
first_pkg=1
for target in vivid ; do
    set_ubuntu_code_name "$target"
    echo "Configure scripts for $ubuntu_codename"
    cp -f "$DEBDIR/control.in" ./debian
    cp -f "$DEBDIR/changelog.in" ./debian
    make -f debian/rules control-file DIST=$target
    make -f debian/rules changelog-file DIST=$target
    rm -f debian/control.in
    rm -f debian/changelog.in

    echo "Package for $ubuntu_codename ($ubuntu_version)"
    if [ $first_pkg -eq 1 ] ; then
        debuild -k$gpgkeyid -S -sa --lintian-opts -i
        first_pkg=0
    else
        debuild -k$gpgkeyid -S --lintian-opts -i
    fi
    echo "ITK source package for Ubuntu $ubuntu_codename is available in $TMPDIR"
done
