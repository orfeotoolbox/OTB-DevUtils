import os, sys, shutil, datetime, subprocess

THIS_DIR = os.path.dirname( os.path.abspath(__file__) )

EXE_TAR="C:\\OSGeo4W\\apps\\msys\\bin\\tar.exe"

# Install tree
OSSIM_INSTALL="C:\\Users\\jmalik\\Dashboard\\install\\ossim-trunk-gui"

# For the OSGeo4W package
def get_ossim_version(ossim_install_path):
	with open( os.path.join(ossim_install_path,"include","ossim","ossimVersion.h") ) as versionfile:
		for line in versionfile:
			if "OSSIM_VERSION" in line:
				version = line.split()[2].split('"')[1]
			if "OSSIM_REVISION_NUMBER" in line:
				rev = line.split()[2]
				
	return "%s-%s" % (version, rev)

OSSIM_VERSION=get_ossim_version(OSSIM_INSTALL)
OSSIM_PACKAGE_VERSION=1


def make_package():	
	# init dest dir
	package_versioned_name = "ossim-%s-%i" % (OSSIM_VERSION, OSSIM_PACKAGE_VERSION)
	dstdir = os.path.join(THIS_DIR, package_versioned_name)
	if os.path.exists(dstdir):
		shutil.rmtree(dstdir)
	os.mkdir(dstdir)

	for subdir in ["bin", "include", "lib", "share"]:
		shutil.copytree( os.path.join(OSSIM_INSTALL, subdir), \
						 os.path.join(dstdir,subdir) )
						 
	# remove some files we don't want in the package
	os.unlink( os.path.join(dstdir, "bin", "msvcr100.dll") )
	os.unlink( os.path.join(dstdir, "bin", "msvcp100.dll") )
	
	os.unlink( os.path.join(dstdir, "include", "ossimConfig.h") )
	os.unlink( os.path.join(dstdir, "include", "ossimVersion.h") )
	
	# compress with osgeo4w compliance
	current_dir = os.getcwd()
	os.chdir( dstdir )
	subprocess.call( [EXE_TAR, "-cjf", "../" + package_versioned_name + ".tar.bz2",  "*" ] )
	os.chdir( current_dir )

if __name__ == "__main__" :
	make_package()
