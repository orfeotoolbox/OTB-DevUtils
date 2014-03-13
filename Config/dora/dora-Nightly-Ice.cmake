set (ENV{DISPLAY} ":0.0")
set (ENV{LANG} "C")

set (CTEST_BUILD_CONFIGURATION "Release")

set (CTEST_SOURCE_DIRECTORY "$ENV{HOME}/Dashboard/nightly/Ice/src")
set (CTEST_BINARY_DIRECTORY "$ENV{HOME}/Dashboard/nightly/Ice/build")
set (CTEST_CMAKE_GENERATOR  "Unix Makefiles")
set (CTEST_CMAKE_COMMAND "cmake" )
set (CTEST_BUILD_COMMAND "/usr/bin/make -j6 -i -k install" )
set (CTEST_SITE "dora.c-s.fr" )
set (CTEST_BUILD_NAME "Ubuntu12.04-64bits-${CTEST_BUILD_CONFIGURATION}")
set (CTEST_HG_COMMAND "/usr/bin/hg")
set (CTEST_HG_UPDATE_OPTIONS "")
set (CTEST_USE_LAUNCHERS ON)

set (ICE_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

CMAKE_C_FLAGS:STRING=-Wall
CMAKE_CXX_FLAGS:STRING=-Wall

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

ITK_DIR:PATH=/home/otbval/Dashboard/experimental/build/ITKv4-RelWithDebInfo

OTB_DIR:PATH=/home/otbval/Dashboard/nightly/OTB-Release/install

BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:PATH=$ENV{HOME}/Dashboard/nightly/Ice/install

# GLFW_INCLUDE_DIR:PATH=$ENV{HOME}/Tools/glfw/install/include
# GLFW_LIBRARY:FILEPATH=$ENV{HOME}/Tools/glfw/install/lib/libglfw3.a

BUILD_ICE_APPLICATION:BOOL=OFF
")

set (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${ICE_INSTALL_PREFIX})
execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${ICE_INSTALL_PREFIX})
ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start (Nightly)
ctest_update (SOURCE "${CTEST_SOURCE_DIRECTORY}")
file (WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${ICE_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files (${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
#ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 6)
ctest_submit ()
