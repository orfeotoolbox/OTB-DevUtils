#!/bin/bash
# Script to automate nightly build of the OTB Ubuntu packages.
#
# 1. Add the following command in your crontab:
#
#    # m h  dom mon dow   command
#    30 20 * * 1-5 /path/to/nightly_build.sh
#
# 2. Adapt environment variables defined below (USER, HOME, SRCDIR)
#
# Copyright (C) 2011 CNES - Centre National d'Etudes Spatiales
# by Sebastien DINOT <sebastien.dinot@c-s.fr>
#
# The OTB is distributed under the CeCILL license version 2. See files
# Licence_CeCILL_V2-en.txt (english version) or Licence_CeCILL_V2-fr.txt
# (french version) in 'Copyright' directory for details. This licenses are
# also available online:
# http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
# http://www.cecill.info/licences/Licence_CeCILL_V2-fr.txt

set -e

export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export USER=otbuser
export HOME=/home/otbuser
export TSOCKS_CONF_FILE=$HOME/.tsocks.conf

SRCDIR=$HOME/otb/src
CMDDIR=$SRCDIR/OTB-DevUtils/Packaging/ubuntu

# Clean previous builds
rm -rf /tmp/otb* /tmp/monteverdi*

# For each project ("OTB" must be the first one)
for project in OTB Monteverdi OTB-Applications OTB-Wrapping ; do

    # Update working copy
    cd $SRCDIR/$project
    hg pull -u

    # Extract last tagged version identifier
    full_version=$(hg tags | head -n 2 | tail -n 1 | cut -d ' ' -f 1)
    major_version=$(echo $full_version | cut -d '.' -f 1)
    minor_version=$(echo $full_version | sed -e 's/^[0-9]\+\.\([0-9]\+\)[.-].*$/\1/')
    patch_version=$(echo $full_version | sed -e 's/^.*[.-]\(.*\)$/\1/')

    # Calculate next version identifier
    # If last_version = x.y.z   then next_version = x.(y+1).0
    # If last_version = x.y-RCz then next_version = x.y.0
    if [ "$(echo $patch_version | sed -e 's/^[0-9]\+$/NOTRC/')" == 'NOTRC' ] ; then
        minor_version=$(($minor_version + 1))
    fi
    next_version="${major_version}.${minor_version}.0"

    # Set package number
    current_date=$(date +%Y%m%d)
    last_changeset=$(hg identify | cut -d ' ' -f 1)
    pkg_version="${current_date}+${last_changeset}"

    # Build source packages
    if [ "$project" == "OTB" ] ; then
        otb_version=$next_version
        $CMDDIR/$project/make_ubuntu_packages.sh -d $SRCDIR/$project -r tip -o $otb_version -p $pkg_version -c "Nightly build"
    else
        $CMDDIR/$project/make_ubuntu_packages.sh -d $SRCDIR/$project -r tip -o $otb_version -p $pkg_version -c "Nightly build" -m $next_version
    fi

    case $project in
        OTB)
            pkg_name=otb
            ;;
        Monteverdi)
            pkg_name=monteverdi
            ;;
        OTB-Applications)
            pkg_name=otbapp
            ;;
        OTB-Wrapping)
            pkg_name=otb-wrapping
            ;;
    esac

    # Push source packages on Launchpad (through tsocks proxy if necessary)
    TSOCKS=$(which tsocks)
    $TSOCKS dput -P ppa-otb-nightly /tmp/${pkg_name}_${next_version}-0ppa~*${pkg_version}_source.changes

done
