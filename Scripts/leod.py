import sys
import os
import platform
import socket
import subprocess

if __name__ == "__main__":
        sys.path.append(os.getcwd()+"/OTB-DevUtils/Scripts")
        try:
                import Validation
        except:
                print 'Impossible to find Validation module (import Validation abort!!)'
                exit(1)
        if len(sys.argv) != 2:
                print "Error  -->   Usage: ", sys.argv[0], " WEEK/WEEKEND/DAY_TESTING/DAY_COMPILATION/LOCAL_TESTING"
                exit(1)

        x=Validation.TestProcessing()

        # Set dirs
        x.SetOutilsDir("/Users/otbval/")
        x.SetRunDir("/Users/otbval/")
        x.SetOtbDataLargeInputDir("/Users/data/OTB-LargeInput")
        x.EnableUseOtbDataLargeInput()
	x.DisableUseGettext()
        x.SetSourcesDir("/Users/otbval/")
        x.SetSite("leod")
	x.SetNumberOfCores(8)
	x.SetDoxygenPath("/Users/otbval/OTB-OUTILS/Doxygen/binaries/bin/doxygen")
	x.SetDotPath("/Users/otbval/OTB-OUTILS/Doxygen/binaries/bin/doxytag")
        
        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableUseVtk()
        x.DisableGlUseAccel()
        x.EnableBuildExamples()

        x.SetGeotiffIncludeDirs("/Users/otbval/OTB-OUTILS/gdal/gdal-1.6.1/frmts/gtiff/libgeotiff")
        x.SetTiffIncludeDirs("/Users/otbval/OTB-OUTILS/gdal/gdal-1.6.1/frmts/gtiff/libtiff")
        x.SetJpegIncludeDirs("/Users/otbval/OTB-OUTILS/gdal/gdal-1.6.1/frmts/jpeg/libjpeg")

        reference_configuration = "macosx-shared-release-itk-internal-fltk-external"
	test_configuration = "TEST-macosx-shared-release-itk-internal-fltk-external"

        # =========    DAY TESTING   ============ 
        if sys.argv[1] == "DAY_TESTING":
                x.EnableUpdateCurrentSources()
                x.EnableGenerateMakefiles()
                x.SetContinuousTesting()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.DisableTlTesting() 
                x.DisableTeTesting()
                x.Run(reference_configuration)
 
        # =========    DAY COMPILATION   ============ 
        if sys.argv[1] == "DAY_COMPILATION":
                x.EnableUpdateCurrentSources()
                x.EnableGenerateMakefiles()
                x.SetContinuousTesting()
                x.EnableTuTesting() 
                x.DisableTvTesting() 
                x.DisableTlTesting() 
                x.DisableTeTesting() 
                x.Run(reference_configuration)
 
        # =========    WEEK    ============ 
        if sys.argv[1] == "WEEK":
                x.EnableUpdateNightlySources()
                x.EnableGenerateMakefiles()
		x.SetNightlyTesting()
                x.EnableCompileWithFullWarning()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.EnableTlTesting() 
                x.EnableTeTesting()
		x.EnableOTBWrapping() 
		x.EnableWrapPython()
		x.EnableWrapJava()
                x.Run(reference_configuration)

        # =========    WEEKEND    ============ 
        if sys.argv[1] == "WEEKEND":
                x.EnableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetNightlyTesting()
                x.EnableCompileWithFullWarning()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.EnableTlTesting() 
                x.EnableTeTesting() 
		x.EnableOTBWrapping() 
		x.EnableWrapPython()
		x.EnableWrapJava()
                x.Run(reference_configuration)

        # =========    LOCAL TESTING   ============ 
        elif sys.argv[1] == "LOCAL_TESTING":
                x.EnableUpdateCurrentSources()
                x.EnableGenerateMakefiles()
                x.SetExperimentalTesting()
                x.EnableTuTesting() 
                #x.EnableTvTesting() 
                #x.EnableTlTesting() 
                x.DisableTeTesting() 
                x.ForceExecution()
                #x.DisableCTest()
		x.EnableOTBWrapping()
		x.DisableWrapPython()
		x.EnableWrapJava()
                x.Run(test_configuration)
