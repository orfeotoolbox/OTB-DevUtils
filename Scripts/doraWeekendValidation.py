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

        #Set the external tools version
#        x.SetItkVersion("3.6.0")
#        x.SetFltkVersion("1.1.9")
#        x.SetVtkVersion("5.0")

#        x.DisableBuildExamples()
#        x.DisableUseVtk()
        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableGlUseAccel()

        x.SetSourcesDir("/ORFEO/otbval")
        x.DisableUpdateSources()

        x.SetOtbDataLargeInputDir("/home2/data/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()

        x.SetOutilsDir("/ORFEO/otbval")
        x.SetRunDir("/ORFEO/otbval")
        
	# Set Generals configuration tests
#        x.EnableMakeClean()
        x.EnableGenerateMakefiles()
        # List of platform must been tested
#        x.DisableCTest()
        
	x.Run("linux-static-debugwall-itk-internal-fltk-internal")
	x.Run("linux-shared-release-itk-external-fltk-external")

