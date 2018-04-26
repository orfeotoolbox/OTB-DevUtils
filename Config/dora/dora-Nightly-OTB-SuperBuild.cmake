set(dashboard_model Nightly)
string(TOLOWER ${dashboard_model} lcdashboard_model)

set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set(CTEST_SITE "dora.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Ubuntu12.04-64bits-SuperBuild")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j9 -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)

set(CTEST_SOURCE_DIRECTORY  "${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-Release/src/SuperBuild")
set(CTEST_BINARY_DIRECTORY  "${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-SuperBuild/build")
set(CTEST_INSTALL_DIRECTORY "${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-SuperBuild/install")

set(OTB_INITIAL_CACHE "
CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_DIRECTORY}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
OTB_DATA_ROOT:PATH=/home/otbval/Data/OTB-Data
DOWNLOAD_LOCATION:PATH=/home/otbval/Data/SuperBuild-archives
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
OTB_USE_QT:BOOL=ON
OTB_USE_QWT:BOOL=ON
USE_SYSTEM_SWIG:BOOL=ON
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=/home/otbval/Data/OTB-LargeInput
OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
")

execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/lib)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/bin)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/include)

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start(${dashboard_model})
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")

ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")

# before testing, set the LD_LIBRARY_PATH
set(ENV{LD_LIBRARY_PATH} ${CTEST_INSTALL_DIRECTORY}/lib)

ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}/OTB/build" ${CTEST_TEST_ARGS})

set(CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
${CTEST_BINARY_DIRECTORY}/OTB/build/CMakeCache.txt
${CTEST_BINARY_DIRECTORY}/OTB/build/otbConfigure.h
)

ctest_submit ()
