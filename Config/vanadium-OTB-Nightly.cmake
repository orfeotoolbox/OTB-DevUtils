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

//Path to a file.

GDAL_INCLUDE_DIR:PATH=C:/OTB/gdal-1.7.1/gcore;C:/OTB/gdal-1.7.1/port
GEOTIFF_INCLUDE_DIRS:PATH=C:/OTB/gdal-1.7.1/frmts/gtiff/libgeotiff
JPEG_INCLUDE_DIRS:PATH=C:/OTB/gdal-1.7.1/frmts/jpeg/libjpeg
OGR_INCLUDE_DIRS:PATH=C:/OTB/gdal-1.7.1/ogr;C:/OTB/gdal-1.7.1/ogr/ogrsf_frmts
TIFF_INCLUDE_DIRS:PATH=C:/OTB/gdal-1.7.1/frmts/gtiff/libtiff

//Path to a library.
GDAL_LIBRARY:FILEPATH=C:/OTB/gdal-1.7.1/gdal.lib;odbc32.lib;odbccp32.lib;user32.lib
GEOTIFF_LIBRARY:FILEPATH=C:/OTB/gdal-1.7.1/gdal.lib
TIFF_LIBRARY:FILEPATH=C:/OTB/gdal-1.7.1/gdal.lib

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
