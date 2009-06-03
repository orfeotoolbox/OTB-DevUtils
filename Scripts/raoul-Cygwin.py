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
        x.SetRunDir("/cygdrive/d")
        x.SetOutilsDir("/cygdrive/d")
#        x.SetOtbDataLargeInputDir("/cygdrive/y/OTB-HG-CS/OTB-Data-LargeInput")
        x.DisableUseOtbDataLargeInput()
        x.SetSourcesDir("/cygdrive/d")

        x.SetGeotiffIncludeDirs("/cygdrive/d/OTB-OUTILS/gdal/install-cygwin/include")
        x.SetTiffIncludeDirs("/cygdrive/d/OTB-OUTILS/gdal/install-cygwin/include")
        x.SetJpegIncludeDirs("/cygdrive/d/OTB-OUTILS/gdal/install-cygwin/include")

        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableUseVtk()
        x.DisableGlUseAccel()
        x.DisableBuildExamples()

        reference_configuration = "cygwin-shared-release-itk-internal-fltk-internal"
	
        # =========    DAY TESTING   ============ 
        if sys.argv[1] == "DAY_TESTING":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetContinuousTesting()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.DisableTlTesting() 
                x.Run(reference_configuration)
 
        # =========    DAY COMPILATION   ============ 
        elif sys.argv[1] == "DAY_COMPILATION":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetContinuousTesting()
                x.EnableTuTesting() 
                x.DisableTvTesting() 
                x.DisableTlTesting() 
                x.Run(reference_configuration)
 
        # =========    WEEKEND    ============ 
        elif sys.argv[1] == "WEEKEND":
                x.DisableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetNightlyTesting()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.EnableTlTesting() 
                x.Run(reference_configuration)
                x.Run("cygwin-static-debug-itk-internal-fltk-internal")

        # =========    WEEK    ============ 
        elif sys.argv[1] == "WEEK":
                x.DisableUpdateNightlySources()
                x.DisableGenerateMakefiles()
#                x.EnableGenerateMakefiles()
                x.SetNightlyTesting()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.EnableTlTesting() 
                x.Run(reference_configuration)

        # =========    LOCAL TESTING   ============ 
        elif sys.argv[1] == "LOCAL_TESTING":
                x.DisableUpdateCurrentSources()
#                x.DisableGenerateMakefiles()
                x.EnableGenerateMakefiles()
                x.SetContinuousTesting()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.EnableTlTesting() 
                x.DisableCTest()
#                x.ForceExecution()
                x.Run(reference_configuration)



