#!/bin/bash
# Script to automate the Orfeo Toolbox library packaging for Debian.
#
# Copyright (C) 2010-2012 CNES - Centre National d'Etudes Spatiales
# by Sebastien DINOT <sebastien.dinot@c-s.fr>
#
# The OTB is distributed under the CeCILL license version 2. See files
# Licence_CeCILL_V2-en.txt (english version) or Licence_CeCILL_V2-fr.txt
# (french version) in 'Copyright' directory for details. This licenses are
# also available online:
# http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
# http://www.cecill.info/licences/Licence_CeCILL_V2-fr.txt


SCRIPT_VERSION="Debian 3.0"

# Idenfify command directory
reldir=$(dirname $0)
if [ "${reldir:0:1}" == "/" ] ; then
    cmddir=$reldir
elif [ "${reldir:0:1}" == "." ] ; then
    cmddir=$(pwd)/${reldir:2}
else
    cmddir=$(pwd)/$reldir
fi


display_help ()
{
    cat <<EOF

make_deb_packages.sh, version ${SCRIPT_VERSION}
Copyright (C) 2010-2012 CNES (Centre National d'Etudes Spatiales)
by Sebastien DINOT <sebastien.dinot@c-s.fr>

This script is used to automate the Orfeo Toolbox library packaging for
Debian.

Usage:
  ./make_deb_packages.sh [options]

Options:

  -h            Display this short help message.

  -a arch       Target architecture (i386, amd64), not supported at the moment

  -d dist       Target distribution (sid, unstable, wheezy, testing, ...)

  -b branch     OTB branch (stable, dev)

  -o repository OTB repository (only local directories are supported at the moment)

  -g id         GnuPG key id used for signing if different from default

  -s            Build only the source package

  -w workspace  Workspace (directory wherein the packages are built)

Example:
  ./make_deb_packages.sh -b stable -o ../../../../OTB -w ~/tmp/packages/stable

EOF
}


check_architecture ()
{
    if [ -z "$arch" ] ; then
        arch=$(dpkg-architecture -qDEB_BUILD_ARCH)
    fi
    if [ "$arch" != "i386" ] && [ "$arch" != "amd64" ] ; then
        echo "*** ERROR: Unknown architecture ('$arch')"
        exit 1
    fi
}


check_distribution ()
{
    if [ -z "$dist" ] ; then
        dist=$(lsb_release -sc)
    fi
    case "$dist" in
        "squeeze"|"stable" )
            target_distributor="debian"
            target_release="stable"
            target_codename="squeeze"
            target_description="Debian GNU/Linux stable (Squeeze)"
            ;;
        "wheezy"|"testing" )
            target_distributor="debian"
            target_release="testing"
            target_codename="wheezy"
            target_description="Debian GNU/Linux testing (Wheezy)"
            ;;
        "sid"|"unstable" )
            target_distributor="debian"
            target_release="unstable"
            target_codename="sid"
            target_description="Debian GNU/Linux unstable (Sid)"
            ;;
        * )
            echo "*** ERROR: Unknown distribution ('$dist')"
            exit 2
            ;;
    esac
}


check_branch ()
{
    if [ -z "$branch" ] ; then
        branch="dev"
    fi
    case "$branch" in
        "dev"|"3.13" )
            otb_branch="dev"
            otb_revision="tip"
            otb_version_major="3"
            otb_version_minor="13"
            otb_version_patch="0"
            ;;
        "stable"|"3.12" )
            otb_branch="stable"
            otb_revision="3.12.0"
            otb_version_major="3"
            otb_version_minor="12"
            otb_version_patch="0"
            ;;
        * )
            echo "*** ERROR: Unknown OTB branch ('$branch')"
            exit 3
            ;;
    esac

    otb_version=${otb_version_major}.${otb_version_minor}.${otb_version_patch}
    otb_version_soname="${otb_version_major}.${otb_version_minor}"

    debdir="$cmddir/otb-${otb_branch}/debian"
}


check_repository ()
{
    if [ -z "$otb_repository" ] ; then
        echo "*** ERROR: missing directory of the Mercurial working copy (option -o)"
        echo "*** Use ./make_deb_packages.sh -h to show command line syntax"
        exit 4
    fi
    if [ ! -d "$otb_repository" ] ; then
        echo "*** ERRROR: directory '$otb_repository' doesn't exist"
        exit 4
    fi
    if [ ! -d "$otb_repository/.hg" ] ; then
        echo "*** ERRROR: No Mercurial working copy found in '$otb_repository' directory"
        exit 4
    fi
    if [ "$(hg identify $otb_repository)" == "000000000000 tip" ] ; then
        echo "*** ERROR: Mercurial failed to identify a valid repository in '$otb_repository'"
        exit 4
    fi
    otb_repository=$( cd $otb_repository ; pwd )
}


check_workspace ()
{
    if [ -z "$workspace" ] ; then
        workspace=$(mktemp -d /tmp/deb-XXXXXX)
    fi
    if [ ! -d "$workspace" ] ; then
        if [ -e "$workspace" ] ; then
            echo "*** ERROR: '$workspace' exists but is not a directory"
            exit 5
        else
            mkdir "$workspace"
            if [ ! -d "$workspace" ] ; then
                echo "*** ERROR: failed to create '$workspace' directory"
                exit 5
            fi
        fi
    fi
}


check_gpg_key_id ()
{
    if [ -z "$gpgkeyid" ] ; then
        gpgkeyid=$DEFAULT_GPGKEYID
    fi
    gpg --list-secret-keys $gpgkeyid &>/dev/null
    if [ "$?" -ne 0 ] ; then
        echo "*** ERROR: Secret part of the GnuPG key $gpgkeyid is unavailable, the packages can't be signed"
        exit 4
    fi
}


complete_environment ()
{
    # if [ "$nightly" == "1" ] ; then
    #     export DEBFULLNAME="OTB Bot"
    #     export DEBEMAIL="bot@orfeo-toolbox.org"
    #     DEFAULT_GPGKEYID=0xAEB3D22F
    # else
        export DEBFULLNAME="OTB Team"
        export DEBEMAIL="contact@orfeo-toolbox.org"
        DEFAULT_GPGKEYID=0x46047121
    # fi
    check_gpg_key_id
}


build_packages ()
{
    echo "Archive export..."
    cd "$otb_repository"
    hg archive -r "$otb_revision" -t tgz "${workspace}/otb-${otb_version}.tar.gz"

    echo "Archive extraction..."
    cd "$workspace"
    tar xzf "otb-${otb_version}.tar.gz"
    mv "otb-${otb_version}.tar.gz" "otb_${otb_version}.orig.tar.gz"

    echo "Debian scripts import..."
    cd "${workspace}/otb-${otb_version}"
    cp -a "$debdir" .
    cd debian
    for f in control ; do
        sed -e "s/@VERSION_MAJOR@/${otb_version_major}/g" \
            -e "s/@VERSION_MINOR@/${otb_version_minor}/g" \
            -e "s/@VERSION_PATCH@/${otb_version_patch}/g" \
            -e "s/@VERSION_SONAME@/${otb_version_soname}/g" \
            -e "s/@VERSION_FULL@/${otb_version}/g" \
            < "$f.in" > "$f"
        rm -f "$f.in"
    done
    for f in *VERSION_MAJOR* ; do
        g=$(echo $f | sed -e "s/VERSION_MAJOR/${otb_version_major}/g")
        mv "$f" "$g"
    done
    for f in *VERSION_SONAME* ; do
        g=$(echo $f | sed -e "s/VERSION_SONAME/${otb_version_soname}/g")
        mv "$f" "$g"
    done

    echo "Packages generation..."
    cd "${workspace}/otb-${otb_version}"
    echo "OTB $otb_branch packages for $target_description"

    export DEB_BUILD_OPTIONS="parallel=3"
    if [ "$srconly" == "1" ] ; then
        debuild -k$gpgkeyid -S -sa --lintian-opts -i
    else
        debuild -k$gpgkeyid -sa --lintian-opts -i
    fi
}


while getopts ":a:d:b:o:w:g:sh" option
do
    case $option in
        a ) arch=$OPTARG
            ;;
        d ) dist=$OPTARG
            ;;
        b ) branch=$OPTARG
            ;;
        o ) otb_repository=$OPTARG
            ;;
        w ) workspace=$OPTARG
            ;;
        g ) gpgkeyid=$OPTARG
            ;;
        s ) srconly=1
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


echo "Command line checking..."
check_architecture
check_distribution
check_branch
check_repository
check_workspace

complete_environment
build_packages


# cat <<EOF

# Packages target:
# - Distributor:  $target_distributor
# - Release:      $target_branch
# - Codename:     $target_codename
# - Description:  $target_description
# - Architecture: $arch

# Orfeo Toolbox:
# - Branch:       $otb_branch
# - Version:      $otb_version
# - Revision:     $otb_revision
# - Repository:   $otb_repository

# Other parameters:
# - Workspace:    $workspace
# - GPG key id.:  $gpgkeyid
# - Contact:      $DEBFULLNAME <$DEBEMAIL>

# EOF
