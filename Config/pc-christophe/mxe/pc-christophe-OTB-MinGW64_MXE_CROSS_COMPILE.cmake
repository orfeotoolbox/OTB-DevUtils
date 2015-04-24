# Client maintainer: manuel.grizonnet@cnes.fr
#This is MinGW MXE cross compilation script.
#Running ctest -VV -SS pc-christophe-OTB-Nightly-MinGW32_MXE_CROSS_COMPILE.cmake will
#submit a build to OTB dashboard:- dash.orfeo-toolbox.org/index.php?project=OTB.
#OTB source code is cloned from OTB-Nightly repository.
#No tests are executed in this submission.

set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Windows-MinGW-w64-x68_64-${CTEST_BUILD_CONFIGURATION}-Shared")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k install" )
set(CTEST_DASHBOARD_ROOT "/home/otbtesting")
set(CTEST_HG_COMMAND "/usr/bin/hg")
set(CTEST_HG_UPDATE_OPTIONS "-C")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")

set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/sources/orfeo/trunk/OTB-Nightly")
set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/build/orfeo/trunk/OTB-MinGW-x86_64-MXE/${CTEST_BUILD_CONFIGURATION}")

##cross compile specific
set(MXE_ROOT "/home/otbtesting/win-sources/mxe")
set(MXE_TARGET_ROOT "${MXE_ROOT}/usr/x86_64-w64-mingw32.shared")
set(CTEST_USE_LAUNCHERS OFF)
##cross compile specific

set (OTB_CTEST_CACHE_SETTINGS "
BUILD_TESTING:BOOL=OFF
BUILD_EXAMPLES:BOOL=OFF
BUILD_APPLICATIONS:BOOL=ON
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

#include tryrun results within
HAS_SSE2_EXTENSIONS_EXITCODE:INTERNAL=0 #otbsiftfast
HAS_SSE_EXTENSIONS_EXITCODE:INTERNAL=0 #otbsiftfast
CHECK_HDF4OPEN_SYMBOL_EXITCODE:INTERNAL=0 #hdf5 and hdf4 in gdal
IS_X86_64_EXITCODE:INTERNAL=0 #otbsiftfast for 64bit

CMAKE_C_FLAGS:STRING='-Wall'
CMAKE_CXX_FLAGS:STRING='-Wall -Wextra -Wno-cpp -Wno-strict-overflow'
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_TOOLCHAIN_FILE:FILEPATH=${MXE_TARGET_ROOT}/share/cmake/mxe-conf.cmake
CMAKE_USE_PTHREADS:BOOL=OFF
CMAKE_USE_WIN32_THREADS:BOOL=ON

GDAL_CONFIG:FILEPATH='${MXE_TARGET_ROOT}/bin/gdal-config'
#ITK et al :- auto detected from MXE_TARGET_ROOT

#auto detects only ossim.dll.a. But we need openthreads to prevent build failure.#TODO: make this change in source CMakeLists.txt?
OSSIM_LIBRARY:FILEPATH='${MXE_TARGET_ROOT}/lib/libossim.dll.a;${MXE_TARGET_ROOT}/lib/libOpenThreads.dll.a'

OpenJPEG_DIR:PATH=${MXE_TARGET_ROOT}/lib/openjpeg-2.1

OTB_COMPILE_WITH_FULL_WARNING:BOOL=OFF
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}sources/orfeo/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=OFF

OTB_USE_CURL:BOOL=ON

OTB_WRAP_PYTHON:BOOL=OFF
OTB_WRAP_JAVA:BOOL=OFF

OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_OPENCV:BOOL=ON
OTB_USE_QT4=ON
OTB_USE_6S=ON
OTB_USE_SIFTFAST=ON

OTB_USE_LIBKML=OFF
OTB_USE_LIBSVM=OFF
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
# append mxe build script and log as notes for validation
list(APPEND CTEST_NOTES_FILES
  "${CTEST_DASHBOARD_ROOT}/logs/mxe_x86_64-w64-mingw32.shared_build.log" 
  "${CTEST_DASHBOARD_ROOT}/sources/orfeo/OTB-DevUtils/Scripts/mxe_build.sh")
ctest_submit ()
