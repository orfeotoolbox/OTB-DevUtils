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
import logging
import datetime
import gzip
import inspect
import itertools

from glob import iglob
from collections import namedtuple
from itertools import ifilter, groupby
from operator import attrgetter
from textwrap import dedent

import otbApplication

otb_create_application = otbApplication.Registry.CreateApplication

logger = logging.getLogger("generateAppliDoc")
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.NullHandler())

PARAMETERS_TYPES_NAMES = {
    'ParameterType_Choice': "Choices",
    'ParameterType_ComplexInputImage': "Input image",
    'ParameterType_ComplexOutputImage': "Output image",
    'ParameterType_Directory': "Directory",
    'ParameterType_Empty': "Boolean",
    'ParameterType_Float': "Float",
    'ParameterType_Group': "Group",
    'ParameterType_InputFilename': "Input file name",
    'ParameterType_InputFilenameList': "Input file name list",
    'ParameterType_InputImage': "Input Image",
    'ParameterType_InputImageList': "Input image list",
    'ParameterType_InputProcessXML': "XML input parameters file",
    'ParameterType_InputVectorData': "Input vector data",
    'ParameterType_InputVectorDataList': "Input vector data list",
    'ParameterType_Int': "Int",
    'ParameterType_ListView': "List",
    'ParameterType_OutputFilename': "Output file name",
    'ParameterType_OutputImage': "Output image",
    'ParameterType_OutputProcessXML': "XML output parameters file",
    'ParameterType_OutputVectorData': "Output vector data",
    'ParameterType_RAM': "Int",
    'ParameterType_Radius': "Int",
    'ParameterType_String': "String",
    'ParameterType_StringList': "String list",
}

PARAMETERS_TYPES = {
    value: PARAMETERS_TYPES_NAMES[name]
    for name, value in inspect.getmembers(otbApplication)
    if name in PARAMETERS_TYPES_NAMES
}


def main(otbbin, output_dir, verbose, quite):
    setup_logging(verbose, quite)

    cmakeFile = os.path.join(otbbin, "CMakeCache.txt")
    otbDir = get_value_from_CMakeCache(cmakeFile, "OTB_SOURCE_DIR")

    applications = get_applications_from_CMakeCache(cmakeFile)
    apps_and_groups = associate_group_to_applications(otbDir, applications)
    apps_groups_html = generate_html_pages(otbbin, output_dir, apps_and_groups)
    generate_html_index(output_dir, apps_groups_html)
    check_number_of_htmlpages(applications, apps_and_groups)


def setup_logging(verbose=False, quite=False):
    """ Set the logging verbosity

    Args:
        verbose (bool): if True set verbosity to INFO, else to WARNING
                        (default False)
        quite (bool): if True disable logger "generateAppliDoc"

    Returns: None

    """
    logger.disabled = True if quite else False
    verbosity = logging.INFO if verbose else logging.WARNING
    steam_handler = logging.StreamHandler()
    steam_handler.set_name('console')
    steam_handler.setLevel(verbosity)
    formatter = logging.Formatter("%(levelname)s :: %(message)s")
    steam_handler.setFormatter(formatter)
    logger.addHandler(steam_handler)


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

        with open(os.devnull, 'w') as DEVNULL:
            # NOTE: in python3, DEVNULL is part of the subprocess module
            logger.info('Generates "{}"'.format(htmlfile))
            subprocess.call(command_line, stdout=DEVNULL)

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
    output_file = os.path.join(output_dir, "index.html")
    logger.info('Generates "{}"'.format(output_file))
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

    with open(output_file, 'w') as fout:
        fout.write(dedent(index_content))


def check_number_of_htmlpages(applications, apps_and_groups):
    """ Print list of applications whose htmlpages was not generated.

    Args:
        applications (list): output of get_applications_from_CMakeCache
        apps_and_groups (list): output of associate_group_to_applications

    Returns: None

    """
    expected = set(applications)
    generated = set(zip(*apps_and_groups)[0])
    not_generated = expected - generated

    if not_generated:
        sorted_not_generated = sorted(not_generated)
        formated = '\n\t-'.join(sorted_not_generated)
        logger.warning("Following applications documentations haven't been "
                       "generated:\n\t-{}".format(formated))


class ManpageGenerator(object):
    """ Generates manpage

    Initialize with the directory where to save the manpage and the name of the
    application to document.

    The `text` method generates and return the raw manpage's text. It generally
    does not need to be called. Use the `write` method to save the manpage to a
    gzip file in the output directory.

    Example:
    -------
        To save the manpage of the application named `my_app` in `output/path`
        directory under the name `otbcli_myapp.1.gz`:
        >>> gen = ManpageGenerator('output/path/', 'my_app')
        >>> gen.write()

    """

    def __init__(self, output_dir, application_name):
        """
        Args:
            output_dir (str): directory where manpage is saved
            application_name (str): name of the application

        Returns: None

        """
        self.output_dir = output_dir
        self.application_name = application_name
        self.exec_name = '_'.join(('otbcli', application_name))
        self.basename = '.'.join((self.exec_name, '1', 'gz'))
        self.filename = os.path.join(output_dir, self.basename)
        self.version = "5.0"  # TODO: find it somehow in the code
        self.application = otb_create_application(application_name)

    def _format(self, string):
        """ Replace some caraters to be well processed by troff

         - escape hypens
         - replace line breaks by a macro
        """
        return string.replace('-', '\-').replace("\n", "\n.br\n")

    @property
    def _header_section(self):
        """ Return manpage's header """
        header = '.TH "{}" "1" "{}" "Version {}" "{} manual"'
        return header.format(self.application_name.upper(),
                             datetime.date.today(), self.version,
                             self.application_name)

    @property
    def _name_section(self):
        return '.SH "NAME"\n{} \- {}'.format(self.application_name,
                                             self.application.GetDescription())

    @property
    def _mandatory_parameters(self):
        return (p for p in self.application.GetParametersKeys()
                if self.application.IsMandatory(p))

    @property
    def _nonmandatory_parameters(self):
        return (p for p in self.application.GetParametersKeys()
                if not self.application.IsMandatory(p))

    @property
    def _synopsis(self):
        """ Return the synopsis """

        def arg(option):
            return PARAMETERS_TYPES[self.application.GetParameterType(option)]

        mandatories = ('.B \-{}\n.I "{}"'.format(p, arg(p).lower())
                       for p in self._mandatory_parameters)

        nonmandatory_parameters = itertools.ifilter(
            lambda a: a not in ('inxml', 'outxml'),
            self._nonmandatory_parameters)

        nonmandatories = ('.RB [\| \-{}\n.IR "{}" \|]'.format(p, arg(p).lower())
                          for p in nonmandatory_parameters)

        xml = dedent("""\
        .P
        .B {} \-inxml
        .I "{}"
        .RB [\| \-outxml
        .IR "{}" \|]""".format(self.exec_name, arg('inxml'), arg('outxml')))

        options = "\n".join(itertools.chain(mandatories, nonmandatories))

        begining = '.SH "SYNOPSIS"\n.B {}'.format(self.exec_name)

        return "\n".join((begining, options, xml))

    @property
    def _description_section(self):
        description = self._format(self.application.GetDocLongDescription())
        return '.SH "DESCRIPTION"\n{}'.format(description)

    def _option_entry(self, option):
        """ Return option entry """
        param_type = PARAMETERS_TYPES[self.application.GetParameterType(option)]
        if param_type == "Choices":
            value = r"\fR\||\|\fP".join(self.application.GetChoiceKeys(option))
        else:
            value = param_type

        description = self._format(
            self.application.GetParameterDescription(option))

        return '.BI \-{}\  "{}"\n{}'.format(option, value, description)

    @property
    def _options_section(self):
        entries = "\n.TP\n".join(self._option_entry(p)
                                 for p in self.application.GetParametersKeys())
        return "\n".join(('.SH "OPTIONS"', ".TP", entries))

    @property
    def _bugs_section(self):
        bugs = self.application.GetDocLimitations()
        if bugs:
            section = '.SH "BUGS"\n{}'.format(bugs)
        else:
            section = r'.\" NO LIMITATIONS'
        return section

    @property
    def _examples_section(self):
        example = self._format(self.application.GetCLExample())
        return '.SH "EXAMPLES"\n{}'.format(example)

    @property
    def _author_section(self):
        authors = self._format(self.application.GetDocAuthors())
        return '.SH "AUTHOR"\n{}'.format(authors)

    @property
    def text(self):
        """ Manpage text """
        return "\n\n".join((self._header_section, self._name_section,
                            self._synopsis, self._description_section,
                            self._options_section, self._bugs_section,
                            self._examples_section, self._author_section))

    def write(self):
        """ Write manpage text to a gzip compressed file """
        with gzip.open(self.filename, 'w') as f:
            f.write(self.text)


if __name__ == "__main__":
    from argparse import ArgumentParser
    parser = ArgumentParser(description="Documentation generator script",
                            epilog=__doc__)
    parser.add_argument("otb_bin_path", help="Path to the otb binary directory")
    parser.add_argument("output_path", help="Path to the output directory")
    parser.add_argument("-v", "--verbose", help="Increase output verbosity",
                        action="store_true")
    parser.add_argument("-q", "--quite", help="No output (even warning)",
                        action="store_true")

    args = parser.parse_args()

    main(args.otb_bin_path, args.output_path, args.verbose, args.quite)
