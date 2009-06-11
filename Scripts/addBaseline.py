# -*- coding: utf-8 -*-

import sys, string, shutil, os

def help():
  print """
  This script provides an easy way to add new baselines by simply copying the
  part of the command line corresponding to the compare-image, compare-ascii
  etc. from the dashboard.
  The script checks for existing baselines and add them after, incrementing the
  baseline id number.

  Using the first argument '0' performs a dryrun letting you know which
  baseline will be added. Always do that first!

  WARNING: Think twice before doing 'hg add' or 'hg commit'!!!

  Arguments should be given as:
  0 baseline1 temporary1 baseline2 temporary2...
  Use the first argument to tell if you want to do a simulation (0) or really
  replace the baselines (1)
  """

def copyBaseline(src,dst,replace):
  if (string.find(dst,'Baseline') == -1):
    print "ERROR: check that the baseline is really a baseline:"
    print dst
    return
  if (string.find(src,'Temporary') == -1):
    print "ERROR: check that the temporary is really the output of the test:"
    print src
    return

  dstparts = string.split(dst, '.')
  prefix = '.'.join(dstparts[0:-1])
  suffix = dstparts[-1]
  ident = ['.','.1.','.2.','.3.','.4.','.5.','.6.','.7.','.8.','.9.']
  for baselineid in ident:
    dstnewbaseline = prefix+baselineid+suffix
    if not os.path.isfile(prefix+baselineid+suffix):
      print "Adding baseline as "+dstnewbaseline
      if (int(replace) == 1):
        shutil.copyfile(src,dstnewbaseline)
        print "Done!"
      return
  print "ERROR: already 10 baselines, you might want to look at the test itself..."
  return

def main(argv):
  argc = len(argv)
  if (argc < 4):
    help()
  replace = argv[1]
  for i in range(2,argc,2):
    if (i+1 == argc):
      print "ERROR: number of argument doesn't match"
      help()
      return
    dst = argv[i]
    src = argv[i+1]
    copyBaseline(src,dst,replace)



if __name__ == "__main__":
    main(sys.argv)
