import os, sys, shutil, datetime, subprocess

THIS_DIR = os.path.dirname( os.path.abspath(__file__) )

EXE_TAR="C:\\OSGeo4W\\apps\\msys\\bin\\tar.exe"

# Install tree
OPENCV_INSTALL="C:\\Users\\jmalik\\Dashboard\\tools\\build\\opencv-2.4.8.2\\install"

# For the OSGeo4W package
def get_opencv_version(opencv_install_path):
	with open( os.path.join(opencv_install_path,"OpenCVConfig-version.cmake") ) as versionfile:
		for line in versionfile:
			if "set(OpenCV_VERSION" in line:
				version = line.split()[1][:-1]
				break
	if not version:
		raise "Version not found"
	return version

OPENCV_VERSION=get_opencv_version(OPENCV_INSTALL)
OPENCV_PACKAGE_VERSION=1

def copy_replace_onthefly(inputfilename, outputfilename, expr, replacement):
    with open(outputfilename, "w") as out:
      with open(inputfilename) as input:
        for line in input:
          out.write(line.replace(expr, replacement))

def make_package():	
	# init dest dir
	package_versioned_name = "opencv-%s-%i" % (OPENCV_VERSION, OPENCV_PACKAGE_VERSION)
	dstdir = os.path.join(THIS_DIR, package_versioned_name)
	if os.path.exists(dstdir):
		shutil.rmtree(dstdir)
	os.mkdir(dstdir)

	for subdir in ["include", "apps"]:
		shutil.copytree( os.path.join(OPENCV_INSTALL, subdir), \
						 os.path.join(dstdir,subdir) )
	for subdir in ["bin", "lib"]:
		shutil.copytree( os.path.join(OPENCV_INSTALL, "x64/vc10", subdir), \
						 os.path.join(dstdir,subdir) )
                         
    # Move OpenCV cmake files from root of install dir to proper share/OpenCV subdir (as in linux)
	cmakefiles_dir = os.path.join(dstdir, "share", "OpenCV")
	os.makedirs(cmakefiles_dir)
	shutil.move(os.path.join(dstdir, "lib/OpenCVConfig.cmake"), cmakefiles_dir)
	shutil.move(os.path.join(dstdir, "lib/OpenCVModules.cmake"), cmakefiles_dir)
	shutil.move(os.path.join(dstdir, "lib/OpenCVModules-release.cmake"), cmakefiles_dir)
    
    # Since we move cmake files around, adapt some paths
	os.system('sed -i "s@${OpenCV_CONFIG_PATH}/include@${OpenCV_CONFIG_PATH}/../../include@g" ' + os.path.join(cmakefiles_dir, "OpenCVConfig.cmake"))
	os.system('sed -i "s@add_library(opencv_videostab SHARED IMPORTED)@add_library(opencv_videostab SHARED IMPORTED)\\nget_filename_component(_IMPORT_PREFIX \\"${CMAKE_CURRENT_LIST_FILE}\\" PATH)\\nget_filename_component(_IMPORT_PREFIX \\"${_IMPORT_PREFIX}\\" PATH)\\nget_filename_component(_IMPORT_PREFIX \\"${_IMPORT_PREFIX}\\" PATH)@g" ' + os.path.join(cmakefiles_dir, "OpenCVModules.cmake"))
	os.system('sed -i "s@${_IMPORT_PREFIX}/x64/vc10/@${_IMPORT_PREFIX}/@g" ' + os.path.join(cmakefiles_dir, "OpenCVModules-release.cmake"))

    # Move OpenCVConfig.cmake too, but replace on the fly
    # the occurence of "${OpenCV_CONFIG_PATH}/" by "${OpenCV_CONFIG_PATH}/../../"
	#copy_replace_onthefly(os.path.join(OPENCV_INSTALL, "OpenCVConfig.cmake"), \
    #                      os.path.join(cmakefiles_dir, "OpenCVConfig.cmake"), \
    #                        "${OpenCV_CONFIG_PATH}/", \
    #                        "${OpenCV_CONFIG_PATH}/../../" )
    
	# Compress with osgeo4w compliance
	current_dir = os.getcwd()
	os.chdir( dstdir )
	subprocess.call( [EXE_TAR, "-cjf", "../" + package_versioned_name + ".tar.bz2",  "*" ] )
	os.chdir( current_dir )

if __name__ == "__main__" :
	make_package()
