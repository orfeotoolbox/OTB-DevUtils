import os, sys, shutil, datetime, subprocess

OTB_SRC="C:\\Users\\jmalik\\Dashboard\\src\\OTB-5.0.0"
MONTEVERDI_SRC="C:\\Users\\jmalik\\Dashboard\\src\\Monteverdi-1.24.0"
MONTEVERDI2_SRC="C:\\Users\\jmalik\\Dashboard\\src\\Monteverdi2-0.8.1"
ICE_SRC="C:\\Users\\jmalik\\Dashboard\\src\\Ice-0.3.0"
#OTB_WRAPPING_SRC="C:\\Users\\jmalik\\Dashboard\\src\\OTB-Wrapping"

OTB_INSTALL="C:\\Users\\jmalik\\Dashboard\\install\\OTB-5.0.0-vc10-x86-Release"
MONTEVERDI_INSTALL="C:\\Users\\jmalik\\Dashboard\\install\\Monteverdi-1.24.0-vc10-x86-Release"
MONTEVERDI2_INSTALL="C:\\Users\\jmalik\\Dashboard\\install\\Monteverdi2-0.8.1-vc10-x86-Release"
ICE_INSTALL="C:\\Users\\jmalik\\Dashboard\\install\\Ice-0.3.0-vc10-x86-Release"
#OTB_WRAPPING_INSTALL="C:\\Users\\jmalik\\Dashboard\\install\\OTB-Wrapping-RelWithDebInfo-VC2008"

OSGEO4W_STAGING="C:\\Users\\jmalik\\Dashboard\\osgeo4w\\x86"
OSGEO4W_TEMPLATE="C:\\Users\\jmalik\\Dashboard\\src\\OTB-DevUtils\\Packaging\\osgeo4w\otb-x86"
TAREXE="C:\\OSGeo4W\\apps\\msys\\bin\\tar.exe"

def get_version(cmakelistpath, id):
    with open(cmakelistpath) as cmakelist:
      for line in cmakelist:
        for set in ["set", "SET"]:
            if set + "(" + id + "_VERSION_MAJOR" in line:
                MAJOR = line.split()[1].split('"')[1]

            if set + "(" + id + "_VERSION_MINOR" in line:
                MINOR = line.split()[1].split('"')[1]
                
            if set + "(" + id + "_VERSION_PATCH" in line:
                PATCH = line.split()[1].split('"')[1]
    return "%s.%s.%s" % (MAJOR, MINOR, PATCH)

def get_short_version(cmakelistpath, id):
    with open(cmakelistpath) as cmakelist:
      for line in cmakelist:
        for set in ["set", "SET"]:
            if set + "(" + id + "_VERSION_MAJOR" in line:
                MAJOR = line.split()[1].split('"')[1]

            if set + "(" + id + "_VERSION_MINOR" in line:
                MINOR = line.split()[1].split('"')[1]
                
    return "%s.%s" % (MAJOR, MINOR)
    
OTB_SHORT_VERSION = get_short_version( os.path.join(OTB_SRC, "CMakeLists.txt"), "OTB" )
OTB_VERSION = get_version( os.path.join(OTB_SRC, "CMakeLists.txt"), "OTB" )
print "OTB version : %s" % OTB_VERSION

MONTEVERDI_VERSION = get_version( os.path.join(MONTEVERDI_SRC, "CMakeLists.txt"), "Monteverdi" )
print "Monteverdi version : %s" % MONTEVERDI_VERSION

ICE_VERSION = get_version( os.path.join(ICE_SRC, "CMakeLists.txt"), "Ice" )
print "Ice version : %s" % ICE_VERSION

MONTEVERDI2_VERSION = get_version( os.path.join(MONTEVERDI2_SRC, "CMakeLists.txt"), "Monteverdi2" )
print "Monteverdi version : %s" % MONTEVERDI2_VERSION

#OTB_WRAPPING_VERSION = get_version( os.path.join(OTB_WRAPPING_SRC, "CMakeLists.txt"), "OTB-Wrapping" )
#print "OTB-Wrapping version : %s" % OTB_WRAPPING_VERSION


todayiso = datetime.date.today().isoformat().replace('-','')
yesterdayiso = (datetime.date.today()-datetime.timedelta(1)).isoformat().replace('-','')

def initialize_package(packagebasename, src_version, pkg_version, stage_root):
    # directory where installation files will be staged
    package_versioned_name = packagebasename + "-" + src_version + "-" + yesterdayiso + "-1"
    dstdir = os.path.join(OSGEO4W_STAGING, package_versioned_name)
    os.chdir( OSGEO4W_STAGING )

    # copy the template to the dstdir
    if os.path.exists(dstdir):
        shutil.rmtree(dstdir)
    shutil.copytree( os.path.join(OSGEO4W_TEMPLATE, "template-" + packagebasename), dstdir )
    
    remove_placeholder_files(dstdir)

    return package_versioned_name

def remove_placeholder_files(dirname):
    for root, dirs, files in os.walk(dirname, topdown=False):
        for name in files:
          if name == "placeholder":
            os.remove(os.path.join(root, name))

def patch_batch_launcher(path):
    inFile = open(path,'rb')
    content = inFile.readlines()
    inFile.close()
    newContent = []
    for line in content:
      if line.find("../lib/otb/applications") != -1:
        line = line.replace("../lib/otb/applications","../apps/orfeotoolbox/applications")
      if line.startswith(":: works for install tree"):
        newContent.append("setlocal\n")
        newContent.append(line)
      elif line.startswith("%OTB_CLI_LAUNCHER%"):
        newContent.append(line)
        newContent.append("endlocal\n")
      elif line.startswith("%OTB_GUI_LAUNCHER%"):
        newContent.append(line)
        newContent.append("endlocal\n")
      else:
        newContent.append(line)
    outFile = open(path,'wb')
    outFile.writelines(newContent)
    outFile.close()

def make_tarbz2(package_versioned_name):
    current_dir = os.getcwd()
    pkg_name = "-".join(package_versioned_name.split('-')[0:2])
    os.chdir( os.path.join(OSGEO4W_STAGING, package_versioned_name) )
    subprocess.call( [TAREXE, "-cvjf", "../" + package_versioned_name + ".tar.bz2",  "*" ] )
    os.chdir( OSGEO4W_STAGING )    
    subprocess.call( [os.path.join(OSGEO4W_TEMPLATE, "otb_make_tar.cmd"),  package_versioned_name, pkg_name ] )
    os.chdir( current_dir )

def make_otb_bin():
    package_name = "otb-bin"
    package_versioned_name = initialize_package(package_name, OTB_VERSION, yesterdayiso, OSGEO4W_STAGING)
    shutil.copy( os.path.join(OTB_SRC, "LICENSE" ),  OSGEO4W_STAGING +  "\\" + package_name +  '_LIC.txt')
    # copy the content of lib/otb/applications to apps/orfeotoolbox/applications
    inputdir = os.path.join(OTB_INSTALL, "lib\\otb\\applications")
    for fic in os.listdir( inputdir ) :
      shutil.copy( os.path.join(inputdir, fic), \
                   os.path.join(OSGEO4W_STAGING, package_versioned_name, "apps", "orfeotoolbox", "applications" ) )

    # copy the .bat launchers in bin
    inputdir = os.path.join(OTB_INSTALL, "bin")
    outputbindir = os.path.join(OSGEO4W_STAGING, package_versioned_name, "bin" )
    for fic in os.listdir( inputdir ) :
      if fic.startswith("otbcli") or fic.startswith("otbgui"):
        shutil.copy( os.path.join(inputdir, fic), \
                     outputbindir )

    # patch the script launchers
    patch_batch_launcher(os.path.join(outputbindir, "otbcli.bat"))
    patch_batch_launcher(os.path.join(outputbindir, "otbgui.bat"))
    
    shutil.copy( os.path.join(OTB_INSTALL, "bin", "otbApplicationLauncherCommandLine.exe"), outputbindir )
    shutil.copy( os.path.join(OTB_INSTALL, "bin", "otbApplicationLauncherQt.exe"), outputbindir )
    #shutil.copy( os.path.join(OTB_INSTALL, "bin", "otbViewer.exe"), outputbindir )
    
    # copy ossim and ossimplugin dll in the otbbin package for now
    shutil.copy( os.path.join(OTB_INSTALL, "bin", "otbossimplugins-" +  OTB_SHORT_VERSION  + ".dll"), outputbindir )
    
    make_tarbz2(package_versioned_name)
                   
def make_otb_python():
    package_name = "otb-python"
    package_versioned_name = initialize_package(package_name, OTB_VERSION, yesterdayiso, OSGEO4W_STAGING)
    shutil.copy( os.path.join(OTB_SRC, "LICENSE" ),  OSGEO4W_STAGING +  "\\" + package_name +  '_LIC.txt')
    # copy the content of lib/otb/python to apps/orfeotoolbox/python
    inputdir = os.path.join(OTB_INSTALL, "lib\\otb\\python")
    for fic in os.listdir( inputdir ) :
      shutil.copy( os.path.join(inputdir, fic), \
                   os.path.join(os.path.join(OSGEO4W_STAGING, package_versioned_name), "apps", "orfeotoolbox", "python" ) )
    make_tarbz2(package_versioned_name)
    
def make_monteverdi():
    package_name = "otb-monteverdi"
    package_versioned_name = initialize_package(package_name, MONTEVERDI_VERSION, yesterdayiso, OSGEO4W_STAGING)
    shutil.copy( os.path.join(OTB_SRC, "LICENSE" ),  OSGEO4W_STAGING +  "\\" + package_name +  '_LIC.txt')
    inputdir = os.path.join(MONTEVERDI_INSTALL, "bin")
    shutil.copy( os.path.join(inputdir, "monteverdi.exe"),
                 os.path.join(OSGEO4W_STAGING, package_versioned_name, "apps", "orfeotoolbox", "monteverdi", "bin" ) )
   
    make_tarbz2(package_versioned_name)

def make_otb_ice():
    package_name = "otb-ice"
    package_versioned_name = initialize_package(package_name, ICE_VERSION, yesterdayiso, OSGEO4W_STAGING)
    shutil.copy( os.path.join(OTB_SRC, "LICENSE" ),  OSGEO4W_STAGING +  "\\" + package_name +  '_LIC.txt')    
    inputdir = os.path.join(ICE_INSTALL, "bin")
    print inputdir
    shutil.copy( os.path.join(inputdir, "otbiceviewer.exe"),
                 os.path.join(OSGEO4W_STAGING, package_versioned_name, "apps", "orfeotoolbox", "ice", "bin" ) )
   
    make_tarbz2(package_versioned_name)

def make_monteverdi2():
    package_name = "otb-monteverdi2"
    package_versioned_name = initialize_package(package_name, MONTEVERDI2_VERSION, yesterdayiso, OSGEO4W_STAGING)
    shutil.copy( os.path.join(OTB_SRC, "LICENSE" ),  OSGEO4W_STAGING +  "\\" + package_name +  '_LIC.txt')
    inputdir = os.path.join(MONTEVERDI2_INSTALL, "bin")
    shutil.copy( os.path.join(inputdir, "monteverdi2.exe"),
                 os.path.join(OSGEO4W_STAGING, package_versioned_name, "apps", "orfeotoolbox", "monteverdi2", "bin" ) )
   
    make_tarbz2(package_versioned_name)
        
# def make_otb_wrapping():
    # package_name = "otb-wrapping"
    # package_versioned_name = initialize_package(package_name, OTB_WRAPPING_VERSION, yesterdayiso, OSGEO4W_STAGING)
    
    # inputdir = os.path.join(OTB_WRAPPING_INSTALL, "lib", "otb-wrapping")
    # outputdir = os.path.join(OSGEO4W_STAGING, package_versioned_name, "apps", "orfeotoolbox", "wrapping")
    # if os.path.exists(outputdir):
        # shutil.rmtree(outputdir) # or copytree fails...
    # shutil.copytree( inputdir, outputdir )
    # make_tarbz2(package_versioned_name)


make_otb_bin()
make_otb_python()
make_otb_ice()
make_monteverdi()
make_monteverdi2()

# Not supported on VC2010, and not supported starting OTB 4.0
#make_otb_wrapping()
