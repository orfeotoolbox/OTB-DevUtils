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
# 3. Create and fill in ~/.tsocks.conf and ~/.dput.cf configuration files.
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
export USER=otbval
export HOME=/home/$USER
# export TSOCKS_CONF_FILE=$HOME/.tsocks.conf

SRCDIR=$HOME/Dashboard/src
CMDDIR=$SRCDIR/OTB-DevUtils/Packaging/ubuntu

# TSOCKS=$(which tsocks)

# Maximum wait time (in seconds 18000 s = 5 h) for OTB binary packages availability
MAX_WAIT_TIME=36000
# Sleep time between two scans of OTB PPA
SLEEP_TIME=300
EXPECTED_OTB_PACKAGES=1

SCRIPT_VERSION="2.0"
TMPDIR="/tmp"


display_version ()
{
    cat <<EOF

nightly_build.sh, version ${SCRIPT_VERSION}
Copyright (C) 2011 CNES (Centre National d'Etudes Spatiales)
by Sebastien DINOT <sebastien.dinot@c-s.fr>

EOF
}


display_help ()
{
    cat <<EOF

This script is used to automate the nightly submission to Launchpad of OTB
sources packages for Ubuntu.

Usage:
  ./nightly_build.sh [options]

Options:
  -h            Display this short help message.

  -v            Display version and copyright informations.

  -t date       Initialize the launching date (because this script is usually
                launched by another which can be launched itself a couple of
                hours before). The default value is the current date.

  -s            Simulate submission.

Example:
  ./nightly_build.sh -t 20110621

EOF
}


timestamp=$(date +%Y%m%d)
simulate=0
while getopts ":t:shv" option
do
    case $option in
        t ) timestamp=$OPTARG
            ;;
        s ) simulate=1
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

# Clean previous builds
rm -rf /tmp/otb* /tmp/monteverdi*

# For each project ("OTB" must be the first one)
#for project in OTB Monteverdi OTB-Wrapping ; do
for project in OTB Monteverdi ; do

    # Update working copy
    cd $SRCDIR/$project
    # $TSOCKS hg pull -u
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
    patch_version=$timestamp
    next_version="${major_version}.${minor_version}.${patch_version}"

    # Set package number
    last_changeset=$(hg identify | cut -d ' ' -f 1)
    pkg_version="0+${last_changeset}"

    # Build source packages
    if [ "$project" == "OTB" ] ; then
        otb_version=$next_version
        otb_pkg_version=$pkg_version
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

    # Unless for OTB, wait OTB packages availability
    if [ "$project" != "OTB" ] ; then
        if [ "$simulate" -eq 0 ] ; then
            otb_pkg_avail=0
        else
            otb_pkg_avail=1
        fi
        ppa_url="http://ppa.launchpad.net/otb/orfeotoolbox-nightly/ubuntu/pool/main/o/otb"
        start_time=$(date +%s)
        elapsed_time=0
        while [ $otb_pkg_avail -eq 0 -a $elapsed_time -le $MAX_WAIT_TIME ] ; do
            # n=$($TSOCKS GET $ppa_url | sed -ne "s/^.* href=\"\(libotb_${otb_version}-0ppa~.*${otb_pkg_version}_all\.deb\)\".*$/\1/p" | wc -l)
            n=$(GET $ppa_url | sed -ne "s/^.* href=\"\(libotb_${otb_version}-0ppa~.*${otb_pkg_version}_all\.deb\)\".*$/\1/p" | wc -l)
            if [ $n -eq "$EXPECTED_OTB_PACKAGES" ] ; then
                echo $(date '+%F %T: ') "OTB packages are now availables for all versions."
                otb_pkg_avail=1
            else
                echo $(date '+%F %T: ') "Waiting for OTB package availability. Next check in $SLEEP_TIME s."
                sleep $SLEEP_TIME
                elapsed_time=$(($(date +%s) - $start_time))
            fi
        done
        # If OTB binary packages are not availables after expected time, cancel remaining submissions
        if [ $otb_pkg_avail -eq 0 ] ; then
            echo "Max wait time ($MAX_WAIT_TIME s) for OTB binary packages reached. Remaining submissions cancelled."
            exit 1
        fi
    fi

    # Push source packages on Launchpad (through tsocks proxy if necessary)
    if [ "$simulate" -eq 0 ] ; then
        # $TSOCKS dput -P ppa-otb-nightly /tmp/${pkg_name}_${next_version}-0ppa~*${pkg_version}_source.changes
        #dput -P ppa-otb-nightly /tmp/${pkg_name}_${next_version}-0ppa~*${pkg_version}_source.changes
        dput -P ppa-otb-nightly /tmp/${pkg_name}_${next_version}-0ppa~precise${pkg_version}_source.changes
    else
        # echo "COMMAND: $TSOCKS dput -P ppa-otb-nightly /tmp/${pkg_name}_${next_version}-0ppa~*${pkg_version}_source.changes"
        echo "COMMAND: dput -P ppa-otb-nightly /tmp/${pkg_name}_${next_version}-0ppa~*${pkg_version}_source.changes"
    fi

done
