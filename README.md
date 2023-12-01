Skript to replicate gentoo portage with arch.
Preparations:

add
[custom]
SigLevel = Optional TrustAll
Server = file:///home/simonheise/customrepo
as top repository to /etc/pacman.conf

skript:
nach initial setup
manuelles Anpassen der PKGBUILDs, dann
git commit -a -m "change PKBGUILD"


mkdir /data/local_repo
mkdir /data/local_repo/packages
mkdir /data/local_repo/source
mkdir /data/local_repo/patches
