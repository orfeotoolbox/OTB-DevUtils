# -----------------------------------------------------------------------------
# Nihtly script for OpenJPEG v2
# This will retrieve/compile/run tests/upload to cdash OpenJPEG
# Results will be available at: http://my.cdash.org/index.php?project=OPENJPEG
# ctest -S PC8908_openJPEG_v2_Nightly.cmake -V
# Author: mickael.savinaud@c-s.fr
# Date: 2011-06-17
# -----------------------------------------------------------------------------

cmake_minimum_required(VERSION 2.8)

# Set where to find srr and test data and where to build binaries.
SET (CTEST_SOURCE_DIRECTORY "C:/OpenJPEG/nightly/opj-v2")
SET (CTEST_BINARY_DIRECTORY "C:/OpenJPEG/nightly/build/OpenJPEG_v2")
SET (CTEST_SOURCE_DATA_DIRECTORY  "C:/OpenJPEG/J2KP4files")

# User inputs:
SET (CTEST_CMAKE_GENERATOR      "Visual Studio 9 2008" )       # What is your compilation apps ?
SET (CTEST_CMAKE_COMMAND        "C:/Program Files/CMake 2.8/bin/cmake.exe")
SET (CTEST_SITE                 "PC8908.c-s.fr" )              # generally the output of hostname
set( CTEST_BUILD_CONFIGURATION  "Debug")                       # What type of build do you want ?
SET (CTEST_BUILD_NAME           "WinXP-VS2008-32bits-v2-${CTEST_BUILD_CONFIGURATION}") # Add by MS

# For the moment we need the OSGeo4W environement and use the lib freeimage compiled by opj 
set( CACHE_CONTENTS "
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

#CMAKE_C_FLAGS:STRING= 

BUILD_TESTING:BOOL=TRUE
BUILD_EXAMPLES:BOOL=TRUE

FREEIMAGE_FOUND:BOOL=ON                                                                                                                 
FREEIMAGE_INCLUDE_PATH:PATH=${CTEST_SOURCE_DIRECTORY}/libs/FreeImage
FREEIMAGE_LIBRARY:PATH=${CTEST_SOURCE_DIRECTORY}/libs/FreeImage/freeimage.s.lib

PNG_PNG_INCLUDE_DIR:PATH=C:/OSGeo4W/include
PNG_LIBRARY:FILEPATH=C:/OSGeo4W/lib/libpng13.lib

TIFF_INCLUDE_DIR:PATH=C:/OSGeo4W/include
TIFF_LIBRARY:FILEPATH=C:/OSGeo4W/lib/libtiff_i.lib

ZLIB_INCLUDE_DIR:PATH=C:/OSGeo4W/include
ZLIB_LIBRARY:FILEPATH=C:/OSGeo4W/lib/zlib.lib

OPJ_DATA_ROOT=${CTEST_SOURCE_DATA_DIRECTORY}

REF_DECODER_BIN_PATH:PATH=C:/Program Files/Kakadu

")

# Update method 
# repository: http://openjpeg.googlecode.com/svn/branches/v2 (openjpeg-read-only)
# need to use https for CS machine 
set( CTEST_UPDATE_COMMAND   "svn")

# 3. cmake specific:
#set( CTEST_NOTES_FILES      "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}")

ctest_empty_binary_directory( "${CTEST_BINARY_DIRECTORY}" )
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "${CACHE_CONTENTS}")

# Perform the Nightly build
ctest_start(Nightly TRACK Nightly-v2)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
ctest_configure(BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_build(BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_submit()
