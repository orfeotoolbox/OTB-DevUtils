#!/bin/sh
#
# Copyright (C) 2016 by Centre National d'Etudes Spatiales (CNES)
#
# Author: Sebastien DINOT <sebastien.dinot@c-s.fr>
#

TOPDIR=$(pwd)
OTBDIR=${TOPDIR}/otb
if [ ! -d "${OTBDIR}/.git" ] ; then
    echo "ERROR: No OTB repository found ('${OTBDIR}')"
    exit 1
fi

WORKINGDIR=${TOPDIR}/otb-license-migration
if [ -d "${WORKINGDIR}" ] ; then
    echo "ERROR: Remove '${WORKINGDIR}' repository first"
    exit 1
fi

cp -a ${OTBDIR} ${WORKINGDIR}
cd ${WORKINGDIR}
git config user.name "OTB Bot"
git config user.email "otbbot@orfeo-toolbox.org"
git checkout develop
git checkout -b apache-license-migration

# Remove obsolete Date, Revision and RCSfile CVS properties
# Space at first position of the pattern is required to exclude lines like:
# static const char OSSIM_ID[] = "$Id$";
grep -Erl ' \$(Id|Date|Revision|RCSfile).*\$' . | \
    grep -Ev '/(\.git|SuperBuild|Copyright)/' | \
    xargs sed -i -e '/ \$\(Id\|Date\|Revision\|RCSfile\).*\$/d'
git commit -a -m "Remove obsolete CVS properties (Id, Date, Revision, RCSfile)"

grep -Erl 'Module:[^:]' . | \
    grep -Ev '/(\.git|SuperBuild|Copyright)/' | \
    grep -E '\.([cht](xx|pp)|h)$' | \
    xargs sed -i -e '/^ *Module: /d'
git commit -a -m "Remove useless references to itkModule"

# Update embedded copyright notices
${TOPDIR}/replace_headers.py

chmod 755 Utilities/Maintenance/SuperbuildDownloadList.sh
chmod 755 Utilities/Maintenance/TravisBuild.sh
git commit -a -m "File headers now state that OTB is released under the Apache license"

cp -f ${TOPDIR}/APACHE-LICENSE-V2.0 LICENSE
cp -f ${TOPDIR}/APACHE-LICENSE-V2.0 SuperBuild/LICENSE
git rm Copyright/License_Apache2.txt
git rm Copyright/Licence_CeCILL_V2-fr.txt
git rm Copyright/Licence_CeCILL_V2-en.txt
git rm SuperBuild/Copyright/LICENSE
git add LICENSE SuperBuild/LICENSE
git commit -m "Updated license text (CeCILL v2.0 => Apache v2.0)"

cp -f ${TOPDIR}/hand-adjusted/NOTICE NOTICE
git add NOTICE
git commit -m "Added NOTICE file that lists third party software"

cp -f ${TOPDIR}/hand-adjusted/Description.txt   CMake/Description.txt
cp -f ${TOPDIR}/hand-adjusted/README.md         README.md
cp -f ${TOPDIR}/hand-adjusted/fr_FR.ts          i18n/fr_FR.ts
cp -f ${TOPDIR}/hand-adjusted/mvdAboutDialog.ui Modules/Visualization/MonteverdiGui/src/mvdAboutDialog.ui
cp -f ${TOPDIR}/hand-adjusted/Abstract.tex      Documentation/SoftwareGuide/Latex/Abstract.tex
cp -f ${TOPDIR}/hand-adjusted/FAQ.tex           Documentation/SoftwareGuide/Latex/FAQ.tex
git commit -a -m "Documentation now state that OTB is released under the Apache license"

cp -f ${TOPDIR}/hand-adjusted/Findcppcheck.cpp CMake/Findcppcheck.cpp
cp -f ${TOPDIR}/hand-adjusted/PythonCompile.py CMake/PythonCompile.py
git commit -a -m "Removed undue copyright notices (trivial code)"

cp -f ${TOPDIR}/hand-adjusted/FindGLEW.cmake        CMake/FindGLEW.cmake
cp -f ${TOPDIR}/hand-adjusted/FindOpenThreads.cmake CMake/FindOpenThreads.cmake
git commit -a -m "Reworked embedded copyright notices"
