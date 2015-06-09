import os, sys, shutil, datetime, subprocess

THIS_DIR = os.path.dirname( os.path.abspath(__file__) )

# Install tree
OPENCV_INSTALL=  os.path.join(THIS_DIR,"opencv-2.4.11-install") 

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

	if os.path.exists(os.path.join(OPENCV_INSTALL, "x86")):
		buildarch = "x86"
	elif os.path.exists(os.path.join(OPENCV_INSTALL, "x64")):
		buildarch = "x64"


	shutil.copytree( os.path.join(OPENCV_INSTALL, "include"),  os.path.join(dstdir,"include") )
	shutil.copytree( os.path.join(OPENCV_INSTALL, buildarch, "vc10", "lib"),  os.path.join(dstdir,"lib") )	
	shutil.copytree( os.path.join(OPENCV_INSTALL, buildarch, "vc10", "bin"), os.path.join(dstdir,"bin") )
  
	cmakefiles_dir = os.path.join(dstdir, "share", "OpenCV")
	os.makedirs(cmakefiles_dir)  

	copy_replace_onthefly(
    os.path.join(dstdir, "lib", "OpenCVConfig.cmake") , 
    os.path.join(cmakefiles_dir, "OpenCVConfig.cmake"), 
    "${OpenCV_CONFIG_PATH}/include",
    "${OpenCV_CONFIG_PATH}/../../include")

    
	shutil.move(os.path.join(dstdir, "lib", "OpenCVModules.cmake"), cmakefiles_dir)
  
	# copy_replace_onthefly(
    # os.path.join(dstdir, "lib", "OpenCVModules.cmake") , 
    # os.path.join(cmakefiles_dir, "OpenCVModules.cmake"), 
    # "add_library(opencv_videostab SHARED IMPORTED)",
    # "add_library(opencv_videostab SHARED IMPORTED) get_filename_component(_IMPORT_PREFIX \\${CMAKE_CURRENT_LIST_FILE}\\ PATH)  get_filename_component(_IMPORT_PREFIX \\${_IMPORT_PREFIX}\\ PATH)  get_filename_component(_IMPORT_PREFIX \\${_IMPORT_PREFIX}\\ PATH)")    
    
	copy_replace_onthefly(
    os.path.join(dstdir, "lib", "OpenCVModules-release.cmake") , 
    os.path.join(cmakefiles_dir, "OpenCVModules-release.cmake"), 
    "${_IMPORT_PREFIX}/"+ buildarch +"/vc10/",
    "${_IMPORT_PREFIX}/")

if __name__ == "__main__" :
	make_package()
