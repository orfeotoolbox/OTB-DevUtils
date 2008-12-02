import sys
import os
import platform
import socket
#import subprocess

if __name__ == "__main__":
        sys.path.append(os.getcwd()+"/OTB-DevUtils/Scripts")
        try:
                import Validation
        except:
                print 'Impossible to find Validation module (import Validation abort!!)'
                exit(1)

        #os.chdir("..")
        x=Validation.TestProcessing()

        #Set the external tools version

        x.DisableBuildExamples()
        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableGlUseAccel()
        x.DisableUseVtk()

        x.SetOtbDataLargeInputDir("X:\\OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()

        x.SetSourcesDir("Z:\\")
        x.DisableUpdateSources()

        x.SetOutilsDir("D:\\")
        x.SetRunDir("D:\\")
        
	# Set Generals configuration tests
#        x.EnableMakeClean()
        x.EnableGenerateMakefiles()

        # List of platform must been tested
	x.Run("visual7-static-release-itk-internal-fltk-internal")

