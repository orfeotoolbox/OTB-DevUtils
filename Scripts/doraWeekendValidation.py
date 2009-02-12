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

        x=Validation.TestProcessing()

        # Set dirs
        x.SetSourcesDir("/ORFEO/otbval")
        x.DisableUpdateNightlySources()

        x.SetOtbDataLargeInputDir("/home2/data/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()

        x.SetOutilsDir("/ORFEO/otbval")
        x.SetRunDir("/ORFEO/otbval")

        x.EnableBuildExamples()
        x.EnableUseVtk()
        x.EnableTestOTBApplicationsWithInstallOTB()
        x.DisableGlUseAccel()
        x.SetDistribName("UBU-8.04") 
        x.SetGeotiffIncludeDirs("/ORFEO/otbval/OTB-OUTILS/gdal/binaries-linux/frmts/gtiff/libgeotiff")
        x.SetTiffIncludeDirs("/usr/include")

        x.EnableGenerateMakefiles()

        # Run WeekValidation tests
        x.Run("linux-static-debug-itk-internal-fltk-internal")
        x.Run("linux-static-release-itk-external-fltk-external")
        x.Run("linux-shared-release-itk-internal-fltk-internal")
        x.Run("linux-shared-debug-itk-external-fltk-external")

