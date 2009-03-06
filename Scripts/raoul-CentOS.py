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
        x.SetRunDir("/data/otbval")
        x.SetOutilsDir("/data/otbval")
        x.SetOtbDataLargeInputDir("/data/otbval/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("/data/otbval")

        # -> Active generation makefiles
        x.EnableTestOTBApplicationsWithInstallOTB()
        x.EnableUseVtk()
        x.DisableGlUseAccel()
        x.EnableBuildExamples()
        x.SetDistribName("CentOS-5.2")
        x.SetGeotiffIncludeDirs("/data/otbval/OTB-OUTILS/gdal/binaries-linux/frmts/gtiff/libgeotiff")
        
        reference_configuration = "centOS-linux-64bits-shared-release-itk-external-fltk-external"

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
                x.Run("centOS-linux-64bits-static-release-itk-internal-fltk-internal")

        # =========    WEEKEND    ============ 
        if sys.argv[1] == "WEEKEND":
                x.EnableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetFullNightlyTesting()

                x.Run(reference_configuration)
#                x.Run("centOS-linux-64bits-static-debug-itk-internal-fltk-internal")
#                x.Run("centOS-linux-64bits-static-debug-itk-external-fltk-external")
#                x.Run("centOS-linux-64bits-shared-debug-itk-internal-fltk-internal")
                # Debug - External
#                x.Run("centOS-linux-64bits-shared-debug-itk-external-fltk-external")
                # Release - Internal
                x.Run("centOS-linux-64bits-static-release-itk-internal-fltk-internal")
                x.Run("centOS-linux-64bits-shared-release-itk-internal-fltk-internal")
                # Release - External
                x.Run("centOS-linux-64bits-static-release-itk-external-fltk-external")

        # =========    LOCAL TESTING   ============ 
        elif sys.argv[1] == "LOCAL_TESTING":
                x.EnableUpdateCurrentSources()
                x.EnableGenerateMakefiles()
                x.SetTuContinuousTesting()
                x.DisableCTest()
                x.Run("centOS-linux-64bits-shared-release-itk-internal-fltk-internal")
