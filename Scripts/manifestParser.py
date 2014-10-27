#!/usr/bin/python
#coding=utf8

import sys
import string
import os.path as op
import codeParser


def showHelp():
  print "Usage : manifestParser.py  MANIFEST_FILE.csv  OTB_SRC_DIRECTORY"


def main(argv):
  csvPath = argv[1]
  otbDir = argv[2]
  
  sourceList = {}
  moduleList = {}
  groups = {}
  nbFields = 6
  fd = open(csvPath,'rb')
  # skip first line
  fd.readline()
  for line in fd:
    words = line.split(',')
    if (len(words) != nbFields):
      print "Wrong number of fields, skipping this line"
      continue
    groupName = words[2].strip(" ,\t\n\r")
    moduleName = words[3].strip(" ,\t\n\r")
    sourceFile = words[0].strip(" ,\t\n\r")
    sourceName = op.basename(sourceFile)
    
    if not groups.has_key(groupName):
      groups[groupName] = []
    groups[groupName].append(moduleName)
    
    if not moduleList.has_key(moduleName):
      moduleList[moduleName] = []
    moduleList[moduleName].append(sourceFile)
    
    sourceList[sourceName] = moduleName
    
  fd.close()
  
  for mod in moduleList.keys():
    print "Module "+mod+" depend on :"
    dependance = {}
    for src in moduleList[mod]:
      srcFullPath = op.join(otbDir,src)
      srcIncludes = codeParser.ParseIncludes(srcFullPath)
      for inc in srcIncludes:
        if inc in sourceList.keys():
          targetModule = sourceList[inc]
          if targetModule != mod:
            # found dependancy outside current module
            if not dependance.has_key(targetModule):
              dependance[targetModule] = []
            dependance[targetModule].append({"from":op.basename(src) , "to":inc})
        else:
          print "Include not found :"+inc
    for dep in dependance.keys():
      print "  -> "+dep
  
  return 0


if __name__ == "__main__":
  if len(sys.argv) < 3 :
    showHelp()
  else:
    main(sys.argv)
