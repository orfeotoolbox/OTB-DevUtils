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
        x.SetOtbDataLargeInputDir("/home2/data/OTB-BASE-SVN/OTB-LargeInput")
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
        # Wrap configurations
        x.SetJavaJvmBaseDir("/usr/lib/jvm/java-6-sun")
        x.SetWrapItkDims("2")

        reference_configuration  = "linux-shared-release-itk-internal-fltk-internal"
        reference_configuration2 = "linux-static-debug-itk-external-fltk-external"

        # =========    DAY TESTING   ============ 
        if sys.argv[1] == "DAY_TESTING":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetContinuousTesting()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.DisableTlTesting() 
                x.DisableTeTesting() 
                x.Run(reference_configuration)
 
        # =========    DAY COMPILATION   ============ 
        elif sys.argv[1] == "DAY_COMPILATION":
                x.EnableUpdateCurrentSources()
                x.DisableGenerateMakefiles()
                x.SetContinuousTesting()
                x.EnableTuTesting() 
                x.DisableTvTesting() 
                x.DisableTlTesting() 
                x.DisableTeTesting() 
                
                x.Run(reference_configuration)
 
        # =========    WEEK    ============ 
        elif sys.argv[1] == "WEEK":
                x.EnableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetNightlyTesting()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.EnableTlTesting() 
                x.EnableTeTesting() 
               
                x.EnableOTBWrapping()
                x.DisableWrapPython()
                x.EnableWrapJava()
                x.Run(reference_configuration)
#                x.Run(reference_configuration2)

        # =========    WEEKEND    ============ 
        elif sys.argv[1] == "WEEKEND":
                x.EnableUpdateNightlySources()
                x.EnableGenerateMakefiles()
                x.SetNightlyTesting()
                x.EnableTuTesting() 
                x.EnableTvTesting() 
                x.EnableTlTesting() 
                x.EnableTeTesting() 

                x.EnableOTBWrapping()
                x.EnableWrapPython()
                x.EnableWrapJava()

                x.Run(reference_configuration)
                
                x.DisableOTBWrapping()
                x.Run(reference_configuration2)
        
        # =========    LOCAL TESTING   ============ 
        elif sys.argv[1] == "LOCAL_TESTING":
                x.EnableUpdateCurrentSources()
                x.EnableGenerateMakefiles()
                x.EnableTuTesting() 
                x.DisableTvTesting() 
                x.DisableTlTesting() 
                x.DisableTeTesting() 

                x.EnableOTBWrapping()
#                x.EnableWrapPython()
                x.EnableWrapJava()
                x.EnableCompileWithFullWarning()
                x.SetExperimentalTesting()
                x.ForceExecution()

                
                x.Run("TEST-SCRIPT-linux-shared-release-itk-internal-fltk-internal")
