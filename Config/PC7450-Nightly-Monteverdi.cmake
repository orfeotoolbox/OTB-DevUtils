SET (CTEST_SOURCE_DIRECTORY "D:/Developpement/OTB-hg/Monteverdi")
SET (CTEST_BINARY_DIRECTORY "D:/Developpement/OTB-NIGHTLY-VALIDATION/OSGEO-Release/binaries/Monteverdi")

SET( CTEST_CMAKE_GENERATOR  "Visual Studio 9 2008" )
SET (CTEST_CMAKE_COMMAND "C:/Program Files/CMake 2.8/bin/cmake.exe" )
SET (CTEST_BUILD_COMMAND "C:\PROGRA~1\MICROS~1.0\Common7\IDE\VCExpress.exe Monteverdi.sln /build Release /project ALL_BUILD" )
SET (CTEST_SITE "PC7450.c-s.fr" )
SET (CTEST_BUILD_NAME "Win32.VisuaExpressl2008-Release-With-OSGEO")
SET (CTEST_BUILD_CONFIGURATION "Release")
SET (CTEST_HG_COMMAND "C:/Program Files/Mercurial/hg.exe")
SET (CTEST_HG_UPDATE_OPTIONS "-C")

SET(CPACK_PACKAGE_NAME "Monteverdi" CACHE STRING "" FORCE)



SET (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_ROOT:STRING=D:/Developpement/OTB-hg/OTB-Data

CMAKE_BUILD_TYPE:STRING=Release
BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=D:/Developpement/OTB-NIGHTLY-VALIDATION/OSGEO-Release/binaries/install/Monteverdi
GDAL_INCLUDE_DIR:STRING=C:/OSGeo4W/apps/gdal-16/include
OTB_DIR:STRING=D:/Developpement/OTB-NIGHTLY-VALIDATION/OSGEO-Release/binaries/OTB
")

SET( OTB_PULL_RESULT_FILE "${CTEST_BINARY_DIRECTORY}/pull_result.txt" )

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${OTB_PULL_RESULT_FILE}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

execute_process( COMMAND ${CTEST_HG_COMMAND} pull http://hg.orfeo-toolbox.org/Monteverdi-Nightly
                 WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}"
                 OUTPUT_VARIABLE   OTB_PULL_RESULT
                 ERROR_VARIABLE    OTB_PULL_RESULT )
				 
execute_process( COMMAND ${CTEST_HG_COMMAND} update 
                 WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}"
                 OUTPUT_VARIABLE   OTB_PULL_RESULT
                 ERROR_VARIABLE    OTB_PULL_RESULT )				 
				 
file(WRITE ${OTB_PULL_RESULT_FILE} ${OTB_PULL_RESULT} )

ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")  # doing this twice because of the use of an internal ITK
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 6)
ctest_submit ()

