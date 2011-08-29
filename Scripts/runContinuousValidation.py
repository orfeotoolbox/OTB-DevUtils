import shutil
import datetime
import os
import sys
import subprocess

# !!! NEED python >= 2.7 !!!!

SRC_ROOT = '/Users/otbval/WWW.ORFEO-TOOLBOX.ORG-CS-NIGHTLY/Continuous'
OTB_NIGHTLY_DIR = os.path.join( os.environ['HOME'], 'OTB-NIGHTLY-VALIDATION' )
LOCKFILE = os.path.join( OTB_NIGHTLY_DIR, 'continuous.lock' )
SCRIPT_DIR = os.path.join( OTB_NIGHTLY_DIR, 'OTB-DevUtils', 'Config')
BUILD_ROOT = os.path.join( OTB_NIGHTLY_DIR, 'build', 'Continuous')

class Locker():
  def __init__(self):
    print 'Creating lock file ' + LOCKFILE
    f = open(LOCKFILE, 'w')
    f.write( str(datetime.datetime.today()) )
    f.close()
    print 'Created lock file ' + LOCKFILE

  def __del__(self):
    os.remove(LOCKFILE)
    print 'Removed lock file ' + LOCKFILE

def IsLocked():
  return os.path.exists(LOCKFILE)

def runTest( name ):
  print 'Running test ' + name
  temporary = os.path.join( BUILD_ROOT, 'Testing', 'Temporary')
  if os.path.exists(temporary):
    os.remove(temporary)
  subprocess.call( ['ctest','-S', os.path.join( SCRIPT_DIR, 'leod-' + name + '-Continuous.cmake'), '-V' ])
  print 'Finished running test ' + name

def HasIncomingChanges(name):
  os.chdir( os.path.join(SRC_ROOT, name) )
  haschanges = True
  try:
    subprocess.check_output( ["hg", "incoming"] ).count("changeset")
  except subprocess.CalledProcessError:
    haschanges = False
  return haschanges

def IsBuildEmpty(name):
  cmakecache = os.path.join(OTB_NIGHTLY_DIR, "build", "Continuous", name, "CMakeCache.txt")
  print 'Testing ' + cmakecache + ' : ' + str( os.path.exists( cmakecache ) )
  return not os.path.exists( cmakecache )

def main():
  if IsLocked():
    sys.exit("Continous is locked, check " + LOCKFILE)

  locker = Locker()

  if HasIncomingChanges('OTB') or IsBuildEmpty('OTB') :
    # do all 3 tests (OTB, mvd, otbapp)
    runTest( 'OTB' )
    runTest( 'Monteverdi' )
    runTest( 'OTB-Applications' )
  else:
    if HasIncomingChanges('Monteverdi') or IsBuildEmpty('Monteverdi'):
      runTest( 'Monteverdi' )

    if HasIncomingChanges('OTB-Applications') or IsBuildEmpty('OTB-Applications'):
      runTest( 'OTB-Applications' )

if __name__ == "__main__":
    main()
