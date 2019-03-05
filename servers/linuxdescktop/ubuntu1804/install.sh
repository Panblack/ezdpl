#!/bin/bash
# Initial script for ubuntu 14.04 fresh installation, by panblack@126.com
#
read -p "Your username:" _user_name

echo "Upgrade & install necessary packages"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y -m \
dconf-editor gnome-tweaks ibus-pinyin fcitx-googlepinyin \
leafpad tree p7zip-full p7zip-rar telnet ssh vim nmap lynx iftop iptraf convmv enca sysstat dstat curl xclip \
git meld subversion chromium-browser jq \ 
python-pip wireshark \
smplayer ubuntu-restricted-extras gstreamer-plugins* openshot gimp gthumb graphicsmagick ffmpeg ffmpeg-doc kazam gaupol xchm kolourpaint \
psensor indicator-cpufreq rdesktop virt-manager virt-viewer \
apache2-utils nginx \
openvpn network-manager-openvpn network-manager-openvpn-gnome tigervnc-viewer \
ttf-wqy-microhei

#gnome-tweak-tool unity-tweak-tool sysv-rc-conf \
#libsdl1.2debian libqt4-opengl lua5.2 lua-bitop \
#vlc vlc-* rkhunter docker-io cgroup-bin

#sudo snap install  mdview
sudo pip install --upgrade pip

echo "Make wireshark able to capture packets with non-root user."
sudo chmod u+s /usr/bin/dumpcap
echo

echo "Make virtualbox VM's able to connect USB devices."
sudo usermod -aG vboxusers $_user_name
echo 

echo "Disable dash"
sudo dpkg-reconfigure dash
echo 

echo "Disable Embed preedit text ..."
ibus-setup
echo 

echo "Modify org.gnome.gnome-screenshot"
dconf-editor

cd

# ufw settings
echo "ufw"
sudo ufw enable
sudo ufw default deny
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 1080/tcp
sudo ufw allow 3306/tcp

echo "Check qimpanel"
dpkg --list | grep qimpanel

