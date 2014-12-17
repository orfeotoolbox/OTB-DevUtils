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


def getTestFunctionFromCode(code):
  # start at 1 (0 is exeName)
  currentPos = 1
  while (code[currentPos].startswith('--')):
    if code[currentPos] in ["--without-threads","--ignore-order"]:
      currentPos = currentPos + 1
    elif code[currentPos] in ["--with-threads","--epsilon-boundary"]:
      currentPos = currentPos + 2
    elif code[currentPos] in ["--compare-binary"]:
      currentPos = currentPos + 3
    elif code[currentPos] in ["--compare-n-images","--compare-n-ascii"]:
      nbComp = int(code[currentPos+2])
      currentPos = currentPos + 3 + 2 * nbComp
    elif code[currentPos] in ["--compare-n-binary"]:
      nbComp = int(code[currentPos+1])
      currentPos = currentPos + 2 + 2 * nbComp
    elif code[currentPos] in ["--ignore-lines-with"]:
      nbComp = int(code[currentPos+1])
      currentPos = currentPos + 2 + nbComp
    else:
      currentPos = currentPos + 4
  
  return code[currentPos]

def findTestFromExe(cmakefile,exeName,exeAlias,functionNames=[]):
  output = {}
  isInAddTest = False
  lineBuffer = ""
  lineList = []
  exePattern = [exeName]
  if exeAlias != "":
    exePattern.append(exeAlias)
  
  addTestSearch = r'^add_test\( *([^ ]+) +([^ ]+) +(.+) *\) *'
  reAddTest = re.compile(addTestSearch)
  
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
    
    if cleanLine.startswith("add_test("):
      isInAddTest = True
    
    if isInAddTest:
      lineBuffer = lineBuffer + cleanLine + " "
      lineList.append(line)
    
    if cleanLine.endswith(')'):
      # parse buffer
      if isInAddTest:
        match = reAddTest.match(lineBuffer)
        if (match != None) and (len(match.groups()) == 3):
          if match.group(1) == "NAME":
            testName = match.group(2)
            words = (match.group(3)).split(' ')
            cmdPos = words.index("COMMAND")
            testCmd = words[cmdPos+1:]
          else:
            testName = match.group(1)
            words = (match.group(3)).split(' ')
            testCmd = [match.group(2)] + words
          if testCmd[0] in exePattern:
            if len(functionNames):
              funcName = getTestFunctionFromCode(testCmd)
              if funcName in functionNames:
                output[testName] = {"code":lineList, "exeName":testCmd[0],"funcName":funcName}
            else:
              output[testName] = {"code":lineList, "exeName":testCmd[0]}
        isInAddTest = False
        lineBuffer = ""
        lineList = []
  
  fd.close()
  return output


def main(argv):
  testManifest = op.expanduser(argv[1])
  otbDir = op.expanduser(argv[2])
  outputDir = argv[3]
  testDepends = op.expanduser(argv[4])
  
  testing_dir = op.join(otbDir,"Testing")
  
  [groups,moduleList,sourceList] = manifestParser.parseManifest(testManifest)
  
  for mod in moduleList:
    if mod == "" or mod == "TBD":
      continue
    
    currentGrp = ""
    for grp in groups:
      if mod in groups[grp]:
        currentGrp = grp
        break
    
    # prepare output directory
    targetDir = op.join(op.join(op.join(op.join(outputDir,"Modules"),currentGrp),mod),"test")
    call(["mkdir","-p",targetDir])
    
    testMains = {}
    testFunctions = {}
    testCode = {}
    
    # parse all test files to extract the functions and mains
    for src in moduleList[mod]:
      fullSrcPath = op.join(otbDir,src)
      srcName = op.basename(src)
      res = createTestManifest.parseTestCxx(fullSrcPath)
      
      currentCMake = op.join(op.dirname(fullSrcPath),"CMakeLists.txt")
      
      exeName = extractExeName(currentCMake,op.basename(src))
      if exeName is "":
        # this source file is not used -> nothing to do
        # (or maybe not here ...)
        continue
      
      exeAlias = checkForAlias(currentCMake,exeName)
      
      # get add_test() code calling "src"
      if res["hasMain"]:
        testMains[srcName] = exeName
        testCode[srcName] = findTestFromExe(currentCMake,exeName,exeAlias)
      else:
        testFunctions[srcName] = res["testFunctions"]
        testCode[srcName] = findTestFromExe(currentCMake,exeName,exeAlias,res["testFunctions"])
    
      # copy (move) test sources
      # TODO : should be done by modulizer.py
      #command = ["cp",fullSrcPath,op.join(targetDir,srcName)]
      #call(command)
    
    
    # generate the test driver source code
    testDriver = op.join(targetDir,"otb"+mod+"TestDriver.cxx")
    fd = open(testDriver,'wb')
    fd.write("#include \"otbTestMain.h\"\n")
    fd.write("void RegisterTests()\n")
    fd.write("{\n")
    for srcName in testFunctions:
      for tFunc in testFunctions[srcName]:
        fd.write("  REGISTER_TEST("+tFunc+");\n")
    fd.write("}\n")
    fd.close()
    
    # generate CMakeLists.txt
    testCmakefile = op.join(targetDir,"CMakeLists.txt")
    fd = open(testCmakefile,'wb')
    
    fd.write("otb_module_test()\n")
    
    #  - declare source files for test driver
    fd.write("set(OTB"+mod+"Tests\n")
    fd.write("otb"+mod+"TestDriver.cxx")
    for srcName in testFunctions:
      fd.write(srcName+"\n")
    fd.write(")\n\n")
    
    #  - add test driver executable
    fd.write("OTB_ADD_EXECUTABLE(otb"+mod+"TestDriver \"${OTB"+mod+"Tests}\" "\
             "\"${OTB"+mod+"-Test_LIBRARIES};${OTBTestKernel_LIBRARIES}\")\n")
    
    #  - add other executables
    for srcName in testMains:
      fd.write("OTB_ADD_EXECUTABLE("+testMains[srcName]+" "+srcName+" \"${OTB"+mod+"-Test_LIBRARIES}\"\n")
    
    fd.write("\n#----------- TESTS DECLARATION ----------------\n")
    
    # add tests
    for srcName in testCode:
      for tName in testCode[srcName]:
        if tName.count("${"):
          print "Warning : test name contains a variable : "+tName
          continue
        
        tCmakeCode = []
        if srcName in testFunctions:
          exeNameReplaced = False
          for line in testCode[srcName][tName]["code"]:
            if exeNameReplaced:
              tCmakeCode.append(line)
            else:
              tCmakeCode.append(line.replace(testCode[srcName][tName]["exeName"],"otb"+mod+"TestDriver",1))
            if line.find(testCode[srcName][tName]["exeName"]) >= 0:
              exeNameReplaced = True  
        else:
          tCmakeCode = testCode[srcName][tName]["code"]
        fd.writelines(tCmakeCode)
        fd.write("\n")
        
    
    fd.close()
  
  return  


if __name__ == "__main__":
  if len(sys.argv) < 5 :
    showHelp()
  else:
    main(sys.argv)
