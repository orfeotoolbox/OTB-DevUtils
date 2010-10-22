SET (CTEST_SOURCE_DIRECTORY "C:/Users/jmalik/dev/src/OTB-Wrapping")
SET (CTEST_BINARY_DIRECTORY "C:/Users/jmalik/dev/nightly/build/OTB-Wrapping")

SET( CTEST_CMAKE_GENERATOR  "NMake Makefiles" )
SET (CTEST_CMAKE_COMMAND "cmake" )
SET (CTEST_BUILD_COMMAND "nmake" )
SET (CTEST_SITE "raoul.c-s.fr" )
SET (CTEST_BUILD_NAME "Win7-VisualExpress2008-Release")
SET (CTEST_BUILD_CONFIGURATION "Release")
SET (CTEST_HG_COMMAND "hg")
SET (CTEST_HG_UPDATE_OPTIONS "-C")

SET (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
OTB_DATA_ROOT:STRING=C:/Users/jmalik/dev/src/OTB-Data
CMAKE_BUILD_TYPE:STRING=Release
BUILD_TESTING:BOOL=ON
GDAL_INCLUDE_DIR:PATH=C:/OSGeo4W/apps/gdal-16/include
OTB_DIR:PATH=C:/Users/jmalik/dev/nightly/build/OTB


SWIG_DIR:PATH=C:/Users/jmalik/dev/outils/swigwin-1.3.40
SWIG_EXECUTABLE:FILEPATH=C:/Users/jmalik/dev/outils/swigwin-1.3.40/swig.exe
CableSwig_DIR:PATH=C:/Users/jmalik/dev/outils/cableswig/build
WRAP_ITK_PYTHON:BOOL=ON
WRAP_ITK_JAVA:BOOL=OFF

")


SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})
ctest_empty_binary_directory ("C:/Users/jmalik/dev/nightly/install/OTB-Wrapping")
ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_submit ()
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_submit ()
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 2)
ctest_submit ()

