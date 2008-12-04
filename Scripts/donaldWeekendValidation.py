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

        # Set dirs
        x.SetOtbDataLargeInputDir("/Users/thomas/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()

        x.SetSourcesDir("/Users/thomas/")
        x.EnableUpdateSources()

        x.SetOutilsDir("/Users/thomas/")
        x.SetRunDir("/Users/thomas/")

        # Set generate makefile options
	# Set Generals configuration tests
#        x.EnableMakeClean()
        x.EnableGenerateMakefiles()
        x.DisableBuildExamples()
        x.DisableUseVtk()
        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableGlUseAccel()
     
       
        # List of platform must been tested
        x.Run("macosx-static-debug-itk-internal-fltk-internal")
        x.Run("macosx-shared-release-itk-internal-fltk-internal")



