set(CTEST_BUILD_CONFIGURATION Release)
set(BUILD_DIR_NAME "OTB-SuperBuild-vc10-x86-RelWithDebInfo")
set(CTEST_BUILD_NAME "Win7-${BUILD_DIR_NAME}-Static")
set(CTEST_SITE "raoul.c-s.fr" )
set(CTEST_DASHBOARD_ROOT "C:/Users/jmalik/Dashboard")
set(CTEST_CMAKE_GENERATOR "NMake Makefiles")
set(CTEST_TEST_TIMEOUT 500)

set(CTEST_SOURCE_DIRECTORY  "${CTEST_DASHBOARD_ROOT}/src/OTB-SuperBuild")
set(CTEST_BINARY_DIRECTORY  "${CTEST_DASHBOARD_ROOT}/build/${BUILD_DIR_NAME}")
set(CTEST_INSTALL_DIRECTORY "${CTEST_DASHBOARD_ROOT}/install/${BUILD_DIR_NAME}")

set(CTEST_NIGHTLY_START_TIME "20:00:00 CEST")
set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "dash.orfeo-toolbox.org")
set(CTEST_DROP_LOCATION "/submit.php?project=OTB")
set(CTEST_DROP_SITE_CDASH TRUE)
set(CTEST_USE_LAUNCHERS TRUE)

# set(OTB_INITIAL_CACHE "
# CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_DIRECTORY}
# CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
# OTB_DATA_ROOT:PATH=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
# CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
# ")

# execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_DIRECTORY})
# execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY})
# execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/lib)
# execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/bin)
# execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/include)

# ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start(Experimental)
# ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
# file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
#ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")

ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})

ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")

ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}/OTB/build" ${CTEST_TEST_ARGS})
ctest_submit ()
