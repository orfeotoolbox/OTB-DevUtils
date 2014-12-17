#!/usr/bin/python
#coding=utf8

import sys
import string
import os.path as op
import codeParser
import manifestParser
import re


def showHelp():
  print "Compute specific dependencies for examples"
  print "Usage : analyseExampleManifest.py  MANIFEST_FILE.csv  MODULE_DEPENDS.csv  OTB_SRC_DIRECTORY  INPUT_EX_MANIFEST  OUT_EX_DEPENDS_CSV"

def main(argv):
  manifestPath = op.expanduser(argv[1])
  moduleDepPath = op.expanduser(argv[2])
  otbDir = op.expanduser(argv[3])
  exManifest = argv[4]
  csvExDepends = argv[5]
  
  # Standard Manifest parsing, extract simple and full dependencies
  [groups,moduleList,sourceList] = manifestParser.parseManifest(manifestPath)
  depList = manifestParser.parseDependList(moduleDepPath)
  fullDepList = manifestParser.buildFullDep(depList)
  
  [exGroups,exModuleList,exSourceList] = manifestParser.parseManifest(exManifest)
  
  exDependsList = manifestParser.buildSimpleDep(otbDir,exModuleList,sourceList)
  
  # clean the dependencies : remove modules already in fullDepList
  cleanDepList = {}
  for mod in exDependsList:
    cleanDepList[mod] = {}
    for dep in exDependsList[mod]:
      if not dep in fullDepList[mod]:
        cleanDepList[mod][dep] = 1
  
  #manifestParser.printDepList(exDependsList)
  
  manifestParser.outputCSVEdgeList(cleanDepList,csvExDepends)
  


if __name__ == "__main__":
  if len(sys.argv) < 6 :
    showHelp()
  else:
    main(sys.argv)
