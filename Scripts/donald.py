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
        if len(sys.argv) != 2:
                print "Error  -->   Usage: ", sys.argv[0], " WEEK/WEEKEND"
                exit(1)

        x=Validation.TestProcessing()

        # Set dirs
        x.SetOutilsDir("/Users/thomas/")
        x.SetRunDir("/Users/thomas/")
        x.SetOtbDataLargeInputDir("/Users/thomas/OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()
        x.SetSourcesDir("/Users/thomas/")
        x.EnableUpdateSources()

        if sys.argv[1] == "WEEKEND":
        	# Set Generals configuration tests
                x.DisableBuildExamples()
                x.DisableUseVtk()
                x.DisableTestOTBApplicationsWithInstallOTB()
                x.DisableGlUseAccel()
                x.EnableGenerateMakefiles()
        else:
                x.DisableGenerateMakefiles()
     
       
        # List of platform must been tested
        x.Run("macosx-static-debug-itk-internal-fltk-internal")
        if sys.argv[1] == "WEEKEND":
                x.Run("macosx-shared-debug-itk-external-fltk-external")
                x.Run("macosx-shared-release-itk-internal-fltk-internal")



