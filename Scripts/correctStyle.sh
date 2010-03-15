#! /bin/sh
# Usage: correcStyle.sh OTB-source
#
# Will:
# 1. Clone the OTB-source
# 2. Set up the user as OTB bot
# 3. Apply the correction
# 4. Push back to OTB-source
# 5. Delete the clone

TMP_DIR=/tmp
CLONE_NAME=style
SRC_DIR=$1

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required, $# provided"

if [ -e $SRC_DIR ]
then
   echo "Working on "$SRC_DIR
else
   die $SRC_DIR " does not exist"
   exit 1
fi

echo "Cloning "$SRC_DIR" to "$TMP_DIR" as "$CLONE_NAME
cd $TMP_DIR
hg clone $SRC_DIR $CLONE_NAME
cd $CLONE_NAME

echo "Set up bot user"
echo "[ui]" >> .hg/hgrc
echo "username = OTB Bot <bot@orfeo-toolbox.org>" >> .hg/hgrc

echo "Apply corrections"
#remove execution rights
chmod -R -x+X *
#no space before the semicolon
find  ./Code/  -name "*.h" -o -name "*.cxx" -o -name "*.txx" | xargs grep -l " ;" | xargs sed -i 's/ ;/;/g'
find  ./Examples/  -name "*.h" -o -name "*.cxx" -o -name "*.txx" | xargs grep -l " ;" | xargs sed -i 's/ ;/;/g'
find ./Testing/ -name "*.cxx" -a -not -path "*/Utilities/*"  | xargs grep -l " ;" | xargs sed -i 's/ ;/;/g'
#replace tabulation by space
find  ./Code/  -name "*.h" -o -name "*.cxx" -o -name "*.txx" | xargs sed -i 's/\t/  /g'
find  ./Examples/  -name "*.h" -o -name "*.cxx" -o -name "*.txx" | xargs sed -i 's/\t/  /g'
find ./Testing/ -name "*.cxx" -a -not -path "*/Utilities/*"  | xargs sed -i 's/\t/  /g'
#no empty lines around the code in the software guide
grep -lR 'BeginCodeSnippet' Examples/* | xargs perl -p0777i -e 's/Software Guide : BeginCodeSnippet\n\n/Software Guide : BeginCodeSnippet\n/mg'
grep -lR 'EndCodeSnippet' Examples/* | xargs perl -p0777i -e 's/\n\n  \/\/ Software Guide : EndCodeSnippet/\n  \/\/ Software Guide : EndCodeSnippet/mg'
grep -lR 'EndCodeSnippet' Examples/* | xargs perl -p0777i -e 's/\n\n\/\/ Software Guide : EndCodeSnippet/\n\/\/ Software Guide : EndCodeSnippet/mg'
#no more than 2 empty lines
find  ./Code/  -name "*.h" -o -name "*.cxx" -o -name "*.txx" | xargs xargs perl -p0777i -e 's/\n\n\n\n/\n\n\n/mg'
find  ./Examples/  -name "*.h" -o -name "*.cxx" -o -name "*.txx" | xargs xargs perl -p0777i -e 's/\n\n\n\n/\n\n\n/mg'

hg st 
hg commit -m "STYLE"
hg push

cd $TMP_DIR
rm -r $CLONE_NAME

exit 0

