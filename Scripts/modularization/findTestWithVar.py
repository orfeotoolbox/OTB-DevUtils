import os
import re
import os.path as op
import sys

def FindProblematicTests(otb_dir):
    re_str = "[a-z][a-z]T[a-z][A-Za-z0-9_\-]*[$\{[A-Za-z0-9_\-]+\}][A-Za-z0-9_\-]*"

    testdir = op.join(otb_dir,"Testing")
    for d in os.listdir(testdir):
        cmakefile = op.join(testdir,d,"CMakeLists.txt")
        f = open(cmakefile,'rb')
        for line in open(cmakefile):
            if re.search(re_str,line):
                print line

FindProblematicTests(sys.argv[1])
