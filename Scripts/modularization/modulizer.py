#!/usr/bin/python
#==========================================================================
#
#   Copyright Insight Software Consortium
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#          http://www.apache.org/licenses/LICENSE-2.0.txt
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
#==========================================================================*/
# This script is used to automate the modularization process. The following
# steps  are included:
# 1. Move the files in the monolithic ITK into modules of the modularized ITK.
#    A manifest text file that lists all the files and their destinations is
#    required to run the script.By default, the manifest file is named as
#    "Manifest.txt" in the  same directory of this script.
# 2. Create CMake Files and put them into modules.

# Modified by Guillaume Pasero <guillaume.pasero@c-s.fr>
# add dependencies in otb-module.cmake

# To run it, type ./modulizer.py  OTB_PATH  Manifest_PATH
# from the otb-modulizer root directory.

print "*************************************************************************"
print "WARNINGs! This modularization script is still in its experimental stage."
print "Current OTB users should not run this script."
print "*************************************************************************"


import shutil
import os.path as op
import re
import sys
import os
import stat
import glob
import documentationCheck
import analyseAppManifest
import dispatchTests
import dispatchExamples
from subprocess import call

def parseFullManifest(path):
  sourceList = []
  nbFields = 6
  fd = open(path,'rb')
  # skip first line and detect separator
  firstLine = fd.readline()
  sep = ','
  if (len(firstLine.split(sep)) != nbFields):
    sep = ';'
  if (len(firstLine.split(sep)) != nbFields):
    sep = '\t'
  if (len(firstLine.split(sep)) != nbFields):
    print "Unknown separator"
    return sourceList
  
  fd.seek(0)
  
  # parse file
  for line in fd:
    if (line.strip()).startswith("#"):
      continue
    words = line.split(sep)
    if (len(words) < (nbFields-1)):
      print "Wrong number of fields, skipping this line"
      continue
    fullPath = words[0].strip(" ,;\t\n\r")
    groupName = words[2].strip(" ,;\t\n\r")
    moduleName = words[3].strip(" ,;\t\n\r")
    subDir = words[4].strip(" ,;\t\n\r")
    sourceName = op.basename(fullPath)
    
    sourceList.append({"path":fullPath, "group":groupName, "module":moduleName, "subDir":subDir})
  fd.close()
  
  return sourceList


def parseDescriptions(path):
  output = {}
  sep = '|'
  nbFields = 2
  fd = open(path,'rb')
  for line in fd:
    if (line.strip()).startswith("#"):
      continue
    words = line.split(sep)
    if len(words) != nbFields:
      continue
    moduleName = words[0].strip(" \"\t\n\r")
    description = words[1].strip(" \"\t\n\r")
    output[moduleName] = description
  fd.close()
  
  return output


if len(sys.argv) < 4:
    print("USAGE:  {0}  monolithic_OTB_PATH  OUTPUT_DIR  Manifest_Path  [module_dep [test_dep [mod_description]]]".format(sys.argv[0]))
    print("  monolithic_OTB_PATH : checkout of OTB repository (will not be modified)")
    print("  OUTPUT_DIR          : output directory where OTB_Modular and OTB_remaining will be created ")
    print("  Manifest_Path       : path to manifest file, in CSV-like format. Fields are :")
    print("                          source_path/current_subDir/group/module/subDir/comment")
    print("  module_dep          : dependencies between modules")
    print("  test_dep            : additional dependencies for tests")
    print("  mod_description     : description for each module")
    print("  migration_password  : password to enable MIGRATION")
    sys.exit(-1)

scriptDir = op.dirname(op.abspath(sys.argv[0]))

HeadOfOTBTree = sys.argv[1]
if (HeadOfOTBTree[-1] == '/'):
    HeadOfOTBTree = HeadOfOTBTree[0:-1]

OutputDir = sys.argv[2]
HeadOfModularOTBTree = op.join(OutputDir,"OTB_Modular")

ManifestPath = sys.argv[3]

EdgePath = ""
if len(sys.argv) >= 5:
  EdgePath = sys.argv[4]
  
testDependPath = ""
if len(sys.argv) >= 6:
  testDependPath = sys.argv[5]

modDescriptionPath = ""
if len(sys.argv) >= 7:
  modDescriptionPath = sys.argv[6]

enableMigration = False
if len(sys.argv) >= 8:
  migrationPass = sys.argv[7]
  if migrationPass == "redbutton":
    enableMigration = True

# copy the whole OTB tree over to a temporary dir
HeadOfTempTree = op.join(OutputDir,"OTB_remaining")

if op.isdir(HeadOfTempTree):
    shutil.rmtree(HeadOfTempTree)

if op.isdir(HeadOfModularOTBTree):
    shutil.rmtree(HeadOfModularOTBTree)

print("Start to copy" + HeadOfOTBTree + " to  ./OTB_remaining ...")
shutil.copytree(HeadOfOTBTree,HeadOfTempTree, ignore = shutil.ignore_patterns('.hg','.hg*'))
print("Done copying!")

# checkout OTB-Modular
cmd ='hg clone http://hg.orfeo-toolbox.org/OTB-Modular  '+HeadOfModularOTBTree
os.system(cmd)

logDir = op.join(OutputDir,"logs")
if not op.isdir(logDir):
  os.makedirs(logDir)

# read the manifest file
print ("moving files from ./OTB_remaining into modules in {0}".format(HeadOfModularOTBTree))
numOfMissingFiles = 0;
missingf =  open(op.join(logDir,'missingFiles.log'),'w')
moduleList=[]
moduleDic={}
sourceList = parseFullManifest(ManifestPath)

for source in sourceList:
  # build module list
  moduleDic[source["module"]] = source["group"]
  
  # create the path
  inputfile = op.abspath(op.join(HeadOfTempTree,source["path"]))
  outputPath = op.join(op.join(HeadOfModularOTBTree,"Modules"),op.join(source["group"],op.join(source["module"],source["subDir"])))
  if not op.isdir(outputPath):
    os.makedirs(outputPath)
  
  # copying files to the destination
  if  op.isfile(inputfile):
    if op.isfile(op.join(outputPath,op.basename(inputfile))):
      os.remove(op.join(outputPath,op.basename(inputfile)))
    shutil.move(inputfile, outputPath)
  else:
    missingf.write(inputfile+'\n')
    numOfMissingFiles = numOfMissingFiles + 1

missingf.close()
print ("listed {0} missing files to logs/missingFiles.log").format(numOfMissingFiles)

moduleList = moduleDic.keys()

# after move, operate a documentation check
for source in sourceList:
  outputPath = op.join(op.join(HeadOfModularOTBTree,"Modules"),op.join(source["group"],op.join(source["module"],source["subDir"])))
  outputFile = op.join(outputPath,op.basename(source["path"]))
  if  op.isfile(outputFile):
    if op.splitext(outputFile)[1] == ".h":
      nextContent = documentationCheck.parserHeader(outputFile,source["module"])
      fd = open(outputFile,'wb')
      fd.writelines(nextContent)
      fd.close()


# get dependencies (if file is present)
dependencies = {}
testDependencies = {}
exDependencies = {}
for mod in moduleList:
  dependencies[mod] = []
  testDependencies[mod] = []
  exDependencies[mod] = []

if op.isfile(EdgePath):
  fd = open(EdgePath,'rb')
  for line in fd:
    words = line.split(',')
    if len(words) == 2:
      depFrom = words[0].strip(" ,;\t\n\r")
      depTo = words[1].strip(" ,;\t\n\r")
      if dependencies.has_key(depFrom):
        dependencies[depFrom].append(depTo)
      else:
        print("Bad dependency : "+depFrom+" -> "+depTo)
  fd.close()

if op.isfile(testDependPath):
  fd = open(testDependPath,'rb')
  for line in fd:
    words = line.split(',')
    if len(words) == 2:
      depFrom = words[0].strip(" ,;\t\n\r")
      depTo = words[1].strip(" ,;\t\n\r")
      if testDependencies.has_key(depFrom):
        testDependencies[depFrom].append(depTo)
      else:
        print("Bad dependency : "+depFrom+" -> "+depTo)
  fd.close()

"""
if op.isfile(exDependPath):
  fd = open(exDependPath,'rb')
  for line in fd:
    words = line.split(',')
    if len(words) == 2:
      depFrom = words[0].strip(" ,;\t\n\r")
      depTo = words[1].strip(" ,;\t\n\r")
      if exDependencies.has_key(depFrom):
        exDependencies[depFrom].append(depTo)
      else:
        print("Bad dependency : "+depFrom+" -> "+depTo)
  fd.close()
"""
modDescriptions = {}
if op.isfile(modDescriptionPath):
  modDescriptions = parseDescriptions(modDescriptionPath)



# list the new files
newf =  open(op.join(logDir,'newFiles.log'),'w')
for (root, subDirs, files) in os.walk(HeadOfTempTree):
   for afile in files:
     newf.write(op.join(root, afile)+'\n')
newf.close()
print ("listed new files to logs/newFiles.log")

###########################################################################

print ('creating cmake files for each module (from the template module)')
#moduleList = os.listdir(HeadOfModularOTBTree)
for  moduleName in moduleList:
  moduleDir = op.join(op.join(HeadOfModularOTBTree,"Modules"),op.join(moduleDic[moduleName],moduleName))
  cmakeModName = "OTB"+moduleName
  
  if op.isdir(moduleDir):
    
    # write CMakeLists.txt
    filepath = moduleDir+'/CMakeLists.txt'
    
    if not op.isfile(filepath):
      o = open(filepath,'w')
      
      if op.isdir(moduleDir+'/src'):
        template_cmakelist = op.join(scriptDir,'templateModule/otb-template-module/CMakeLists.txt')
      else:
        template_cmakelist = op.join(scriptDir,'templateModule/otb-template-module/CMakeLists-nosrc.txt')
        
      for line in open(template_cmakelist,'r'):
          line = line.replace('otb-template-module',cmakeModName)
          o.write(line);
      o.close()

    # write src/CMakeLists.txt
    # list of CXX files
    if op.isdir(moduleDir+'/src'):
      cxxFiles = glob.glob(moduleDir+'/src/*.cxx')
      cxxFileList='';
      for cxxf in cxxFiles:
          cxxFileList = cxxFileList+'  '+cxxf.split('/')[-1]+'\n'
      # build list of link dependencies
      linkLibs = ""
      for dep in dependencies[moduleName]:
        #verify if dep is a header-onlymodule
        depThirdParty = False
        try:
          moduleDic[dep]
        except KeyError:
          # this is a ThirdParty module
          depThirdParty = True
 
        if not depThirdParty:
          depModuleDir = op.join(op.join(HeadOfModularOTBTree,"Modules"),op.join(moduleDic[dep],dep))
          depcxx = glob.glob(depModuleDir+'/src/*.cxx')
          if depcxx :
            linkLibs = linkLibs + "  ${OTB"+dep+"_LIBRARIES}" + "\n"
        else:
          linkLibs = linkLibs + "  ${OTB"+dep+"_LIBRARIES}" + "\n"
          
      if len(linkLibs) == 0:
        linkLibs = " ${OTBITK_LIBRARIES}"
      filepath = moduleDir+'/src/CMakeLists.txt'
      if not op.isfile(filepath):
        o = open(filepath,'w')
        for line in open(op.join(scriptDir,'templateModule/otb-template-module/src/CMakeLists.txt'),'r'):
          line = line.replace('otb-template-module',cmakeModName)
          line = line.replace('LIST_OF_CXX_FILES',cxxFileList[0:-1]) #get rid of the last \n
          line = line.replace('LINK_LIBRARIES_TO_BE_REPLACED',linkLibs)
          o.write(line);
        o.close()

    # write app/CMakeLists.txt
    if op.isdir(moduleDir+'/app'):
      os.mkdir(moduleDir+'/test')
      srcFiles = glob.glob(moduleDir+'/app/*.cxx')
      srcFiles += glob.glob(moduleDir+'/app/*.h')
      appList = {}
      
      for srcf in srcFiles:
        # get App name
        appName = analyseAppManifest.findApplicationName(srcf)
        if len(appName) == 0:
          continue
        
        appList[appName] = {"source":op.basename(srcf)}
        
        # get original location
        cmakeListPath = ""
        for item in sourceList:
          if op.basename(item["path"]) == op.basename(srcf) and \
             moduleName == item["module"]:
            appDir = op.basename(op.dirname(item["path"]))
            cmakeListPath = op.join(HeadOfOTBTree,op.join("Testing/Applications"),op.join(appDir,"CMakeLists.txt"))
            break
        
        # get App tests
        if not op.isfile(cmakeListPath):
          continue
        
        appList[appName]["test"] = analyseAppManifest.findTestFromApp(cmakeListPath,appName)
      
      # build list of link dependencies
      linkLibs = ""
      for dep in dependencies[moduleName]:
        linkLibs = linkLibs + "  ${OTB"+dep+"_LIBRARIES}" + "\n"
      
      filepath = moduleDir+'/app/CMakeLists.txt'
      if not op.isfile(filepath):
        o = open(filepath,'w')
        # define link libraries 
        o.write("set("+cmakeModName+"_LINK_LIBS\n")
        o.write(linkLibs)
        o.write(")\n")
        
        for appli in appList:
          content =  "\notb_create_application(\n"
          content += "  NAME           " + appli + "\n"
          content += "  SOURCES        " + appList[appli]["source"] + "\n"
          content += "  LINK_LIBRARIES ${${otb-module}_LIBRARIES})\n"
          o.write(content)
        o.close()
      
      filepath = moduleDir+'/test/CMakeLists.txt'
      if not op.isfile(filepath):
        o = open(filepath,'w')
        o.write("otb_module_test()")
        for appli in appList:
          if not appList[appli].has_key("test"):
            continue
          o.write("\n#----------- "+appli+" TESTS ----------------\n")
          for test in appList[appli]["test"]:
            if test.count("${"):
              print "Warning : test name contains a variable : "+test
              continue
            
            testcode=appList[appli]["test"][test]
            testcode=[s.replace('OTB_TEST_APPLICATION', 'otb_test_application') for s in testcode]
            o.writelines(testcode)
            o.write("\n")
        o.close()

    # write  test/CMakeLists.txt : done by dispatchTests.py
    """
    if op.isdir(moduleDir+'/test'):
      cxxFiles = glob.glob(moduleDir+'/test/*.cxx')
      cxxFileList='';
      for cxxf in cxxFiles:
           cxxFileList = cxxFileList+cxxf.split('/')[-1]+'\n'
      filepath = moduleDir+'/test/CMakeLists.txt'
      if not op.isfile(filepath):
          o = open(filepath,'w')
          for line in open('./templateModule/otb-template-module/test/CMakeLists.txt','r'):
             # TODO : refactor for OTB
             words= moduleName.split('-')
             moduleNameMod='';
             for word in words:
                moduleNameMod=moduleNameMod + word.capitalize()
             line = line.replace('itkTemplateModule',moduleNameMod)
             line = line.replace('itk-template-module',moduleName)
             line = line.replace('LIST_OF_CXX_FILES',cxxFileList[0:-1]) #get rid of the last \n
             o.write(line);
          o.close()
    """
    
    # write otb-module.cmake, which contains dependency info
    filepath = moduleDir+'/otb-module.cmake'
    if not op.isfile(filepath):
      o = open(filepath,'w')
      for line in open(op.join(scriptDir,'templateModule/otb-template-module/otb-module.cmake'),'r'):
        # replace documentation
        if line.find("DESCRIPTION_TO_BE_REPLACED") >= 0:
          docString = "\"TBD\""
          if moduleName in modDescriptions:
            descPos = line.find("DESCRIPTION_TO_BE_REPLACED")
            limitChar = 80
            docString = "\""+modDescriptions[moduleName]+"\""
            curPos = 80 - descPos
            while curPos < len(docString):
              lastSpace = docString[0:curPos].rfind(' ')
              if lastSpace > max(0,curPos-80):
                docString = docString[0:lastSpace] + '\n' + docString[lastSpace+1:]
              else:
                docString = docString[0:curPos] + '\n' + docString[curPos:]
              curPos += 81
          line = line.replace('DESCRIPTION_TO_BE_REPLACED',docString)
        
        # replace module name
        line = line.replace('otb-template-module',cmakeModName)
        # replace depend list
        dependTagPos = line.find("DEPENDS_TO_BE_REPLACED")
        if dependTagPos >= 0:
          replacementStr = "DEPENDS"
          indentStr = ""
          for it in range(dependTagPos+2):
            indentStr = indentStr + " "
          if len(dependencies[moduleName]) > 0:
            deplist = dependencies[moduleName]
          else:
            deplist = ["Common"]
          for dep in deplist:
            replacementStr = replacementStr + "\n" + indentStr +"OTB"+ dep
          line = line.replace('DEPENDS_TO_BE_REPLACED',replacementStr)
        # replace test_depend list
        testDependTagPos = line.find("TESTDEP_TO_BE_REPLACED")
        if testDependTagPos >= 0:
          if moduleName.startswith("App"):
            # for application : hardcode TestKernel and CommandLine
            indentStr = ""
            for it in range(testDependTagPos+2):
                indentStr = indentStr + " "
            replacementStr = "TEST_DEPENDS\n" + indentStr + "OTBTestKernel\n" + indentStr + "OTBCommandLine"
            line = line.replace('TESTDEP_TO_BE_REPLACED',replacementStr)
          else:
            # standard case

            if len(testDependencies[moduleName]) > 0:
              indentStr = ""
              replacementStr = "TEST_DEPENDS"
              for it in range(testDependTagPos+2):
                indentStr = indentStr + " "
              for dep in testDependencies[moduleName]:
                replacementStr = replacementStr + "\n" + indentStr +"OTB"+ dep  
              line = line.replace('TESTDEP_TO_BE_REPLACED',replacementStr)
            else:
              line = line.replace('TESTDEP_TO_BE_REPLACED','')
          
        # replace example_depend list
        exDependTagPos = line.find("EXDEP_TO_BE_REPLACED")
        if exDependTagPos >= 0:
          if len(exDependencies[moduleName]) > 0:
            indentStr = ""
            replacementStr = "EXAMPLE_DEPENDS"
            for it in range(exDependTagPos+2):
              indentStr = indentStr + " "
            for dep in exDependencies[moduleName]:
              replacementStr = replacementStr + "\n" + indentStr +"OTB"+ dep  
            line = line.replace('EXDEP_TO_BE_REPLACED',replacementStr)
          else:
            line = line.replace('EXDEP_TO_BE_REPLACED','')
        o.write(line);
        
      o.close()

# call dispatchTests to fill test/CMakeLists
if op.isfile(testDependPath):
  dispatchTests.main(["dispatchTests.py",ManifestPath,HeadOfOTBTree,HeadOfModularOTBTree,testDependPath])

"""
# call dispatchExamples to fill example/CMakeLists
if op.isfile(exDependPath):
  dispatchExamples.main(["dispatchExamples.py",ManifestPath,HeadOfOTBTree,HeadOfModularOTBTree,exDependPath])
"""

# examples
for i in sorted(os.listdir(HeadOfTempTree + "/Examples")):
  if i == "CMakeLists.txt" or i == "README.txt":
    continue

  for j in sorted(os.listdir(HeadOfTempTree + "/Examples/" + i)):
    if j == "CMakeLists.txt" or j.startswith("otb"):
      continue
    
    command = "cp %s/Examples/%s/%s %s/Examples/%s/%s" % ( HeadOfTempTree, i, j,  HeadOfModularOTBTree, i, j) 
    os.system(command)

for i in sorted(os.listdir(HeadOfTempTree + "/Examples/DataRepresentation")):
  if i == "CMakeLists.txt" or i == "README.txt":
    continue

  for j in sorted(os.listdir(HeadOfTempTree + "/Examples/DataRepresentation/" + i)):
    if j == "CMakeLists.txt" or j.startswith("otb"):
      continue
    
    command = "cp %s/Examples/DataRepresentation/%s/%s %s/Examples/DataRepresentation/%s/%s" % ( HeadOfTempTree, i, j,  HeadOfModularOTBTree, i, j) 
    os.system(command)


# save version without patches (so that we can regenerate patches later)
os.system( "cp -ar " + op.join(OutputDir,"OTB_Modular") + " " + op.join(OutputDir,"OTB_Modular-nopatch") )

# apply patches in OTB_Modular
curdir = op.abspath(op.dirname(__file__))
command =  "cd " + op.join(OutputDir,"OTB_Modular") + " && patch -p1 < " + curdir + "/patches/otbmodular.patch"
print "Executing " + command
os.system( command )

# PREPARE MIGRATION COMMIT ON A CLONE OF ORIGINAL CHECKOUT
if enableMigration:
  print("Executing migration on a clone of original checkout")
  HeadOfTempTree = op.abspath(HeadOfTempTree)
  OutputDir = op.abspath(OutputDir)
  
  # clone original checkout
  outputModular = op.join(OutputDir,"OTB_Modular")
  outputMigration = op.join(OutputDir,"OTB_Migration")
  if op.exists(outputMigration):
    os.removedirs(outputMigration)
  command = ["cp","-ar",HeadOfOTBTree,outputMigration]
  call(command)
  os.chdir(outputMigration)
  
  # walk through OTB_Remaining and delete corresponding files in OTB checkout
  print("DELETE STEP...")
  for dirPath, dirNames, fileNames in os.walk(HeadOfTempTree):
    currentSourceDir = dirPath.replace(HeadOfTempTree,'.')
    for fileName in fileNames:
      if op.exists(op.join(currentSourceDir,fileName)):
        command = ["hg","remove",op.join(currentSourceDir,fileName)]
        call(command)
      else:
        print("Unknown file : "+op.join(currentSourceDir,fileName))
  command = ['hg','commit','-m','RMV: remove files not handled by modularization']
  call(command)
  
  # walk through manifest and rename files
  print("MOVE STEP...")
  for source in sourceList:
    outputPath = op.join("./Modules",op.join(source["group"],op.join(source["module"],source["subDir"])))
    command = ['hg','rename',source["path"],op.join(outputPath,op.basename(source["path"]))]
    call(command)
  command = ['hg','commit','-m','MOV: move source files into modules']
  call(command)
  
  # add new files from OTB_Modular (files from OTB-Modular repo + generated files)
  print("ADD STEP...")
  for dirPath, dirNames, fileNames in os.walk(outputModular):
    currentSourceDir = dirPath.replace(outputModular,'.')
    if currentSourceDir.startswith("./.hg"):
      print("skip .hg")
      continue
    for fileName in fileNames:
      # skip hg files
      if fileName.startswith(".hg"):
        continue
      targetFile = op.join(currentSourceDir,fileName)
      if not op.exists(targetFile):
        if not op.exists(currentSourceDir):
          command = ["mkdir","-p",currentSourceDir]
          call(command)
        shutil.copy(op.join(dirPath,fileName),targetFile)
  command = ['hg','add']
  call(command)
  command = ['hg','commit','-m','ADD: add new files for modular build system']
  call(command)
  
  # apply patches on OTB Checkout
  print("PATCH STEP...")
  for dirPath, dirNames, fileNames in os.walk(outputModular):
    currentSourceDir = dirPath.replace(outputModular,'.')
    if currentSourceDir.startswith("./.hg"):
      continue
    for fileName in fileNames:
      # skip hg files
      if fileName.startswith(".hg"):
        continue
      targetFile = op.join(currentSourceDir,fileName)
      if op.exists(targetFile):
        command = ['cp',op.join(dirPath,fileName),targetFile]
        call(command)
  command = ['hg','commit','-m','ENH: patches and file modifications']
  call(command)


