#!/usr/bin/env python3

import subprocess
import sys

def run_otb(cmd, prefix):
    cmd = prefix + ";" + cmd

    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    outs, errs = p.communicate()

    return outs.decode("utf-8")

def run_py(pycmd, prefix, pythonbin):
    title, params = pycmd

    code = "import otbApplication\n"
    code += "app = otbApplication.Registry.CreateApplication('{}')\n".format(title)

    for key, value in params.items():
        if key == "IL" or key == "LIST":
            code += "app.SetParameterStringList('{}', {})\n".format(key.lower(), repr(value))
        else:
            code += "app.{} = {}\n".format(key, repr(value))

    code += "app.ExecuteAndWriteOutput()\n"

    cmd = prefix + "; {} -c '{}'".format(pythonbin, code.replace("'", "\""))

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

    ("Input file does not exist (DynamicConvert)",
     "otbcli_DynamicConvert -in blabla.tif -out /tmp/out.tif",
     ("DynamicConvert", {"IN": "blabla.tif",
                 "OUT": "/tmp/out.tif"})),

    ("Input file does not exist (ReadImageInfo)",
     "otbcli_ReadImageInfo -in blabla.tif",
     ("ReadImageInfo", {"IN": "blabla.tif"})),

    ("Input file does not exist, with extended filename (DynamicConvert)",
     "otbcli_DynamicConvert -in 'blabla.tif&bands=1' -out /tmp/out.tif",
     ("DynamicConvert", {"IN": "blabla.tif&bands=1",
                  "OUT": "/tmp/out.tif"})),

    ("One of the input files does not exist",
     "otbcli_BandMath -il data/QB_1_ortho.tif blabla.tif -out /tmp/out.tif -exp '1'",
     ("BandMath", {"IL": ["data/QB_1_ortho.tif", "blabla.tif"],
                   "OUT": "/tmp/out.tif"})),

    ("Unsupported input format",
     "otbcli_DynamicConvert -in data/svm_model.svm -out /tmp/out.tif",
     ("DynamicConvert", {"IN": "data/svm_model.svm",
                   "OUT": "/tmp/out.tif"})),

    ("Unsupported output format",
     "otbcli_DynamicConvert -in data/QB_1_ortho.tif -out /tmp/out.blabla",
     ("DynamicConvert", {"IN": "data/QB_1_ortho.tif",
                 "OUT": "/tmp/out.blabla"})),

    ("Invalid input image (DynamicConvert)",
     "otbcli_DynamicConvert -in data/notActuallyTif.tif -out /tmp/out.tif",
     ("DynamicConvert", {"IN": "data/notActually.tif",
                 "OUT": "/tmp/out.tif"})),

    ("Permission denied (input)",
     "otbcli_DynamicConvert -in noReadPermission.png -out /tmp/out.tif",
     ("DynamicConvert", {"IN": "noReadPermission.png",
                 "OUT": "/tmp/out.tif"})),

    ("Permission denied (output)",
     "otbcli_DynamicConvert -in data/QB_1_ortho.tif -out /root/out.tif -progress false",
     ("DynamicConvert", {"IN": "data/QB_1_ortho.tif",
                 "OUT": "/root/out.tif"})),

    ("Trying to open a directory",
     "otbcli_DynamicConvert -in data/DEM_srtm -out /tmp/out.tif",
     ("DynamicConvert", {"IN": "data/DEM_srtm",
                 "OUT": "/tmp/out.tif"})),

]),
("Parameter errors", [

    ("Too many dashes",
     "otbcli_BandMath --il -out /tmp/out.tif -exp '1'"),

    ("Repeated parameter",
     "otbcli_DynamicConvert -in data/QB_1_ortho.tif -in data/QB_1_ortho.tif -out /tmp/out.tif -progress false"),

    ("No parameter",
     "otbcli_DynamicConvert"),

    ("Non existing parameter",
     "otbcli_DynamicConvert -hello world",
     ("DynamicConvert", {"HELLO": "WORLD"})),

    ("Missing parameter (output)",
     "otbcli_DynamicConvert -in data/QB_1_ortho.tif",
     ("DynamicConvert", {"IN": "data/QB_1_ortho.tif"})),

    ("Missing parameter (input)",
     "otbcli_DynamicConvert -out /tmp/out.tif",
     ("DynamicConvert", {"OUT": "/tmp/out.tif"})),

    ("Missing parameter value",
     "otbcli_DynamicConvert -in -out /tmp/out.tif",
     ("DynamicConvert", {"IN": "",
                  "OUT": "/tmp/out.tif"})),

    ("Empty input image list",
     "otbcli_BandMath -il -out /tmp/out.tif -exp '1'",
     ("BandMath", {"IL": [],
                   "OUT": "/tmp/out.tif"})),

    ("Missing input extension (DynamicConvert)",
     "otbcli_DynamicConvert -in data/QB_1_ortho -out /tmp/out.tif"),

    ("Missing output extension (DynamicConvert)",
     "otbcli_DynamicConvert -in data/QB_1_ortho.tif -out /tmp/out -progress false"),

    ("Empty output filename",
     "otbcli_BandMath -il data/QB_1_ortho.tif -out -exp '1'"),

    ("Invalid extended filename",
     "otbcli_DynamicConvert -in data/'QB_1_ortho.tif?&bla=blabla' -out /tmp/out.tif -progress false"),

    ("Parameter syntax error (forgot '-in')",
     "otbcli_DynamicConvert data/QB_1_ortho.tif -out /tmp/out.tif"),

    ("Parameter syntax error (forgot '-out')",
     "otbcli_DynamicConvert -in data/QB_1_ortho.tif /tmp/out.tif"),

    ("Progress value error",
     "otbcli_DynamicConvert -in data/QB_1_ortho.tif -out /tmp/out.tif -progress false false true"),

    ("Progress value error 2",
     "otbcli_DynamicConvert -in data/QB_1_ortho.tif -out /tmp/out.tif -progress blabla"),

    ("Invalid output type",
     "otbcli_DynamicConvert -in data/QB_1_ortho.tif -out /tmp/out.tif iunt8 -progress false"),

    # TODO
    #("Invalid output type (complex image)",
    #"otbcli_DynamicConvert -in ata/QB_1_ortho.tif -out /tmp/out.tif iunt8 -progress false"),

    ("Type given to input image",
     "otbcli_DynamicConvert -in data/QB_1_ortho.tif uint8 -out /tmp/out.tif -progress false"),

    ("Too many parameter values (-in)",
     "otbcli_DynamicConvert -in data/QB_1_ortho.tif blabla.tif -out /tmp/out.tif -progress false"),

    ("Too many parameter values (-out)",
     "otbcli_DynamicConvert -in data/QB_1_ortho.tif -out /tmp/out.tif uint8 float double -progress false"),

]),
("Module path errors", [

    ("otbApplicationLauncherCommandLine without arguments",
     "otbApplicationLauncherCommandLine"),

    ("No module available",
    """OTB_APPLICATION_PATH=""; otbApplicationLauncherCommandLine DynamicConvert"""),

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

    ("DynamicConvert",
     "otbcli_DynamicConvert -in data/QB_1_ortho.tif -out /tmp/out.tif -progress false"),

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

    mediawiki_template = open("/home/poughov/cnes/dev/otb-devutils/Scripts/testIOErrors_template.md").read()
    template_python = open("/home/poughov/cnes/dev/otb-devutils/Scripts/testIOErrors_template_py.md").read()

    otb_branch_release = ". ~/cnes/dev/config/env-develop.sh"
    #otb_branch_debug = "source ~/cnes/dev/config/env-develop.sh"
    otb_master = ". ~/Downloads/OTB-6.6.1-Linux64/otbenv.profile"

    for section_title, section in all_entries:
        print("## ".format(section_title))

        for entry in section:
            comment, cli = entry[0], entry[1]
            pycmd = entry[2] if len(entry) == 3 else None

            out_branch_release = run_otb(cli, otb_branch_release)
            #out_branch_debug = run_otb(cli, otb_branch_debug)
            out_master = run_otb(cli, otb_master)

            # Render to mediawiki
            print(mediawiki_template.format(
                comment,
                cli, out_branch_release,
                "",#out_branch_debug,
                out_master))

            if pycmd is not None:
                code, out_py_branch_release = run_py(pycmd, otb_branch_release, "python3")
                #code, out_py_branch_debug = run_py(pycmd, otb_branch_debug)
                code, out_py_master = run_py(pycmd, otb_master, "python2")

                print(template_python.format(code,
                    out_py_branch_release,
                    " ",# out_py_branch_debug,
                    out_py_master
                    ))
