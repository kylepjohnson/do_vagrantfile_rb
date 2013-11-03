#!/usr/bin/env bash

#to start new server: vagrant up --provider=digital_ocean
#to run bootstrap.sh: vagrant reload --provision

FILE=".initial_vagrant_setup.lock"
if [ -f $FILE ];
then
    echo "Software already installed."
else
    echo "Installing Radio Buddha's software ..."
    echo "Updating system ..."
    apt-get update
    echo "Upgrading system ..."
    apt-get -y upgrade
    echo "Installing lame, mpd, mpc ncmpcpp, git ..."
    apt-get -y install lame
    apt-get -y install mpd
    apt-get -y install mpc
    apt-get -y install ncmpcpp
    apt-get -y install git
    echo "Writing initial setup lockfile"
    touch $FILE
    echo "Rebooting system ..."
    reboot now
fi

RB_GIT_DIR="radio_buddha_mpd_confs"

if [ -d $RB_GIT_DIR ];
then
    echo "Updating $RB_GIT_DIR"
    cd radio_buddha_mpd_confs
    git pull
    cd ..
else
    echo "Cloning $RB_GIT_DIR"
    git clone https://github.com/kylepjohnson/radio_buddha_mpd_confs.git
fi

echo "Copying playlist and mpd.conf ..."
cp -rf radio_buddha_mpd_confs/playlists/* /var/lib/mpd/playlists
cp -f radio_buddha_mpd_confs/mpd.conf /etc/mpd.conf

#transfer audio ex
#rsync -avz root@192.241.186.239:/var/lib/mpd/music/* /var/lib/mpd/music

echo "Restarting MPD ..."
service mpd restart

echo "Starting playlist ..."
cd /var/lib/mpd/playlists
mpc load master.m3u
mpc repeat on
mpc play
cd /root
