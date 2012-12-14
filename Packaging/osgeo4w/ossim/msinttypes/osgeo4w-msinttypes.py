import os, sys, shutil, datetime, subprocess

CURDIR = os.path.dirname(  os.path.abspath(__file__) )

MSINTTYPES_SRC_VERSION=26
MSINTTYPES_PACKAGE_VERSION=1

MSINTTYPES_SRC = os.path.join(CURDIR, "msinttypes-r%i" % (MSINTTYPES_SRC_VERSION) )

TAREXE="C:\\OSGeo4W\\apps\\msys\\bin\\tar.exe"
	
def make_package():	
	# init dest dir
	package_versioned_name = "msinttypes-%i-%i" % (MSINTTYPES_SRC_VERSION, MSINTTYPES_PACKAGE_VERSION)
	dstdir = os.path.join(CURDIR, package_versioned_name)
	if os.path.exists(dstdir):
		shutil.rmtree(dstdir)
	os.mkdir(dstdir)
	
	# cp necessary files
	include_dir = os.path.join(dstdir, "include") # shutil.copytree will create it
	shutil.copytree( MSINTTYPES_SRC, include_dir )
	os.unlink( os.path.join(include_dir, "changelog.txt") )
	
	# compress with osgeo4w compliance
	os.chdir( dstdir )
	subprocess.call( [TAREXE, "-cvjf", "../" + package_versioned_name + ".tar.bz2",  "*" ] )
	os.chdir( CURDIR )


if __name__ == "__main__" :
	make_package()
