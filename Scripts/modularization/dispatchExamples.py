#!/usr/bin/python
#coding=utf8

import sys
import string
import os.path as op
import codeParser
import manifestParser
import createTestManifest
import dispatchTests
import re
from subprocess import call, PIPE


def showHelp():
  print "Usage : dispatchExamples.py  EXAMPLE_MANIFEST.csv  OTB_SRC_DIRECTORY  OUTPUT_OTB_DIR  EXAMPLE_DEPENDS.csv"



def main(argv):
  exManifest = op.expanduser(argv[1])
  otbDir = op.expanduser(argv[2])
  outputDir = argv[3]
  exDepends = op.expanduser(argv[4])
  
  example_dir = op.join(otbDir,"Examples")
  
  [groups,moduleList,sourceList] = manifestParser.parseManifest(exManifest)
  
  for mod in moduleList:
    if mod == "" or mod == "TBD":
      continue
    
    currentGrp = manifestParser.getGroup(mod,groups)
    
    # prepare output directory
    targetDir = op.join(op.join(op.join(op.join(outputDir,"Modules"),currentGrp),mod),"example")
    call(["mkdir","-p",targetDir])
    
    testCode = {}
    
    # parse all example files to extract the functions and mains
    for src in moduleList[mod]:
      fullSrcPath = op.join(otbDir,src)
      srcName = op.basename(src)
      
      exeName = "${EXE_TESTS}"
      exeAlias = "${EXE_TESTS1}"
      
      currentCMake = op.join(op.dirname(fullSrcPath),"CMakeLists.txt")
      
      # get add_test() code corresponding to the example
      testFunctionName = op.splitext(srcName)[0]+"Test"
      testCode[srcName] = dispatchTests.findTestFromExe(currentCMake,exeName,exeAlias,[testFunctionName])
      
      # try additional exeName : ${EXE_TESTS2}
      moreCode = dispatchTests.findTestFromExe(currentCMake,"${EXE_TESTS2}","",[testFunctionName])
      for tName in moreCode:
        testCode[srcName][tName] = moreCode[tName]
      
      # copy (move) example sources
      # TODO : this should be done in modulizer for every manifests (src, app, test, examples)
      #command = ["cp",fullSrcPath,op.join(targetDir,srcName)]
      #call(command)
    
    
    # generate the test driver source code
    testDriver = op.join(targetDir,"otb"+mod+"ExamplesTests.cxx")
    fd = open(testDriver,'wb')
    fd.write("#include <iostream>\n")
    fd.write("#include \"otbTestMain.h\"\n")
    fd.write("void RegisterTests()\n")
    fd.write("{\n")
    for src in moduleList[mod]:
      tFunc = op.splitext(op.basename(srcName))[0]+"Test"
      fd.write("  REGISTER_TEST("+tFunc+");\n")
    fd.write("}\n\n")
    for src in moduleList[mod]:
      tFunc = op.splitext(op.basename(srcName))[0]+"Test"
      fd.write("#undef main\n")
      fd.write("#define main "+tFunc+"\n")
      fd.write("#include \""+op.basename(srcName)+"\"\n\n")
    fd.close()
    
    # generate CMakeLists.txt
    testCmakefile = op.join(targetDir,"CMakeLists.txt")
    fd = open(testCmakefile,'wb')
    
    # declare each example executable
    for src in moduleList[mod]:
      srcName = op.basename(src)
      exeName = op.splitext(srcName)[0]
      fd.write("add_executable("+exeName+" "+srcName+")\n")
      fd.write("target_link_libraries("+exeName+\
               " ${OTB"+mod+"_LIBRARIES} ${OTB"+mod+"-Example_LIBRARIES})\n\n")
    
    fd.write("if( BUILD_TESTING )\n")
    
    # TODO : move example baselines according to new dispatch
    fd.write("set(BASELINE ${OTB_DATA_ROOT}/Baseline/Examples/"+mod+")\n")
    
    fd.write("set(INPUTDATA ${OTB_DATA_ROOT}/Examples)\n")
    fd.write("set(TEMP ${OTB_BINARY_DIR}/Testing/Temporary)\n")
    
    fd.write("set(EXE_TESTS ${CXX_TEST_PATH}/otb"+mod+"ExamplesTests)\n")
    
    # declare tests
    fd.write("\n#----------- TESTS DECLARATION ----------------\n")
    for srcName in testCode:
      for tName in testCode[srcName]:
        for line in testCode[srcName][tName]["code"]:
          cleanLine = line.replace(testCode[srcName][tName]["exeName"],"${EXE_TESTS}")
          fd.write(cleanLine)
    
    # declare test driver
    fd.write("add_executable(otb"+mod+"ExamplesTests otb"+mod+"ExamplesTests.cxx)\n")
    fd.write("target_link_libraries(otb"+mod+"ExamplesTests "+\
             "${OTB"+mod+"_LIBRARIES} ${OTB"+mod+"-Example_LIBRARIES} "\
             "${OTBTestKernel_LIBRARIES})\n\n")
    
    fd.write("endif()\n")
    
    fd.close()
  
  return  


if __name__ == "__main__":
  if len(sys.argv) < 5 :
    showHelp()
  else:
    main(sys.argv)
