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
        x.SetOutilsDir("/Users/thomas/")
        x.SetRunDir("/Users/thomas/")
        x.SetOtbDataLargeInputDir("/Users/thomas/OTB-Data-LargeInput")
        x.DisableUseOtbDataLargeInput()
        x.SetSourcesDir("/Users/thomas/")

        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableUseVtk()
        x.DisableGlUseAccel()
        x.DisableBuildExamples()

        x.SetGeotiffIncludeDirs("/Users/thomas/OTB-OUTILS/gdal/gdal1.6.0/frmts/gtiff/libgeotiff")
        x.SetTiffIncludeDirs("/Users/thomas/OTB-OUTILS/gdal/gdal1.6.0/frmts/gtiff/libtiff")
        x.SetJpegIncludeDirs("/Users/thomas/OTB-OUTILS/gdal/gdal1.6.0/frmts/jpeg/libjpeg")

        reference_configuration = "macosx-static-release-itk-internal-fltk-external"

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
                x.DisableGenerateMakefiles()
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
                x.DisableUpdateCurrentSources()
                x.EnableGenerateMakefiles()
                x.SetTuContinuousTesting()
                x.ForceExecution()
                x.DisableCTest()
                x.Run("macosx-static-release-itk-internal-fltk-external")
