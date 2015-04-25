# Client maintainer: manuel.grizonnet@cnes.fr

##This is MinGW MXE cross compilation script.
##Running ctest -VV -SS pc-christophe-Ice-MinGW32_MXE_CROSS_COMPILE.cmake will
##submit a build to OTB-Ice dashboard:- dash.orfeo-toolbox.org/index.php?project=OTB-Ice.
##source code is cloned from Ice repository.
##No tests are executed in this submission.

set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Windows1.0-MinGW-i686-${CTEST_BUILD_CONFIGURATION}-Shared-MXE_CROSS_COMPILE")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k install" )
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_DASHBOARD_ROOT "/home/otbtesting")
set(CTEST_HG_COMMAND "/usr/bin/hg")
set(CTEST_HG_UPDATE_OPTIONS "-C")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")

set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/sources/orfeo/trunk/Ice")
set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/build/orfeo/trunk/Ice-MinGW-i686-MXE/${CTEST_BUILD_CONFIGURATION}")

##cross compile specific
set(MXE_ROOT "/home/otbtesting/win-sources/mxe")
set(MXE_TARGET_ROOT "${MXE_ROOT}/usr/i686-w64-mingw32.shared")
set(CTEST_USE_LAUNCHERS OFF)
##cross compile specific
set (OTB_CTEST_CACHE_SETTINGS "
BUILD_TESTING:BOOL=OFF
BUILD_ICE_APPLICATION:BOOL=ON
BUILDNAME:STRING=${CTEST_BUILD_NAME}

SITE:STRING=${CTEST_SITE}

CMAKE_C_FLAGS:STRING='-Wall'
CMAKE_CXX_FLAGS:STRING='-Wall'
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_TOOLCHAIN_FILE:FILEPATH=${MXE_TARGET_ROOT}/share/cmake/mxe-conf.cmake
CMAKE_USE_PTHREADS:BOOL=OFF
CMAKE_USE_WIN32_THREADS:BOOL=ON

#GLFW_LIBRARY:PATH=${MXE_TARGET_ROOT}/lib/glfw3.dll

#ITK et al :- auto detected from MXE_TARGET_ROOT
")

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

set (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt)
ctest_start(Nightly)

ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "${OTB_CTEST_CACHE_SETTINGS}")

ctest_configure (BUILD   "${CTEST_BINARY_DIRECTORY}"
                 SOURCE  "${CTEST_SOURCE_DIRECTORY}" )

ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_submit ()
