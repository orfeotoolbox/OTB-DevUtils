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
        x.SetOtbDataLargeInputDir("/home2/data/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("/ORFEO/otbval")
        x.SetOutilsDir("/ORFEO/otbval")
        x.SetRunDir("/ORFEO/otbval")


        # -> Active generation makefiles
        x.EnableTestOTBApplicationsWithInstallOTB()
        x.EnableUseVtk()
        x.DisableGlUseAccel()
        x.EnableBuildExamples()

        x.SetGeotiffIncludeDirs("/ORFEO/otbval/OTB-OUTILS/gdal/gdal-1.6.0/frmts/gtiff/libgeotiff")
        x.SetTiffIncludeDirs("/ORFEO/otbval/OTB-OUTILS/gdal/gdal-1.6.0/frmts/gtiff/libtiff")
        x.SetJpegIncludeDirs("/ORFEO/otbval/OTB-OUTILS/gdal/gdal-1.6.0/frmts/jpeg/libjpeg")
        x.SetDistribName("UBU-8.04") 

        reference_configuration  = "linux-shared-release-itk-internal-fltk-internal"
        reference_configuration2 = "linux-static-debug-itk-external-fltk-external"

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
 
        # =========    WEEK    ============ 
        elif sys.argv[1] == "WEEK":
                x.EnableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetFullNightlyTesting()
               
                x.Run(reference_configuration)

        # =========    WEEKEND    ============ 
        elif sys.argv[1] == "WEEKEND":
                x.EnableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetFullNightlyTesting()

                x.Run(reference_configuration)
                x.Run(reference_configuration2)
        
        # =========    LOCAL TESTING   ============ 
        elif sys.argv[1] == "LOCAL_TESTING":
                x.EnableUpdateCurrentSources()
                x.EnableGenerateMakefiles()
                x.SetTuContinuousTesting()
#                x.ForceExecution()
                x.DisableCTest()
                
                x.Run(reference_configuration)
