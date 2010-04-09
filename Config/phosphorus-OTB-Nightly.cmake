SET (CTEST_SOURCE_DIRECTORY "E:/crsec/trunk/OTB")
SET (CTEST_BINARY_DIRECTORY "E:/crsec/OTB-Binary")
SET (CTEST_CMAKE_COMMAND "E:/crsec/cmake/cmake-binary/bin/Release/cmake.exe")
SET (CTEST_COMMAND "E:/crsec/cmake/cmake-binary/bin/Release/ctest.exe -D Nightly -A CMakeCache.txt")
SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)
SET (CTEST_INITIAL_CACHE "
//Name of generator.
CMAKE_GENERATOR:INTERNAL=Visual Studio 9 2008

//Name of the build
BUILDNAME:STRING=Win32-VC90prof

//Name of the computer/site where compile is being run
SITE:STRING=phosphorus

//Build the testing tree.
BUILD_TESTING:BOOL=ON

//Use an outside build of FLTK.
OTB_USE_EXTERNAL_FLTK:BOOL=OFF

//Path to a file.
GDAL_INCLUDE_DIR:PATH=E:/crsec/gdal-1.6.0-win32-vc90-debug/include

//Path to a library.
GDAL_LIBRARY:FILEPATH=E:/crsec/gdal-1.6.0-win32-vc90-debug/lib/gdal.lib

//
OTB_DATA_ROOT:PATH=E:/crsec/trunk/OTB-Data

//Setting up gettext
GETTEXT_MSGFMT_EXECUTABLE:FILEPATH=C:/Program Files/GnuWin32/bin/msgfmt.exe
GETTEXT_MSGMERGE_EXECUTABLE:FILEPATH=C:/Program Files/GnuWin32/bin/msgmerge.exe
GETTEXT_INCLUDE_DIR:PATH=C:/Program Files/GnuWin32/include
GETTEXT_LIBRARY:FILEPATH=C:/Program Files/GnuWin32/lib/libgettextlib.lib
GETTEXT_INTL_LIBRARY:FILEPATH=C:/Program Files/GnuWin32/lib/libintl.lib

//Using curl
//OTB_USE_CURL:BOOL=ON
//CURL_INCLUDE_DIR:PATH=E:/crsec/libcurl-7.19.3-win32-ssl-msvc/include
//CURL_LIBRARY:FILEPATH=E:/crsec/libcurl-7.19.3-win32-ssl-msvc/lib/Release/curllib.lib

")
