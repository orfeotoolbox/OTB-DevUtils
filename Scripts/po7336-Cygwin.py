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
        x.SetOtbDataLargeInputDir("/cygdrive/d/OTB-CNES/OTB-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("/cygdrive/d")

#        x.SetGeotiffIncludeDirs("/cygdrive/d/OTB-OUTILS/gdal/sources/gdal-1.6.0/frmts/gtiff/libgeotiff")
#        x.SetTiffIncludeDirs("/cygdrive/d/OTB-OUTILS/gdal/sources/gdal-1.6.0/frmts/gtiff/libtiff")
#        x.SetJpegIncludeDirs("/cygdrive/d/OTB-OUTILS/gdal/sources/gdal-1.6.0/frmts/jpeg/libjpeg")
        x.SetGeotiffIncludeDirs("/cygdrive/d/OTB-OUTILS/gdal/install-cygwin")
        x.SetTiffIncludeDirs("/cygdrive/d/OTB-OUTILS/gdal/install-cygwin")
        x.SetJpegIncludeDirs("/cygdrive/d/OTB-OUTILS/gdal/install-cygwin")

        # =========    DAY TESTING   ============ 
        if sys.argv[1] == "DAY_TESTING":
                x.DisableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetContinuousTesting()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.DisableTlTesting() 
                x.DisableTeTesting() 
                x.Run("cygwin-static-debug-itk-internal-fltk-internal")
 
        # =========    DAY COMPILATION   ============ 
        elif sys.argv[1] == "DAY_COMPILATION":
                x.DisableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetContinuousTesting()
                x.EnableTuTesting() 
                x.DisableTvTesting() 
                x.DisableTlTesting() 
                x.DisableTeTesting() 
                x.Run("cygwin-static-debug-itk-internal-fltk-internal")
 
        # =========    WEEKEND    ============ 
        elif sys.argv[1] == "WEEKEND":
                x.DisableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetNightlyTesting()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.DisableTlTesting() 
                x.EnableTeTesting() 
                x.Run("cygwin-static-debug-itk-internal-fltk-internal")
                x.Run("cygwin-shared-release-itk-internal-fltk-internal")

        # =========    WEEK    ============ 
        elif sys.argv[1] == "WEEK":
                x.DisableUpdateNightlySources()
                x.DisableGenerateMakefiles()
                x.SetNightlyTesting()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.DisableTlTesting() 
                x.DisableTeTesting() 
                x.Run("cygwin-static-debug-itk-internal-fltk-internal")


        # =========    LOCAL TESTING   ============ 
        elif sys.argv[1] == "LOCAL_TESTING":
                x.DisableUpdateCurrentSources()
                x.EnableGenerateMakefiles()
                x.SetNightlyTesting()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.EnableTlTesting() 
                x.DisableTeTesting() 
#                x.DisableCTest()
                x.ForceExecution()
                x.Run("cygwin-shared-release-itk-internal-fltk-internal")
#                x.Run("cygwin-static-debug-itk-internal-fltk-internal")


