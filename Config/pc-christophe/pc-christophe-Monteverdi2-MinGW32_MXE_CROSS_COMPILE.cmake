# Client maintainer: manuel.grizonnet@cnes.fr

##This is MinGW MXE cross compilation script. 
##Running ctest -VV -SS pc-christophe-Monteverdi2-MinGW32_MXE_CROSS_COMPILE.cmake will
##submit a build to Monteverdi2 dashboard:- dash.orfeo-toolbox.org/index.php?project=Monteverdi2.
##source code is cloned from Monteverdi2 repository.
##No tests are executed in this submission.

set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora20-64bits-${CTEST_BUILD_CONFIGURATION}-Windows1.0_MXE_CROSS_COMPILE")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k install" )
set(CTEST_DASHBOARD_ROOT "/home/otbtesting")
set(CTEST_HG_COMMAND "/usr/bin/hg")
set(CTEST_HG_UPDATE_OPTIONS "-C")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")

set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/sources/orfeo/trunk/Monteverdi2")
set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/build/orfeo/trunk/Monteverdi2-MXE_CROSS_COMPILE/${CTEST_BUILD_CONFIGURATION}")

##cross compile specific
set(MXE_ROOT "/home/otbtesting/win-sources/mxe") 
set(MXE_TARGET_ROOT "${MXE_ROOT}/usr/i686-pc-mingw32.shared")
set(CTEST_USE_LAUNCHERS OFF)
##cross compile specific

set (OTB_CTEST_CACHE_SETTINGS "
BUILD_TESTING:BOOL=OFF
BUILDNAME:STRING=${CTEST_BUILD_NAME}

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_C_FLAGS:STRING=-Wall -Wno-uninitialized 
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized
CMAKE_TOOLCHAIN_FILE:FILEPATH=${MXE_TARGET_ROOT}/share/cmake/mxe-conf.cmake
CMAKE_USE_PTHREADS:BOOL=OFF
CMAKE_USE_WIN32_THREADS:BOOL=ON

#ITK et al :- auto detected from MXE_TARGET_ROOT
OTB_DIR:PATH=${MXE_TARGET_ROOT}

#Using linux executable for generating translation files on Windows.
QT_LRELEASE_EXECUTABLE=/usr/lib64/qt4/bin/lrelease-qt4

QWT_INCLUDE_DIR:PATH=${MXE_TARGET_ROOT}/qwt-5.2.2/include/
QWT_LIBRARY:FILEPATH=${MXE_TARGET_ROOT}/qwt-5.2.2/lib/qwt5.dll

SITE:STRING=${CTEST_SITE}
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
