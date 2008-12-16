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

        if len(sys.argv) != 2:
                print "Error  -->   Usage: ", sys.argv[0], " WEEK/WEEKEND"
                exit(1)

        x=Validation.TestProcessing()

        # Set dirs
        x.SetSourcesDir("/ORFEO/otbval")
        x.DisableUpdateSources()
        x.SetOtbDataLargeInputDir("/home2/data/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetOutilsDir("/ORFEO/otbval")
        x.SetRunDir("/ORFEO/otbval")

        if sys.argv[1] == "WEEKEND":
                x.DisableUseVtk()
                x.DisableTestOTBApplicationsWithInstallOTB()
                x.DisableGlUseAccel()
                x.EnableBuildExamples()
                x.EnableGenerateMakefiles()
        else:
                x.DisableGenerateMakefiles()

	# Run WeekValidation tests
        x.Run("linux-static-debug-itk-internal-fltk-internal")

#        x.DisableBuildExamples()

        # Run specifics Weekend tests
        if sys.argv[1] == "WEEKEND":
                x.Run("linux-static-release-itk-external-fltk-external")
                x.Run("linux-shared-release-itk-internal-fltk-internal")
                x.Run("linux-shared-debug-itk-external-fltk-external")

