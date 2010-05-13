SET (CTEST_SOURCE_DIRECTORY "E:/crsec/trunk/Monteverdi")
SET (CTEST_BINARY_DIRECTORY "E:/crsec/OTB-Binary-Monteverdi")
SET (CTEST_CMAKE_COMMAND "E:/crsec/cmake/cmake-binary/bin/Release/cmake.exe")
SET (CTEST_COMMAND "E:/crsec/cmake/cmake-binary/bin/Release/ctest.exe -D Nightly -A CMakeCache.txt")
SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)
SET (CTEST_INITIAL_CACHE "
//Name of generator.
CMAKE_GENERATOR:INTERNAL=Visual Studio 9 2008

//Name of the build
BUILDNAME:STRING=Win32-VC90prof

//Name of the computer/site where compile is being run
SITE:STRING=phosphorus

//Build the testing tree.
BUILD_TESTING:BOOL=ON

//Path to a file.
GDAL_INCLUDE_DIR:PATH=C:/OSGeo4W/apps/gdal-16/include
")
