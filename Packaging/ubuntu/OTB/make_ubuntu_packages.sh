#!/bin/bash
# Script to automate the Orfeo Toolbox library packaging for Ubuntu.
#
# Copyright (C) 2010-2014 CNES - Centre National d'Etudes Spatiales
# by Sebastien DINOT <sebastien.dinot@c-s.fr>
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

TMPDIR=$(mktemp -d /tmp/otb.XXXXXX)
DIRNAME=$(dirname $0)
if [ "${DIRNAME:0:1}" == "/" ] ; then
    CMDDIR=$DIRNAME
elif [ "${DIRNAME:0:1}" == "." ] ; then
    CMDDIR=$(pwd)/${DIRNAME:2}
else
    CMDDIR=$(pwd)/$DIRNAME
fi
DEBDIR=$CMDDIR/debian.4
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

This script is used to automate the Orfeo Toolbox library packaging for
Ubuntu. Source packages are created in ${TMPDIR} directory.

Usage:
  ./make_ubuntu_packages.sh [options]

Options:
  -h            Display this short help message.

  -v            Display version and copyright informations.

  -d directory  Top directory of the local repository clone

  -r tag        Revision to extract.

  -o version    External version of the OTB library (ex. 3.8.0)

  -p version    Version of the package (ex. 2)

  -c message    Changelog message

  -g id         GnuPG key id used for signing (default ${DEFAULT_GPGKEYID})

Example:
  ./make_ubuntu_packages.sh -d ~/otb/src/OTB -r 9244 -o 3.8-RC1 -p 2

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
    if [ "$(hg identify $topdir)" == "000000000000 tip" ] ; then
        echo "*** ERROR: Mercurial failed to identify a valid repository in '$topdir'"
        exit 2
    fi
    topdir=$( cd $topdir ; pwd )
}


check_src_revision ()
{
    if [ -z "$revision" ] ; then
        echo "*** ERROR: missing revision identifier of the repository (option -r)"
        echo "*** Use ./make_ubuntu_packages.sh -h to show command line syntax"
        exit 3
    fi
    olddir=$(pwd)
    cd "$topdir"
    if ! hg log -r "$revision" &>/dev/null ; then
        echo "*** ERROR: Revision $revision unknown"
        exit 2
    fi
    cd "$olddir"
}


check_external_version ()
{
    # If OTB version is not given on command line, this script parse the top
    # level CMakeLists.txt file to find it.
    if [ -n "$otb_version_full" ] ; then
        if [ "$(echo $otb_version_full | sed -e 's/^[0-9]\+\.[0-9]\+\(\.[0-9]\+\|-RC[0-9]\+\)$/OK/')" != "OK" ] ; then
            echo "*** ERROR: OTB full version ($otb_version_full) has an unexpected format"
            exit 3
        fi
        otb_version_major=$(echo $otb_version_full | sed -e 's/^\([0-9]\+\)\..*$/\1/')
        otb_version_minor=$(echo $otb_version_full | sed -e 's/^[^\.]\+\.\([0-9]\+\)[\.-].*$/\1/')
        otb_version_patch=$(echo $otb_version_full | sed -e 's/^.*[\.-]\(\(RC\)\?[0-9]\+\)$/\1/')
    else
        otb_version_major=$(sed -n -e 's/SET(OTB_VERSION_MAJOR "\([0-9]\+\)")/\1/p' $topdir/CMakeLists.txt)
        otb_version_minor=$(sed -n -e 's/SET(OTB_VERSION_MINOR "\([0-9]\+\)")/\1/p' $topdir/CMakeLists.txt)
        otb_version_patch=$(sed -n -e 's/SET(OTB_VERSION_PATCH "\(\(RC\)\?[0-9]\+\)")/\1/p' $topdir/CMakeLists.txt)
        if [ "${otb_version_patch:0:2}" == "RC" ] ; then
            otb_version_full=${otb_version_major}.${otb_version_minor}-${otb_version_patch}
        else
            otb_version_full=${otb_version_major}.${otb_version_minor}.${otb_version_patch}
        fi
    fi
    otb_version_soname="${otb_version_major}.${otb_version_minor}"
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


while getopts ":r:d:o:p:c:g:hv" option
do
    case $option in
        d ) topdir=$OPTARG
            ;;
        r ) revision=$OPTARG
            ;;
        o ) otb_version_full=$OPTARG
            ;;
        p ) pkg_version=$OPTARG
            ;;
        c ) changelog_message=$OPTARG
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

echo "Command line checking..."
check_src_top_dir
check_src_revision
check_external_version
check_gpgkeyid

echo "Archive export..."
cd "$topdir"
hg archive -r "$revision" -t tgz -p "otb-$otb_version_full" "$TMPDIR/otb_${otb_version_full}.orig.tar.gz"

echo "Archive extraction..."
cd "$TMPDIR"
tar xzf "otb_${otb_version_full}.orig.tar.gz"

echo "Debian scripts import..."
cd "$TMPDIR/otb-${otb_version_full}"
cp -a "$DEBDIR" debian
cd debian
sed -e "s/@OTB_VERSION_SONAME@/${otb_version_soname}/g" < control.in > control
rm -f control.in

echo "Source package generation..."
cd "$TMPDIR/otb-${otb_version_full}"
first_pkg=1
for target in precise quantal saucy trusty ; do
    set_ubuntu_code_name "$target"
    echo "Package for $ubuntu_codename ($ubuntu_version)"
    cp -f "$DEBDIR/changelog" debian
    if [ -n "$changelog_message" ] ; then
        dch_message="$changelog_message"
    else
        dch_message="Automated update for $ubuntu_codename ($ubuntu_version)."
    fi
    dch --force-distribution --distribution "$target" \
        -v "${otb_version_full}-1otb~${target}${pkg_version}" "$dch_message"
    if [ $first_pkg -eq 1 ] ; then
        debuild -k$gpgkeyid -S -sa --lintian-opts -i
        first_pkg=0
    else
        debuild -k$gpgkeyid -S --lintian-opts -i
    fi
    echo "OTB source package for Ubuntu $ubuntu_codename is available in $TMPDIR"
    echo "You might want to run 'cp \"$TMPDIR/otb-${otb_version_full}/debian/changelog\" \"$DEBDIR/changelog\"' and commit"
done
