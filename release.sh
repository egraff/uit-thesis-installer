#!/bin/bash
set -e

# Note: this script is based on the installer script from msysGit
# (/share/msysGit/net/release.sh)

# Recreate uit-thesis-install.exe

TARGET="$(pwd -L)"/uit-thesis-install.exe
TMPDIR=/tmp/uit-thesis-installer-tmp
OPTS7="-m0=lzma -mx=9 -md=64M"
TMPPACK=/tmp.7z

# Get script dir
cd "$(dirname "${0}")"
SHARE="$(pwd -L)"
cd - > /dev/null

test ! -d "$TMPDIR" || rm -rf "$TMPDIR" || exit
mkdir "$TMPDIR"
cd "$TMPDIR"

(cd .. && test ! -f "$TMPPACK" || rm "$TMPPACK")

echo "Copying files"

cp "$SHARE"/install.bat install.bat

mkdir msys64
pushd msys64

sed 's/\r//g' "$SHARE"/fileList.txt |
	(cd / && tar -c --file=- --files-from=-; echo $? > /tmp/exitstatus) |
	tar xvf - &&
test 0 = "$(cat /tmp/exitstatus)"

sed 's/\r//g' "$SHARE"/fileList-mingw.txt |
	(cd /mingw64 && tar -c --file=- --files-from=-; echo $? > /tmp/exitstatus) |
	tar xvf - &&
test 0 = "$(cat /tmp/exitstatus)"

strip usr/bin/*.exe usr/lib/git-core/*.exe

mkdir -p usr/share
cp -R /usr/share/terminfo ./usr/share/terminfo

mkdir -p usr/ssl
cp -R /usr/ssl/certs ./usr/ssl/certs

mkdir tmp

mkdir etc
cp "$SHARE"/gitconfig etc/
cp /etc/fstab ./etc/fstab
cp /etc/msystem ./etc/msystem
cp /etc/profile ./etc/profile

if test -d /etc/profile.d
then
	cp -R /etc/profile.d ./etc/profile.d
fi

cp "$SHARE"/setup-ult.sh setup-ult.sh

# Pop msys64 dir, to get back to $TMPDIR
popd

echo "Creating archive"

cd ..
/usr/bin/7za a $OPTS7 "$TMPPACK" uit-thesis-installer-tmp
(cat "$SHARE"/7zsd_extra/7zsd_All_x64.sfx &&
 echo ';!@Install@!UTF-8!' &&
 echo 'Title="UiT thesis LaTeX template installation"' &&
 echo 'GUIFlags="8+32+64+256+4096"' &&
 echo 'GUIMode="1"' &&
 echo 'OverwriteMode="2"' &&
 echo 'RunProgram="cmd /c \"%%T\uit-thesis-installer-tmp\install.bat\""' &&
 echo ';!@InstallEnd@!' &&
 cat "$TMPPACK") > "$TARGET"

echo "Success! You'll find the new installer at \"$TARGET\"."
rm $TMPPACK
rm -rf "$TMPDIR"
