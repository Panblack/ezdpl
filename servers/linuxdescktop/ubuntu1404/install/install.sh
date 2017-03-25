#!/bin/bash
# Initial script for ubuntu 14.04 fresh installation, by panblack@126.com
_pwd=`pwd`
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y gnome-tweak-tool unity-tweak-tool sysv-rc-conf dconf-editor \
leafpad tree p7zip-full p7zip-rar telnet bash ssh vim nmap lynx iftop iptraf convmv sysstat dstat curl httping xclip \
smplayer vlc vlc-* gstreamer1.0-plugins* openshot gimp gthumb graphicsmagick kazam gaupol ttf-wqy-microhei \
git meld subversion \
psensor indicator-cpufreq \
rdesktop virt-manager virt-viewer wireshark lua5.2 lua-bitop \
chromium-browser libqt4-opengl \
docker.io apache2 php5 apache2-utils python-pip \
openvpn network-manager-openvpn network-manager-openvpn-gnome 

# python pip & tools
sudo pip install --upgrade pip
sudo pip install memcached-cli
sudo pip install httpie

# app dir
sudo mkdir -p /home/app/iso/packages
sudo chown -R panblack:panblack /home/app

# node.js , whistle
#sudo curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
#sudo apt-get install node
#sudo npm install cnpm -g --registry=https://registry.npm.taobao.org
#sudo cnpm install -g whistle
echo "nodejs & wps,virtualbox (2017-03)"
cd /home/app/iso/packages
wget https://atom-installer.github.com/v1.15.0/atom-amd64.deb?s=1489019656&ext=.deb
wget https://nodejs.org/dist/v6.10.0/node-v6.10.0-linux-x64.tar.xz
wget http://kdl.cc.ksosoft.com/wps-community/download/a21/wps-office_10.1.0.5672~a21_amd64.deb
wget http://download.virtualbox.org/virtualbox/5.1.16/virtualbox-5.1_5.1.16-113841~Ubuntu~trusty_amd64.deb
wget http://download.virtualbox.org/virtualbox/5.1.16/Oracle_VM_VirtualBox_Extension_Pack-5.1.16-113841.vbox-extpack

cd /home/app
tar Jxvf /home/app/iso/packages/node-v6.10.0-linux-x64.tar.xz && ln -sf /home/app/node-v6.10.0-linux-x64 /home/app/node


echo "Local Configuration"
cd $_pwd
/bin/cp ./packages/*.deb /home/app/iso/packages/ 2>/dev/null

echo "Modifying ~/.bashrc"
/bin/cp ~/.bashrc ~/.bashrc.bak.`date +%F_%H%M`
sed -i /'alias ll'/d ~/.bashrc
sed -i 's/]:/] \\t /g' ~/.bashrc
sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/g' ~/.bashrc
/bin/cp vimrc ~/.vimrc

echo "Modifying /etc/skel/.bashrc"
sudo /bin/cp /etc/skel/.bashrc /etc/skel/.bashrc.bak.`date +%F_%H%M`
sudo sed -i /alias ll/d /etc/skel/.bashrc
sudo sed -i 's/]:/] \\t /g' /etc/skel/.bashrc
sudo sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/g' /etc/skel/.bashrc

echo "zz_custom_env.sh to /etc/profile.d/"
sudo /bin/cp zz_custom_env.sh /etc/profile.d/
source /etc/profile

# ufw settings
echo "ufw"
sudo ufw enable
sudo ufw default deny
sudo ufw allow 80/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 1080/tcp
sudo ufw allow 3306/tcp
sudo ufw allow 443/tcp
sudo ufw allow 10001/tcp
sudo ufw allow 10002/tcp
sudo ufw allow 8686/tcp

echo "Blocking wo.com.cn"
sudo sed -i "/End required lines/r blocking.wo.com.cn" /etc/ufw/before.rules

echo "Installing node packages"
sudo npm install -g whistle
sudo npm install -g anyproxy

# Install deb packages
cd /home/app/iso/packages/
for x in *.deb; do sudo dpkg -i $x; done

echo "Disable dash"
sudo dpkg-reconfigure dash

echo "Make wireshark able to capture packets with non-root user."
sudo chmod u+s /usr/bin/dumpcap

echo "Make virtualbox VM's able to connect USB devices."
sudo usermod -aG vboxusers ezdpl

echo "Disable Embed preedit text ..."
ibus-setup

echo "Modify org.gnome.gnome-screenshot"
dconf-editor

# Theme tweak
echo "vim /usr/share/themes/Ambiance/gtk-3.0/gtk-widgets.css"
echo ":1212	background-color: shade (@selected_bg_color, 1.02);"

cd

exit 0



#Ubuntu14.04 Post Install

# shadowsocks
# sudo add-apt-repository ppa:hzwhuang/ss-qt5
# sudo apt-get update
# sudo apt-get install shadowsocks-qt5

# suspended packages
# calibre sound-juicer isomaster fcitx-googlepinyin 
# discontinued packages
# chmsee gnome-subtitles(replaced with Gaupol)
