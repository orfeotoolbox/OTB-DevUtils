#!/bin/sh
#
# Copyright (C) 2016 by Centre National d'Etudes Spatiales (CNES)
#
# Author: Sebastien DINOT <sebastien.dinot@c-s.fr>
#

TOPDIR=$(pwd)
if [ -d "${TOPDIR}/otb" ] ; then
    if [ -d "${TOPDIR}/otb/.git" ] ; then
        echo "ERROR: Remove '${TOPDIR}/otb' repository first"
        exit 1
    fi
fi

# git clone git@git.orfeo-toolbox.org:otb.git otb.orig
cp -a ${TOPDIR}/otb.orig ${TOPDIR}/otb
cd ${TOPDIR}/otb
git checkout develop
git checkout -b apache-license-migration

cp ${TOPDIR}/APACHE-LICENSE-V2.0 LICENSE
git add LICENSE
git commit -m "Updated license text (CeCILL v2.0 => Apache v2.0)"

# Remove obsolete CVS fields
grep -rlE '\$(Revision|Date|RCSfile).*\$' . | \
    grep -vE '/(SuperBuild|Copyright)/' | \
    xargs sed -i -e '/\$\(Date\|Revision\|RCSfile\).*\$/d'
git commit -a -m "Remove obsolete CVS fields"

grep -Elr 'Module:[^:]' . | \
    grep -vE '/(SuperBuild|Copyright)/' | \
    grep -vE '\.([cht](xx|pp)|h)$' | \
    xargs sed -i -e '/^ *Module: /d'
git commit -a -m "Remove useless references to itkModule"

cd $TOPDIR
./replace_headers.py
