SET (CTEST_SOURCE_DIRECTORY "D:/DONNEES/Nightly-OTB/src/OTB")
SET (CTEST_BINARY_DIRECTORY "D:/DONNEES/Nightly-OTB/bin/OTB")
SET (CTEST_CMAKE_COMMAND "D:/DONNEES/Softwares/CMake\ 2.8/bin/cmake.exe")
SET (CTEST_COMMAND "D:/DONNEES/Softwares/CMake\ 2.8/bin/ctest.exe -D Nightly -A CMakeCache.txt")
SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)
SET (CTEST_INITIAL_CACHE "
//Name of generator.
CMAKE_GENERATOR:INTERNAL=Visual Studio 10

//Name of the build
BUILDNAME:STRING=Win32-VC10Express

//Name of the computer/site where compile is being run
SITE:STRING=PC-2132356

//Build the testing tree.
BUILD_TESTING:BOOL=ON

// Build the examples
BUILD_EXAMPLES:BOOL=ON

//Use an outside build of FLTK.
OTB_USE_EXTERNAL_FLTK:BOOL=OFF

//Gdal configuration
//required to put the directory of the libgdal.dll in the path
GDAL_INCLUDE_DIR:PATH=D:/DONNEES/Softwares/OSGeo4W/apps/gdal-17/include
GDAL_LIBRARY:FILEPATH=D:/DONNEES/Softwares/OSGeo4W/apps/gdal-17/lib/gdal_i.lib

GEOTIFF_INCLUDE_DIRS:PATH=D:/DONNEES/Softwares/OSGeo4W/include
GEOTIFF_LIBRARY:FILEPATH=D:/DONNEES/Softwares/OSGeo4W/lib/geotiff_i.lib

TIFF_INCLUDE_DIRS:PATH=D:/DONNEES/Softwares/OSGeo4W/include
TIFF_LIBRARY:FILEPATH=D:/DONNEES/Softwares/OSGeo4W/lib/libtiff_i.lib

JPEG_INCLUDE_DIRS:PATH=D:/DONNEES/Softwares/OSGeo4W/include
JPEG_LIBRARY:FILEPATH=D:/DONNEES/Softwares/OSGeo4W/lib/jpeg_i.lib

//Curl configuration
OTB_USE_CURL:BOOL=ON
CURL_INCLUDE_DIR:PATH=D:/DONNEES/Softwares/OSGeo4W/include
CURL_LIBRARY:FILEPATH=D:/DONNEES/Softwares/OSGeo4W/lib/libcurl_imp.lib

// PATH to OTB-Data
OTB_DATA_ROOT:PATH=D:/DONNEES/Nightly-OTB/src/OTB-Data

CMAKE_CONFIGURATION_TYPES:STRING=Release
")
