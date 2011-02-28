SET (CTEST_SOURCE_DIRECTORY "C:/Users/jmalik/Dashboard/src/OTB_3.8")
SET (CTEST_BINARY_DIRECTORY "C:/Users/jmalik/Dashboard/build/OTB-Release-VC2008-3_8")

SET (CTEST_CMAKE_GENERATOR  "Visual Studio 9 2008" )
SET (CTEST_CMAKE_COMMAND "C:/Program Files (x86)/CMake 2.8/bin/cmake.exe")
SET (CTEST_SITE "raoul.c-s.fr" )
SET (CTEST_BUILD_NAME "Win7-Visual2008-Release-Static-3_8")
SET (CTEST_BUILD_CONFIGURATION "Release")
#SET (CTEST_HG_COMMAND "C:/Program Files (x86)/Mercurial/hg.exe")
#SET (CTEST_HG_UPDATE_OPTIONS "-C")

SET (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=OFF
OTB_USE_CPACK:BOOL=ON

OTB_DATA_ROOT:STRING=C:/Users/jmalik/Dashboard/src/OTB-Data
#OTB_DATA_USE_LARGEINPUT:BOOL=ON
#OTB_DATA_LARGEINPUT_ROOT:PATH=C:/Users/jmalik/Dashboard/src/OTB-LargeInput

GDAL_INCLUDE_DIR:PATH=C:/OSGeo4W/include
GDAL_LIBRARY:FILEPATH=C:/OSGeo4W/lib/gdal_i.lib


GEOTIFF_INCLUDE_DIRS:PATH=C:/OSGeo4W/include
GEOTIFF_LIBRARY:FILEPATH=C:/OSGeo4W/lib/geotiff_i.lib

JPEG_INCLUDE_DIRS:PATH=C:/OSGeo4W/include
JPEG_INCLUDE_DIR:PATH=C:/OSGeo4W/include
JPEG_LIBRARY:FILEPATH=C:/OSGeo4W/lib/jpeg_i.lib

TIFF_INCLUDE_DIRS:PATH=C:/OSGeo4W/include
TIFF_LIBRARY:FILEPATH=C:/OSGeo4W/lib/libtiff_i.lib

OTB_USE_EXTERNAL_BOOST:BOOL=OFF
OTB_USE_MAPNIK:BOOL=OFF
MAPNIK_INCLUDE_DIR:PATH=C:/OSGeo4W/include/mapnik
MAPNIK_LIBRARY:FILEPATH=C:/OSGeo4W/lib/mapnik.lib
FREETYPE2_INCLUDE_DIR:PATH=C:/OSGeo4W/include/freetype
ICUUC_INCLUDE_DIR:PATH=C:/Program Files (x86)/icu4c-4_2_1-Win32-msvc9/icu/include
ICUUC_LIBRARY:FILEPATH=C:/Program Files (x86)/icu4c-4_2_1-Win32-msvc9/icu/lib/icuuc.lib
LTDL_INCLUDE_DIR:PATH=C:/Program Files (x86)/GnuWin32/include
LTDL_LIBRARY:FILEPATH=C:/Program Files (x86)/GnuWin32/lib/ltdl.lib

OTB_USE_CURL:BOOL=ON
CURL_INCLUDE_DIR:PATH=C:/OSGeo4W/include
CURL_LIBRARY:FILEPATH=C:/OSGeo4W/lib/libcurl_imp.lib

OTB_USE_EXTERNAL_EXPAT:BOOL=ON
EXPAT_INCLUDE_DIR:PATH=C:/OSGeo4W/include
EXPAT_LIBRARY:FILEPATH=C:/OSGeo4W/lib/libexpat.lib

OTB_USE_LIBLAS:BOOL=ON
OTB_USE_EXTERNAL_LIBLAS:BOOL=ON
LIBLAS_INCLUDE_DIR:PATH=C:/OSGeo4W/include
LIBLAS_LIBRARY:FILEPATH=C:/OSGeo4W/lib/liblas_c.lib

ZLIB_INCLUDE_DIR:PATH=C:/OSGeo4W/include
ZLIB_LIBRARY:FILEPATH=C:/OSGeo4W/lib/zlib.lib

PNG_PNG_INCLUDE_DIR:PATH=C:/OSGeo4W/include
PNG_LIBRARY:FILEPATH=C:/OSGeo4W/lib/libpng13.lib

OTB_USE_GETTEXT:BOOL=OFF
OTB_USE_JPEG2000:BOOL=OFF

")

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_start(Experimental)
#ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
#ctest_submit (PARTS Start Update Configure)
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
#ctest_submit (PARTS Build)
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()
