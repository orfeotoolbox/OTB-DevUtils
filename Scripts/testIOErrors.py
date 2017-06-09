#!/usr/bin/env python3

import subprocess
import sys

def run_otb(cmd, prefix):
    cmd = prefix + ";" + cmd

    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    outs, errs = p.communicate()

    return outs.decode("utf-8")

def run_py(pycmd, prefix):
    title, params = pycmd

    code = "import otbApplication\n"
    code += "app = otbApplication.Registry.CreateApplication('{}')\n".format(title)

    for key, value in params.items():
        if key == "IL" or key == "LIST":
            code += "app.SetParameterStringList('{}', {})\n".format(key.lower(), repr(value))
        else:
            code += "app.{} = {}\n".format(key, repr(value))

    code += "app.ExecuteAndWriteOutput()\n"

    cmd = prefix + "; python -c '{}'".format(code.replace("'", "\""))

    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    outs, errs = p.communicate()

    return code, outs.decode("utf-8")

def indent(string):
    if string == "":
        return "    [no output]"

    if string.endswith("\n"):
        # Dont indent the terminating endline
        string = string[:-1]
    else:
        raise ValueError("expecting end line terminated string")

    lines = string.split("\n")
    return "\n".join(["    " + l for l in lines])

all_entries = [

("IO Errors", [

    ("Input file does not exist (Convert)",
     "otbcli_Convert -in blabla.tif -out /tmp/out.tif",
     ("Convert", {"IN": "blabla.tif",
                 "OUT": "/tmp/out.tif"})),

    ("Input file does not exist (ReadImageInfo)",
     "otbcli_ReadImageInfo -in blabla.tif",
     ("ReadImageInfo", {"IN": "blabla.tif"})),

    ("Input file does not exist, with extended filename (Convert)",
     "otbcli_Convert -in 'blabla.tif&bands=1' -out /tmp/out.tif",
     ("Convert", {"IN": "blabla.tif&bands=1",
                  "OUT": "/tmp/out.tif"})),

    ("One of the input files does not exist",
     "otbcli_BandMath -il data/QB_1_ortho.tif blabla.tif -out /tmp/out.tif -exp '1'",
     ("BandMath", {"IL": ["data/QB_1_ortho.tif", "blabla.tif"],
                   "OUT": "/tmp/out.tif"})),

    ("Unsupported input format",
     "otbcli_Convert -in data/svm_model.svm -out /tmp/out.tif",
     ("Convert", {"IN": "data/svm_model.svm",
                   "OUT": "/tmp/out.tif"})),

    ("Unsupported output format",
     "otbcli_Convert -in data/QB_1_ortho.tif -out /tmp/out.blabla",
     ("Convert", {"IN": "data/QB_1_ortho.tif",
                 "OUT": "/tmp/out.blabla"})),

    ("Invalid input image (Convert)",
     "otbcli_Convert -in data/notActuallyTif.tif -out /tmp/out.tif",
     ("Convert", {"IN": "data/notActually.tif",
                 "OUT": "/tmp/out.tif"})),

    ("Permission denied (input)",
     "otbcli_Convert -in noReadPermission.png -out /tmp/out.tif",
     ("Convert", {"IN": "noReadPermission.png",
                 "OUT": "/tmp/out.tif"})),

    ("Permission denied (output)",
     "otbcli_Convert -in data/QB_1_ortho.tif -out /root/out.tif -progress false",
     ("Convert", {"IN": "data/QB_1_ortho.tif",
                 "OUT": "/root/out.tif"})),

    ("Trying to open a directory",
     "otbcli_Convert -in data/DEM_srtm -out /tmp/out.tif",
     ("Convert", {"IN": "data/DEM_srtm",
                 "OUT": "/tmp/out.tif"})),

]),
("Parameter errors", [

    ("Too many dashes",
     "otbcli_BandMath --il -out /tmp/out.tif -exp '1'"),

    ("Repeated parameter",
     "otbcli_Convert -in data/QB_1_ortho.tif -in data/QB_1_ortho.tif -out /tmp/out.tif -progress false"),

    ("No parameter",
     "otbcli_Convert"),

    ("Non existing parameter",
     "otbcli_Convert -hello world",
     ("Convert", {"HELLO": "WORLD"})),

    ("Missing parameter (output)",
     "otbcli_Convert -in data/QB_1_ortho.tif",
     ("Convert", {"IN": "data/QB_1_ortho.tif"})),

    ("Missing parameter (input)",
     "otbcli_Convert -out /tmp/out.tif",
     ("Convert", {"OUT": "/tmp/out.tif"})),

    ("Missing parameter value",
     "otbcli_Convert -in -out /tmp/out.tif",
     ("Convert", {"IN": "",
                  "OUT": "/tmp/out.tif"})),

    ("Empty input image list",
     "otbcli_BandMath -il -out /tmp/out.tif -exp '1'",
     ("BandMath", {"IL": [],
                   "OUT": "/tmp/out.tif"})),

    ("Missing input extension (Convert)",
     "otbcli_Convert -in data/QB_1_ortho -out /tmp/out.tif"),

    ("Missing output extension (Convert)",
     "otbcli_Convert -in data/QB_1_ortho.tif -out /tmp/out -progress false"),

    ("Empty output filename",
     "otbcli_BandMath -il data/QB_1_ortho.tif -out -exp '1'"),

    ("Invalid extended filename",
     "otbcli_Convert -in data/'QB_1_ortho.tif?&bla=blabla' -out /tmp/out.tif -progress false"),

    ("Parameter syntax error (forgot '-in')",
     "otbcli_Convert data/QB_1_ortho.tif -out /tmp/out.tif"),

    ("Parameter syntax error (forgot '-out')",
     "otbcli_Convert -in data/QB_1_ortho.tif /tmp/out.tif"),

    ("Progress value error",
     "otbcli_Convert -in data/QB_1_ortho.tif -out /tmp/out.tif -progress false false true"),

    ("Progress value error 2",
     "otbcli_Convert -in data/QB_1_ortho.tif -out /tmp/out.tif -progress blabla"),

    ("Invalid output type",
     "otbcli_Convert -in data/QB_1_ortho.tif -out /tmp/out.tif iunt8 -progress false"),

    # TODO
    #("Invalid output type (complex image)",
    #"otbcli_Convert -in data/QB_1_ortho.tif -out /tmp/out.tif iunt8 -progress false"),

    ("Type given to input image",
     "otbcli_Convert -in data/QB_1_ortho.tif uint8 -out /tmp/out.tif -progress false"),

    ("Too many parameter values (-in)",
     "otbcli_Convert -in data/QB_1_ortho.tif blabla.tif -out /tmp/out.tif -progress false"),

    ("Too many parameter values (-out)",
     "otbcli_Convert -in data/QB_1_ortho.tif -out /tmp/out.tif uint8 float double -progress false"),

]),
("Module path errors", [

    ("otbApplicationLauncherCommandLine without arguments",
     "otbApplicationLauncherCommandLine"),

    ("No module available",
    """OTB_APPLICATION_PATH=""; otbApplicationLauncherCommandLine Convert"""),

    ("Application not available",
    "otbApplicationLauncherCommandLine MakeCoffee"),

    ("Almost nothing (segfault)",
     "otbApplicationLauncherCommandLine ''"),

    ("A bit more than almost nothing",
     "otbApplicationLauncherCommandLine '' /tmp"),

]),
("Application errors", [

    ("RadiometricIndices",
     "otbcli_RadiometricIndices -in data/QB_1_ortho.tif  -out /tmp/out.tif -list blabla",
     ("RadiometricIndices", {"IN": "data/QB_1_ortho.tif",
                             "OUT": "/tmp/out.tif",
                             "LIST": "blabla"})),

    ("PixelValue",
     "otbcli_PixelValue -in ~/cnes/dev/otb-data/Examples/QB_1_ortho.tif -coordx 50 -coordy -6",
     ("PixelValue", {"IN": "/home/poughov/cnes/dev/otb-data/Examples/QB_1_ortho.tif",
                     "COORDX": 50,
                     "COORDY": -6})),

    ("ConcatenateImage",
     "otbcli_ConcatenateImages -il data/QB_1_ortho.tif data/Circle.png -out /tmp/out.tif"),

]),

("Correct parameters", [

    ("ReadImageInfo",
     "otbcli_ReadImageInfo -in data/QB_1_ortho.tif"),

    ("Convert",
     "otbcli_Convert -in data/QB_1_ortho.tif -out /tmp/out.tif -progress false"),

    ("BandMath",
     "otbcli_BandMath -il data/QB_1_ortho.tif -out /tmp/out.tif -exp '1' -progress false",
     ("BandMath", {"IL": ["data/QB_1_ortho.tif"],
                   "OUT": "/tmp/out.tif",
                   "EXP": "1"})),

    ("BandMathX",
     "otbcli_BandMathX -il data/QB_1_ortho.tif -out /tmp/out.tif -exp '1' -progress false"),

    ("Rescale",
     "otbcli_Rescale -in data/QB_1_ortho.tif -out /tmp/out.tif -progress false",
     ("Rescale", {"IN": "data/QB_1_ortho.tif",
                 "OUT": "/tmp/out.tif"})),

    # TODO
    # complex input image
    # complex input image list
    # GDAL derived subdataset
    # and too many parameter values (output complex image)
    # directory image product

]),

]

if __name__ == "__main__":

    mediawiki_template = ("==== {} ====\n"
                          "''$ {}''\n"
                          "{}\n"
                          "\n"
                          '<div class="mw-collapsible mw-collapsed">\n'
                          "''In debug:''\n"
                          '<div class="mw-collapsible-content">\n'
                          "{}\n"
                          "\n"
                          "</div>\n"
                          "</div>\n"
                          '<div class="mw-collapsible mw-collapsed">\n'
                          "''On release-6.0:\n"
                          '<div class="mw-collapsible-content">\n'
                          "{}\n"
                          "</div>\n"
                          "</div>\n"
                          )

    template_python = ('<div class="mw-collapsible mw-collapsed">\n'
                       "''Python API:\n"
                       '<div class="mw-collapsible-content">\n'
                       "Code:\n"
                       "{}\n"
                       "\n"
                       "''Output on better_error_messages branch:''\n"
                       "{}\n"
                       "\n"
                       "''Output on better_error_messages branch (in Debug):''\n"
                       "{}\n"
                       "\n"
                       "''Output on release-6.0:\n"
                       "{}\n"
                       "</div>\n"
                       "</div>\n")

    otb_branch_release = "source ~/cnes/dev/config/env-develop-releasemode.sh"
    otb_branch_debug = "source ~/cnes/dev/config/env-develop.sh"
    otb_develop = "source ~/Téléchargements/OTB-contrib-6.0.0-Linux64/otbenv.profile"

    print("This page is an annex to [[Request_for_Changes-91:_Better_error_messages]]. It contains the full output of the error messages test script.")
    print("")
    print("")
    print("")

    for section_title, section in all_entries:
        print("=== {} ===".format(section_title))

        for entry in section:
            comment, cli = entry[0], entry[1]
            pycmd = entry[2] if len(entry) == 3 else None

            out_branch_release = run_otb(cli, otb_branch_release)
            out_branch_debug = run_otb(cli, otb_branch_debug)
            out_develop = run_otb(cli, otb_develop)

            # Render to mediawiki
            print(mediawiki_template.format(
                comment,
                cli, indent(out_branch_release),
                indent(out_branch_debug),
                indent(out_develop)))

            if pycmd is not None:
                code, out_py_branch_release = run_py(pycmd, otb_branch_release)
                code, out_py_branch_debug = run_py(pycmd, otb_branch_debug)
                code, out_py_develop = run_py(pycmd, otb_develop)

                print(template_python.format(indent(code),
                    indent(out_py_branch_release),
                    indent(out_py_branch_debug),
                    indent(out_py_develop)
                    ))
