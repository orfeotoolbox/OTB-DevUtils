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

def findApplicationName(path):
  search_string=r'^class +([A-Za-z0-9]+) *: *public Application'
  appRe=re.compile(search_string)
  
  for line in open(path,'rb'):
    cleanLine = line.strip(' \n\r\t')
    gg = appRe.match(cleanLine)
    if (gg != None) and (len(gg.groups()) == 1):
      return gg.group(1)
  return "" 

def findTestFromApp(cmakefile,appName):
  output = {}
  isInAddTest = False
  lineBuffer = ""
  lineList = []
  
  fd = open(cmakefile,'rb')
  for line in fd:
    cleanLine = (line.replace("\t"," ")).strip(" \n\r")
    
    # skip commented line
    if cleanLine.startswith("#"):
      continue
    
    # collapse multi-spaces
    sizeChanged = True
    while (sizeChanged):
      sizeBefore = len(cleanLine)
      cleanLine = cleanLine.replace('  ',' ')
      sizeAfter = len(cleanLine)
      if (sizeBefore == sizeAfter):
        sizeChanged = False
    
    if cleanLine.startswith("OTB_TEST_APPLICATION("):
      isInAddTest = True
    
    if isInAddTest:
      lineBuffer = lineBuffer + cleanLine + " "
      lineList.append(line)
    
    if cleanLine.endswith(')'):
      # parse buffer
      if isInAddTest:
        match = (lineBuffer[21:-2]).split(' ')
        currentApp = ""
        currentTest = ""
        
        if "APP" in match:
          appPos = match.index("APP")
          currentApp = match[appPos+1]
        
        if "NAME" in match:
          namePos = match.index("NAME")
          currentTest = match[namePos+1]
        
        if currentApp == appName:
          output[currentTest] = lineList
        
        isInAddTest = False
        lineBuffer = ""
        lineList = []
  
  fd.close()
  return output

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
