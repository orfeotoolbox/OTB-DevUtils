SET (ENV{DISPLAY} ":0.0")

SET (dashboard_model Nightly)
string(TOLOWER ${dashboard_model} lcdashboard_model)

SET (CTEST_BUILD_CONFIGURATION Release)

SET (CTEST_SOURCE_DIRECTORY "$ENV{HOME}/Dashboard/${lcdashboard_model}/Monteverdi-${CTEST_BUILD_CONFIGURATION}_double/src")
SET (CTEST_BINARY_DIRECTORY "$ENV{HOME}/Dashboard/${lcdashboard_model}/Monteverdi-${CTEST_BUILD_CONFIGURATION}_double/build")

SET( CTEST_CMAKE_GENERATOR  "Unix Makefiles" )
SET (CTEST_CMAKE_COMMAND "cmake" )
SET (CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k" )
SET (CTEST_SITE "dora.c-s.fr" )
SET (CTEST_BUILD_NAME "Ubuntu12.04-64bits-${CTEST_BUILD_CONFIGURATION}-double")
SET (CTEST_HG_COMMAND "/usr/bin/hg")
SET (CTEST_HG_UPDATE_OPTIONS "-C")
SET (CTEST_USE_LAUNCHERS ON)

SET (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data


CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

OTB_DIR:STRING=$ENV{HOME}/Dashboard/${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/build
ITK_DIR:PATH=$ENV{HOME}/Dashboard/experimental/build/ITKv4-RelWithDebInfo

BUILD_TESTING:BOOL=ON
Monteverdi_FLOATING_TYPE:STRING=double

#FLTK_DIR:PATH=$ENV{HOME}/OTB-OUTILS/fltk/binaries-linux-shared-release-fltk-1.1.9

#MAPNIK_INCLUDE_DIR:PATH=/ORFEO/otbval/OTB-OUTILS/mapnik/install/include
#MAPNIK_LIBRARY:FILEPATH=/ORFEO/otbval/OTB-OUTILS/mapnik/install/lib/libmapnik.so

#GDALCONFIG_EXECUTABLE:FILEPATH=${OTB_GDAL_INSTALL_DIR}/bin/gdal-config
#GDAL_CONFIG:FILEPATH=${OTB_GDAL_INSTALL_DIR}/bin/gdal-config
#GDAL_INCLUDE_DIR:STRING=${OTB_GDAL_INSTALL_DIR}/include
#GDAL_LIBRARY:FILEPATH=${OTB_GDAL_INSTALL_DIR}/lib/libgdal.so

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
file(WRITE ${OTB_PULL_RESULT_FILE} ${OTB_PULL_RESULT} )

ctest_start(${dashboard_model})
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 6)
ctest_submit ()

