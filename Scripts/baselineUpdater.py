#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, os
import os.path as op
from getopt import getopt

from subprocess import call, Popen, PIPE

def showHelp():
  print "Script to update a baseline with a file generated during ctest execution"
  print "Limitations : only handles images for now"
  print "Usage: baselineUpdater.py [OPTIONS] -p BUILD_PATH"
  print "Options:"
  print "\t-p (--path) DIRECTORY      : OTB build directory where the new baselines are located"
  print "\t-t (--test) TEST_NAME      : test name to select the one test to update"
  print "\t-R (--regex) REGEX_EXPR    : regex expression to select the tests to update"
  print "\t-l (--list) TEST_LIST      : path to a file containing all the tests to update"
  print "\t-h (--help)                : print help"

def parseLine(line):
  words = line.split()
  baselines = []
  testFiles = []
  index = 0
  while index in range(len(words)):
    cleanWord = words[index].strip("\"\'\t\r ")
    if cleanWord in ["--compare-image","--compare-ogr","--compare-ascii","--compare-metadata"]:
      cleanBaseline = words[index+2].strip("\"\'\t\r ")
      cleanTestFile = words[index+3].strip("\"\'\t\r ")
      [currentBaselines, currentTestFiles] = expandFiles(cleanBaseline,cleanTestFile)
      baselines += currentBaselines
      testFiles += currentTestFiles
      index +=3
    if cleanWord in ["--compare-n-images","--compare-n-ascii"]:
      nbImages = int(words[index+2].strip("\"\'\t\r "))
      for k in range(nbImages):
        cleanBaseline = words[index+3+2*k].strip("\"\'\t\r ")
        cleanTestFile = words[index+4+2*k].strip("\"\'\t\r ")
        [currentBaselines, currentTestFiles] = expandFiles(cleanBaseline,cleanTestFile)
        baselines += currentBaselines
        testFiles += currentTestFiles
      index += (2 + 2*nbImages)
    # TODO --compare-binary
    # TODO --compare-n-binary
    
    index +=1
  return [baselines, testFiles]

def expandFiles(cleanBaseline,cleanTestFile):
  currentBaselines = []
  currentTestFiles = []
  
  if op.exists(cleanBaseline):
    currentBaselines.append(cleanBaseline)
  else:
    print "\tBaseline file not found : "+cleanBaseline
    currentBaselines.append("")
  
  if op.exists(cleanTestFile):
    currentTestFiles.append(cleanTestFile)
  else:
    print "\tTest file not found : "+cleanTestFile
    currentTestFiles.append("")
  
  [bBase, bExt] = op.splitext(cleanBaseline)
  [tBase, tExt] = op.splitext(cleanTestFile)
  
  # detect Multi-baseline
  multiBaseline = bBase+".1"+bExt
  if op.exists(multiBaseline):
    print "\tMulti-baseline detected !"
  
  # Raw format file
  if (bExt.lower() == ".hdr") and (tExt.lower() == ".hdr"):
    currentBaselines.append(bBase)
    currentTestFiles.append(tBase)
  
  # ESRI shapefile
  if (bExt.lower() == ".shp") and (tExt.lower() == ".shp"):
    currentBaselines.append(op.join(bBase,".shx"))
    currentTestFiles.append(op.join(tBase,".shx"))
    currentBaselines.append(op.join(bBase,".dbf"))
    currentTestFiles.append(op.join(tBase,".dbf"))
    # test if prj files are used
    bPRJ = op.join(bBase,".prj")
    tPRJ = op.join(tBase,".prj")
    if op.exists(bPRJ) and op.exists(tPRJ):
      currentBaselines.append(bPRJ)
      currentTestFiles.append(tPRJ)
  
  # test geom metadata file
  bGEOM = op.join(bBase,".geom")
  tGEOM = op.join(tBase,".geom")
  if op.exists(bGEOM) and op.exists(tGEOM):
    currentBaselines.append(bGEOM)
    currentTestFiles.append(tGEOM)
  
  # test aux.xml metadata file
  bAUX = op.join(cleanBaseline,".aux.xml")
  tAUX = op.join(cleanTestFile,".aux.xml")
  if op.exists(bAUX) and op.exists(tAUX):
    currentBaselines.append(bAUX)
    currentTestFiles.append(tAUX)
  
  return [currentBaselines, currentTestFiles]


def copyFiles(baselines, testFiles):
  if len(baselines) != len(testFiles):
    print "ERROR : Number of baseline files different from number of "\
          "test files ! ("+str(len(baselines))+" vs "+str(len(testFiles))+")"
    return False
  
  for index in range(len(baselines)):
    if (baselines[index] == "") or (testFiles[index] == ""):
      return False
    command = ["cp"]
    command.append(testFiles[index])
    command.append(baselines[index])
    call(command)
  return True  
  

def processQuery(cleanTestName,isRegex=False):
  command = ["ctest","-R","^"+cleanTestName+"$","-V","-N"]
  if isRegex:
    command[2] = cleanTestName
  
  ctest = Popen(command,stdout=PIPE)
  result = ctest.communicate()[0]
  
  testFound = result.split('\n')
  
  count = 0
  for index in range(len(testFound)):
    if testFound[index].find("Test command:") >= 0:
      count += 1
      # print test name 
      if isRegex:
        nextLine = testFound[index+1].split()
        name = nextLine[-1].strip("\"\'\t\n\r ")
        print "Updating : "+name
      else:
        print "Updating : "+cleanTestName
      [baselines, testFiles] = parseLine(testFound[index])
      res = copyFiles(baselines,testFiles)
  
  return count 

def main(argv):
  if len(argv) < 2 :
    showHelp()
    return 1
  
  buildPath = ""
  testName = ""
  regexCTest = ""
  testListPath = ""
  
  opts, rest = getopt(argv[1:], "p:t:R:l:h",["path=","test=", "regex=","list=", "help"])
  for o, a in opts:
    if o in ["-h", "--help"]:
      showHelp()
      return 0
    if o in ["-p", "--path"]: buildPath = a.decode('utf-8')
    if o in ["-t", "--test"]: testName = a
    if o in ["-R", "--regex"]: regexCTest = a
    if o in ["-l", "--list"]: testListPath = a.decode('utf-8')
  
  if buildPath == "":
    print "No build directory given"
    showHelp()
    return 1
  
  if (testName == "") and (regexCTest == "") and (testListPath == ""):
    print "No test specified"
    showHelp()
    return 1
  
  print "WARNING : be sure to only update baselines with the normal expected test results"
  
  content = []
  
  if testName != "":
    content = [testName]
  elif testListPath != "":
    testListFile = open(testListPath,'rb')
    content = testListFile.readlines()
    testListFile.close()
  
  # change current directory to build directory
  os.chdir(buildPath);
  
  if len(content) > 0:
    for name in content:
      cleanName = name.strip("\"\'\t\n\r ")
      nbTest = processQuery(cleanName)
      if nbTest == 0:
        print "Not found:\t"+cleanName 
  elif regexCTest != "":
    nbTest = processQuery(regexCTest,True)
    if nbTest == 0:
      print "Not found:\t"+regexCTest 
  
  return 0

if __name__ == "__main__":
  main(sys.argv)
