#!/bin/bash
#########################################################################################
# USAGE											#
#											#
# parameters 	i: setup (i.e. initial cloning of repos)				#
#		s: set source Directory for cloning, rebasing and building		#
#		d: set Directory where Packages are stored after building		#
#		g: if set, build git packages in addition to all other packages		#
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
init=0
buildGit=0

# read parameters
while getopts "s:d:ig" flag
do
	case "${flag}" in
        	s) sourceDir=${OPTARG};;
		d) destDir=${OPTARG};;
        	i) init=1;;
        	g) buildGit=1;;
    	esac
done

export PKGDEST="$destDir"

#Cleaning source dir and clone repos
if [ "$init" == "1" ]
then
	echo -e "${LBLUE}Initializing sources${NOCOLOR}"
	echo -e "\n${LBLUE}Delete all source files and folders${NOCOLOR}"
	for f in $sourceDir/*
	do
		currentDir=$(basename "$f")
    		echo -e "${YELLOW}$currentDir${NOCOLOR}"
  		# if f is a directory, continue
  		if [ -d "$f" ]; then
    			sudo rm -r $f
  		fi
	done

	echo -e "${LBLUE}Cloning Git-Repos${NOCOLOR}"
	echo -e "\n${YELLOW}tuxedo-control-center-bin${NOCOLOR}"
	git clone https://aur.archlinux.org/tuxedo-control-center-bin.git $sourceDir/tuxedo-control-center-bin
	echo -e "\n${YELLOW}tuxedo-keyboard-dkms${NOCOLOR}"
	git clone https://aur.archlinux.org/tuxedo-keyboard-dkms.git $sourceDir/tuxedo-keyboard-dkms
	echo -e "\n${YELLOW}tuxedo-keyboard-ite-dkms${NOCOLOR}"
	git clone https://aur.archlinux.org/tuxedo-keyboard-ite-dkms.git $sourceDir/tuxedo-keyboard-ite-dkms
	echo -e "\n${YELLOW}waybar${NOCOLOR}"
	git clone https://gitlab.archlinux.org/archlinux/packaging/packages/waybar $sourceDir/waybar
	echo -e "\n${YELLOW}hyprland${NOCOLOR}"
	git clone https://gitlab.archlinux.org/archlinux/packaging/packages/hyprland $sourceDir/hyprland

	#checkout local branch
	for f in $sourceDir/*
        do
                currentDir=$(basename "$f")
                # if f is a directory, continue
                if [ -d "$f" ]; then
                        pushd $f > /dev/null
			git checkout -b local_repo
			popd > /dev/null
                fi
        done

	echo -e "done\n"
fi

#check for updates, diff and build (only non-git packages)
for f in $sourceDir/*
do
currentDir=$(basename "$f")
if ! [[ "$currentDir" == *"-git" ]]; then

	# if f is a directory, continue
	if [ -d "$f" ]; then
		pushd $f > /dev/null
		ver_local=$(source PKGBUILD; echo "$pkgver-$pkgrel")
		#merge upstream with local changes into testing branch
		git checkout -b testing
		#pull from master if exists, otherwise from main
		git pull --rebase origin master || git pull --rebase origin main
		ver_upstream=$(source PKGBUILD; echo "$pkgver-$pkgrel")
		#only continue if versions are different
		if  [ "$ver_local" == "$ver_upstream" ]
		then
			#create and show diff of local_repo and testing
			git diff local_repo..testing
			continue="e"
              		echo -n "Continue (c), Abort (a) or Edit (e): "
              		read continue
			#if not aborted, adopt changes to local branch
        		if ! [[ "$continue" == "a" || "$continue" == "A" ]]
			then
				#switch to local branch
				git checkout local_repo
				#delete testing branch
				git branch -D testing
				#apply changes and commit to local branch
				git pull --rebase origin master || git pull --rebase origin main
			fi
			#if edit was chosen, open PKGBUILD
			if [[ "$continue" == "e" || "$continue" == "E" ]]
			then
				nano PKGBUILD
				continue="c"
                        	echo -n "Continue (c), Abort (a): "
                        	read continue
			fi
			#not aborted --> build package
			if ! [[ "$continue" == "a" || "$continue" == "A" ]]
                        then
				#remove old buildfiles
                		echo -e "\n${LBLUE}removing old buildfiles${NOCOLOR}"
                		sudo rm -r pkg
                		sudo rm -r src
                		sudo rm *.rpm
                		sudo rm *.zst
                		echo -e "${LBLUE}building new version${NOCOLOR}\n"
                		makepkg -sr
                		#repo-add ...
                		echo -e "done\n"
			fi
		fi
		popd > /dev/null
	fi
fi
done

#check for updates, diff and build (only git packages)

if [ "$buildGit" == "1" ]
then
	for f in $sourceDir/*
	do
		currentDir=$(basename "$f")
		if [[ "$currentDir" == *"-git" ]]; then
	
		        # if f is a directory, continue
		        if [ -d "$f" ]; then
		                pushd $f > /dev/null
				#remove old buildfiles
                                echo -e "\n${LBLUE}removing old buildfiles${NOCOLOR}"
                                sudo rm -r pkg
                                sudo rm -r src
                                sudo rm *.rpm
                                sudo rm *.zst
                                echo -e "${LBLUE}building new version${NOCOLOR}\n"
                                makepkg -sr
				package=$(ls $destDir/$currentDir*.zst)
                                #repo-add ...
				repo-add $destDir/custom.db.tar.gz $destDir/
                                echo -e "done\n"
				popd
			fi
		fi
	done
fi


