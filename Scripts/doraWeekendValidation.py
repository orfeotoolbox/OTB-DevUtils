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
        x.DisableUpdateSources()

        x.SetOtbDataLargeInputDir("/home2/data/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()

        x.SetOutilsDir("/ORFEO/otbval")
        x.SetRunDir("/ORFEO/otbval")

        #Set the external tools version
#        x.SetItkVersion("3.6.0")
#        x.SetFltkVersion("1.1.9")
#        x.SetVtkVersion("5.0")

        x.DisableUseVtk()
        x.DisableTestOTBApplicationsWithInstallOTB()
        x.DisableGlUseAccel()
#        x.DisableBuildExamples()

        x.EnableGenerateMakefiles()

	# Run WeekValidation tests
	x.Run("linux-static-debug-itk-internal-fltk-internal")

#        x.DisableBuildExamples()

        # Run specifics Weekend tests
	x.Run("linux-static-release-itk-external-fltk-external")
	x.Run("linux-shared-release-itk-internal-fltk-internal")
	x.Run("linux-shared-debug-itk-external-fltk-external")

