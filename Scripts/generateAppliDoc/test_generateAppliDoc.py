# encoding: utf-8

import logging
import os

from operator import attrgetter
from collections import namedtuple
from textwrap import dedent

import pytest


@pytest.fixture
def get_value_from_CMakeCache():
    from generateAppliDoc import get_value_from_CMakeCache as fct
    return fct


class Test_get_value_from_CMakeCache:
    def test_file_does_not_exist(self, get_value_from_CMakeCache):
        filename = "does_not_exist_file"
        key = "OTB_APPLICATIONS_NAME_LIST"
        with pytest.raises(IOError):
            get_value_from_CMakeCache(filename, key)

    def test_no_key_corresponding(self, get_value_from_CMakeCache, tmpdir):
        cmakefile = tmpdir.mkdir("sub").join("CMakeCache.txt")
        cmakefile.write('nothing')
        filename = str(cmakefile)
        key = "OTB_APPLICATIONS_NAME_LIST"
        with pytest.raises(KeyError):
            get_value_from_CMakeCache(filename, key)

    def test_key_corresponding(self, get_value_from_CMakeCache, tmpdir):
        key = "OTB_APPLICATIONS_NAME_LIST"
        input_value = ('MultivariateAlterationDetector;'
                       'ComputeOGRLayersFeaturesStatistics')

        cmakefile = tmpdir.mkdir("sub").join("CMakeCache.txt")
        filecontent = dedent("""
                             //comment
                             {}:STRING={}
                             //comment
                             """.format(key, input_value))
        cmakefile.write(filecontent)
        filename = str(cmakefile)
        value = get_value_from_CMakeCache(filename, key)
        assert value == input_value


class Test_get_applications_from_CMakeCache:
    def common(self, monkeypatch, input_applications):
        from generateAppliDoc import get_applications_from_CMakeCache
        monkeypatch.setattr("generateAppliDoc.get_value_from_CMakeCache",
                            lambda filename, key: ";".join(input_applications))

        applications = get_applications_from_CMakeCache("CMakeCache.txt")
        return applications

    def test_TestApplication_not_in_list(self, monkeypatch):
        input_applications = ['a', 'b', 'c']
        applications = self.common(monkeypatch, input_applications)
        assert applications == input_applications

    def test_TestApplication_removed(self, monkeypatch):
        input_applications = ['a', 'b', 'c', "TestApplication"]
        applications = self.common(monkeypatch, input_applications)
        assert "TestApplication" not in applications


@pytest.fixture(params=['no_test_dir', 'test_dir', 'otb_prefix', 'extra_apps'])
# `no_test_dir` : `Apptest` directory does not exist. `App` prefix to group are
#                 ignored.
# `test_dir`    : `Apptest` directory is present in the application directory
#                  and should be ignored for the source file listing.
# `otb_prefix`  : source file is prefixed by `otb` or ignored
# `extra_apps`  : source files whose name is not in the list of applications
#                 should be ignored.
def sources_tree(tmpdir, request):
    apps_dir = tmpdir.ensure_dir('Modules', 'Applications')

    groups = {'Edge': ('CMakeLists.txt', 'otbEdgeExtraction.cxx',),
              'Others': ('CMakeLists.txt', 'otbOther.cxx'),
              'ImageUtils': ('otbCompareImages.cxx', 'otbSplitImage.cxx',
                             'CMakeLists.txt'),
              }

    if request.param == 'test_dir':
        apps_dir.ensure('AppTest', 'app', 'otbMyTest.cxx')
    elif request.param == 'otb_prefix':
        groups['Others'] += ('notprefixed.cxx',)
    elif request.param == 'extra_apps':
        groups['Edge'] += ('otbLineSegmentDetection.cxx',)

    for group, apps in groups.iteritems():
        group_dir = apps_dir.mkdir("App{}".format(group))
        group_dir.ensure('CMakeLists.txt')
        group_dir.ensure('otb-module.cmake')
        group_dir.ensure('test', 'CMakeLists.txt')
        group_dir.ensure('test', 'dummy.cxx')
        for app in apps:
            group_dir.ensure('app', app)

    return tmpdir


@pytest.fixture
def fx_apps(monkeypatch):
    apps = ['SplitImage', 'EdgeExtraction', 'CompareImages', 'Other']
    monkeypatch.setattr("generateAppliDoc.get_applications_from_CMakeCache",
                        lambda filename: apps)
    return apps


def test_associate_group_to_applications(sources_tree, fx_apps):
    from generateAppliDoc import associate_group_to_applications
    output = associate_group_to_applications(sources_tree.strpath, fx_apps)
    AppProp = namedtuple('AppProp', ['name', 'group'])
    expected = [AppProp('SplitImage', 'ImageUtils'),
                AppProp('CompareImages', 'ImageUtils'),
                AppProp('EdgeExtraction', 'Edge'),
                AppProp('Other', 'Others'),
                ]

    assert sorted(output) == sorted(expected)

@pytest.fixture
def fx_htmlpages(tmpdir, monkeypatch):  # TODO: insert mocker fixture
    from generateAppliDoc import generate_html_pages
    monkeypatch.setattr('subprocess.call', lambda *args, **kwargs: None)
    # TODO:
    # replace by:
    # mocked_call = mocker.patch('subprocess.call')

    AppProp = namedtuple('AppProp', ['name', 'group'])

    applications = [AppProp('aa', 'a'),
                    AppProp('cc', 'c'),
                    AppProp('ab', 'b'),
                    AppProp('bc', 'c'),
                    AppProp('cb', 'b'),
                    AppProp('ac', 'c'),
                    AppProp('ba', 'a'),
                    AppProp('bb', 'b'),
                    AppProp('ca', 'a'),
                    ]
    updtated_applications = generate_html_pages(tmpdir.strpath,
                                                tmpdir.join('out').strpath,
                                                applications)
    Output = namedtuple('htmlpages', ['applications', 'updtated_applications',
                                      'tmpdir'])
    return Output(applications, updtated_applications, tmpdir)



class Test_generate_html_pages:
    def test_generate_html_pages(self, fx_htmlpages):
        Expected = namedtuple('AppProp', ['name', 'group', 'htmlfile'])
        expected_apps = [
            Expected('aa', 'a',
                     fx_htmlpages.tmpdir.join('out', 'aa.html').strpath),
            Expected('cc', 'c',
                     fx_htmlpages.tmpdir.join('out', 'cc.html').strpath),
            Expected('ab', 'b',
                     fx_htmlpages.tmpdir.join('out', 'ab.html').strpath),
            Expected('bc', 'c',
                     fx_htmlpages.tmpdir.join('out', 'bc.html').strpath),
            Expected('cb', 'b',
                     fx_htmlpages.tmpdir.join('out', 'cb.html').strpath),
            Expected('ac', 'c',
                     fx_htmlpages.tmpdir.join('out', 'ac.html').strpath),
            Expected('ba', 'a',
                     fx_htmlpages.tmpdir.join('out', 'ba.html').strpath),
            Expected('bb', 'b',
                     fx_htmlpages.tmpdir.join('out', 'bb.html').strpath),
            Expected('ca', 'a',
                     fx_htmlpages.tmpdir.join('out', 'ca.html').strpath),
        ]

        # TODO:
        # I don't know how to test this call without reimplement the function
        # itself into the test: bad design?
        # mocked_call.assert_has_calls()
        assert fx_htmlpages.updtated_applications == expected_apps

    def test_logging(self, fx_htmlpages, caplog):
        htmlfiles = (a.htmlfile for a in fx_htmlpages.updtated_applications)

        # logger = logging.getLogger("generateAppliDoc")
        # logger.addHandler(logging.StreamHandler)
        assert caplog.records()
        for record, htmlfile in zip(caplog.records(), htmlfiles):
            expected_msg = 'Generates "{}"'.format(htmlfile)
            assert record.getMessage() == expected_msg


class Test_generate_html_index:
    def test_generate_html_index(self, tmpdir):
        from generateAppliDoc import generate_html_index
        AppProp = namedtuple('AppProp', ['name', 'group', 'htmlfile'])

        applications = [AppProp('aa', 'a', tmpdir.join('out', 'aa.html').strpath),
                        AppProp('cc', 'c', tmpdir.join('out', 'cc.html').strpath),
                        AppProp('ab', 'b', tmpdir.join('out', 'ab.html').strpath),
                        AppProp('bc', 'c', tmpdir.join('out', 'bc.html').strpath),
                        AppProp('cb', 'b', tmpdir.join('out', 'cb.html').strpath),
                        AppProp('ac', 'c', tmpdir.join('out', 'ac.html').strpath),
                        AppProp('ba', 'a', tmpdir.join('out', 'ba.html').strpath),
                        AppProp('bb', 'b', tmpdir.join('out', 'bb.html').strpath),
                        AppProp('ca', 'a', tmpdir.join('out', 'ca.html').strpath),
                        ]

        generate_html_index(tmpdir.strpath, applications)
        # groups and application names are expected to appear in alphabetic order.
        expected_content = [
            '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//ENhttp://www.w3.org/TR/REC-html40/strict.dtd">\n',
            '<html>\n',
            '\t<head>\n',
            '\t\t<meta name="qrichtext" content="1" />\n',
            '\t\t<style type="text/css">p, li { white-space: pre-wrap; }</style>\n',
            '\t</head>\n',
            '\t<body style=" font-family:\'Sans Serif\'; font-size:9pt; font-weight:400; font-style:normal;">\n',
            '\t\t<h1>The following applications are distributed with OTB.</h1>\n',
            '\t\t\tList of available applications:<br /><br />\n',
            '\t\t\t<h2>a</h2>\n',
            '\t\t\t\t<a href="{}">aa</a><br />\n'.format(tmpdir.join('out', 'aa.html')),
            '\t\t\t\t<a href="{}">ba</a><br />\n'.format(tmpdir.join('out', 'ba.html')),
            '\t\t\t\t<a href="{}">ca</a><br />\n'.format(tmpdir.join('out', 'ca.html')),
            '\t\t\t<h2>b</h2>\n',
            '\t\t\t\t<a href="{}">ab</a><br />\n'.format(tmpdir.join('out', 'ab.html')),
            '\t\t\t\t<a href="{}">bb</a><br />\n'.format(tmpdir.join('out', 'bb.html')),
            '\t\t\t\t<a href="{}">cb</a><br />\n'.format(tmpdir.join('out', 'cb.html')),
            '\t\t\t<h2>c</h2>\n',
            '\t\t\t\t<a href="{}">ac</a><br />\n'.format(tmpdir.join('out', 'ac.html')),
            '\t\t\t\t<a href="{}">bc</a><br />\n'.format(tmpdir.join('out', 'bc.html')),
            '\t\t\t\t<a href="{}">cc</a><br />\n'.format(tmpdir.join('out', 'cc.html')),
            '\t</body>\n',
            '</html>',]

        with open(tmpdir.join('index.html').strpath, 'r') as f:
            content = f.readlines()
        assert content == expected_content

    def test_logging(self, tmpdir, caplog):
        from generateAppliDoc import generate_html_index
        AppProp = namedtuple('AppProp', ['name', 'group', 'htmlfile'])

        applications = [AppProp('aa', 'a', tmpdir.join('out', 'aa.html').strpath),
                        AppProp('cc', 'c', tmpdir.join('out', 'cc.html').strpath),
                        AppProp('ab', 'b', tmpdir.join('out', 'ab.html').strpath),
                        AppProp('bc', 'c', tmpdir.join('out', 'bc.html').strpath),
                        AppProp('cb', 'b', tmpdir.join('out', 'cb.html').strpath),
                        AppProp('ac', 'c', tmpdir.join('out', 'ac.html').strpath),
                        AppProp('ba', 'a', tmpdir.join('out', 'ba.html').strpath),
                        AppProp('bb', 'b', tmpdir.join('out', 'bb.html').strpath),
                        AppProp('ca', 'a', tmpdir.join('out', 'ca.html').strpath),
                        ]

        generate_html_index(tmpdir.strpath, applications)
        expected = 'Generates "{}"'.format(tmpdir.join('index.html').strpath)

        for record in caplog.records():
            assert record.getMessage() == expected


class Test_check_number_of_htmlpages:
    @pytest.mark.parametrize('applications', [pytest.mark.xfail(['aa', 'cc']),
                                              ['aa', 'cc', 'bb', 'dd']],
                             ids=('no_log_expected', 'log_expected'))
    def test_logging(self, applications, caplog):
        from generateAppliDoc import check_number_of_htmlpages
        WithHtml = namedtuple('AppProp', ['name', 'group', 'htmlfile'])

        with_html = [WithHtml('aa', 'a', 'aa.html'),
                     WithHtml('cc', 'c', 'cc.html'),]

        check_number_of_htmlpages(applications, with_html)

        expected_log = ("Following applications documentations haven't been "
                        "generated:\n\t-bb\n\t-dd")

        assert caplog.record_tuples() == [
            ('generateAppliDoc', logging.WARNING, expected_log),]

@pytest.yield_fixture
def setup_logging():
    from generateAppliDoc import setup_logging
    logger = logging.getLogger("generateAppliDoc")
    handlers = logger.handlers[:]
    level = logger.level
    disabled = logger.disabled
    progpagate = logger.propagate
    yield setup_logging
    logger.handlers = handlers
    logger.level = level
    logger.disabled = disabled
    logger.propagate = progpagate


class Test_setup_logging:
    def test_no_option(self, setup_logging, caplog):
        assert setup_logging.func_defaults == (False, False)

    @pytest.mark.parametrize('verbose, quite, level, disabled',
                             [(False, False, logging.WARNING, False),
                              (True, False, logging.INFO, False),
                              (True, True, logging.INFO, True),
                              (False, True, logging.WARNING, True),
                              ],
                             ids=("no_verbose no_quite", "verbose no_quite",
                                  "verbose quite", "no_verbose quite"))
    def test_quite_option(self, verbose, quite, level, disabled, setup_logging,
                          caplog):
        setup_logging(verbose=verbose, quite=quite)
        logger = logging.getLogger("generateAppliDoc")

        assert logger.disabled == disabled
        assert logger.getEffectiveLevel() == logging.DEBUG
        assert len(logger.handlers) == 2

        null_handler, stream_handler = logger.handlers
        assert isinstance(null_handler, logging.NullHandler)
        assert isinstance(stream_handler, logging.StreamHandler)
        assert stream_handler.name == "console"
        assert stream_handler.level == level


@pytest.fixture
def manpage_generator(tmpdir):
    from generateAppliDoc import ManpageGenerator
    generator = ManpageGenerator(tmpdir.strpath, 'my-app')
    generator.version = "5.0"
    return generator


@pytest.fixture
def faketime(monkeypatch):
    import datetime

    class FakeDate(datetime.date):
        @classmethod
        def today(cls):
            return cls(2010, 1, 1)

    monkeypatch.setattr("datetime.date", FakeDate)
    return datetime.date.today()


class TestManpageGenerator:
    def test_init(self, tmpdir):
        from generateAppliDoc import ManpageGenerator
        import otbApplication
        _output_dir = tmpdir
        output_dir = _output_dir.join('man1')
        application_name = 'my-app'
        exec_name = '_'.join(('otbcli', application_name))
        basename = '.'.join((exec_name, '1', 'gz'))
        filename = output_dir.join(basename)
        generator = ManpageGenerator(_output_dir.strpath, application_name)
        # FIXME: returns None if application_name not real otb application
        otb = otbApplication.Registry.CreateApplication(application_name)

        assert generator._output_dir == os.path.normpath(_output_dir.strpath)
        assert generator.output_dir == output_dir
        assert generator.application_name == application_name
        assert generator.exec_name == exec_name
        assert generator.basename == basename
        assert generator.filename == filename
        assert generator.version == "5.0"
        assert generator.application == otb

    @pytest.mark.parametrize("output_dir, expected",
                             [("tmpdir", "tmpdir.join('man1')"),
                              ("tmpdir.ensure_dir('man1')",
                               "tmpdir.join('man1')")],
                             ids=["no man1 subdir", "man1 subdir"])
    def test_setup_output_dir(self, output_dir, expected, tmpdir):
        from generateAppliDoc import ManpageGenerator
        output_dir = eval(output_dir)
        expected = eval(expected)
        application_name = 'my-app'
        generator = ManpageGenerator(output_dir.strpath, application_name)
        generator._output_dir = output_dir.strpath  # Reset value
        generator.setup_output_dir()
        assert expected.check()
        assert generator.output_dir == expected.strpath

    @pytest.mark.parametrize("input_string, expected",
                             [("bla-bla", "bla\-bla"),
                              ("bla\nbla", "bla\n.br\nbla")],
                             ids=["escape hyphen", "line break"])
    def test_format(self, manpage_generator, input_string, expected):
        assert manpage_generator._format(input_string) == expected

    def test_header_section(self, manpage_generator, faketime):
        header = manpage_generator._header_section
        expected = '.TH "MY-APP" "1" "{}" "Version 5.0" "my-app manual"'
        expected = expected.format(faketime)
        assert header == expected

    def test_name_section(self, manpage_generator, monkeypatch):
        class FakeApplication:
            def GetDescription(self):
                return "I do stuff"

        monkeypatch.setattr(manpage_generator, "application",
                            FakeApplication())

        expected = '.SH "NAME"\nmy-app \- I do stuff'
        assert manpage_generator._name_section == expected

    def test_mandatory_nonmandatory_parameters(self, manpage_generator,
                                               monkeypatch):
        class FakeApplication:
            def GetParametersKeys(self):
                return ['a', 'b', 'c', 'd']
            def IsMandatory(self, p):
                return p in ['a', 'c']

        monkeypatch.setattr(manpage_generator, "application",
                            FakeApplication())

        assert tuple(manpage_generator._mandatory_parameters) == ('a', 'c')
        assert tuple(manpage_generator._nonmandatory_parameters) == ('b', 'd')

    def test_description_section(self, manpage_generator, monkeypatch):
        class FakeApplication:
            def GetDocLongDescription(self):
                return "I do very cool stuff"

        monkeypatch.setattr(manpage_generator, "application",
                            FakeApplication())

        expected = '.SH "DESCRIPTION"\nI do very cool stuff'
        assert manpage_generator._description_section == expected

    @pytest.mark.parametrize(
        "param, param_type, choices, description, expected",
        [("p", 0, None, "I am a boolean",
          '.BI \-p\  "Boolean"\nI am a boolean'),
         ("p", 9, ('a', 'b'), "I am a choice",
          '.BI \-p\  "a\\fR\\||\\|\\fPb"\nI am a choice'),
         ("p", 17, ('a', 'b'), "I am a group",
          '.BI \-p\  "Group"\nI am a group'),
         ],
        ids=["normal", "choice", "group"])
    def test_option_entry(self, manpage_generator, param, param_type, choices,
                           description, expected, monkeypatch):
        class FakeApplication:
            def GetParameterType(self, param):
                return param_type

            def GetParameterDescription(self, param):
                return description

            def GetChoiceKeys(self, param):
                return choices

        monkeypatch.setattr(manpage_generator, "application",
                            FakeApplication())

        assert manpage_generator._option_entry(param) == expected

    def test_options_section(self, manpage_generator, monkeypatch):
        class FakeApplication:
            def GetParametersKeys(self):
                return ('a', 'b', 'c')

        monkeypatch.setattr(manpage_generator, "application",
                            FakeApplication())
        monkeypatch.setattr(manpage_generator, "_option_entry",
                            lambda a: a)

        expected = '.SH "OPTIONS"\n.TP\na\n.TP\nb\n.TP\nc'
        assert manpage_generator._options_section == expected

    @pytest.mark.parametrize("GetDocLimitations, expected",
                             [("bla-bla", '.SH "BUGS"\nbla-bla'),
                              (None, r'.\" NO LIMITATIONS'),
                              ('None', r'.\" NO LIMITATIONS')],
                             ids=["limitations", "no limitations (None)",
                                  "no limitations (str)"])
    def test_bug_section(self, manpage_generator, GetDocLimitations, expected,
                         monkeypatch):
        class FakeApplication:
            def GetDocLimitations(self):
                return GetDocLimitations

        monkeypatch.setattr(manpage_generator, "application",
                            FakeApplication())

        assert manpage_generator._bugs_section == expected

    def test_examples_section(self, manpage_generator, monkeypatch):
        class FakeApplication:
            def GetCLExample(self):
                return "This is an example"

        monkeypatch.setattr(manpage_generator, "application",
                            FakeApplication())
        monkeypatch.setattr(manpage_generator, "_format",
                            lambda a: a)

        expected = '.SH "EXAMPLES"\nThis is an example'
        assert manpage_generator._examples_section == expected

    def test_author_section(self, manpage_generator, monkeypatch):

        class FakeApplication:
            def GetDocAuthors(self):
                return "OTB-Team"

        monkeypatch.setattr(manpage_generator, "application",
                            FakeApplication())
        monkeypatch.setattr(manpage_generator, "_format",
                            lambda a: a)

        expected = '.SH "AUTHOR"\nOTB-Team'
        assert manpage_generator._author_section == expected
