#!/usr/bin/python
import otbTestDriver

driverName  = "TestDriver"
logFilePath = "/ORFEO/julien/TEMP/TestDriver/"
srcPath     = "/ORFEO/julien/ORFEO-TOOLBOX/otb-hg/Monteverdi"
buildPath   = "/ORFEO/julien/TEMP/TestDriver-Build/"
confPath    = "/ORFEO/julien/TEMP/test.cmake"
ctestArgs   = "-D ExperimentalBuild -DExperimentalTest"

myDriver = otbTestDriver.otbTestDriver()

myDriver.SetDriverName(driverName)

myDriver.SetLogFilesPath(logFilePath)

myDriver.HgPullUpdate(srcPath)

myDriver.CleanDirectory(buildPath)

myDriver.CMake(srcPath,buildPath,confPath)

myDriver.CTest(buildPath,ctestArgs)




                       
