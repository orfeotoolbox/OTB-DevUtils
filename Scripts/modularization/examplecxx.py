#!/usr/bin/python2.7

import os

HeadOfTempTree="/home/jmalik/dev/src/OTB-modular-test/OTB_remaining"
HeadOfModularOTBTree="/home/jmalik/dev/src/OTB-modular-test/OTB_Modular"
HeadOfOTBTree="/home/jmalik/dev/src/OTB"

for i in sorted(os.listdir(HeadOfTempTree + "/Examples")):
  if i == "CMakeLists.txt" or i == "README.txt":
    continue
    
  print "-"*20
  print i
  
  for j in sorted(os.listdir(HeadOfTempTree + "/Examples/" + i)):
    if j == "CMakeLists.txt":
      continue
    print j
    
    command = "cp %s/Examples/%s/%s %s/Examples/%s/%s" % ( HeadOfTempTree, i, j,  HeadOfModularOTBTree, i, j) 
    print command
