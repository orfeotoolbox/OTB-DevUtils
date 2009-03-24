import sys
import os
import platform
import socket
#import subprocess

if __name__ == "__main__":
        
#        chaine = 'cmake'
#        ded = chaine.split(' ')
#        print ded
#        for i in range(len(ded)):
#            print ded[i]
#        exit(1)
        
        crtfile = open("/ORFEO/otbval/OTB-NIGHTLY-VALIDATION/pyton.txt","w")
        crtfile.write("START\n")
        crtfile.close()
        # Update OTB-DevUtils module
        sys.path.append("/ORFEO/otbval/OTB-NIGHTLY-VALIDATION/OTB-DevUtils/Scripts")
        try:
                import Validation
        except:
                print 'Impossible to find Validation module (import Validation abort!!)'
                exit(1)

        crtfile = open("/ORFEO/otbval/OTB-NIGHTLY-VALIDATION/pyton.txt","a")
        crtfile.write("START 2\n")
        crtfile.close()
        
        print 'Star.............'
        x=Validation.TestProcessing()

        # Set dirs
        x.SetOtbDataLargeInputDir("/home2/data/OTB-Data-LargeInput")
        x.DisableUseOtbDataLargeInput()

        x.SetSourcesDir("/ORFEO/otbval")
        x.DisableUpdateNightlySources()

        x.SetOutilsDir("/ORFEO/otbval")
        x.SetRunDir("/ORFEO/otbval")

        # Set generate makefile options
	    # Set Generals configuration tests
        x.EnableGenerateMakefiles()

#        x.EnableBuildExamples()
#        x.EnableUseVtk()
#        x.EnableTestOTBApplicationsWithInstallOTB()
        x.DisableBuildExamples()
        x.DisableUseVtk()
        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableGlUseAccel()
	
#        x.SetGeotiffIncludeDirs("/ORFEO/otbval/OTB-OUTILS/gdal/install-linux/include")
#        x.SetTiffIncludeDirs("/ORFEO/otbval/OTB-OUTILS/gdal/install-linux/include")
#        x.SetJpegIncludeDirs("/ORFEO/otbval/OTB-OUTILS/gdal/install-linux/include")
        
        x.SetGeotiffIncludeDirs("/ORFEO/otbval/OTB-OUTILS/gdal/gdal-1.6.0/frmts/gtiff/libgeotiff")
        x.SetTiffIncludeDirs("/ORFEO/otbval/OTB-OUTILS/gdal/gdal-1.6.0/frmts/gtiff/libtiff")
        x.SetJpegIncludeDirs("/ORFEO/otbval/OTB-OUTILS/gdal/gdal-1.6.0/frmts/jpeg/libjpeg")
        x.SetDistribName("UBU-8.04") 

        x.SetTuContinuousTesting()
        x.DisableCTest()
#        x.ForceExecution()

        # List of platform must been tested
#        try:
#                x.Run("linux-static-debug-itk-internal-fltk-internal")
#        except:
#                print 'Error while executing run method', sys.exc_info()[0]
#                exit(1)

        print 'Run.............'
        try:
                x.Run("linux-shared-release-itk-external-fltk-external")
        except:
                print 'Error while executing run method (doraWeekValidation.py file)', sys.exc_info()[0]

