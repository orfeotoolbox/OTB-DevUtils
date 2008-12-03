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

        x.SetOutilsDir("E:\\")
        x.SetRunDir("E:\\")
        x.SetOtbDataLargeInputDir("E:\\OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()

        x.SetSourcesDir("Z:\\")
        x.DisableUpdateSources()

        
	# Set Generals configuration tests
        x.EnableBuildExamples()
        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableGlUseAccel()
        x.DisableUseVtk()
#        x.EnableMakeClean()
        x.EnableGenerateMakefiles()

        # List of platform must been tested
	x.Run("visual8-static-debug-itk-internal-fltk-internal")
#	x.Run("visual8-static-release-itk-internal-fltk-internal")
#	x.Run("visual8-static-debug-itk-external-fltk-external")
	x.Run("visual8-static-release-itk-external-fltk-external")

