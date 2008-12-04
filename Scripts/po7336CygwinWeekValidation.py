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
        x.SetRunDir("/cygdrive/d")
        x.SetOutilsDir("/cygdrive/d")
        x.SetOtbDataLargeInputDir("/cygdrive/d/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("/cygdrive/d")
        x.DisableUpdateSources()

        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableUseVtk()
        x.DisableGlUseAccel()
        x.DisableBuildExamples()

        x.EnableGenerateMakefiles()

        # List of platform must been tested
	x.Run("cygwin-static-release-itk-internal-fltk-internal")

