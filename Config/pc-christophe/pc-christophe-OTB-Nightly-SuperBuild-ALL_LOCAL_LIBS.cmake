# Client maintainer: manuel.grizonnet@cnes.fr
set(CTEST_DASHBOARD_ROOT "/home/otbtesting")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora20-64bits-SuperBuild-ALL_LOCAL_LIBS")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j2 -k")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 2)
set(CTEST_TEST_TIMEOUT 1500)

set(CTEST_SOURCE_DIRECTORY  "${CTEST_DASHBOARD_ROOT}/sources/orfeo/trunk/OTB-Nightly/SuperBuild")
set(CTEST_BINARY_DIRECTORY  "${CTEST_DASHBOARD_ROOT}/build/orfeo/trunk/OTB-SuperBuild-ALL_LOCAL_LIBS")
set(CTEST_INSTALL_DIRECTORY "${CTEST_DASHBOARD_ROOT}/install/orfeo/trunk/OTB-SuperBuild-ALL_LOCAL_LIBS")

set(CTEST_HG_COMMAND          "/usr/bin/hg")
set(CTEST_HG_UPDATE_OPTIONS   "-C")

set(CTEST_NIGHTLY_START_TIME "20:00:00 CEST")
set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "dash.orfeo-toolbox.org")
set(CTEST_DROP_LOCATION "/submit.php?project=OTB")
set(CTEST_DROP_SITE_CDASH TRUE)

set(CTEST_USE_LAUNCHERS TRUE)

set(OTB_INITIAL_CACHE "
CMAKE_INSTALL_PREFIX:PATH=${CTEST_DASHBOARD_ROOT}/install/orfeo/trunk/OTB-SuperBuild-ALL_LOCAL_LIBS
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
OTB_DATA_ROOT:PATH=${CTEST_DASHBOARD_ROOT}/sources/orfeo/OTB-Data
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
DOWNLOAD_LOCATION:PATH=${CTEST_DASHBOARD_ROOT}/sources/archives-superbuild-trunk
BUILD_TESTING:BOOL=ON
")

execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/lib)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/bin)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/include)

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")

ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")

# before testing, set the LD_LIBRARY_PATH
set(ENV{LD_LIBRARY_PATH} ${CTEST_INSTALL_DIRECTORY}/lib)

ctest_test(BUILD "${CTEST_BINARY_DIRECTORY}/OTB/build" ${CTEST_TEST_ARGS})
ctest_submit ()


