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
