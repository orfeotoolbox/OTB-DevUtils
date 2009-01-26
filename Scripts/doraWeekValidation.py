import sys
import os
import platform
import socket
#import subprocess

if __name__ == "__main__":
        # Update OTB-DevUtils module
        sys.path.append("/ORFEO/otbval/OTB-NIGHTLY-VALIDATION/OTB-DevUtils/Scripts")
        try:
                import Validation
        except:
                print 'Impossible to find Validation module (import Validation abort!!)'
                exit(1)

        x=Validation.TestProcessing()

        # Set dirs
        x.SetOtbDataLargeInputDir("/home2/data/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()

        x.SetSourcesDir("/ORFEO/otbval")
        x.DisableUpdateNightlySources()

        x.SetOutilsDir("/ORFEO/otbval")
        x.SetRunDir("/ORFEO/otbval")

        # Set generate makefile options
	# Set Generals configuration tests
	x.EnableGenerateMakefiles()
        x.EnableBuildExamples()
        x.EnableUseVtk()
        x.EnableTestOTBApplicationsWithInstallOTB()
        x.DisableGlUseAccel()
        x.SetDistribName("RHEL4.0") 
#        x.DisableCTest()
        
        # List of platform must been tested
        try:
                x.Run("linux-static-debug-itk-internal-fltk-internal")
        except:
                print 'Error while executing run method', sys.exc_info()[0]
                exit(1)

        try:
                x.Run("linux-shared-release-itk-external-fltk-external")
        except:
                print 'Error while executing run method', sys.exc_info()[0]

