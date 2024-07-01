#!/bin/bash -e

[[ $USER != root ]] || (echo "Must not be root"; exit 1)

cd $(dirname $0)
HERE=$(pwd)

. ./config.env

echo "=> Installing other debian packages"
sudo apt update
sudo apt install python3-pip redis-server mpv nginx libmpv-dev


echo "=> Installing pip packages"
# IMPORTANT NOTE: The original code installs mpx using the apt package manager but the code uses a python import so I added the python-mpv, this may cause issues later
pip3 install --user --upgrade cherrypy youtube-dl redis pyserial mplayer.py python-mpv


echo "=> Creating systemd services"
mkdir -p $HOME/.config/systemd/user

for x in webserver.service downloader.service player.service button.service nopeserver.service wipe.service wipe.timer
do
	cat $HERE/$x | sed "s|DIR|$HERE|g" >$HOME/.config/systemd/user/$x
done


#echo "=> Setting up nginx web server"
#cat $HERE/nginx-site | sed "s|DIR|$MZ_LOCATION|" | sudo tee /etc/nginx/sites-available/musicazoo > /dev/null
#sudo ln -sf /etc/nginx/sites-available/musicazoo /etc/nginx/sites-enabled/musicazoo


echo "=> Disabling unwanted programs"
killall -q xscreensaver || true
# IMPORTANT NOTE: temporarily removing this line
# sed -i '/xscreensaver/d' $HOME/.config/lxsession/LXDE/autostart


echo "=> Starting systemd services"
sudo systemctl restart redis-server nginx
sudo loginctl enable-linger $USER

systemctl daemon-reload --user
systemctl enable --user webserver downloader player wipe.timer
systemctl restart --user webserver downloader player wipe.timer
if [ "$MZ_BUTTON" == "true" ]
then
	systemctl enable --user button
	systemctl restart --user button
fi
