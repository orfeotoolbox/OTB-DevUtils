# -----------------------------------------------------------------------------
# Nihtly script for OpenJPEG v1.5
# This will retrieve/compile/run tests/upload to cdash OpenJPEG
# Results will be available at: http://my.cdash.org/index.php?project=OPENJPEG
# ctest -S PC8908_OpenJPEG_v1.5_Nightly.cmake -V
# Author: mickael.savinaud@c-s.fr
# Date: 2011-06-17
# -----------------------------------------------------------------------------

cmake_minimum_required(VERSION 2.8)

# Set where to find srr and test data and where to build binaries.
SET (CTEST_SOURCE_DIRECTORY       "C:/OpenJPEG/nightly/opj-1.5")
SET (CTEST_BINARY_DIRECTORY       "C:/OpenJPEG/nightly/build/OpenJPEG_v1.5")
SET (CTEST_SOURCE_DATA_DIRECTORY  "C:/OpenJPEG/opj-data")

# User inputs:
SET( CTEST_CMAKE_GENERATOR      "Visual Studio 9 2008" )      # What is your compilation apps ?
SET( CTEST_CMAKE_COMMAND        "C:/Program Files/CMake 2.8/bin/cmake.exe" )
SET( CTEST_SITE                 "PC8908.c-s.fr" )             # Generally the output of hostname
SET( CTEST_BUILD_CONFIGURATION  Debug)                        # What type of build do you want ?
SET( CTEST_BUILD_NAME           "WinXP-VS2008-32bits-v1.5-${CTEST_BUILD_CONFIGURATION}") # Build Name
SET( ENV{CFLAGS} "-Wall" )                                    # All warnings ...

# FIXME: For the moment we used the OSGeo4W environement and personal build of liblcms
# altough opj lib provided internal src for this lib
set( CACHE_CONTENTS "
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

BUILD_TESTING:BOOL=TRUE
BUILD_EXAMPLES:BOOL=TRUE

JPEG2000_CONFORMANCE_DATA_ROOT:PATH=${CTEST_SOURCE_DATA_DIRECTORY}

BUILD_THIRDPARTY:BOOL=ON

LCMS2_INCLUDE_DIR:PATH=C:/OpenJPEG/trunk/thirdparty/liblcms2/include
LCMS2_LIBRARY:PATH=C:/OpenJPEG/utils/lcms2/thirdparty/lib/Debug/liblcms2.lib

TIFF_INCLUDE_DIR:PATH=C:/OSGeo4W/include
TIFF_LIBRARY:PATH=C:/OSGeo4W/lib/libtiff_i.lib

PNG_PNG_INCLUDE_DIR:PATH=C:/OSGeo4W/include/libpng12
PNG_LIBRARY:PATH=C:/OSGeo4W/lib/libpng13.lib

ZLIB_INCLUDE_DIR:PATH=C:/OSGeo4W/include
ZLIB_LIBRARY:PATH=C:/OSGeo4W/lib/zlib.lib
" )

# Update method 
# repository: http://openjpeg.googlecode.com/svn/branches/openjpeg-1.5 
# need to use https for CS machine
set( CTEST_UPDATE_COMMAND   "svn")

# 3. cmake specific:
#set( CTEST_NOTES_FILES      "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}")

ctest_empty_binary_directory( "${CTEST_BINARY_DIRECTORY}" )
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "${CACHE_CONTENTS}")

# Perform the Nightly build
ctest_start(Nightly TRACK Nightly-v1.5)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
ctest_configure(BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_submit()

