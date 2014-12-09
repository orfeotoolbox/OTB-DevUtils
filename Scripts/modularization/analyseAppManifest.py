#!/usr/bin/python
#coding=utf8

import sys
import string
import os.path as op
import codeParser
import manifestParser
import re


def showHelp():
  print "Usage : analyseAppManifest.py  MANIFEST_FILE.csv  MODULE_DEPENDS.csv  OTB_SRC_DIRECTORY  INPUT_APP_MANIFEST  OUT_APP_DEPENDS_CSV"

def main(argv):
  manifestPath = op.expanduser(argv[1])
  moduleDepPath = op.expanduser(argv[2])
  otbDir = op.expanduser(argv[3])
  appManifest = argv[4]
  csvAppDepends = argv[5]
  
  #app_dir = op.join(otbDir,"Applications")
  
  # Standard Manifest parsing, extract simple and full dependencies
  [groups,moduleList,sourceList] = manifestParser.parseManifest(manifestPath)
  depList = manifestParser.parseDependList(moduleDepPath)
  fullDepList = manifestParser.buildFullDep(depList)
  
  [appGroups,appModuleList,appSourceList] = manifestParser.parseManifest(appManifest)
  
  # add application sources to sourceList
  for item in appSourceList:
    sourceList[item] = appSourceList[item]
  
  appDependsList = manifestParser.buildSimpleDep(otbDir,appModuleList,sourceList)
  
  #manifestParser.printDepList(appDependsList)
  
  manifestParser.outputCSVEdgeList(appDependsList,csvAppDepends)
  


if __name__ == "__main__":
  if len(sys.argv) < 6 :
    showHelp()
  else:
    main(sys.argv)
