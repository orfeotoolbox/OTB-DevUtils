#!/usr/bin/python
#coding=utf8

import sys
import string
import os.path as op
import codeParser
import manifestParser
import re
from subprocess import call


def showHelp():
  print "Usage : documentationCheck.py  Manifest.csv  OTB_DIR  [OUTPUT_DIR]"


def parserHeader(srcPath, mod):
  content = []
  lineBuffer = []
  isInComment = False
  hasClassKeyword = False
  groupKeywordPos = []
  
  fd = open(srcPath,'rb')
  for line in fd:
    cleanLine = (line.replace("\t"," ")).strip(" \n\r")
    
    if cleanLine.startswith("/**"):
      isInComment = True
    
    if isInComment:
      lineBuffer.append(line)
      if cleanLine.count("\class ") == 1:
        hasClassKeyword = True
      if cleanLine.count("\ingroup OTB") == 1:
        groupKeywordPos.append(len(lineBuffer) -1)
    else:
      content.append(line)
    
    if cleanLine.endswith("*/"):
      # check this is really a class documentation bloc
      if hasClassKeyword:
        # Always add group keyword at the end
        if len(groupKeywordPos) > 0:
        #if 0:
          # a group keyword is already present (or more) : modify the lines
          linePos = lineBuffer[groupKeywordPos[0]].find("\ingroup OTB")
          lineBuffer[groupKeywordPos[0]] = lineBuffer[groupKeywordPos[0]][0:linePos+9]+"OTB"+mod+"\n"
          # remove additionnal group keywords
          for otherPos in groupKeywordPos[1:]:
            lineBuffer = lineBuffer[0:otherPos]+lineBuffer[otherPos+1:]
        else:
          # no group keyword : add one at the bloc end
          lastLine = lineBuffer.pop()
          lineBuffer.append(" *\n")
          lineBuffer.append(" * \ingroup OTB"+mod+"\n")
          lineBuffer.append(lastLine)
      # copy buffer to ouput
      content = content+lineBuffer
      # reset temporary vars
      isInComment = False
      hasClassKeyword = False
      groupKeywordPos = []
      lineBuffer = []
  
  fd.close()
  return content
  

def main(argv):
  manifestPath = argv[1]
  otbDir = argv[2]
  
  if len(argv) >= 4:
    outPath = argv[3]
  else:
    outPath = ""
    print "Warning ! Results will be produced in "+otbDir+" , the current content will be modified"
    resp = raw_input("Press 'y' to continue : ")
    if resp.lower() != "y":
      return 0
  
  
  [groups,moduleList,sourceList] = manifestParser.parseManifest(manifestPath)
  
  for mod in moduleList:
    for src in moduleList[mod]:
      if src.endswith(".h"):
        nextContent = parserHeader(op.join(otbDir,src),mod)
        if outPath == "":
          nextPath = op.join(otbDir,src) 
        else:
          nextPath = op.join(outPath,src)
          call(["mkdir","-p",op.dirname(nextPath)])
        fd = open(nextPath,'wb')
        fd.writelines(nextContent)
        fd.close()
  
  return 0

if __name__ == "__main__":
  if len(sys.argv) < 3 :
    showHelp()
  else:
    main(sys.argv)
