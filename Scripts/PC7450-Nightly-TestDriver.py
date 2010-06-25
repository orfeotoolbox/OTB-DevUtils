import otbTestDriver

driverName  = 'PC7450-Nightly-TestDriver-Release-Internal-ITK-Internal-FLTK-With-OSGEO'
logFilePath = 'D:/Developpement/OTB-NIGHTLY-VALIDATION/crt'

cmakeExe    = 'C:/Program Files/CMake 2.8/bin/cmake.exe'
cmakeArgs   = '-G "Visual Studio 9 2008"'
ctestExe    = 'C:/Program Files/CMake 2.8/bin/ctest.exe'
ctestArgs   = '-D Nightly'
cpackExe    = 'C:/Program Files/CMake 2.8/bin/cpack.exe'
hgExe       = 'C:/Program Files/Mercurial/hg.exe'

binRootPath = 'D:/Developpement/OTB-NIGHTLY-VALIDATION/OSGEO-Release/binaries/'
srcRootPath = 'D:/Developpement/OTB-hg/'

otbSrcPath     = srcRootPath+'OTB'
otbBuildPath   = binRootPath+'OTB'
otbConfPath    = 'D:\Developpement\OTB-hg\OTB-DevUtils\Config\PC7450-OTB-Nightly.cmake'

montSrcPath    = srcRootPath+'Monteverdi'
montBuildPath  = binRootPath+'Monteverdi'
montConfPath   = 'D:\Developpement\OTB-hg\OTB-DevUtils\Config\PC7450-Monteverdi-Nightly.cmake'

#GEmontSrcPath    = srcRootPath+'GE-Monteverdi'
#GEmontBuildPath  = binRootPath+'GE-Monteverdi'
#GEmontConfPath   = '/ORFEO/otbval/OTB-NIGHTLY-VALIDATION/OTB-DevUtils/Config/dora-GE-Monteverdi-Nightly.cmake'

wrappingSrcPath    = srcRootPath+'OTB-Wrapping'
wrappingBuildPath  = binRootPath+'OTB-Wrapping'
wrappingConfPath   = 'D:\Developpement\OTB-hg\OTB-DevUtils\Config\PC7450-OTB-Wrapping-Nightly.cmake'

dataPath    = srcRootPath+'OTB-Data'

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
myDriver.SetMercurialExecutable(hgExe)

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


#==== Monteverdi ====

# Update
myDriver.HgPullUpdate(montSrcPath,nightlyRevisions['Monteverdi'])

# Clean the build directory
myDriver.CleanDirectory(montBuildPath)

# Cmake configure
myDriver.CMake(montSrcPath,montBuildPath,montConfPath,cmakeArgs)

# CTest
myDriver.CTest(montBuildPath,ctestArgs)

#==== OTB-Applications ====

# Update
#myDriver.HgPullUpdate(appSrcPath,nightlyRevisions['OTB-Applications'])

# Clean the build directory
#myDriver.CleanDirectory(appBuildPath)

# Cmake configure
#myDriver.CMake(appSrcPath,appBuildPath,appConfPath,cmakeArgs)

# CTest
#myDriver.CTest(appBuildPath,ctestArgs)




#==== GE-Monteverdi ====
# Update
myDriver.HgPullUpdate(wrappingSrcPath,'')

# Clean the build directory
myDriver.CleanDirectory(wrappingBuildPath)

# Cmake configure
myDriver.CMake(wrappingSrcPath,wrappingBuildPath,wrappingConfPath,cmakeArgs)

# CTest
myDriver.CTest(wrappingBuildPath,ctestArgs)

