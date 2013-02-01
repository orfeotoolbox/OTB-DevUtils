set (ENV{DISPLAY} ":0.0")

# Avoid non-ascii characters in tool output.
set(ENV{LC_ALL} C)

set (CTEST_BUILD_CONFIGURATION "Release")

set (DASHBOARD_DIR "$ENV{HOME}/OTB")

set (CTEST_SOURCE_DIRECTORY "${DASHBOARD_DIR}/trunk/Monteverdi2")
set (CTEST_BINARY_DIRECTORY "${DASHBOARD_DIR}/bin/Monteverdi2-Nightly")
set (CTEST_CMAKE_GENERATOR  "Unix Makefiles")
set (CTEST_CMAKE_COMMAND "cmake" )
set (CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k install" )
set (CTEST_SITE "pc-christophe.cst.cnes.fr" )
set (CTEST_BUILD_NAME "Fedora17-64bits-Release")
set (CTEST_HG_COMMAND "/usr/bin/hg")
set (CTEST_HG_UPDATE_OPTIONS "-C")
set (CTEST_USE_LAUNCHERS ON)

set (OTB_INSTALL_PREFIX ${DASHBOARD_DIR}/bin/Monteverdi2-Nightly-Install)

set (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=OFF
//OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOMe}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/OTB/trunk/OTB-Data

CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

OTB_DIR:STRING=$ENV{HOME}/OTB/bin/OTB-Nightly

BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=${OTB_INSTALL_PREFIX}
")

set (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${OTB_INSTALL_PREFIX})
execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${OTB_INSTALL_PREFIX})
ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start (Nightly)
ctest_update (SOURCE "${CTEST_SOURCE_DIRECTORY}")
file (WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files (${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()