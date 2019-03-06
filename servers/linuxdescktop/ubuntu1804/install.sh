#!/bin/bash
# Initial script for ubuntu 14.04 fresh installation, by panblack@126.com
#
read -p "Your username:" _user_name
if [[ -z $_user_name ]]; then 
    exit 
fi

echo "Deb packages need to be installed: mysql-apt-config, virtualbox "
read -p "Path for Deb files: " _deb_files
if [[ -n $_deb_files ]]; then
    cd $_deb_files
    sudo dpkg -i *.deb
fi

echo "Upgrade & install necessary packages"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y -m \
dconf-editor gnome-tweaks ibus-pinyin fcitx-googlepinyin \
leafpad tree p7zip-full p7zip-rar telnet ssh vim nmap lynx iftop iptraf convmv enca sysstat dstat curl xclip \
git meld subversion chromium-browser jq whois calibre python-pip python3-pip wireshark net-tools ansible \
smplayer ubuntu-restricted-extras gstreamer-plugins* openshot gimp gthumb graphicsmagick ffmpeg ffmpeg-doc kazam gaupol xchm kolourpaint \
psensor indicator-cpufreq rdesktop virt-manager virt-viewer \
apache2-utils nginx openvpn network-manager-openvpn network-manager-openvpn-gnome tigervnc-viewer \
fonts-wqy-microhei mysql-workbench-community 

#vlc vlc-* rkhunter docker-io cgroup-bin
#sudo snap install  mdview

echo "Upgrade pip, install termtosvg"
sudo pip2 install --upgrade pip
sudo pip3 install --upgrade pip
sudo pip3 install termtosvg 

echo "Make wireshark able to capture packets with non-root user."
sudo chmod u+s /usr/bin/dumpcap
echo

echo "Make virtualbox VM's able to connect USB devices."
sudo usermod -aG vboxusers $_user_name
echo 

echo "Disable dash"
sudo dpkg-reconfigure dash
echo 

echo "Disable 'Embed preedit text'"
ibus-setup
echo 

echo "Configure fcitx"
fcitx-config-gtk3
echo 

echo "Check qimpanel"
dpkg --list | grep qimpanel

#echo "Modify org.gnome.gnome-screenshot"
#dconf-editor

# ufw settings
echo "ufw"
sudo ufw enable
sudo ufw default deny
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 1080/tcp
sudo ufw allow 3306/tcp

echo "Finished."
cd

