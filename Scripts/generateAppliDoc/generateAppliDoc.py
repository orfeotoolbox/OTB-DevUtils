#!/usr/bin/env python2
# -*- coding: utf-8 -*-

"""
This script provides an easy way to generate the application documentation in
html format. It uses the class otbWrapperApplicationHtmlDocGenerator class to
do so.
"""

import os
import re

from glob import iglob
from collections import namedtuple
from itertools import ifilter


def get_applications_from_CMakeCache(cmakefile):
    """ Give list of applications listed in CMakeFile """
    unsplited = get_value_from_CMakeCache(cmakefile,
                                          "OTB_APPLICATIONS_NAME_LIST")
    applications = unsplited.split(';')

    try:
        applications.remove("TestApplication")  # supposed their is only one
    except ValueError:
        pass

    applications.sort()
    return applications


def get_value_from_CMakeCache(filename, key):
    """ Extract from a CMakeCache file the value corresponding to the key given
    as argument.

    Raise a KeyError exception if key is not in the file.
    """
    key_found = False
    value = None
    line = True
    with open(filename, 'r') as f:
        while line and not key_found:
            line = f.readline()  # Do NOT strip to avoid infinite loop
            if line.strip().startswith(key):
                key_found = True
                value = line.strip().split('=')[1]
    if not key_found:
        raise KeyError('No key "{}" in "{}".'.format(key, filename))
    return value


def associate_group_to_applications(src_dir, apps):
    """ Associate applications names with the group it belongs to.

    Search for source files in the source directory tree and compares their
    names to those in the list of applications given in argument. If a name
    match, the name of the group it belongs to is deduced from its path.

    Returns a list of namedtuples with the name of each application and its
    group.

    Assumptions are:
        - source filename is of the form of ``otbAPPLICATIONNAME.cxx``
        - group names can be prefixed by ``App``. This prefix is ignored
        - source filepath is ``src_dir/Modules/Applications/GROUPNAME/app/``
        - module named ``Test`` is ignored

    Args:
        src_dir (str): source directory of otb
        apps (list): list of applications to document

    Returns:
        list: list of namedtuples

        namedtuples are defined as `namedtuple('AppProp', ['name', 'group'])`
    """
    apps_dir = os.path.join(src_dir, 'Modules', 'Applications')
    glob_pattern = os.path.join(apps_dir, '**', 'app', '*.cxx')
    match_pattern = re.compile(os.path.join(apps_dir, "(?:App)?(?P<group>.+)",
                                            'app', 'otb(?P<name>.+).cxx'))

    AppProp = namedtuple('AppProp', ['name', 'group'])

    def match_filter_condition(match):
        if match:
            group, name = match.groups()
            if name in apps and group != 'Test':
                return True
        return False

    files = iglob(glob_pattern)
    matches = ifilter(match_filter_condition,
                      (re.match(match_pattern, f) for f in files))
    output = [AppProp(**m.groupdict()) for m in matches]
    return output


def main(otbbin, outDir):
    test_driver_path = os.path.join(otbbin, "bin",
                                    "otbApplicationEngineTestDriver")

    docExe = " ".join((test_driver_path,
                       "otbWrapperApplicationHtmlDocGeneratorTest1"))

    cmakeFile = os.path.join(otbbin, "CMakeCache.txt")

    applications = get_applications_from_CMakeCache(cmakeFile)
    otbDir = get_value_from_CMakeCache(cmakeFile, "OTB_SOURCE_DIR")

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
        for app in applications:
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

    if count != len(applications):
        print "Some application doc may haven't been generated:"
        print "Waited for " + str(len(applications)) + " doc, only " + str(count) + " generated..."
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
