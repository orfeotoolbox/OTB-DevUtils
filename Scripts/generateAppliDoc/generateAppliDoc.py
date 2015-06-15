#!/usr/bin/env python2
# -*- coding: utf-8 -*-

"""
This script provides an easy way to generate the application documentation in
html format. It uses the class otbWrapperApplicationHtmlDocGenerator class to
do so.
"""

import os
import re
import subprocess

from glob import iglob
from collections import namedtuple
from itertools import ifilter, groupby
from operator import attrgetter
from textwrap import dedent


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


def generate_html_pages(otb_bin_path, output_dir, applications):
    """ Generate html pages in output_dir.

    Args:
        otb_bin_path (str): path to otb binaries
        output_dir (str): directory where to write html pages
        applications (namedtuple): name of applications associated to their
                                   group

    Returns: list of namedtuples

             namedtuples are defined as:

             ``namedtuple('AppProp', ['name', 'group', 'htmlfile'])``

             Where ``name`` refers to the name of the application, ``group`` to
             the group it belongs to and ``htmlfile`` is the path to the
             generated htmlfile corresponding to the application.

    """

    test_driver_path = os.path.join(otb_bin_path, "bin",
                                    "otbApplicationEngineTestDriver")

    test_app = "otbWrapperApplicationHtmlDocGeneratorTest1"

    applications_path = os.path.join(otb_bin_path, "lib", "otb", "applications")

    AppProp = namedtuple('AppProp', ['name', 'group', 'htmlfile'])

    updtated_applications = []
    for app in applications:
        basename = '.'.join((app.name, "html"))
        htmlfile = os.path.join(output_dir, basename)

        updtated_applications.append(AppProp(*app, htmlfile=htmlfile))

        command_line = (test_driver_path, test_app, app.name,
                        applications_path, htmlfile, "1")
        subprocess.call(command_line)

    return updtated_applications


def generate_html_index(output_dir, applications):
    """ Generate an html page index with links to html pages given in argument

    Args:
        output_dir (str): directory where to write the html index page
        applications (list): name of applications associated to their group and
                             htmlfile in a namedtuple of the form of
                             ``namedtuple('AppProp', ['name', 'group',
                                                      'htmlfile'])``

    Returns: None

    """
    entries = []
    applications.sort(key=attrgetter('group'))  # needed to use groupby
    for group, apps in groupby(applications, attrgetter('group')):
        entries.append("<h2>{group}</h2>".format(group=group))
        for app in sorted(apps):
            entries.append('\t<a href="{htmlfile}">{app}</a><br />'.format(htmlfile=app.htmlfile, app=app.name))

    index_content = """\
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//ENhttp://www.w3.org/TR/REC-html40/strict.dtd">
    <html>
    \t<head>
    \t\t<meta name="qrichtext" content="1" />
    \t\t<style type="text/css">p, li {{ white-space: pre-wrap; }}</style>
    \t</head>
    \t<body style=" font-family:'Sans Serif'; font-size:9pt; font-weight:400; font-style:normal;">
    \t\t<h1>The following applications are distributed with OTB.</h1>
    \t\t\tList of available applications:<br /><br />
    \t\t\t{entries}
    \t</body>
    </html>""".format(entries='\n    \t\t\t'.join(entries))

    with open(os.path.join(output_dir, "index.html"), 'w') as fout:
        fout.write(dedent(index_content))


def main(otbbin, output_dir):
    cmakeFile = os.path.join(otbbin, "CMakeCache.txt")
    otbDir = get_value_from_CMakeCache(cmakeFile, "OTB_SOURCE_DIR")

    applications = get_applications_from_CMakeCache(cmakeFile)
    apps_and_groups = associate_group_to_applications(otbDir, applications)
    apps_groups_html = generate_html_pages(otbbin, output_dir, apps_and_groups)
    generate_html_index(output_dir, apps_groups_html)


    if count != len(applications):
        print "Some application doc may haven't been generated:"
        print "Waited for " + str(len(applications)) + " doc, only " + str(count) + " generated..."
    else:
        print str(count) + " application documentations have been generated..."

if __name__ == "__main__":
    from argparse import ArgumentParser
    parser = ArgumentParser(description="Documentation generator script",
                            epilog=__doc__)
    parser.add_argument("otb_bin_path", help="Path to the otb binary directory")
    parser.add_argument("output_path", help="Path to the output directory")
    args = parser.parse_args()

    main(args.otb_bin_path, args.output_path)
