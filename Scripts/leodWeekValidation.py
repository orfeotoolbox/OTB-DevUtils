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
        x.SetOtbDataLargeInputDir("/Users/cyrille/ORFEO-TOOLBOX/LargeInput")
        x.EnableUseOtbDataLargeInput()

        x.SetSourcesDir("/Users/cyrille/ORFEO-TOOLBOX/OTB")
        x.EnableUpdateSources()

        x.SetOutilsDir("/Users/otbval")
        x.SetRunDir("/Users/otbval")

        # List of platform must been tested
        x.Run("macosx-static-release-itk-external-fltk-internal")



