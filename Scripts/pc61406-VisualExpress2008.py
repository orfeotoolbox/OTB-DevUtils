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
        x.SetRunDir("D:\\OTB-NIGHTLY")
        x.SetOutilsDir("D:\\OTB-NIGHTLY")
        x.DisableUseOtbDataLargeInput()
#        x.SetOtbDataLargeInputDir("D:\\OTB-NIGHTLY\\OTB-Data-LargeInput")
        x.SetSourcesDir("D:\\OTB-NIGHTLY")
        x.EnableUpdateNightlySources()

        # -> Active generation makefiles
        x.EnableTestOTBApplicationsWithInstallOTB()
        x.DisableUseVtk()
        x.DisableGlUseAccel()
        x.EnableBuildExamples()

        x.SetGeotiffIncludeDirs("D:\\OTB-NIGHTLY\\OTB-OUTILS\\gdal\\install-visualExpress2008\\include")
        x.SetTiffIncludeDirs("D:\\OTB-NIGHTLY\\OTB-OUTILS\\gdal\\install-visualExpress2008\\include")
        x.SetJpegIncludeDirs("D:\\OTB-NIGHTLY\\OTB-OUTILS\\gdal\\install-visualExpress2008\\include")

        reference_configuration = "visualExpress2008-static-release-itk-internal-fltk-internal"

        # =========    DAY TESTING   ============ 
        if sys.argv[1] == "DAY_TESTING":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetFullContinuousTesting()
                x.Run(reference_configuration)
 
        # =========    DAY COMPILATION   ============ 
        if sys.argv[1] == "DAY_COMPILATION":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetTuContinuousTesting()
                x.Run(reference_configuration)
 
        # =========    WEEK    ============ 
        if sys.argv[1] == "WEEK":
                x.EnableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetFullNightlyTesting()
                x.Run(reference_configuration)

        # =========    WEEKEND    ============ 
        if sys.argv[1] == "WEEKEND":
                x.EnableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetFullNightlyTesting()
                x.Run(reference_configuration)

        # =========    LOCAL TESTING   ============ 
        elif sys.argv[1] == "LOCAL_TESTING":
                x.EnableUpdateCurrentSources()
                x.EnableGenerateMakefiles()
                x.SetFullNightlyTesting()
#				x.DisableCTest()
                x.Run(reference_configuration)
