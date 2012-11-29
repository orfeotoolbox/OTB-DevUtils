set (ENV{DISPLAY} ":0.0")

set (CTEST_SOURCE_DIRECTORY "$ENV{HOME}/dev/source/Monteverdi")
set (CTEST_BINARY_DIRECTORY "$ENV{HOME}/dev/build/Monteverdi")

set( CTEST_CMAKE_GENERATOR  "Unix Makefiles" )
set (CTEST_CMAKE_COMMAND "cmake" )
set (CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k install" )
set (CTEST_SITE "dora.c-s.fr" )
set (CTEST_BUILD_NAME "salbert_Ubuntu-12.04_x86_64_Debug")
set (CTEST_BUILD_CONFIGURATION "Debug")
set (CTEST_HG_COMMAND "/usr/bin/hg")
set (CTEST_HG_UPDATE_OPTIONS "-C")
set (CTEST_USE_LAUNCHERS ON)

set(OTB_INSTALL_PREFIX $ENV{HOME}/dev/install/Monteverdi)

set (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/home/otbval/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/dev/source/OTB-Data

CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

OTB_DIR:STRING=$ENV{HOME}/dev/build/OTB

BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=${OTB_INSTALL_PREFIX}

")

set (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${OTB_INSTALL_PREFIX})
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${OTB_INSTALL_PREFIX})
ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start(Experimental)
#ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
#ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 6)
ctest_submit ()

