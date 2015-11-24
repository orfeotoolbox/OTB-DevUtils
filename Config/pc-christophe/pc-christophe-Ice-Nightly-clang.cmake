#set (ENV{DISPLAY} ":0.0")
# Avoid non-ascii characters in tool output.
#set(ENV{LC_ALL} C)

set (CTEST_BUILD_CONFIGURATION "Debug")
SET (CTEST_DASHBOARD_ROOT "/home/otbtesting")
SET (CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/sources/orfeo/trunk/Ice/")
SET (CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/build/orfeo/trunk/Ice-clang-ThridPartyTrunk/")
set (CTEST_CMAKE_GENERATOR  "Unix Makefiles")
set (CTEST_CMAKE_COMMAND "cmake" )
set (CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k install" )
set (CTEST_SITE "pc-christophe.cst.cnes.fr" )
set (CTEST_BUILD_NAME "Fedora22-64bits-clang-${CTEST_BUILD_CONFIGURATION}")
set (CTEST_HG_COMMAND "/usr/bin/hg")
set (CTEST_HG_UPDATE_OPTIONS "-C")

set(INSTALLROOT "${CTEST_DASHBOARD_ROOT}/install")
set (ICE_INSTALL_PREFIX "${INSTALLROOT}/orfeo/trunk/Ice-clang-ThridPartyTrunk/${CTEST_BUILD_CONFIGURATION}")

set (CTEST_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
BUILD_ICE_APPLICATION:BOOL=ON

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_C_COMPILER=/usr/bin/clang
CMAKE_CXX_COMPILER=/usr/bin/clang++
CMAKE_C_FLAGS:STRING=-Wall -Wno-gnu-static-float-init
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-gnu-static-float-init -Wno-\\\\#warnings
CMAKE_INSTALL_PREFIX:PATH=${ICE_INSTALL_PREFIX}

#currently. i am forced to keep this for clang
CMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}'-L/home/otbtesting/install/openjpeg/trunk/lib/'
CMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}'-L/home/otbtesting/install/ossim/dev/lib64
CMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}'-L/home/otbtesting/install/gdal/trunk/lib'

GLFW_INCLUDE_DIR:PATH=/usr/include/GLFW

ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/build/itk/trunk/Release
OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}/build/orfeo/trunk/OTB-clang-ThirdPartyTrunk/${CTEST_BUILD_CONFIGURATION}


SITE:STRING=${CTEST_SITE}
")

set (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${ICE_INSTALL_PREFIX})
execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${ICE_INSTALL_PREFIX})
ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start (Nightly)
ctest_update (SOURCE "${CTEST_SOURCE_DIRECTORY}")
file (WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${CTEST_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files (${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()
