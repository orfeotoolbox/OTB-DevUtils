import sys
import os
import platform
import socket

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
        x.SetRunDir("D:\\")
        x.SetOutilsDir("D:\\")
        x.EnableUseOtbDataLargeInput()
        x.SetOtbDataLargeInputDir("D:\\OTB-CNES\\OTB-LargeInput")
        x.SetSourcesDir("D:\\")

        # -> Active generation makefiles
        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableUseVtk()
        x.DisableGlUseAccel()
        x.EnableBuildExamples()

        x.SetGeotiffIncludeDirs("D:\\OTB-OUTILS\\gdal\\install-visualExpress2008\\include")
        x.SetTiffIncludeDirs("D:\\OTB-OUTILS\\gdal\\install-visualExpress2008\\include")
        x.SetJpegIncludeDirs("D:\\OTB-OUTILS\\gdal\\install-visualExpress2008\\include")
        # Wrap configurations
        x.SetWrapItkDims("2")
	x.SetDoxygenPath("D:\\OTB-OUTILS\\doxygen\\bin\\doxygen.exe")
	x.SetDotPath("D:\O\TB-OUTILS\doxygen\\bin\\doxytag.exe")

        reference_configuration = "visualExpress2008-static-release-itk-internal-fltk-internal"

        # =========    DAY TESTING   ============ 
        if sys.argv[1] == "DAY_TESTING":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetContinuousTesting()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.DisableTlTesting() 
                x.DisableTeTesting() 
                x.Run(reference_configuration)
 
        # =========    DAY COMPILATION   ============ 
        if sys.argv[1] == "DAY_COMPILATION":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetContinuousTesting()
                x.EnableTuTesting() 
                x.DisableTvTesting() 
                x.DisableTlTesting() 
                x.DisableTeTesting() 
                x.Run(reference_configuration)
 
        # =========    WEEK    ============ 
        if sys.argv[1] == "WEEK":
                x.EnableUpdateNightlySources()
#                x.DisableGenerateMakefiles()
                x.EnableGenerateMakefiles()
                x.SetNightlyTesting()
                x.EnableTuTesting() 
#                x.EnableTvTesting() 
#                x.EnableTlTesting() 
                x.DisableTvTesting() 
                x.DisableTlTesting() 
                x.DisableTeTesting()
		
		x.EnableOTBWrapping()
#               x.EnableWrapPython()
                x.EnableWrapJava()
                x.EnableCompileWithFullWarning()
                x.SetExperimentalTesting()

                x.Run(reference_configuration)

        # =========    WEEKEND    ============ 
        if sys.argv[1] == "WEEKEND":
                x.EnableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetNightlyTesting()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.EnableTlTesting() 
                x.DisableTeTesting() 
                x.Run(reference_configuration)

        # =========    LOCAL TESTING   ============ 
        elif sys.argv[1] == "LOCAL_TESTING":
                x.EnableUpdateCurrentSources()
                x.EnableGenerateMakefiles()
                x.SetContinuousTesting()
                x.EnableTuTesting() 
                x.DisableTvTesting() 
                x.DisableTlTesting() 
                x.DisableTeTesting() 
#               x.ForceExecution()
                x.DisableCTest()
                

   
                
                x.Run("MONTEVERDI-visualExpress2008-static-release-itk-internal-fltk-internal")

