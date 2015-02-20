#!/usr/bin/python
#coding=utf8

import sys
import string
import os.path as op
import codeParser
import manifestParser
import createTestManifest
import re
from subprocess import call, PIPE


def showHelp():
  print "Script to move a source file from an OTB tree (after modularization)"+\
    ". Allows to move source files from a module to an other and operate the "+\
    "corresponding modifications in the build system."
  print "Usage : moveSource.py  OTB_SRC_DIRECTORY  TARGET_MODULE  SOURCES_FILES"
  print "  OTB_SRC_DIRECTORY : checkout of modular OTB (will be modified)"
  print "  TARGET_MODULE     : destination module"
  print "                      use 'group/module' in case of a new module"
  print "  SOURCES_FILES     : list of source files"

def parseModuleDefinition(path):
  output = {}
  # TODO
  return output


def main(argv):
  otbDir = argv[1]
  
  targetModule = argv[2]
  targetGroup = "TBD"
  if targetModule.count('/') == 1:
    pos = targetModule.find('/')
    targetGroup = targetModule[0:pos]
    targetModule = targetModule[pos+1:]
  if targetModule == "":
    print "Wrong module name, check input argument : "+argv[2]
  if targetGroup == "":
    print "Wrong group name, check input argument : "+argv[2]
  
  srcFiles = argv[3:]
  
  # First, analyse current OTB tree, retrieve :
  #  - module list
  #  - group vs module association
  #  - module dependency graph from otb-module.cmake
  modulesDepBefore = {}
  moduleList = {}
  modulesRoot = op.join(otbDir,"Modules")
  for grpDir in os.listdir(modulesRoot):
    grpPath = op.join(modulesRoot,grpDir)
    if not op.isdir(grpPath):
      continue
    for modDir in os.listdir(grpPath):
      modPath = op.join(grpPath,modDir)
      if not op.isdir(modPath):
        continue
      otbModuleCmake = op.join(modPath,"otb-module.cmake")
      if not op.isfile(otbModuleCmake):
        # not a valid OTB module
        continue
      moduleList[modDir] = grpDir
      # parse module declaration
      
    
  
  
  # Second, operate the move
  # check
  
  # if new module, check that we have a valid group
  
  # Compute new modules dependencies
  # check for cycles in graph
  
  # Fix build system :
  #  - for input files in 'src' : adapt OTBModule_SRC
  #  - fix the target_link_libraries
  #  - fix the otb-module.cmake
  
  
  
  
  


if __name__ == "__main__":
  if len(sys.argv) < 4 :
    showHelp()
  else:
    main(sys.argv)

