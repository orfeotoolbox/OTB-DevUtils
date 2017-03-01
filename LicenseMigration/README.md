# License migration

## Summary

The Orfeo Toolbox steering committee decided to abandon the strong copyleft
license ([CeCILL v2.0](http://cecill.info/licences/Licence_CeCILL_V2-en.html))
under which OTB have been released up to now in favour of a permissive license
([Apache v2.0](http://apache.org/licenses/LICENSE-2.0.html)).

Details and rationale are available in the
"[Request for Changes-84: Change license to Apache v2.0](https://wiki.orfeo-toolbox.org/index.php/Request_for_Changes-84:_Change_license_to_Apache_v2.0)".

This directory contains all the scripts and resources required to automate the
license migration process.

## Operational mode

Choose a working directory in which two repositories will be cloned:

* the first (`otb-devutils`) by you,
* the second (`otb`) by the migration script.

Let's say that this working directory is symbolised by `&lt;working dir&gt;`.
The commands that must be run are:

    $ cd <working dir>
    $ git clone https://git@git.orfeo-toolbox.org/git/otb-devutils.git
    $ cd otb-devutils/LicenseMigration/
    $ ./migrate.sh <working dir>

For instance, if the selected working directory is `~/tmp`, the above commands
become:

    $ cd ~/tmp
    $ git clone https://git@git.orfeo-toolbox.org/git/otb-devutils.git
    $ cd otb-devutils/LicenseMigration/
    $ ./migrate.sh ~/tmp

The script creates a local feature branch named `apache-license-migration` and
makes various adjustements inside the files and in the source tree, among
which headers and files substitutions, to implement the license migration.
Every stage in the migration process is concluded by a thematic commit but,
deliberately, the feature branch is not pushed in the public repository at the
end of the script. Like this, this migration process can be reviewed, adjusted
and played again as many times as required.
