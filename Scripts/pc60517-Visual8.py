import otbTestDriver

driverName  = 'PC60517-VS8.0-TestDriver'
logFilePath = 'E:/Validation-OTB/LOGS'

cmakeExe    = 'C:/Program Files/CMake 2.6/bin/cmake.exe'
cmakeArgs   = '-G "Visual Studio 8 2005"'
ctestExe    = 'C:/ProgramFiles/CMake 2.6/bin/ctest.exe'
ctestArgs   = '--track Nightly'
cpackExe    = 'C:/Program Files/CMake 2.6/bin/cpack.exe'

otbSrcPath     = 'E:/Validation-OTB/HG/OTB'
otbBuildPath   = 'E:/Validation-OTB/BIN/OTB'
otbConfPath    = 'E:/Validation-OTB/HG/OTB-DevUtils/Config/PC60517-OTB-Nightly.cmake'

appSrcPath     = 'E:/Validation-OTB/HG/OTB-Applications'
appBuildPath   = 'E:/Validation-OTB/BIN/OTB-Applications'
appConfPath    = 'E:/Validation-OTB/HG/OTB-DevUtils/Config/PC60517-OTB-Applications-Nightly.cmake'

montSrcPath    = 'E:/Validation-OTB/HG/Monteverdi'
montBuildPath  = 'E:/Validation-OTB/BIN/Monteverdi'
montConfPath   = 'E:/Validation-OTB/HG/OTB-DevUtils/Config/PC60517-Monteverdi-Nightly.cmake'

dataPath       = 'E:/Validation-OTB/HG/OTB-Data'

# Create the driver
myDriver = otbTestDriver.otbTestDriver()

# Set the driver name
myDriver.SetDriverName(driverName)

# Set the path to the log files
myDriver.SetLogFilesPath(logFilePath)

# Set path to a specific version of cmake
myDriver.SetCMakeExecutable(cmakeExe)
myDriver.SetCTestExecutable(ctestExe)
myDriver.SetCPackExecutable(cpackExe)

# Retrieve the nightly revisions
nightlyRevisions = myDriver.GetNightlyRevisions()
 
# Update data
myDriver.HgPullUpdate(dataPath)

#==== OTB ====

# Update
myDriver.HgPullUpdate(otbSrcPath,nightlyRevisions['OTB'])

# Clean the build directory
myDriver.CleanDirectory(otbBuildPath)

# Cmake configure
myDriver.CMake(otbSrcPath,otbBuildPath,otbConfPath,cmakeArgs)

# CTest
myDriver.CTest(otbBuildPath,ctestArgs)

#==== OTB-Applications ====

# Update
myDriver.HgPullUpdate(appSrcPath,nightlyRevisions['OTB-Applications'])

# Clean the build directory
myDriver.CleanDirectory(appBuildPath)

# Cmake configure
myDriver.CMake(appSrcPath,appBuildPath,appConfPath,cmakeArgs)

# CTest
myDriver.CTest(appBuildPath,ctestArgs)

#==== Monteverdi ====

# Update
myDriver.HgPullUpdate(montSrcPath,nightlyRevisions['Monteverdi'])

# Clean the build directory
myDriver.CleanDirectory(montBuildPath)

# Cmake configure
myDriver.CMake(montSrcPath,montBuildPath,montConfPath,cmakeArgs)

# CTest
myDriver.CTest(montBuildPath,ctestArgs)
