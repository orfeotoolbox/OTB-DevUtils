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
        x.SetRunDir("/cygdrive/y")
        x.SetOutilsDir("/cygdrive/y")
        x.SetOtbDataLargeInputDir("/cygdrive/y/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("/cygdrive/y")

        x.SetGeotiffIncludeDirs("/cygdrive/y/OTB-OUTILS/gdal/install-cygwin/include")
        x.SetTiffIncludeDirs("/cygdrive/y/OTB-OUTILS/gdal/install-cygwin/include")
        x.SetJpegIncludeDirs("/cygdrive/y/OTB-OUTILS/gdal/install-cygwin/include")

        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableUseVtk()
        x.DisableGlUseAccel()
        x.DisableBuildExamples()
	
        # =========    DAY TESTING   ============ 
        if sys.argv[1] == "DAY_TESTING":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetFullContinuousTesting()
                x.Run("cygwin-shared-release-itk-external-fltk-external")
 
        # =========    DAY COMPILATION   ============ 
        elif sys.argv[1] == "DAY_COMPILATION":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetTuContinuousTesting()
                x.Run("cygwin-shared-release-itk-external-fltk-external")
 
        # =========    WEEKEND    ============ 
        elif sys.argv[1] == "WEEKEND":
#                x.EnableUpdateNightlySources()
                x.DisableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetFullNightlyTesting()
                x.Run("cygwin-shared-release-itk-external-fltk-external")
                x.Run("cygwin-static-debug-itk-internal-fltk-internal")

        # =========    WEEK    ============ 
        elif sys.argv[1] == "WEEK":
#                x.EnableUpdateNightlySources()
                x.DisableUpdateNightlySources()
#                x.DisableGenerateMakefiles()
                x.EnableGenerateMakefiles()
                x.SetFullNightlyTesting()
                x.Run("cygwin-shared-release-itk-external-fltk-external")

        # =========    LOCAL TESTING   ============ 
        elif sys.argv[1] == "LOCAL_TESTING":
                x.EnableUpdateCurrentSources()
#                x.EnableGenerateMakefiles()
                x.DisableGenerateMakefiles()
                x.SetTuContinuousTesting()
                x.DisableCTest()
                x.Run("cygwin-shared-release-itk-external-fltk-external")



