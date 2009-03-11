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
        x.SetRunDir("/cygdrive/d/OTB-VALIDATION")
        x.SetOutilsDir("/cygdrive/d/OTB-VALIDATION")
        x.DisableUseOtbDataLargeInput()
#        x.SetOtbDataLargeInputDir("/cygdrive/d/XXXXXXXXXXXXXXXX_OTB-Data-LargeInput")
        x.SetSourcesDir("/cygdrive/d/OTB-VALIDATION")

        x.SetGeotiffIncludeDirs("/cygdrive/d/OTB-VALIDATION/OTB-OUTILS/gdal/install-cygwin/include")
        x.SetTiffIncludeDirs("/cygdrive/d/OTB-VALIDATION/OTB-OUTILS/gdal/install-cygwin/include")
        x.SetJpegIncludeDirs("/cygdrive/d/OTB-VALIDATION/OTB-OUTILS/gdal/install-cygwin/include")

         # -> Active generation makefiles
        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableUseVtk()
        x.DisableGlUseAccel()
        x.DisableBuildExamples()

        reference_configuration = "cygwin-shared-release-itk-internal-fltk-internal"
       # =========    DAY TESTING   ============ 
        if sys.argv[1] == "DAY_TESTING":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetFullContinuousTesting()
                x.Run(reference_configuration)
 
        # =========    DAY COMPILATION   ============ 
        elif sys.argv[1] == "DAY_COMPILATION":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetTuContinuousTesting()
                x.Run(reference_configuration)
 
        # =========    WEEKEND    ============ 
        elif sys.argv[1] == "WEEKEND":
                x.EnsableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetFullNightlyTesting()
                x.Run(reference_configuration)

        # =========    WEEK    ============ 
        elif sys.argv[1] == "WEEK":
                x.EnableUpdateNightlySources()
                x.DisableGenerateMakefiles()
                x.SetFullNightlyTesting()
                x.Run(reference_configuration)


        # =========    LOCAL TESTING   ============ 
        elif sys.argv[1] == "LOCAL_TESTING":
                x.DisableUpdateCurrentSources()
                x.EnableGenerateMakefiles()
                x.SetTuContinuousTesting()
                x.DisableCTest()
                x.Run(reference_configuration)


