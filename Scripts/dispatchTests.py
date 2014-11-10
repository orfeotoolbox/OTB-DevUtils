#!/usr/bin/python
#coding=utf8

import sys
import string
import os.path as op
import codeParser
import manifestParser
import createTestManifest
import re


def showHelp():
  print "Usage : dispatchTests.py  TEST_MANIFEST.csv  OTB_SRC_DIRECTORY  OUTPUT_OTB_DIR  TEST_DEPENDS.csv"


def parseTestDepends(path):
  testDepends = {}
  fd = open(path,'rb')
  for line in fd:
    words = line.split(',')
    if len(words) == 2:
      depFrom = words[0].strip(" ,;\t\n\r")
      depTo = words[1].strip(" ,;\t\n\r")
      if not testDepends.has_key(depFrom):
        testDepends[depFrom] = []
      testDepends[depFrom].append(depTo)
  fd.close()


def extractExeName(path,srcFile):
  outputName = ""
  isInAddExe = False
  isInOTBAddExe = False
  isInSet = False
  srcTarget = srcFile
  lineBuffer = ""
  
  addExeSearch = r'^add_executable *\( *([^ ]+) +([^ ]+) *([^ ]+)? *\) *'
  otbAddExeSearch= r'^OTB_ADD_EXECUTABLE *\( *([^ ]+) +"([^ ]+)" +"([^ ]+)" *\) *'
  setSearch = r'^set *\( *([^ ]+) +(.+) *\) *'
  
  reAddExe = re.compile(addExeSearch)
  reOTBAddExe = re.compile(otbAddExeSearch)
  reSet = re.compile(setSearch)
  
  fd = open(path,'rb')
  for line in fd:
    cleanLine = (line.replace("\t"," ")).strip(" \n\r")
    
    # skip commented line
    if cleanLine.startswith("#"):
      continue
    
    if cleanLine.startswith("add_executable") and cleanLine.count('(') == 1:
      isInAddExe = True
    
    if cleanLine.startswith("OTB_ADD_EXECUTABLE") and cleanLine.count('(') == 1:
      isInOTBAddExe = True
    
    if cleanLine.startswith("set(") or cleanLine.startswith("set ("):
      if (not isInAddExe) and (not isInOTBAddExe):
        isInSet = True  
    
    if isInAddExe or isInOTBAddExe or isInSet:
      lineBuffer = lineBuffer + cleanLine + " "
    
    if cleanLine.endswith(')'):
      # parse buffer
      if isInAddExe:
        curMatch = reAddExe.match(lineBuffer)
        
        if (curMatch != None) and (len(curMatch.groups()) >= 2):
          exeMatch = curMatch.group(1)
          for srcMatch in curMatch.groups()[1:]:
            if not srcMatch is None:
              if srcMatch.strip(' ') == srcTarget:
                outputName = exeMatch
        isInAddExe = False
        lineBuffer = ""
      
      if isInOTBAddExe:
        match = reOTBAddExe.match(lineBuffer)
        if (match != None) and (len(match.groups()) == 3):
          exeMatch = match.group(1)
          srcMatch = match.group(2)
          if srcMatch == srcTarget:
            outputName = exeMatch
        isInOTBAddExe = False
        lineBuffer = ""
      
      if isInSet:
        match = reSet.match(lineBuffer)
        if (match != None) and (len(match.groups()) == 2):
          varName = match.group(1)
          values = (match.group(2)).split(' ')
          if srcFile in values:
            srcTarget = "${"+varName+"}"
              
        isInSet = False
        lineBuffer = ""
        
    if outputName != "":
      break
   
  fd.close()
  return outputName
  

def checkForAlias(path,exeName):
  outputName = ""
  isInSet = False
  lineBuffer = ""
  
  setSearch = r'^set *\( *([^ ]+) +([^ ]+) *\) *'
  
  reSet = re.compile(setSearch)
  
  fd = open(path,'rb')
  for line in fd:
    cleanLine = (line.replace("\t"," ")).strip(" \n\r")
    
    # skip commented line
    if cleanLine.startswith("#"):
      continue
    
    if cleanLine.startswith("set(") or cleanLine.startswith("set ("):
      isInSet = True  
    
    if isInSet:
      lineBuffer = lineBuffer + cleanLine + " "
    
    if cleanLine.endswith(')'):
      # parse buffer
      if isInSet:
        match = reSet.match(lineBuffer)
        if (match != None) and (len(match.groups()) == 2):
          varName = match.group(1)
          value = match.group(2)
          if value.endswith(exeName):
            outputName = "${"+varName+"}"  
        isInSet = False
        lineBuffer = ""
        
    if outputName != "":
      break
  
  fd.close()
  return outputName


def main(argv):
  testManifest = op.expanduser(argv[1])
  otbDir = op.expanduser(argv[2])
  outputDir = argv[3]
  testDepends = op.expanduser(argv[4])
  
  testing_dir = op.join(otbDir,"Testing")
  
  [groups,moduleList,sourceList] = manifestParser.parseManifest(testManifest)
  
  for mod in moduleList:
    testMains = []
    testFunctions = {}
    
    # parse all test files to extract the functions and mains
    for src in moduleList[mod]:
      fullSrcPath = op.join(otbDir,src)
      res = createTestManifest.parseTestCxx(fullSrcPath)
      
      currentCMake = op.join(op.dirname(fullSrcPath),"CMakeLists.txt")
      
      exeName = extractExeName(currentCMake,op.basename(src))
      if exeName is "":
        # this source file is not used -> nothing to do
        # (or maybe not here ...)
        continue
      
      exeAlias = checkForAlias(currentCMake,exeName)
      
      print src + " -> "+exeName+" ("+exeAlias+")"
      
      # get add_test() code using "src"
      if res["hasMain"]:
        testMains.append(src)
      else:
        testFunctions[src] = res["testFunctions"]
      
      
  
  
  
  
  # TODO
  
  return  
  
  
  # Get test list ( except application tests)
  testing_dir = op.join(otbDir,"Testing")
  test_count = 0
  tests_map = {}
  for (d,f) in codeParser.Find(testing_dir,"CMakeLists.txt"):
    tests = codeParser.ParseAddTests(op.join(d,f))
    test_count = test_count + len(tests)
    
    for (testName,testCode) in tests:
      # for each testName, extract its corresponding "test_function_name" as called in add_test()
      #testFunctionName = extractTestFunctionName(testCode)
      #print testName + "\t\t->" + testFunctionName
      pass
      
      # store each test name with usefull informations


if __name__ == "__main__":
  if len(sys.argv) < 5 :
    showHelp()
  else:
    main(sys.argv)
