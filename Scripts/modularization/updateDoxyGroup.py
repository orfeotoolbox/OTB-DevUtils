#!/usr/bin/python
#coding=utf8

import sys
import string
import os
import os.path as op
import codeParser
import manifestParser
import createTestManifest
import documentationCheck
import shutil
from subprocess import call, PIPE
import dispatchTests


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    OKRED = '\033[91m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

import sourceAPI

def showHelp():
  print "This script will check and update group declaration in doxygen tags."
  print "Usage : updateDoxyGroup.py  OTB_SRC_DIRECTORY"
  print "  OTB_SRC_DIRECTORY : checkout of OTB (will be modified)"


#----------------- MAIN ---------------------------------------------------
def update(otbDir):
    modulesRoot = op.join(otbDir,"Modules")

    [groups,moduleList,sourceList,testList] = sourceAPI.parseModuleRoot(modulesRoot)
  
    for (m,files) in moduleList.iteritems():
        for f in files:
            if f.endswith(".h"):
                content = documentationCheck.parserHeader(op.join(otbDir,f),m)
                fd = open(op.join(otbDir,f),'wb')
                fd.writelines(content)
                fd.close()

def main(argv):
    
    otbDir = op.abspath(argv[1])

    update(otbDir)
                        

if __name__ == "__main__":
  if len(sys.argv) < 1 :
    showHelp()
  else:
    main(sys.argv)

