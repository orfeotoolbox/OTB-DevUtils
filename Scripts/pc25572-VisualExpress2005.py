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
        #x.SetOtbDataLargeInputDir("D:\\OTB-Data-LargeInput")
        x.DisableUseOtbDataLargeInput()
        x.SetSourcesDir("D:\\")
        x.EnableUpdateNightlySources()

#        x.SetGeotiffIncludeDirs("D:\\OTB-OUTILS\\gdal\\sources\\gdal-1.6.0\\frmts\\gtiff\\libgeotiff")
#        x.SetTiffIncludeDirs("D:\\OTB-OUTILS\\gdal\\sources\\gdal-1.6.0\\frmts\\gtiff\\libtiff")
#        x.SetJpegIncludeDirs("D:\\OTB-OUTILS\\gdal\\sources\\gdal-1.6.0\\frmts\\jpeg\\libjpeg")
        x.SetGeotiffIncludeDirs("D:\\OTB-OUTILS\\gdal\\install-visual7\\include")
        x.SetTiffIncludeDirs("D:\\OTB-OUTILS\\gdal\\install-visual7\\include")
        x.SetJpegIncludeDirs("D:\\OTB-OUTILS\\gdal\\install-visual7\\include")

        # =========    DAY TESTING   ============ 
        if sys.argv[1] == "DAY_TESTING":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetFullContinuousTesting()
                x.Run("visual7-static-release-itk-internal-fltk-internal")
 
        # =========    DAY COMPILATION   ============ 
        if sys.argv[1] == "DAY_COMPILATION":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetTuContinuousTesting()
                x.Run("visual7-static-release-itk-internal-fltk-internal")
 
        # =========    WEEK    ============ 
        if sys.argv[1] == "WEEK":
                x.EnableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetFullNightlyTesting()
                x.Run("visual7-static-release-itk-internal-fltk-internal")

        # =========    WEEKEND    ============ 
        if sys.argv[1] == "WEEKEND":
                x.EnableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetFullNightlyTesting()
                x.Run("visual7-static-release-itk-internal-fltk-internal")

        # =========    LOCAL TESTING   ============ 
        elif sys.argv[1] == "LOCAL_TESTING":
                x.EnableUpdateCurrentSources()
                x.EnableGenerateMakefiles()
                x.SetTuContinuousTesting()
                x.DisableCTest()
                x.Run("visual7-static-release-itk-internal-fltk-internal")
