SET (CTEST_SOURCE_DIRECTORY "C:/Users/jmalik/Dashboard/src/OTB")
SET (CTEST_BINARY_DIRECTORY "C:/Users/jmalik/Dashboard/build/OTB-Release-VC2010")

SET (CTEST_CMAKE_GENERATOR  "Visual Studio 10" )
SET (CTEST_CMAKE_COMMAND "C:/Program Files (x86)/CMake 2.8/bin/cmake.exe")
SET (CTEST_SITE "raoul.c-s.fr" )
SET (CTEST_BUILD_NAME "Win7-Visual2010-Release-Static")
SET (CTEST_BUILD_CONFIGURATION "Release")
SET (CTEST_HG_COMMAND "C:/Program Files (x86)/Mercurial/hg.exe")
SET (CTEST_HG_UPDATE_OPTIONS "-C")

SET (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CMAKE_INSTALL_PREFIX:PATH=C:/Users/jmalik/Dashboard/install/OTB-Release-VC2010

BUILD_TESTING:BOOL=ON
OTB_DATA_ROOT:STRING=C:/Users/jmalik/Dashboard/src/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_LARGEINPUT_ROOT:PATH=C:/Users/jmalik/Dashboard/src/OTB-LargeInput

BUILD_EXAMPLES:BOOL=OFF

BUILD_APPLICATIONS:BOOL=ON
# On windows, we need python27_d.lib, dragged by python.h
# and it is not available with OSGeo4W python
OTB_WRAP_PYTHON:BOOL=ON
SWIG_EXECUTABLE:FILEPATH=C:/OSGeo4W/apps/swigwin/swig.exe
PYTHON_EXECUTABLE:FILEPATH=C:/OSGeo4W/bin/python.exe
PYTHON_INCLUDE_DIR:PATH=C:/OSGeo4W/apps/Python27/include
PYTHON_LIBRARY:FILEPATH=C:/OSGeo4W/apps/Python27/libs/python27.lib

OTB_WRAP_QT:BOOL=ON

OTB_USE_CPACK:BOOL=OFF

OTB_USE_EXTERNAL_FLTK:BOOL=OFF
OTB_USE_EXTERNAL_OSSIM:BOOL=ON

OTB_USE_CURL:BOOL=ON

OTB_USE_EXTERNAL_EXPAT:BOOL=ON

OTB_USE_LIBLAS:BOOL=ON
OTB_USE_EXTERNAL_LIBLAS:BOOL=ON

OTB_USE_GETTEXT:BOOL=OFF

OTB_USE_JPEG2000:BOOL=ON


")

#remove build dir
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
#ctest_submit (PARTS Start Update Configure)
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}" TARGET INSTALL)
#ctest_submit (PARTS Start Update Configure Build)
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()
