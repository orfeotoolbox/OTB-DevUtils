import sys
import os
import platform
import socket
import subprocess

if __name__ == "__main__":
        # Update OTB-DevUtils module
        os.chdir("OTB-DevUtils")
        subprocess.call("hg pull", shell=True)
        subprocess.call("hg update default", shell=True)
        print os.getcwd()
        sys.path.append(os.getcwd()+"/Scripts")
        try:
                import Validation
        except:
                print 'Impossible to find Validation module (import Validation abort!!)'
                exit(1)

        os.chdir("..")
        x=Validation.TestProcessing()
        x.SetSourcesDir("/ORFEO/otbval")
	x.RunUpdateSources()
	

