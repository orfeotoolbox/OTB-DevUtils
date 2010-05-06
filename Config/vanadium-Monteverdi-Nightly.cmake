SET (CTEST_SOURCE_DIRECTORY "C:/OTB/trunk/Monteverdi")
SET (CTEST_BINARY_DIRECTORY "C:/OTB/Monteverdi-Binary")
SET (CTEST_CMAKE_COMMAND "C:/Program Files/CMake 2.8/bin/cmake.exe")
SET (CTEST_COMMAND "C:/Program Files/CMake 2.8/bin/ctest.exe -D Experimental -A CMakeCache.txt")
SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)
SET (CTEST_INITIAL_CACHE "
//Name of generator.
CMAKE_GENERATOR:INTERNAL=Visual Studio 9 2008

//Name of the build
BUILDNAME:STRING=Win32-VC90express

//Name of the computer/site where compile is being run
SITE:STRING=vanadium

//Build the testing tree.
BUILD_TESTING:BOOL=ON

//Path to a file.
GDAL_INCLUDE_DIR:PATH=C:/OSGeo4W/apps/gdal-16/include
")
