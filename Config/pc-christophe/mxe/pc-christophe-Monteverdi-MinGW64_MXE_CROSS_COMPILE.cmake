# Client maintainer: manuel.grizonnet@cnes.fr

##This is MinGW MXE cross compilation script.
##Running ctest -VV -SS pc-christophe-Monteverdi-MinGW32_MXE_CROSS_COMPILE.cmake will
##submit a build to Monteverdi dashboard:- dash.orfeo-toolbox.org/index.php?project=Monteverdi
##source code is cloned from Monteverdi repository.
##No tests are executed in this submission.

set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Windows-MinGW-w64-x68_64-${CTEST_BUILD_CONFIGURATION}-Shared")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k install" )
set(CTEST_DASHBOARD_ROOT "/home/otbtesting")
set(CTEST_HG_COMMAND "/usr/bin/hg")
set(CTEST_HG_UPDATE_OPTIONS "-C")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")

set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/sources/orfeo/trunk/Monteverdi-Nightly")
set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/build/orfeo/trunk/Monteverdi-MinGW-x86_64-MXE/${CTEST_BUILD_CONFIGURATION}")

##cross compile specific
set(MXE_ROOT "/home/otbtesting/win-sources/mxe")
set(MXE_TARGET_ROOT "${MXE_ROOT}/usr/x86_64-w64-mingw32.shared")
set(CTEST_USE_LAUNCHERS OFF)
##cross compile specific

set (OTB_CTEST_CACHE_SETTINGS "
BUILD_TESTING:BOOL=ON
BUILDNAME:STRING=${CTEST_BUILD_NAME}

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_C_FLAGS:STRING='-Wall -Wno-uninitialized'
CMAKE_CXX_FLAGS:STRING='-Wall -Wno-deprecated -Wno-uninitialized -Wno-cpp'
CMAKE_TOOLCHAIN_FILE:FILEPATH=${MXE_TARGET_ROOT}/share/cmake/mxe-conf.cmake
CMAKE_USE_PTHREADS:BOOL=OFF
CMAKE_USE_WIN32_THREADS:BOOL=ON

#If FLTK_FLUID_EXECUTABLE is missing install yum install -y fluid
#The idea is to borrow fluid executable from linux as we are cross compiling
#FLTK_FLUID_EXECUTABLE=/usr/bin/fluid

CTEST_USE_LAUNCHERS:BOOL=OFF
SITE:STRING=${CTEST_SITE}
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
                 SOURCE  "${CTEST_SOURCE_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_submit ()
