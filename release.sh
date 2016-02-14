#!/bin/sh

# Note: this script is based on the installer script from msysGit
# (/share/msysGit/net/release.sh)

# Recreate uit-thesis-install.exe

TARGET="$(pwd -L)"/uit-thesis-install.exe
TMPDIR=/tmp/ultinstaller-tmp
OPTS7="-m0=lzma -mx=9 -md=64M"
TMPPACK=/tmp.7z

# Get script dir
cd "$(dirname "${0}")"
SHARE="$(pwd -L)"
cd - > /dev/null

test ! -d "$TMPDIR" || rm -rf "$TMPDIR" || exit
mkdir "$TMPDIR" &&
cd "$TMPDIR" &&
(cd .. && test ! -f "$TMPPACK" || rm "$TMPPACK") &&
echo "Copying files" &&
sed 's/\r//g' "$SHARE"/fileList.txt |
	(cd / && tar -c --file=- --files-from=-; echo $? > /tmp/exitstatus) |
	tar xvf - &&
test 0 = "$(cat /tmp/exitstatus)" &&
sed 's/\r//g' "$SHARE"/fileList-mingw.txt |
	(cd /mingw && tar -c --file=- --files-from=-;
	 echo $? > /tmp/exitstatus) |
	tar xvf - &&
test 0 = "$(cat /tmp/exitstatus)" &&
strip bin/*.exe libexec/git-core/*.exe &&
mkdir etc &&
cp "$SHARE"/gitconfig etc/ &&
if test -d /etc/profile.d
then
	cp -R /etc/profile.d ./
fi &&
cp "$SHARE"/setup-ult.sh setup-ult.sh &&
echo "Creating archive" &&
cd .. &&
/share/7-Zip/7za.exe a $OPTS7 "$TMPPACK" ultinstaller-tmp &&
(cat /share/7-Zip/7zSD.sfx &&
 echo ';!@Install@!UTF-8!' &&
 echo 'Title="UiT thesis LaTeX template installation"' &&
 echo 'GUIFlags="8+32+64+256+4096"' &&
 echo 'GUIMode="1"' &&
 echo 'OverwriteMode="2"' &&
 echo 'RunProgram="\"%%T\ultinstaller-tmp\bin\sh.exe\" /setup-ult.sh"' &&
 echo ';!@InstallEnd@!' &&
 cat "$TMPPACK") > "$TARGET" &&
echo "Success! You'll find the new installer at \"$TARGET\"." &&
rm $TMPPACK
