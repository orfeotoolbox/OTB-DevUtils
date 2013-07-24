SET (CTEST_SOURCE_DIRECTORY "C:/Users/jmalik/Dashboard/src/OTB-Wrapping")
SET (CTEST_BINARY_DIRECTORY "C:/Users/jmalik/Dashboard/build/OTB-Wrapping-RelWithDebInfo-VC2010")

SET (CTEST_CMAKE_GENERATOR  "Visual Studio 10" )
SET (CTEST_CMAKE_COMMAND "C:/Program Files (x86)/CMake 2.8/bin/cmake.exe")
SET (CTEST_SITE "raoul.c-s.fr" )
SET (CTEST_BUILD_NAME "Win7-Visual2010-RelWithDebInfo")

SET (CTEST_BUILD_CONFIGURATION "RelWithDebInfo")

SET (CTEST_HG_COMMAND "C:/Program Files (x86)/Mercurial/hg.exe")
SET (CTEST_HG_UPDATE_OPTIONS "-C")

SET (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_CONFIGURATION_TYPES:STRING=${CTEST_BUILD_CONFIGURATION}

OTB_DATA_ROOT:STRING=C:/Users/jmalik/Dashboard/src/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=C:/Users/jmalik/Dashboard/src/OTB-LargeInput

GDAL_INCLUDE_DIR:PATH=C:/OSGeo4W/include
GDAL_LIBRARY:FILEPATH=C:/OSGeo4W/lib/gdal_i.lib

OTB_DIR:PATH=C:/Users/jmalik/Dashboard/build/OTB-RelWithDebInfo-VC2010
OTB_USE_CPACK:BOOL=ON

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

# Utilitites for Wrapping
SWIG_DIR:PATH=C:/Users/jmalik/Dashboard/tools/build/swigwin-1.3.40/Source/Swig
SWIG_EXECUTABLE:FILEPATH=C:/Users/jmalik/Dashboard/tools/build/swigwin-1.3.40/swig.exe
CableSwig_DIR:PATH=C:/Users/jmalik/Dashboard/tools/build/CableSwig-3.20-VC9

# OTB Test driver to launch the tests
OTB_TEST_DRIVER:FILEPATH=C:/Users/jmalik/Dashboard/build/OTB-RelWithDebInfo-VC2010/bin/RelWithDebInfo/otbTestDriver.exe

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

JAVADOC_EXECUTABLE:FILEPATH=C:/Program Files (x86)/Java/jdk1.6.0_22/bin/javadoc.exe

#PYTHON_EXECUTABLE
PYTHON_EXECUTABLE:FILEPATH=C:/Python27/python.exe
PYTHON_LIBRARIES:PATH=C:/Python27/libs
PYTHON_INCLUDE_DIR:PATH=C:/Python27/include
PYTHON_INCLUDE_DIRS:PATH=C:/Python27/include
PYTHON_LIBRARY:FILEPATH=C:/Python27/libs/python27.lib

#Javadoc 
#WRAP_ITK_DOC:BOOL=ON
#WRAP_ITK_JAVADOC:BOOL=ON
#LATEXLET_JAR:FILEPATH=C:/Users/jmalik/Dashboard/tools/build/LaTeXlet-bin-1.1/LaTeXlet-1.1.jar

# Select Languages to Wrap
WRAP_ITK_JAVA:BOOL=ON
WRAP_ITK_PYTHON:BOOL=ON

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
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()