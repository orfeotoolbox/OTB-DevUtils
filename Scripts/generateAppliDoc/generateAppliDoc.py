#!/usr/bin/env python2
# -*- coding: utf-8 -*-

"""
This script provides an easy way to generate the application documentation in
html format. It uses the class otbWrapperApplicationHtmlDocGenerator class to
do so.
"""

import os


def main(otbbin, outDir):
    test_driver_path = os.path.join(otbbin, "bin",
                                    "otbApplicationEngineTestDriver")

    docExe = " ".join((test_driver_path,
                       "otbWrapperApplicationHtmlDocGeneratorTest1"))

    cmakeFile = os.path.join(otbbin, "CMakeCache.txt")

    ## open CMakeCache.txt
    f = open(cmakeFile, 'r')
    # Extract the list of modules from CMakeCache.txt
    appliKey = "OTB_APPLICATIONS_NAME_LIST"
    appSorted = []
    for line in f:
        if line.find(appliKey) != -1:
            # supress white space if any
            line2 = line.strip()
            # supress line return
            line = line.strip(" \n")
            appList = line.split("=")[1]
            appSortedTmp = appList.split(";")
            appSortedTmp.sort()
            for app in appSortedTmp:
                if app != "TestApplication":
                    appSorted.append(app)
            break
    #print "Found applications:"
    #print appSorted


    ## close CMakeCache.txt
    f.close()

    # Extract the OTB_DIR_SOURCE path form CMakeCache.txt
    ## open CMakeCache.txt
    f = open(cmakeFile, 'r')
    for line in f:
        if line.find("OTB_SOURCE_DIR") != -1:
            # supress white space if any
            otbDir = line.strip()
            # supress line return
            otbDir = line.strip(" \n")
            otbDir = otbDir.split("=")[1]
            break
    #print "OTB_SOURCE_DIR:" + otbDir

    ## close CMakeCache.txt
    f.close()


    ## Find the list of subdir Application to sort them
    appDir = os.path.join(otbDir, "Modules", "Applications")
    fileList = os.listdir(appDir)
    dirList = []
    for fname in fileList:
        if os.path.isdir(os.path.join(appDir, fname)):
            if fname != "AppTest":
                dirList.append(fname)
    #print "Subdir in Application:"
    #print dirList


    fout = open(os.path.join(outDir, "index.html"), 'w')
    fout.write("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//ENhttp://www.w3.org/TR/REC-html40/strict.dtd\"><html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">p, li { white-space: pre-wrap; }</style></head><body style=\" font-family:'Sans Serif'; font-size:9pt; font-weight:400; font-style:normal;\"></style></head><body style=\" font-family:'Sans Serif'; font-size:9pt; font-weight:400; font-style:normal;\">")
    fout.write("<h1>The following applications are distributed with OTB.</h1>")
    fout.write("List of available applications:<br /><br />")

    count = 0
    for dirName in dirList:
        group = dirName
        if dirName.startswith("App") and len(dirName) > 4:
            group = dirName[3:]
        fout.write("<h2>" + group + "</h2>")
        fList = os.listdir(os.path.join(appDir, dirName, "app"))
        for app in appSorted:
            for fname in fList:
                # We assume that the class source file nane is otb#app#.cxx
                if fname.find("otb" + app + ".cxx") != -1:
                    print ("Generating " + app + " ...")
                    filename = '.'.join((app, "html"))
                    filepath = os.path.join(outDir, filename)
                    application_path = os.path.join(otbbin, "lib", "otb",
                                                    "applications")

                    commandLine = " ".join((docExe, app, application_path,
                                            filepath, "1"))
                    os.system(commandLine)

                    outLine = "<a href=\"" + filename + "\">" + app + "</a><br />"
                    fout.write(outLine)
                    count = count + 1
                    break

    if count != len(appSorted):
        print "Some application doc may haven't been generated:"
        print "Waited for " + str(len(appSorted)) + " doc, only " + str(count) + " generated..."
    else:
        print str(count) + " application documentations have been generated..."

    fout.write("</body")
    fout.write("</html>")
    fout.close()

if __name__ == "__main__":
    from argparse import ArgumentParser
    parser = ArgumentParser(description="Documentation generator script",
                            epilog=__doc__)
    parser.add_argument("otb_bin_path", help="Path to the otb binary directory")
    parser.add_argument("output_path", help="Path to the output directory")
    args = parser.parse_args()

    main(args.otb_bin_path, args.output_path)
