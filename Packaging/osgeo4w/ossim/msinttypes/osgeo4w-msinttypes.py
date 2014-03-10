import os, sys, shutil, datetime, subprocess, urllib

CURDIR = os.path.dirname(  os.path.abspath(__file__) )

MSINTTYPES_SRC_VERSION=29
MSINTTYPES_PACKAGE_VERSION=1

MSINTTYPES_SRC = os.path.join(CURDIR, "msinttypes-r%i" % (MSINTTYPES_SRC_VERSION) )

TAREXE="C:\\OSGeo4W64\\apps\\msys\\bin\\tar.exe"
	
def make_package():	
	# init dest dir
	package_versioned_name = "msinttypes-%i-%i" % (MSINTTYPES_SRC_VERSION, MSINTTYPES_PACKAGE_VERSION)
	dstdir = os.path.join(CURDIR, package_versioned_name)
	if os.path.exists(dstdir):
		shutil.rmtree(dstdir)
	os.mkdir(dstdir)
	
	# cp necessary files
	include_dir = os.path.join(dstdir, "include") # shutil.copytree will create it
	os.mkdir(include_dir)
	urllib.urlretrieve ( "http://msinttypes.googlecode.com/svn-history/r%s/trunk/stdint.h" % (MSINTTYPES_SRC_VERSION), os.path.join(include_dir, "stdint.h"))
	urllib.urlretrieve ( "http://msinttypes.googlecode.com/svn-history/r%s/trunk/inttypes.h" % (MSINTTYPES_SRC_VERSION), os.path.join(include_dir, "inttypes.h"))
		
	# compress with osgeo4w compliance
	os.chdir( dstdir )
	os.system("tar -cvjf ../%s.tar.bz2 *" % (package_versioned_name))
#	subprocess.call( [TAREXE, "-cvjf", "../" + package_versioned_name + ".tar.bz2",  "*" ] )
	os.chdir( CURDIR )


if __name__ == "__main__" :
	make_package()
