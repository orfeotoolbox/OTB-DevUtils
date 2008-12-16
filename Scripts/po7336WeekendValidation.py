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

        x=Validation.TestProcessing()
        x.SetRunDir("D:\\")
        x.SetOutilsDir("D:\\")
        x.SetOtbDataLargeInputDir("D:\\OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("D:\\")

        x.DisableUpdateSources()

        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableUseVtk()
        x.DisableGlUseAccel()
        x.DisableBuildExamples()

        # -> Active generation makefiles
        x.EnableGenerateMakefiles()
        
        x.DisableCTest()

        # List of platform must been tested
	x.Run("visual7-static-debug-itk-internal-fltk-internal")
#	x.Run("visual7-static-release-itk-external-fltk-external")
