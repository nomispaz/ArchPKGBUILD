#!/bin/bash

#delete everything that is not committed in git. Removes all source directories and packages and therefore forces a new build
pushd ~/ArchPKGBUILD
sudo git clean -x -d -f -f

# get newest version of git repo
git pull origin main
popd

#build packages
for f in ~/ArchPKGBUILD/*; do
    # if f is a directory, continue
    if [ -d "$f" ]; then
	pushd $f
	#only build packages
        makepkg -sr
	popd
    fi
done

#install packages
install="sudo pacman -U"
for f in ~/ArchPKGBUILD/*/*tar.zst; do
    install="$install $f"
done
install="$install --needed"
$install

#clear build directories
pushd ~/ArchPKGBUILD
sudo git clean -x -d -f -f
popd
