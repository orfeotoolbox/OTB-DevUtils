# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/OTB")
SET (CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "ArchLinux-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_HG_COMMAND "/usr/bin/hg")

set(dashboard_root_name "tests")
set(dashboard_source_name "trunk/OTB")
set(dashboard_binary_name "bin/OTB-Nightly")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(dashboard_hg_branch "default")

#set(ENV{DISPLAY} ":0.0")

macro(dashboard_hook_init)
set(dashboard_cache "${dashboard_cache}
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/ssh/pc-inglada/media/TeraDisk2/LargeInput

OTB_DATA_ROOT:STRING=/home/otbtesting/OTB/trunk/OTB-Data

CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
ITK_USE_OPTIMIZED_REGISTRATION_METHODS:BOOL=ON
OTB_USE_VISU_GUI:BOOL=ON
BUILD_APPLICATIONS:BOOL=ON
OTB_WRAP_PYTHON:BOOL=ON
PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python2.7
OTB_WRAP_QT:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
JAVACOMMAND:FILEPATH=/opt/java/bin/java
JAVA_AWT_INCLUDE_PATH:FILEPATH=/opt/java/include
JAVA_AWT_LIBRARY:FILEPATH=/opt/java/jre/lib/amd64/libjawt.so
JAVA_INCLUDE_PATH:FILEPATH=/opt/java/include
JAVA_INCLUDE_PATH2:FILEPATH=/opt/java/include/linux
JAVA_JVM_LIBRARY:FILEPATH=/opt/java/jre/lib/amd64/server/libjvm.so
JPEG_INCLUDE_DIRS:FILEPATH=/usr/include                   
Java_JAR_EXECUTABLE:FILEPATH=/opt/java/bin/jar
Java_JAVAC_EXECUTABLE:FILEPATH=/opt/java/bin/javac
Java_JAVADOC_EXECUTABLE:FILEPATH=/opt/java/bin/javadoc 
Java_JAVAH_EXECUTABLE:FILEPATH=/opt/java/bin/javah
Java_JAVA_EXECUTABLE:FILEPATH=/opt/java/bin/java  
    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/otb_common.cmake)
