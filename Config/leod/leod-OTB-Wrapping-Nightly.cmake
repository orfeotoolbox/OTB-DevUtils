SET (CTEST_SOURCE_DIRECTORY "/Users/otbval/Dashboard/nightly/OTB-Wrapping/src")
SET (CTEST_BINARY_DIRECTORY "/Users/otbval/Dashboard/nightly/OTB-Wrapping/build")

SET( CTEST_CMAKE_GENERATOR  "Unix Makefiles" )
SET (CTEST_CMAKE_COMMAND "cmake" )
SET (CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k install" )
SET (CTEST_SITE "leod.c-s.fr")
SET (CTEST_BUILD_NAME "MacOSX10.8-Release-macport")
SET (CTEST_BUILD_CONFIGURATION "Release")
SET (CTEST_HG_COMMAND "/opt/local/bin/hg")
SET (CTEST_HG_UPDATE_OPTIONS "-C")

SET (CTEST_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

#OTB_DATA_USE_LARGEINPUT:BOOL=ON
#OTB_DATA_LARGEINPUT_ROOT:STRING=/Users/otbval/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data

CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable -Wno-gnu
CMAKE_BUILD_TYPE:STRING=Release

OTB_DIR:STRING=$ENV{HOME}/Dashboard/nightly/OTB-Release/build

BUILD_TESTING:BOOL=ON

CMAKE_INSTALL_PREFIX:STRING=/Users/otbval/Dashboard/nightly/OTB-Wrapping/install

GDALCONFIG_EXECUTABLE:FILEPATH=/opt/local/bin/gdal-config
GDAL_CONFIG:FILEPATH=/opt/local/bin/gdal-config
GDAL_INCLUDE_DIR:STRING=/opt/local/include
GDAL_LIBRARY:FILEPATH=/opt/local/lib/libgdal.dylib

GEOTIFF_INCLUDE_DIRS:PATH=/opt/local/include
GEOTIFF_LIBRARY:FILEPATH=/opt/local/lib/libgeotiff.dylib

TIFF_INCLUDE_DIRS:PATH=/opt/local/include
TIFF_LIBRARY:FILEPATH=/opt/local/lib/libtiff.dylib

JPEG_INCLUDE_DIRS:PATH=/opt/local/include
JPEG_INCLUDE_DIR:PATH=/opt/local/include
JPEG_LIBRARY:FILEPATH=/opt/local/lib/libjpeg.dylib

## TODO : need configuration
#SWIG_DIR:PATH=$ENV{HOME}/OTB-OUTILS/swig/install-macosx
#SWIG_EXECUTABLE:FILEPATH=$ENV{HOME}/OTB-OUTILS/swig/install-macosx/bin/swig
#CableSwig_DIR:PATH=$ENV{HOME}/OTB-OUTILS/cableswig/binaries-macosx-release-cableswig-3.16.0
WRAP_ITK_PYTHON:BOOL=ON
WRAP_ITK_JAVA:BOOL=ON

# We need the following to be compatible with cmake 2.8.2
JAVA_ARCHIVE:FILEPATH=/usr/bin/jar
JAVA_COMPILE:FILEPATH=/usr/bin/javac
JAVA_RUNTIME:FILEPATH=/usr/bin/java

#Python Executable
PYTHON_EXECUTABLE:FILEPATH=/opt/local/bin/python

")

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})
ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${CTEST_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()

