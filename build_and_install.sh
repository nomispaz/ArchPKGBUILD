#!/bin/bash
#########################################################################################
# USAGE											#
#											#
# parameters 	s: set source Directory for cloning, rebasing and building		#
#		d: set Directory where Packages are stored after building		#
#		g: if set, build git packages in addition to all other packages		#
#		a: set archive Directory for Backups					#
#		t: directory to temporarily store git clones				#
#########################################################################################

#colorcoding
RED='\033[0;31m'
YELLOW='\033[1;33m'
LBLUE='\033[1;34m'
NOCOLOR='\033[0m'

date=$(date '+%Y-%m-%d')

#default parameters
sourceDir=/data/local_repo/source/
destDir=/data/local_repo/packages/
archiveDir=/data/local_repo/archive/
tempDir=/data/local_repo/temp/
buildGit=0

# read parameters
while getopts "s:d:a:i" flag
do
	case "${flag}" in
        	s) sourceDir=${OPTARG};;
		d) destDir=${OPTARG};;
		a) archiveDir=${OPTARG};;
		t) archiveDir=${OPTARG};;
        	g) buildGit=1;;
    	esac
done

export PKGDEST="$destDir"

#Cleaning temp dir and clone repos
echo -e "\n${LBLUE}Delete old temp files${NOCOLOR}"
for f in $tempDir/*
do
	currentDir=$(basename "$f")
    	echo -e "${YELLOW}$currentDir${NOCOLOR}"
  	# if f is a directory, continue
	if [ -d "$f" ]; then
		sudo rm -r $f
	fi
done

#Cleaning source dir
echo -e "\n${LBLUE}Cleanup old buildfiles${NOCOLOR}"
for f in $sourceDir/*
do
	currentDir=$(basename "$f")
	echo -e "${YELLOW}$currentDir${NOCOLOR}"
  	# if f is a directory, continue
	if [ -d "$f" ]; then
		pushd $f > /dev/null
		sudo rm -r pkg
		sudo rm -r src
		sudo rm *.rpm
		sudo rm *.zst
		sudo rm *.gz
		popd > /dev/null
	fi
done

echo -e "${LBLUE}Cloning Git-Repos${NOCOLOR}"
echo -e "\n${YELLOW}tuxedo-control-center-bin${NOCOLOR}"
git clone https://aur.archlinux.org/tuxedo-control-center-bin.git $tempDir/tuxedo-control-center-bin
echo -e "\n${YELLOW}tuxedo-keyboard-dkms${NOCOLOR}"
git clone https://aur.archlinux.org/tuxedo-keyboard-dkms.git $tempDir/tuxedo-keyboard-dkms
echo -e "\n${YELLOW}tuxedo-keyboard-ite-dkms${NOCOLOR}"
git clone https://aur.archlinux.org/tuxedo-keyboard-ite-dkms.git $tempDir/tuxedo-keyboard-ite-dkms
echo -e "\n${YELLOW}waybar${NOCOLOR}"
git clone https://gitlab.archlinux.org/archlinux/packaging/packages/waybar $tempDir/waybar
echo -e "\n${YELLOW}hyprland${NOCOLOR}"
git clone https://gitlab.archlinux.org/archlinux/packaging/packages/hyprland $tempDir/hyprland

echo -e "${LBLUE}done${NOCOLOR}\n"


#check for updates, backup, diff and build (only non-git packages)
for f in $sourceDir/*
do
currentDir=$(basename "$f")
if ! [[ "$currentDir" == *"-git" ]]; then

	# if f is a directory, continue
	if [ -d "$f" ]; then
		pushd $f > /dev/null
		ver_local=$(source PKGBUILD; echo "$pkgver-$pkgrel")
		ver_upstream=$(source $tempDir/$currentDir/PKGBUILD; echo "$pkgver-$pkgrel")
		
		#only continue if versions are different
		if ! [ "$ver_local" == "$ver_upstream" ]
		then
			#create backup of last buildfiles
			echo -e "${LBLUE}Creating backup of last buildfiles in $archiveDir/$currentDir${NOCOLOR}\n"
			mkdir -p $archiveDir/$date/$currentDir
			
			for file in $f/*
			do
				currentFile=$(basename "$file")
				echo -e "${YELLOW}$currentDir/$currentFile${NOCOLOR}"
				if ! [ -d "$file" ]
				then
					cp $file $archiveDir/$date/$currentDir/
					#start meld to diff old and new buildfile and change old file
					meld $file $tempDir/$currentDir/$currentFile
					
				fi
			done

			continue="c"
			echo -n "Continue (c), Abort (a): "
            read continue

			#not aborted --> build package
			if ! [[ "$continue" == "a" || "$continue" == "A" ]]
            then
				echo -e "${LBLUE}building new version${NOCOLOR}\n"
				makepkg -sr
				package=$(ls $destDir/$currentDir*.zst)
				repo-add $destDir/custom.db.tar.gz $destDir/
				echo -e "done\n"
			fi
		fi
	popd > /dev/null
	fi
fi
done

#Cleaning source dir
echo -e "\n${LBLUE}Cleanup old buildfiles${NOCOLOR}"
for f in $sourceDir/*
do
	currentDir=$(basename "$f")
	echo -e "${YELLOW}$currentDir${NOCOLOR}"
  	# if f is a directory, continue
	if [ -d "$f" ]; then
		pushd $f > /dev/null
		sudo rm -r pkg
		sudo rm -r src
		sudo rm *.rpm
		sudo rm *.zst
		sudo rm *.gz
		popd > /dev/null
	fi
done
