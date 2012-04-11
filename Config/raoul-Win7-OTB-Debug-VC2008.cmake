SET (CTEST_SOURCE_DIRECTORY "C:/Users/jmalik/Dashboard/src/OTB")
SET (CTEST_BINARY_DIRECTORY "C:/Users/jmalik/Dashboard/build/OTB-Debug-VC2008")

SET (CTEST_CMAKE_GENERATOR  "Visual Studio 9 2008" )
SET (CTEST_CMAKE_COMMAND "C:/Program Files (x86)/CMake 2.8/bin/cmake.exe")
SET (CTEST_SITE "raoul.c-s.fr" )
SET (CTEST_BUILD_NAME "Win7-Visual2008-Debug-Static")
SET (CTEST_BUILD_CONFIGURATION "Debug")
SET (CTEST_HG_COMMAND "C:/Program Files (x86)/Mercurial/hg.exe")
SET (CTEST_HG_UPDATE_OPTIONS "-C")

SET (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=OFF
BUILD_APPLICATIONS:BOOL=ON

OTB_WRAP_QT:BOOL=ON

# On windows, we need python27_d.lib, dragged by python.h
# and it is not available with OSGeo4W python
# OTB_WRAP_PYTHON:BOOL=ON

OTB_WRAP_JAVA:BOOL=ON

OTB_USE_CPACK:BOOL=OFF

OTB_DATA_ROOT:STRING=C:/Users/jmalik/Dashboard/src/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_LARGEINPUT_ROOT:PATH=C:/Users/jmalik/Dashboard/src/OTB-LargeInput

GDAL_INCLUDE_DIR:PATH=C:/OSGeo4W/include
GDAL_LIBRARY:FILEPATH=C:/OSGeo4W/lib/gdal_i.lib


OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_MAPNIK:BOOL=ON
MAPNIK_INCLUDE_DIR:PATH=C:/OSGeo4W/include/mapnik
MAPNIK_LIBRARY:FILEPATH=C:/OSGeo4W/lib/mapnik.lib
FREETYPE2_INCLUDE_DIR:PATH=C:/OSGeo4W/include/freetype
ICUUC_INCLUDE_DIR:PATH=C:/Program Files (x86)/icu4c-4_2_1-Win32-msvc9/icu/include
ICUUC_LIBRARY:FILEPATH=C:/Program Files (x86)/icu4c-4_2_1-Win32-msvc9/icu/lib/icuuc.lib
LTDL_INCLUDE_DIR:PATH=C:/Program Files (x86)/GnuWin32/include
LTDL_LIBRARY:FILEPATH=C:/Program Files (x86)/GnuWin32/lib/ltdl.lib

GEOTIFF_INCLUDE_DIRS:PATH=C:/OSGeo4W/include
GEOTIFF_LIBRARY:FILEPATH=C:/OSGeo4W/lib/geotiff_i.lib

JPEG_INCLUDE_DIRS:PATH=C:/OSGeo4W/include
JPEG_INCLUDE_DIR:PATH=C:/OSGeo4W/include
JPEG_LIBRARY:FILEPATH=C:/OSGeo4W/lib/jpeg_i.lib

TIFF_INCLUDE_DIRS:PATH=C:/OSGeo4W/include
TIFF_LIBRARY:FILEPATH=C:/OSGeo4W/lib/libtiff_i.lib

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
OTB_USE_JPEG2000:BOOL=ON

SWIG_EXECUTABLE:FILEPATH=C:/OSGeo4W/apps/swigwin/swig.exe

PYTHON_EXECUTABLE:FILEPATH=C:/OSGeo4W/bin/python.exe
PYTHON_INCLUDE_DIR:PATH=C:/OSGeo4W/apps/Python27/include
PYTHON_LIBRARY:FILEPATH=C:/OSGeo4W/apps/Python27/libs/python27.lib

# Java Stuffs
JAVA_JVM_LIBRARY:FILEPATH=C:/Program Files (x86)/Java/jdk1.6.0_22/lib/jvm.lib
JAVA_INCLUDE_PATH:PATH=C:/Program Files (x86)/Java/jdk1.6.0_22/include
JAVA_INCLUDE_PATH2:PATH=C:/Program Files (x86)/Java/jdk1.6.0_22/include/win32
JAVA_AWT_INCLUDE:PATH=C:/Program Files (x86)/Java/jdk1.6.0_22/include
JAVA_RUNTIME:FILEPATH=C:/Program Files (x86)/Java/jdk1.6.0_22/bin/java.exe
JAVA_COMPILE:FILEPATH=C:/Program Files (x86)/Java/jdk1.6.0_22/bin/javac.exe
JAVA_ARCHIVE:FILEPATH=C:/Program Files (x86)/Java/jdk1.6.0_22/bin/jar.exe
JAVA_MAXIMUM_HEAP_SIZE:STRING=1G
JAVA_INITIAL_HEAP_SIZE:STRING=256m

Java_JAR_EXECUTABLE:FILEPATH=C:/Program Files (x86)/Java/jdk1.6.0_22/bin/jar.exe
Java_JAVAC_EXECUTABLE:FILEPATH=C:/Program Files (x86)/Java/jdk1.6.0_22/bin/javac.exe
Java_JAVA_EXECUTABLE:FILEPATH=C:/Program Files (x86)/Java/jdk1.6.0_22/bin/java.exe

")

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
#ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()
