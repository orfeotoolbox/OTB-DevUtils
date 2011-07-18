# -----------------------------------------------------------------------------
# Nightly script for OpenJPEG v1.5 with hulk paltform
# This will retrieve/compile/run tests/upload to cdash OpenJPEG
# Results will be available at: http://my.cdash.org/index.php?project=OPENJPEG
# ctest -S hulk_openJPEG_v1.5_nightly.cmake -V
# Author: mickael.savinaud@c-s.fr
# Date: 2011-07-12
# -----------------------------------------------------------------------------

cmake_minimum_required(VERSION 2.8)

# Set where to find srr and test data and where to build binaries.
SET (CTEST_SOURCE_DIRECTORY       "$ENV{HOME}/Dashboard/src/OpenJPEG/openjpeg-1.5")
SET (CTEST_BINARY_DIRECTORY       "$ENV{HOME}/Dashboard/build/OpenJPEG_v1.5")
SET (CTEST_SOURCE_DATA_DIRECTORY  "$ENV{HOME}/Dashboard/src/OpenJPEG/opj-data")

# User inputs:
SET( CTEST_CMAKE_GENERATOR      "Unix Makefiles" )    # What is your compilation apps ? (Eclipse CDT4 - Unix Makefiles)
SET( CTEST_CMAKE_COMMAND        "cmake" )
SET( CTEST_BUILD_COMMAND        "/usr/bin/make " )
SET( CTEST_SITE                 "hulk.c-s.fr" )       # Generally the output of hostname
SET( CTEST_BUILD_CONFIGURATION  Debug)                # What type of build do you want ?
SET( CTEST_BUILD_NAME           "Ubuntu10.04-64bits-v1.5-${CTEST_BUILD_CONFIGURATION}") # Build Name
SET( ENV{CFLAGS} "-Wall" )                            # All warnings ...

# FIXME: For the moment, I need to build my own version of liblcms2
set( CACHE_CONTENTS "
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

BUILD_TESTING:BOOL=TRUE
BUILD_EXAMPLES:BOOL=TRUE

JPEG2000_CONFORMANCE_DATA_ROOT:PATH=${CTEST_SOURCE_DATA_DIRECTORY}

LCMS2_INCLUDE_DIR:PATH=/home/mickael/dev/src/OpenJPEG/trunk/thirdparty/liblcms2/include
LCMS2_LIBRARY:PATH=/home/mickael/dev/libMS/libLCMS2/thirdparty/lib/liblcms2.a

" )

# Update method 
# repository: http://openjpeg.googlecode.com/svn/branches/openjpeg-1.5 (openjpeg-read-only)
# need to use https for CS machine
SET( CTEST_SVN_COMMAND      "/usr/bin/svn")


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

