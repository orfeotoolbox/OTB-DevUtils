SET (CTEST_SOURCE_DIRECTORY  "$ENV{HOME}/Dashboard/src/OTB-Documents/CookBook")
SET (CTEST_BINARY_DIRECTORY  "$ENV{HOME}/Dashboard/build/OTB-Documents/CookBook")

SET (CTEST_CMAKE_GENERATOR     "Unix Makefiles")
SET (CTEST_CMAKE_COMMAND       "cmake")
SET (CTEST_BUILD_COMMAND       "/usr/bin/make -i -k")
SET (CTEST_SITE                "hulk.c-s.fr" )
SET (CTEST_BUILD_CONFIGURATION "Release")
SET (CTEST_BUILD_NAME          "Ubuntu10.04-64bits-${CTEST_BUILD_CONFIGURATION}")
SET (CTEST_HG_COMMAND          "/usr/bin/hg")
SET (CTEST_HG_UPDATE_OPTIONS   "-C")
SET (CTEST_USE_LAUNCHERS ON)

SET (OTB_INITIAL_CACHE "

BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

OTB_DATA_ROOT:STRING=$ENV{HOME}/Dashboard/src/OTB-Data
OTB_DATA_PATHS:STRING=$ENV{HOME}/Dashboard/src/OTB-Data/Examples::$ENV{HOME}/Dashboard/src/OTB-Data/Input

OTB_DIR:STRING=$ENV{HOME}/Dashboard/build/OTB-RelWithDebInfo
ITK_DIR:PATH=$ENV{HOME}/Dashboard/build/ITKv4-upstream-RelWithDebInfo
OpenCV_DIR:PATH=/usr/share/OpenCV
")

SET( OTB_PULL_RESULT_FILE "${CTEST_BINARY_DIRECTORY}/pull_result.txt" )

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${OTB_PULL_RESULT_FILE}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${CTEST_BINARY_DIRECTORY})
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${CTEST_BINARY_DIRECTORY})

execute_process( COMMAND ${CTEST_HG_COMMAND} pull http://hg.orfeo-toolbox.org/OTB-Documents
                 WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}"
                 OUTPUT_VARIABLE   OTB_PULL_RESULT
                 ERROR_VARIABLE    OTB_PULL_RESULT )
file(WRITE ${OTB_PULL_RESULT_FILE} ${OTB_PULL_RESULT} )

ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
#ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")

