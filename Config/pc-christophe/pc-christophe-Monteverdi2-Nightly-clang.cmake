#set (ENV{DISPLAY} ":0.0")
# Avoid non-ascii characters in tool output.
#set(ENV{LC_ALL} C)

set (CTEST_BUILD_CONFIGURATION "Release")

set (DASHBOARD_DIR "$ENV{HOME}/OTB")

set (CTEST_SOURCE_DIRECTORY "${DASHBOARD_DIR}/trunk/Monteverdi2")
set (CTEST_BINARY_DIRECTORY "${DASHBOARD_DIR}/bin/Monteverdi2-clang-Nightly")
set (CTEST_CMAKE_GENERATOR  "Unix Makefiles")
set (CTEST_CMAKE_COMMAND "cmake" )
set (CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k" )
set (CTEST_SITE "pc-christophe.cst.cnes.fr" )
set (CTEST_BUILD_NAME "Fedora20-64bits-clang-Release")
set (CTEST_HG_COMMAND "/usr/bin/hg")
set (CTEST_HG_UPDATE_OPTIONS "-C")
set (CTEST_USE_LAUNCHERS ON)

set (CTEST_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

CMAKE_C_COMPILER=/usr/bin/clang
CMAKE_CXX_COMPILER=/usr/bin/clang++

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/ssh/pc-inglada/media/TeraDisk2/LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/OTB/trunk/OTB-Data

CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable -Wno-gnu
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable -Wno-gnu -Wno-overloaded-virtual

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
ITK_DIR:STRING=${DASHBOARD_DIR}/bin/ITKv4-upstream-Release
OTB_DIR:STRING=${DASHBOARD_DIR}/bin/OTB-clang-Nightly

BUILD_TESTING:BOOL=ON

#otbIce
ICE_INCLUDE_DIR=${DASHBOARD_DIR}/bin/OTB-Ice-trunk-Release/include/otb/
ICE_LIBRARY=${DASHBOARD_DIR}/bin/OTB-Ice-trunk-Release/lib/otb/libOTBIce.so

QWT_INCLUDE_DIR:PATH=/usr/include/qwt5-qt4
QWT_LIBRARY:PATH=/usr/lib64/libqwt.so.5

")

set (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start (Nightly)
ctest_update (SOURCE "${CTEST_SOURCE_DIRECTORY}")
file (WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${CTEST_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files (${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()
