# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "C:/Users/jmalik/Dashboard")
set(CTEST_SITE "raoul.c-s.fr" )
set(CTEST_BUILD_NAME "Win7-Visual2008-ITKV4-Release-Static")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_CMAKE_GENERATOR  "Visual Studio 9 2008" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 2)
set(CTEST_TEST_TIMEOUT 500)

set(CTEST_HG_COMMAND "C:/Program Files (x86)/Mercurial/hg.exe")
set(CTEST_HG_UPDATE_OPTIONS "-r otb-itkv4")

set(dashboard_source_name "src/OTB-ITKv4")
set(dashboard_binary_name "bin/OTB-ITKv4-Debug")

set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-SandBox")
set(dashboard_hg_branch "otb-itkv4")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
OTB_USE_CPACK:BOOL=ON

OTB_USE_EXTERNAL_ITK:BOOL=ON
ITK_DIR:PATH=C:/Users/jmalik/Dashboard/build/ITKv4-Release

OTB_DATA_ROOT:STRING=C:/Users/jmalik/Dashboard/src/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=C:/Users/jmalik/Dashboard/src/OTB-LargeInput

GDAL_INCLUDE_DIR:PATH=C:/OSGeo4W/include
GDAL_LIBRARY:FILEPATH=C:/OSGeo4W/lib/gdal_i.lib

GEOTIFF_INCLUDE_DIRS:PATH=C:/OSGeo4W/include
GEOTIFF_LIBRARY:FILEPATH=C:/OSGeo4W/lib/geotiff_i.lib

JPEG_INCLUDE_DIRS:PATH=C:/OSGeo4W/include
JPEG_INCLUDE_DIR:PATH=C:/OSGeo4W/include
JPEG_LIBRARY:FILEPATH=C:/OSGeo4W/lib/jpeg_i.lib

TIFF_INCLUDE_DIRS:PATH=C:/OSGeo4W/include
TIFF_LIBRARY:FILEPATH=C:/OSGeo4W/lib/libtiff_i.lib

OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_MAPNIK:BOOL=ON
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
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/otb_common.cmake)
