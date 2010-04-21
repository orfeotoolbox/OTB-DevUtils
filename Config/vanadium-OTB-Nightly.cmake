SET (CTEST_SOURCE_DIRECTORY "C:/OTB/trunk/OTB")
SET (CTEST_BINARY_DIRECTORY "C:/OTB/OTB-Binary")
SET (CTEST_CMAKE_COMMAND "C:/Program Files/CMake 2.8/bin/cmake.exe")
SET (CTEST_COMMAND "C:/Program Files/CMake 2.8/bin/ctest.exe -D Experimental -A CMakeCache.txt")
SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)
SET (CTEST_INITIAL_CACHE "
//Name of generator.
CMAKE_GENERATOR:INTERNAL=Visual Studio 9 2008

//Name of the build
BUILDNAME:STRING=Win32-VC90express

//Name of the computer/site where compile is being run
SITE:STRING=vanadium

//Build the testing tree.
BUILD_TESTING:BOOL=ON

//Use an outside build of FLTK.
OTB_USE_EXTERNAL_FLTK:BOOL=OFF

//Gdal configuration
//required to put the directory of the libgdal.dll in the path
GDAL_INCLUDE_DIR:PATH=C:/OSGeo4W/apps/gdal-16/include
GDAL_LIBRARY:FILEPATH=C:/OSGeo4W/apps/gdal-16/lib/gdal_i.lib

GEOTIFF_INCLUDE_DIRS:PATH=C:/OSGeo4W/include
GEOTIFF_LIBRARY:FILEPATH=C:/OSGeo4W/lib/geotiff_i.lib

TIFF_INCLUDE_DIRS:PATH=C:/OSGeo4W/include
TIFF_LIBRARY:FILEPATH=C:/OSGeo4W/lib/libtiff_i.lib

JPEG_INCLUDE_DIRS:PATH=C:/OSGeo4W/include
JPEG_LIBRARY:FILEPATH=C:/OSGeo4W/lib/jpeg_i.lib

//Curl configuration
OTB_USE_CURL:BOOL=ON
CURL_INCLUDE_DIR:PATH=C:/OSGeo4W/include
CURL_LIBRARY:FILEPATH=C:/OSGeo4W/lib/libcurl_imp.lib

//
OTB_DATA_ROOT:PATH=C:/OTB/trunk/OTB-Data

//Setting up gettext
//GETTEXT_MSGFMT_EXECUTABLE:FILEPATH=C:/Program Files/GnuWin32/bin/msgfmt.exe
//GETTEXT_MSGMERGE_EXECUTABLE:FILEPATH=C:/Program Files/GnuWin32/bin/msgmerge.exe
//GETTEXT_INCLUDE_DIR:PATH=C:/Program Files/GnuWin32/include
//GETTEXT_LIBRARY:FILEPATH=C:/Program Files/GnuWin32/lib/libgettextlib.lib
//GETTEXT_INTL_LIBRARY:FILEPATH=C:/Program Files/GnuWin32/lib/libintl.lib

//Using curl
//OTB_USE_CURL:BOOL=ON
//CURL_INCLUDE_DIR:PATH=C:/OTB/libcurl-7.19.3-win32-ssl-msvc/include
//CURL_LIBRARY:FILEPATH=C:/OTB/libcurl-7.19.3-win32-ssl-msvc/lib/Release/curllib.lib

")
