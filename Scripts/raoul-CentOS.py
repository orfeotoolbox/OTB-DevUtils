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
                print "Error  -->   Usage: ", sys.argv[0], " WEEK/WEEKEND"
                exit(1)

        x=Validation.TestProcessing()
        x.SetRunDir("/data/otbval")
        x.SetOutilsDir("/data/otbval")
        x.SetOtbDataLargeInputDir("/data/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("/data/otbval")
        x.EnableUpdateNightlySources()

        # -> Active generation makefiles
        x.EnableTestOTBApplicationsWithInstallOTB()
        x.EnableUseVtk()
        x.DisableGlUseAccel()
        x.EnableBuildExamples()
        x.SetDistribName("CentOS-5.2")
        x.SetGeotiffIncludeDirs("/data/otbval/OTB-OUTILS/gdal/binaries-linux/frmts/gtiff/libgeotiff")
        
        # -> Complet GENERATION
        x.EnableGenerateMakefiles()

        # =========    WEEK    ============ 
        x.Run("CentOS-linux-64bits-shared-release-itk-external-fltk-external")
        x.Run("CentOS-linux-64bits-static-debug-itk-internal-fltk-internal")

        # =========    WEEKEND    ============ 
        if sys.argv[1] == "WEEKEND":
                x.Run("CentOS-linux-64bits-static-debug-itk-external-fltk-external")
                x.Run("CentOS-linux-64bits-shared-debug-itk-internal-fltk-internal")
                # Debug - External
                x.Run("CentOS-linux-64bits-shared-debug-itk-external-fltk-external")
                # Release - Internal
                x.Run("CentOS-linux-64bits-static-release-itk-internal-fltk-internal")
                x.Run("CentOS-linux-64bits-shared-release-itk-internal-fltk-internal")
                # Release - External
                x.Run("CentOS-linux-64bits-static-release-itk-external-fltk-external")
