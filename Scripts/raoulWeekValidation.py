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
        x.SetOtbDataLargeInputDir("E:\\OTB-Data-LargeInput")
        x.EnableUseOtbDataLargeInput()

        x.SetSourcesDir("E:\\")
        x.EnableUpdateSources()

        x.SetOutilsDir("E:\\")
        x.SetRunDir("E:\\")
        
        x.DisableGenerateMakefiles()
        
        # List of platform must been tested
	x.Run("visual8-static-debug-itk-external-fltk-external")

