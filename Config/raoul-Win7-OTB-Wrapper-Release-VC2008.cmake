SET (CTEST_BUILD_CONFIGURATION "Release")
SET (CTEST_TEST_CONFIGURATION "Release")

SET (CTEST_SOURCE_DIRECTORY "C:/Users/jmalik/Dashboard/src/OTB-Wrapper")
SET (CTEST_BINARY_DIRECTORY "C:/Users/jmalik/Dashboard/build/OTB-Wrapper-${CTEST_BUILD_CONFIGURATION}-VC2008")

SET (CTEST_CMAKE_GENERATOR  "Visual Studio 9 2008" )
SET (CTEST_CMAKE_COMMAND "C:/Program Files (x86)/CMake 2.8/bin/cmake.exe")
SET (CTEST_SITE "raoul.c-s.fr" )
SET (CTEST_BUILD_NAME "Win7-Visual2008-${CTEST_BUILD_CONFIGURATION}-Static")
SET (CTEST_HG_COMMAND "C:/Program Files (x86)/Mercurial/hg.exe")
SET (CTEST_HG_UPDATE_OPTIONS "-C")

SET (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

BUILD_TESTING:BOOL=ON
OTB_DIR:PATH=C:/Users/jmalik/Dashboard/build/OTB-${CTEST_BUILD_CONFIGURATION}-VC2008

OTB_DIR:PATH=C:/Users/jmalik/Dashboard/build/OTB-${CTEST_BUILD_CONFIGURATION}-VC2008

GDAL_INCLUDE_DIR:PATH=C:/OSGeo4W/include
GDAL_LIBRARY:FILEPATH=C:/OSGeo4W/lib/gdal_i.lib
EXPAT_INCLUDE_DIR:PATH=C:/OSGeo4W/include
EXPAT_LIBRARY:FILEPATH=C:/OSGeo4W/lib/libexpat.lib
LIBLAS_INCLUDE_DIR:PATH=C:/OSGeo4W/include
LIBLAS_LIBRARY:FILEPATH=C:/OSGeo4W/lib/liblas_c.lib
MAPNIK_INCLUDE_DIR:PATH=C:/OSGeo4W/include/mapnik
MAPNIK_LIBRARY:FILEPATH=C:/OSGeo4W/lib/mapnik.lib
FREETYPE2_INCLUDE_DIR:PATH=C:/OSGeo4W/include/freetype
ICUUC_INCLUDE_DIR:PATH=C:/Program Files (x86)/icu4c-4_2_1-Win32-msvc9/icu/include
ICUUC_LIBRARY:FILEPATH=C:/Program Files (x86)/icu4c-4_2_1-Win32-msvc9/icu/lib/icuuc.lib
LTDL_INCLUDE_DIR:PATH=C:/Program Files (x86)/GnuWin32/include
LTDL_LIBRARY:FILEPATH=C:/Program Files (x86)/GnuWin32/lib/ltdl.lib

OTB_DATA_ROOT:STRING=C:/Users/jmalik/Dashboard/src/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_LARGEINPUT_ROOT:PATH=C:/Users/jmalik/Dashboard/src/OTB-LargeInput

SWIG_DIR:PATH=C:/Users/jmalik/Dashboard/tools/build/swigwin-1.3.40/Source/Swig
SWIG_EXECUTABLE:FILEPATH=C:/Users/jmalik/Dashboard/tools/build/swigwin-1.3.40/swig.exe

PYTHON_EXECUTABLE:FILEPATH=C:/OSGeo4W/bin/python.exe
PYTHON_INCLUDE_DIR:PATH=C:/OSGeo4W/apps/python25/include
PYTHON_LIBRARY:FILEPATH=C:/OSGeo4W/apps/python25/libs/python25.lib
PYTHON_DEBUG_LIBRARY:FILEPATH=C:/OSGeo4W/apps/python25/libs/python25.lib

WRAP_PYTHON:BOOL=ON
WRAP_QT:BOOL=ON
WRAP_PYQT:BOOL=ON
")

#ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)


ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
#ctest_submit (PARTS Start Update Configure)
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
#ctest_submit (PARTS Build)
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()
