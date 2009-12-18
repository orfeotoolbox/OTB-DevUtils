import otbTestDriver

myDriver = otbTestDriver.otbTestDriver()

myDriver.SetDriverName("TestDriver")
myDriver.SetBuildPath("/home/julien/Local/bin/TestScriptMonteverdi")
myDriver.SetSourcePath("/home/julien/Local/src/Monteverdi")
myDriver.SetConfigurationFile("/home/julien/Local/config.cmake")
myDriver.SetLogFilesPath("/home/julien/Local/")

myDriver.UpdateSources()
myDriver.CleanBuild()
myDriver.Configure()
myDriver.Test("-D ExperimentalBuild -DExperimentalTest")




                       
