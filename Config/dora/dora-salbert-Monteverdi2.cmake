set (ENV{DISPLAY} ":0.0")
set (ENV{LANG} "C")

set (CTEST_BUILD_CONFIGURATION "Debug")
# set (CTEST_BUILD_CONFIGURATION "Release")

#set (OTB_DASHBOARD_DIR "$ENV{HOME}/dev/install/Monteverdi2Dashboard/nightly/Monteverdi2-${CTEST_BUILD_CONFIGURATION}")

set (CTEST_SOURCE_DIRECTORY "$ENV{HOME}/dev/source/monteverdi2")
set (CTEST_BINARY_DIRECTORY "$ENV{HOME}/dev/build/monteverdi2")
set (CTEST_CMAKE_GENERATOR  "Unix Makefiles")
set (CTEST_CMAKE_COMMAND "cmake" )
set (CTEST_BUILD_COMMAND "/usr/bin/make -j4 -k install" )
set (CTEST_SITE "dora.c-s.fr" )
set (CTEST_BUILD_NAME "UbuntuMM.mm-64bits-${CTEST_BUILD_CONFIGURATION}-$ENV{USER}")
# set (CTEST_GIT_COMMAND "/usr/bin/git")
# set (CTEST_GIT_UPDATE_OPTIONS "")
set (CTEST_USE_LAUNCHERS ON)

set (MVD2_INSTALL_PREFIX "$ENV{HOME}/dev/install/monteverdi2")

set (MVD2_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

CMAKE_C_FLAGS:STRING=-Wall -Wextra
CMAKE_CXX_FLAGS:STRING=-Wall -Wextra
# CMAKE_C_FLAGS:STRING=-Wall -Wextra -Wno-unused-parameter -Wno-sign-compare -Wno-unused-variable
# CMAKE_CXX_FLAGS:STRING=-Wall -Wextra -Wno-unused-parameter

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

ITK_DIR:PATH=/home/otbval/Tools/ITK-4.7.1/install/lib/cmake/ITK-4.7

OTB_DIR:PATH=$ENV{HOME}/dev/install/otb/lib/cmake/OTB-5.3

BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=${MVD2_INSTALL_PREFIX}

MERGE_TS:BOOL=OFF
GENERATE_SQL:BOOL=ON

# Temporary workaround
# OTB_USE_QT4:BOOL=ON
")

set (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${MVD2_INSTALL_PREFIX})
execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${MVD2_INSTALL_PREFIX})
ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start (Experimental)
# ctest_update (SOURCE "${CTEST_SOURCE_DIRECTORY}")
file (WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${MVD2_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files (${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 6)
ctest_submit ()
