SET (CTEST_SOURCE_DIRECTORY "C:/Users/msavinau/dev/nightly/MVD-MVSC10-Release/src")
SET (CTEST_BINARY_DIRECTORY "C:/Users/msavinau/dev/nightly/MVD-MVSC10-Release/build")

SET (CTEST_CMAKE_GENERATOR  "Visual Studio 10" )
SET (CTEST_CMAKE_COMMAND "C:/Program Files (x86)/CMake 2.8/bin/cmake.exe")
SET (CTEST_SITE "PO9450.c-s.fr" )
SET (CTEST_BUILD_NAME "Win7-MVD-MVSC10-Release-Static")
SET (CTEST_BUILD_CONFIGURATION "Release")
SET (CTEST_HG_COMMAND "C:/Program Files (x86)/Mercurial/hg.exe")
SET (CTEST_HG_UPDATE_OPTIONS "-C")

SET (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

CMAKE_INCLUDE_PATH:PATH=$ENV{OSGEO4W_ROOT}/include
CMAKE_LIBRARY_PATH:PATH=$ENV{OSGEO4W_ROOT}/lib

BUILD_TESTING:BOOL=OFF
OTB_USE_CPACK:BOOL=ON

OTB_DIR:PATH=C:/Users/msavinau/dev/nightly/OTB-MVSC10-ExternalOSSIM-ExternaFLTK-Release/install/lib/otb
OTB_USE_CPACK:BOOL=ON

FLTK_DIR:PATH=C:/Users/msavinau/dev/OTB-ExternalTools/fltk-1.3.0_Release/install/CMake
")

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_start(Experimental)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()
