SET (CTEST_SOURCE_DIRECTORY "D:/DONNEES/Nightly-OTB/src/Monteverdi")
SET (CTEST_BINARY_DIRECTORY "D:/DONNEES/Nightly-OTB/bin/Monteverdi")
SET (CTEST_CMAKE_COMMAND "D:/DONNEES/Softwares/CMake\ 2.8/bin/cmake.exe")
SET (CTEST_COMMAND "D:/DONNEES/Softwares/CMake\ 2.8/bin/ctest.exe -D Nightly -A CMakeCache.txt")
SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)
SET (CTEST_INITIAL_CACHE "
//Name of generator.
CMAKE_GENERATOR:INTERNAL=Visual Studio 10

//Name of the build
BUILDNAME:STRING=Win32-VC10Express

//Name of the computer/site where compile is being run
SITE:STRING=PC-2132356

//Build the testing tree.
BUILD_TESTING:BOOL=ON

//Path to a file.
GDAL_INCLUDE_DIR:PATH=D:/DONNEES/Softwares/OSGeo4W/apps/gdal-17/include

//OTB Dir
OTB_DIR:PATH=D:/DONNEES/Nightly-OTB/bin/OTB

CMAKE_CONFIGURATION_TYPES:STRING=Release
")
