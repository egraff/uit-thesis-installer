#!/bin/sh

# Note: this script is based on the setup script from msysGit
# (/share/msysGit/net/setup-msysgit.sh)

export PATH="/usr/local/bin:/usr/bin:/bin:/opt/bin:$PATH"

error () {
    echo "* error: $*"
    echo INSTALLATION ABORTED
    read -e IGNORED_INPUT
    trap - exit
    exit 1
}

echo
echo -------------------------------------------------------
echo Fetching the latest UiT thesis LaTeX template revision
echo -------------------------------------------------------
ULT_REPO_HTTP=https://github.com/egraff/uit-thesis.git

git config --system http.sslCAinfo /usr/ssl/certs/ca-bundle.crt

git init &&
git config core.autocrlf true &&
git config remote.origin.url $ULT_REPO_HTTP &&
git config remote.origin.fetch \
	+refs/heads/master:refs/remotes/origin/master &&
git config branch.master.remote origin &&
git config branch.master.merge refs/heads/master &&

git fetch --depth=1 || {
		echo -n "Please enter a HTTP proxy: " &&
		read proxy &&
		test ! -z "$proxy" &&
		export http_proxy="$proxy" &&
		export https_proxy="$proxy" &&
		git fetch
} ||
error "Could not get uit-thesis.git"

git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'

echo
echo -------------------------------------------------------
echo Checking out the uit-thesis master branch
echo -------------------------------------------------------
git checkout -l -f -q -b master origin/master ||
	error Couldn\'t checkout the master branch!

git submodule sync
git submodule init
git submodule update --init --recursive

echo
echo
echo -------------------------------------------------------
echo Installing UiT thesis LaTeX template
echo -------------------------------------------------------
make install CONTINUE=y

echo
echo
echo -------------------------------------------------------
echo Updating LaTeX database
echo -------------------------------------------------------
cmd.exe /c texhash
