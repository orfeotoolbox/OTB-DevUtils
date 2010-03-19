import otbTestDriver

driverName  = 'dora-GE-Monteverdi-TestDriver'
logFilePath = '/ORFEO/otbval/OTB-NIGHTLY-VALIDATION/crt'

cmakeExe    = '/usr/bin/cmake'
cmakeArgs   = ''
ctestExe    = '/usr/bin/ctest'
ctestArgs   = '--track Nightly'
cpackExe    = '/usr/bin/cpack'

binRootPath = "/ORFEO/otbval/OTB-NIGHTLY-VALIDATION/testDriver-linux-shared-release-itk-internal-fltk-internal/binaries/"
srcRootPath = "/ORFEO/otbval/WWW.ORFEO-TOOLBOX.ORG-CS-NIGHTLY/"

otbSrcPath     = srcRootPath+'OTB'
otbBuildPath   = binRootPath+'OTB'
otbConfPath    = '/ORFEO/otbval/OTB-NIGHTLY-VALIDATION/OTB-DevUtils/Config/dora-OTB-Nightly.cmake'

appSrcPath     = srcRootPath+'OTB-Applications'
appBuildPath   = binRootPath+'OTB-Applications'
appConfPath    = '/ORFEO/otbval/OTB-NIGHTLY-VALIDATION/OTB-DevUtils/Config/dora-OTB-Applications-Nightly.cmake'

montSrcPath    = srcRootPath+'Monteverdi'
montBuildPath  = binRootPath+'Monteverdi'
montConfPath   = '/ORFEO/otbval/OTB-NIGHTLY-VALIDATION/OTB-DevUtils/Config/dora-Monteverdi-Nightly.cmake'

GEmontSrcPath    = srcRootPath+'GE-Monteverdi'
GEmontBuildPath  = binRootPath+'GE-Monteverdi'
GEmontConfPath   = '/ORFEO/otbval/OTB-NIGHTLY-VALIDATION/OTB-DevUtils/Config/dora-GE-Monteverdi-Nightly.cmake'

#wrappingSrcPath    = srcRootPath+'OTB-Wrapping'
#wrappingBuildPath  = binRootPath+'OTB-Wrapping'
#wrappingConfPath   = '/ORFEO/otbval/OTB-NIGHTLY-VALIDATION/OTB-DevUtils/Config/dora-OTB-Wrapping-Nightly.cmake'

dataPath    = srcRootPath+'OTB-Data'

print 'step 1'

# Create the driver
myDriver = otbTestDriver.otbTestDriver()

print 'step 2'

# Set the driver name
myDriver.SetDriverName(driverName)

print 'step 3'

# Set the path to the log files
myDriver.SetLogFilesPath(logFilePath)

print 'step 4'

# Set path to a specific version of cmake
myDriver.SetCMakeExecutable(cmakeExe)
myDriver.SetCTestExecutable(ctestExe)
myDriver.SetCPackExecutable(cpackExe)

print 'step 5'

# Retrieve the nightly revisions
nightlyRevisions = myDriver.GetNightlyRevisions()
print 'step 6'
# Update data
myDriver.HgPullUpdate(dataPath)

print 'step 7'

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


#==== GE-Monteverdi ====
# Update
myDriver.HgPullUpdate(GEmontSrcPath,'')

# Clean the build directory
myDriver.CleanDirectory(GEmontBuildPath)

# Cmake configure
myDriver.CMake(GEmontSrcPath,GEmontBuildPath,GEmontConfPath,cmakeArgs)

# CTest
myDriver.CTest(GEmontBuildPath,ctestArgs)

