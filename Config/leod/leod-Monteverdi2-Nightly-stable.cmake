set(dashboard_model Nightly)
string(TOLOWER ${dashboard_model} lcdashboard_model)
set(OTB_PROJECT Monteverdi2)
SET (CTEST_BUILD_CONFIGURATION Release)
SET (CTEST_BUILD_NAME "MacOSX10.10-${CTEST_BUILD_CONFIGURATION}-stable")
include(${CTEST_SCRIPT_DIRECTORY}/leod_common.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)

set(dashboard_root_name "tests")
set(dashboard_source_name "${lcdashboard_model}/Monteverdi2-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "${lcdashboard_model}/Monteverdi2-${CTEST_BUILD_CONFIGURATION}/build-stable")

set(MVD2_INSTALL_PREFIX $ENV{HOME}/Dashboard/${lcdashboard_model}/Monteverdi2-${CTEST_BUILD_CONFIGURATION}/install-stable)

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/monteverdi2.git")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_LIBRARY_PATH:PATH=/opt/local/lib
CMAKE_INCLUDE_PATH:PATH=/opt/local/include

BUILD_SHARED_LIBS:BOOL=OFF
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=${MVD2_INSTALL_PREFIX}

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data

CMAKE_C_FLAGS:STRING= -Wall
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-gnu -Wno-\\\\#warnings

OTB_DIR:STRING=$ENV{HOME}/Dashboard/nightly/OTB-Release/install-stable/${OTB_STABLE_DIR_SUFFIX}

# ICE_INCLUDE_DIR:PATH=/Users/otbval/Dashboard/nightly/Ice-Release/install-stable/include
# ICE_LIBRARY:FILEPATH=/Users/otbval/Dashboard/nightly/Ice-Release/install-stable/lib/libOTBIce.dylib

Monteverdi_USE_CPACK:BOOL=ON

")
endmacro()

macro(dashboard_hook_test)
# before testing, set the DYLD_LIBRARY_PATH
set(ENV{DYLD_LIBRARY_PATH} /Users/otbval/Dashboard/nightly/OTB-Release/install-stable/lib::/Users/otbval/Dashboard/nightly/Ice-Release/install-stable/lib)
endmacro()

macro(dashboard_hook_end)
  find_program(HDIUTIL_EXECUTABLE hdiutil)
  if(HDIUTIL_EXECUTABLE)
    file(READ "${CTEST_DASHBOARD_ROOT}/${dashboard_source_name}/CMakeLists.txt" _CMAKEFILE_CONTENT)
    string(REGEX REPLACE ".*set\\(Monteverdi_VERSION_MAJOR \"([0-9]+)\"\\).*" "\\1" VER_MAJOR "${_CMAKEFILE_CONTENT}")
    string(REGEX REPLACE ".*set\\(Monteverdi_VERSION_MINOR \"([0-9]+)\"\\).*" "\\1" VER_MINOR "${_CMAKEFILE_CONTENT}")
    string(REGEX REPLACE ".*set\\(Monteverdi_VERSION_PATCH \"([0-9]+)\"\\).*" "\\1" VER_PATCH "${_CMAKEFILE_CONTENT}")
    string(REGEX REPLACE ".*set\\(Monteverdi_VERSION_SUFFIX \"([a-zA-Z0-9]*)\"\\).*" "\\1" VER_SUFFIX "${_CMAKEFILE_CONTENT}")
    set(DMG_VERSION "${VER_MAJOR}.${VER_MINOR}.${VER_PATCH}")
    if("${VER_SUFFIX}")
      set(DMG_VERSION "${DMG_VERSION}.${VER_SUFFIX}")
    endif()
    execute_process(COMMAND hdiutil create -srcfolder ${MVD2_INSTALL_PREFIX}/Monteverdi.app Monteverdi-${DMG_VERSION}-Darwin.dmg  -megabytes 150
                    WORKING_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name})
    execute_process(COMMAND hdiutil create -srcfolder ${MVD2_INSTALL_PREFIX}/Mapla.app Mapla-${DMG_VERSION}-Darwin.dmg
                    WORKING_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name})
  endif()
endmacro()

# Remove install tree
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${MVD2_INSTALL_PREFIX})
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${MVD2_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
