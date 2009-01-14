import sys
import os
import platform
import socket
import subprocess

if __name__ == "__main__":
        # Update OTB-DevUtils module
        sys.path.append(os.getcwd()+"/OTB-DevUtils/Scripts")
        try:
                import Validation
        except:
                print 'Impossible to find Validation module (import Validation abort!!)'
                exit(1)
        x=Validation.TestProcessing()
        x.SetSourcesDir("/ORFEO/otbval")
	x.RunUpdateSources()
