SET (CTEST_SOURCE_DIRECTORY "C:/Users/msavinau/dev/nightly/MVD2-MVSC10-Release/src")
SET (CTEST_BINARY_DIRECTORY "C:/Users/msavinau/dev/nightly/MVD2-MVSC10-Release/build")

SET (CTEST_CMAKE_GENERATOR  "Visual Studio 10" )
SET (CTEST_CMAKE_COMMAND "C:/Program Files (x86)/CMake 2.8/bin/cmake.exe")
SET (CTEST_SITE "PO9450.c-s.fr" )
SET (CTEST_BUILD_NAME "Win7-MVD2-MVSC10-Release-Static")
SET (CTEST_BUILD_CONFIGURATION "Release")
SET (CTEST_HG_COMMAND "C:/Program Files (x86)/Mercurial/hg.exe")
SET (CTEST_HG_UPDATE_OPTIONS "-C")

SET (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CMAKE_INSTALL_PREFIX:PATH=C:/Users/msavinau/dev/nightly/MVD2-MVSC10-Release/install

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

CMAKE_INCLUDE_PATH:PATH=$ENV{OSGEO4W_ROOT}/include
CMAKE_LIBRARY_PATH:PATH=$ENV{OSGEO4W_ROOT}/lib

BUILD_TESTING:BOOL=ON
OTB_USE_CPACK:BOOL=ON

OTB_DIR:PATH=C:/Users/msavinau/dev/nightly/OTB-MVSC10-ExternalOSSIM-ExternaFLTK-Release/install/lib/otb
")

#Remove install dir
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory 
				C:/Users/msavinau/dev/nightly/OTB-MVSC10-ExternalOSSIM-ExternaFLTK-Release/install/lib/otb)
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory 
				C:/Users/msavinau/dev/nightly/OTB-MVSC10-ExternalOSSIM-ExternaFLTK-Release/install/lib/otb)

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

SET( OTB_PULL_RESULT_FILE "${CTEST_BINARY_DIRECTORY}/pull_result.txt" )
execute_process( COMMAND ${CTEST_HG_COMMAND} pull http://hg.orfeo-toolbox.org/Monteverdi2
                 WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}"
                 OUTPUT_VARIABLE   OTB_PULL_RESULT
                 ERROR_VARIABLE    OTB_PULL_RESULT )
file(WRITE ${OTB_PULL_RESULT_FILE} ${OTB_PULL_RESULT} )

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
${OTB_PULL_RESULT_FILE}
)

ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}" TARGET INSTALL)
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_submit ()
