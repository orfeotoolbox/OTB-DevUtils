#!/bin/sh

if [ $# -lt 1 ]; then
    echo "$0: required one argument which is path to OTB source directory" 
fi

OTB_SOURCE_DIR="$1"

SHELLCHECK=$(which shellcheck)
if [ -z "$SHELLCHECK" ]; then
    echo "$0: Cannot find shellcheck. Make sure it is installed and can be found in PATH"
fi

"$SHELLCHECK" "$OTB_SOURCE_DIR/CMake/otbcli.sh.in"
"$SHELLCHECK" "$OTB_SOURCE_DIR/CMake/otbcli_app.sh.in"

"$SHELLCHECK" "$OTB_SOURCE_DIR/CMake/otbgui.sh.in"
"$SHELLCHECK" "$OTB_SOURCE_DIR/CMake/otbgui_app.sh.in"

"$SHELLCHECK" "$OTB_SOURCE_DIR/Utilities/Maintenance/SuperbuildDownloadList.sh"
"$SHELLCHECK" "$OTB_SOURCE_DIR/SuperBuild/Packaging/linux_pkgsetup.in"
"$SHELLCHECK" "$OTB_SOURCE_DIR/SuperBuild/Packaging/macx_pkgsetup.in"
