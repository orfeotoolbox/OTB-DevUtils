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
        x.SetRunDir("G:\\")
        x.SetOutilsDir("G:\\")
        x.SetOtbDataLargeInputDir("G:\\OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("G:\\")

        x.SetGeotiffIncludeDirs("D:\\OTB-OUTILS\\gdal\\install-visual7\\include")
        x.SetTiffIncludeDirs("D:\\OTB-OUTILS\\gdal\\install-visual7\\include")
        x.SetJpegIncludeDirs("D:\\OTB-OUTILS\\gdal\\install-visual7\\include")

        x.EnableBuildExamples()
        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableGlUseAccel()
        x.DisableUseVtk()

        # =========    DAY TESTING   ============ 
        if sys.argv[1] == "DAY_TESTING":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.EnableGenerateMakefiles()
                x.SetFullContinuousTesting()
                x.Run("visual7-static-debug-itk-internal-fltk-internal")
 
        # =========    DAY COMPILATION   ============ 
        elif sys.argv[1] == "DAY_COMPILATION":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetTuContinuousTesting()
                x.Run("visual7-static-debug-itk-internal-fltk-internal")

        # =========    WEEK END VALIDATION   ============ 
        elif sys.argv[1] == "WEEKEND":
                x.EnableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetFullNightlyTesting()
                x.Run("visual7-static-debug-itk-internal-fltk-internal")
                x.Run("visual7-static-release-itk-internal-fltk-internal")
                x.Run("visual7-static-debug-itk-external-fltk-external")
                x.Run("visual7-static-release-itk-external-fltk-external")

        # =========    WEEK VALIDATION   ============ 
        elif sys.argv[1] == "WEEK":
                x.EnableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetFullNightlyTesting()
                x.Run("visual7-static-debug-itk-internal-fltk-internal")

        # =========    LOCAL TESTING   ============ 
        elif sys.argv[1] == "LOCAL_TESTING":
                x.EnableUpdateCurrentSources()
                x.EnableGenerateMakefiles()
                x.SetTuContinuousTesting()
                x.DisableCTest()
                x.Run("visual7-static-release-itk-internal-fltk-internal")
