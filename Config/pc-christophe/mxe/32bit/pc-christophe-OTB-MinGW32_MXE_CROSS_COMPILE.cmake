# Client maintainer: manuel.grizonnet@cnes.fr
#This is MinGW MXE cross compilation script. 
#Running ctest -VV -SS pc-christophe-OTB-Nightly-MinGW32_MXE_CROSS_COMPILE.cmake will
#submit a build to OTB dashboard:- dash.orfeo-toolbox.org/index.php?project=OTB.
#OTB source code is cloned from OTB-Nightly repository.
#No tests are executed in this submission.

set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora20-64bits-${CTEST_BUILD_CONFIGURATION}-Windows1.0_MXE_CROSS_COMPILE")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k install" )
set(CTEST_DASHBOARD_ROOT "/home/otbtesting")
set(CTEST_HG_COMMAND "/usr/bin/hg")
set(CTEST_HG_UPDATE_OPTIONS "-C")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")

set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/sources/orfeo/trunk/OTB-Nightly")
set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/build/orfeo/trunk/OTB-Nightly-MXE_CROSS_COMPILE_32bit/${CTEST_BUILD_CONFIGURATION}")


#-Wno-unused-function -Wno-maybe-uninitialized -Wno-unused-but-set-variable -Wno-format-extra-args -Wno-format -Wno-unused-variable -Wno-unused-but-set-parameter -Wno-deprecated-declarations

##cross compile specific
set(MXE_ROOT "/home/otbtesting/win-sources/mxe") 
set(MXE_TARGET_ROOT "${MXE_ROOT}/usr/i686-pc-mingw32.shared")
set(CTEST_USE_LAUNCHERS OFF)
set(OTB_CMAKE_TRYRUN_FILE "${MXE_ROOT}/TryRunResults-OTB.cmake")
##cross compile specific

set (OTB_CTEST_CACHE_SETTINGS "
BUILD_TESTING:BOOL=OFF
BUILD_EXAMPLES:BOOL=ON
BUILD_APPLICATIONS:BOOL=ON
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

CMAKE_C_FLAGS:STRING= -Wall 
CMAKE_CXX_FLAGS:STRING= -Wall -Wextra -Wno-cpp -Wno-strict-overflow
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_TOOLCHAIN_FILE:FILEPATH=${MXE_TARGET_ROOT}/share/cmake/mxe-conf.cmake
CMAKE_USE_PTHREADS:BOOL=OFF
CMAKE_USE_WIN32_THREADS:BOOL=ON

#ITK et al :- auto detected from MXE_TARGET_ROOT

#auto detects only ossim.dll.a. But we need openthreads to prevent build failure.#TODO: make this change in source CMakeLists.txt?
OSSIM_LIBRARY:FILEPATH='${MXE_TARGET_ROOT}/lib/libossim.dll.a;${MXE_TARGET_ROOT}/lib/libOpenThreads.dll.a'

OTB_COMPILE_WITH_FULL_WARNING:BOOL=OFF
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}sources/orfeo/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_USE_PATENTED:BOOL=OFF
OTB_USE_CURL:BOOL=ON
OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
OTB_USE_EXTERNAL_ITK:BOOL=ON
OTB_USE_EXTERNAL_OSSIM:BOOL=ON
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_OPENCV:BOOL=ON
OTB_USE_SIFTFAST:BOOL=OFF
OTB_WRAP_JAVA:BOOL=OFF
OTB_WRAP_PYTHON:BOOL=OFF
OTB_WRAP_QT:BOOL=ON
")

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

set (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt)
ctest_start(Nightly)

ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "${OTB_CTEST_CACHE_SETTINGS}")

ctest_configure (BUILD   "${CTEST_BINARY_DIRECTORY}"    
                 SOURCE  "${CTEST_SOURCE_DIRECTORY}"
                 OPTIONS "-C${OTB_CMAKE_TRYRUN_FILE}" )


ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_submit ()
