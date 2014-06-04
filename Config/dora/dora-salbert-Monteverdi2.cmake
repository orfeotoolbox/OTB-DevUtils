set (ENV{DISPLAY} ":0.0")
set (ENV{LANG} "C")

set (CTEST_BUILD_CONFIGURATION "Debug")
# set (CTEST_BUILD_CONFIGURATION "Release")

#set (OTB_DASHBOARD_DIR "$ENV{HOME}/dev/install/Monteverdi2Dashboard/nightly/Monteverdi2-${CTEST_BUILD_CONFIGURATION}")

set (CTEST_SOURCE_DIRECTORY "$ENV{HOME}/dev/source/Monteverdi2")
set (CTEST_BINARY_DIRECTORY "$ENV{HOME}/dev/build/Monteverdi2")
set (CTEST_CMAKE_GENERATOR  "Unix Makefiles")
set (CTEST_CMAKE_COMMAND "cmake" )
set (CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k install" )
set (CTEST_SITE "dora.c-s.fr" )
set (CTEST_BUILD_NAME "Ubuntu12.04-64bits-${CTEST_BUILD_CONFIGURATION}-$ENV{USER}")
set (CTEST_HG_COMMAND "/usr/bin/hg")
set (CTEST_HG_UPDATE_OPTIONS "")
set (CTEST_USE_LAUNCHERS ON)

set (MVD2_INSTALL_PREFIX "$ENV{HOME}/dev/install/Monteverdi2")

set (MVD2_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

CMAKE_C_FLAGS:STRING=-Wall
CMAKE_CXX_FLAGS:STRING=-Wall

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

ITK_DIR:PATH=/home/otbval/Dashboard/experimental/build/ITKv4-RelWithDebInfo

# OTB_DIR:STRING=/home/otbval/Dashboard/nightly/OTB-Release/install/lib/otb
# OTB_DIR:STRING=~/dev/install/OTB-stable/lib/otb
OTB_DIR:STRING=~/dev/install/OTB/lib/otb
# OTB_DIR:STRING=~/dev/build/OTB/bin

# ICE_DIR:STRING=$ENV{HOME}/dev/install/ice
ICE_INCLUDE_DIR=$ENV{HOME}/dev/install/Ice/include/otb
ICE_LIBRARY=$ENV{HOME}/dev/install/Ice/lib/otb/libOTBIce.so

BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=${MVD2_INSTALL_PREFIX}

MERGE_TS:BOOL=OFF
GENERATE_SQL:BOOL=ON
")

set (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${MVD2_INSTALL_PREFIX})
execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${MVD2_INSTALL_PREFIX})
ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start (Experimental)
#ctest_update (SOURCE "${CTEST_SOURCE_DIRECTORY}")
file (WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${MVD2_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files (${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 6)
ctest_submit ()
