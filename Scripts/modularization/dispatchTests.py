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
  print "Usage : dispatchTests.py  MANIFEST.csv  OTB_SRC_DIRECTORY  OUTPUT_OTB_DIR  TEST_DEPENDS.csv"


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
    #if cleanLine.startswith("#"):
    #  continue
    
    idx=cleanLine.find('#')
    if idx != -1:
      cleanLine=cleanLine[0:idx]
    
    if not cleanLine:
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

def findTestProperties(cmakefile,testList):
  output = {}
  isInSetProp = False
  lineBuffer = ""
  lineList = []
  
  fd = open(cmakefile,'rb')
  for line in fd:
    cleanLine = (line.replace("\t"," ")).strip(" \n\r")
    
    # skip commented line
    idx=cleanLine.find('#')
    if idx != -1:
      cleanLine=cleanLine[0:idx]
    
    if not cleanLine:
      continue
    
    # collapse multi-spaces
    sizeChanged = True
    while (sizeChanged):
      sizeBefore = len(cleanLine)
      cleanLine = cleanLine.replace('  ',' ')
      sizeAfter = len(cleanLine)
      if (sizeBefore == sizeAfter):
        sizeChanged = False
    
    if cleanLine.startswith("set_tests_properties("):
      isInSetProp = True
    
    if isInSetProp:
      lineBuffer = lineBuffer + cleanLine + " "
      lineList.append(line)
    
    if cleanLine.endswith(')'):
      # parse buffer
      if isInSetProp:
        words = (lineBuffer[21:-2]).split(' ')
        testName = words[0]
        if (testName in testList) and len(words) == 4:
          if not testName in output:
            output[testName] = []
          output[testName].append("set_property(TEST "+testName+"\n")
          output[testName].append("  PROPERTY "+words[2]+" "+words[3]+")\n")
        isInSetProp = False
        lineBuffer = ""
        lineList = []
  
  fd.close()
  return output


def main(argv):
  manifest = op.expanduser(argv[1])
  otbDir = op.expanduser(argv[2])
  outputDir = argv[3]
  testDepends = op.expanduser(argv[4])
  
  testing_dir = op.join(otbDir,"Testing")
  
  [groups,moduleList,sourceList] = manifestParser.parseManifest(manifest)
  
  for mod in moduleList:
    if mod == "" or mod == "TBD":
      continue
    
    # remove non-testing source files
    for src in moduleList[mod]:
      cleanSrc = src.strip("./")
      if not cleanSrc.startswith("Testing/"):
        moduleList[mod].remove(src)
    if len(moduleList[mod]) == 0:
      continue
    
    currentGrp = ""
    for grp in groups:
      if mod in groups[grp]:
        currentGrp = grp
        break
    
    testMains = {}
    testFunctions = {}
    testCode = {}
    testProp = {}
    
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
        
      # get set_test_properties()
      testProp[srcName] = findTestProperties(currentCMake,testCode[srcName].keys())
    
    if len(testCode) == 0:
      continue
    
    targetDir = op.join(op.join(op.join(op.join(outputDir,"Modules"),currentGrp),mod),"test")
    if op.exists(op.join(targetDir,"CMakeLists.txt")):
      continue
    
    # prepare output directory
    call(["mkdir","-p",targetDir])
    
    if len(testFunctions)>0:
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
    
    fd.write("otb_module_test()\n\n")
    
    if len(testFunctions)>0:
      #  - declare source files for test driver
      fd.write("set(OTB"+mod+"Tests\n")
      fd.write("otb"+mod+"TestDriver.cxx\n")
      for srcName in testFunctions:
        fd.write(srcName+"\n")
      fd.write(")\n\n")
    
      #  - add test driver executable
      testdriverdecl =  """\
add_executable(otb%sTestDriver ${OTB%sTests})
target_link_libraries(otb%sTestDriver ${OTB%s-Test_LIBRARIES})
otb_module_target_label(otb%sTestDriver)
""" % (mod, mod, mod, mod, mod)
      fd.write(testdriverdecl);
      
      #  - add other executables
      for srcName in testMains:
        testdriverdecl =  """\
add_executable(%s %s)
target_link_libraries(%s ${OTB%s-Test_LIBRARIES})
otb_module_target_label(otb%sTestDriver)
""" % (testMains[srcName], srcName, testMains[srcName], testMains[srcName], mod)

    fd.write("\n# Tests Declaration\n\n")
    
    # add tests
    for srcName in testCode:
      for tName in testCode[srcName]:
        
        skip=False
        if tName.count("${"):
          print "Warning : test name contains a variable : "+tName
          skip=True

        if skip:
          continue

        tCmakeCode = []
        if srcName in testFunctions:
          exeNameReplaced = False
          for i, line in zip(range(len(testCode[srcName][tName]["code"])), testCode[srcName][tName]["code"]):
            line=line.strip(' \t')
            if i == 0:
              if "NAME" not in line:
                line=line.replace(" ", " COMMAND ", 1)
                line=line.replace("add_test(", "otb_add_test(NAME ")
              else:
                line=line.replace("add_test(", "otb_add_test(")

            # replace large input references
            if line.find('${OTB_DATA_LARGEINPUT_ROOT}') != -1:
              start = line.find('${OTB_DATA_LARGEINPUT_ROOT}')
              end1 = line.find(' ', start)
              end2 = line.find(')', start)
              if end1 == -1:
                end1=end2
              if end2 == -1:
                end2=end1
              end = min(end1,end2)
              before = line[:start]
              after = line[end:]
              largepath = line[start + len('${OTB_DATA_LARGEINPUT_ROOT}/'):end]
              line = before + "LARGEINPUT{" + largepath + "}" + after

            if exeNameReplaced:
              tCmakeCode.append(line)
            else:
              tCmakeCode.append(line.replace(testCode[srcName][tName]["exeName"],"otb"+mod+"TestDriver",1))

            if line.find(testCode[srcName][tName]["exeName"]) >= 0:
              exeNameReplaced = True
        else:
          tCmakeCode = testCode[srcName][tName]["code"]

        tCmakeCodeFinal = []
        # indent
        for i, line in zip(range(len(tCmakeCode)), tCmakeCode):
          outputline = line
          if i != 0:
            outputline = '%s%s' % ('  ', outputline)
          tCmakeCodeFinal.append(outputline)
        
        # add set_property if any
        if testProp[srcName].has_key(tName):
          tCmakeCodeFinal += testProp[srcName][tName]

        fd.writelines(tCmakeCodeFinal)
        fd.write("\n")

    fd.close()
  
  return  


if __name__ == "__main__":
  if len(sys.argv) < 5 :
    showHelp()
  else:
    main(sys.argv)
