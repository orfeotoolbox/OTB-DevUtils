set (ENV{DISPLAY} ":0.0")
set (ENV{LANG} "C")

set (dashboard_model Nightly)
string(TOLOWER ${dashboard_model} lcdashboard_model)

set (CTEST_BUILD_CONFIGURATION Release)

set (DASHBOARD_DIR "$ENV{HOME}/Dashboard/${lcdashboard_model}/Monteverdi2-${CTEST_BUILD_CONFIGURATION}")

set (CTEST_SOURCE_DIRECTORY "${DASHBOARD_DIR}/src")
set (CTEST_BINARY_DIRECTORY "${DASHBOARD_DIR}/build")
set (CTEST_CMAKE_GENERATOR  "Unix Makefiles")
set (CTEST_CMAKE_COMMAND "cmake" )
set (CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k install" )
set (CTEST_SITE "dora.c-s.fr" )
set (CTEST_BUILD_NAME "Ubuntu12.04-64bits-${CTEST_BUILD_CONFIGURATION}")
set (CTEST_HG_COMMAND "/usr/bin/hg")
set (CTEST_HG_UPDATE_OPTIONS "-C")
set (CTEST_USE_LAUNCHERS ON)

set (OTB_INSTALL_PREFIX ${DASHBOARD_DIR}/install/)

set (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data

CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

# ITK_DIR:PATH=$ENV{HOME}/Dashboard/experimental/build/ITKv4-RelWithDebInfo
ITK_DIR:PATH=/home/otbval/Dashboard/experimental/install/ITK-4.5.0

# OTB_DIR:STRING=$ENV{HOME}/Dashboard/${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/build
OTB_DIR:PATH=$ENV{HOME}/Dashboard/${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/install/lib/cmake/OTB-4.5

BUILD_TESTING:BOOL=ON

ICE_INCLUDE_DIR=$ENV{HOME}/Dashboard/nightly/Ice/install/include
ICE_LIBRARY=$ENV{HOME}/Dashboard/nightly/Ice/install/lib/libOTBIce.so

CMAKE_INSTALL_PREFIX:STRING=${OTB_INSTALL_PREFIX}
")

set (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${OTB_INSTALL_PREFIX})
execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${OTB_INSTALL_PREFIX})
ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start (${dashboard_model})
ctest_update (SOURCE "${CTEST_SOURCE_DIRECTORY}")
file (WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files (${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 6)
ctest_submit ()
