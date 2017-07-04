#!/bin/bash
# Initial script for ubuntu 14.04 fresh installation, by panblack@126.com
#
read -p "Your username:" _user_name

echo "Upgrade & install necessary packages"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y -m gnome-tweak-tool unity-tweak-tool sysv-rc-conf dconf-editor \
leafpad tree p7zip-full p7zip-rar telnet ssh vim nmap lynx iftop iptraf convmv enca sysstat dstat curl httping xclip \
git meld subversion chromium-browser libsdl1.2debian libqt4-opengl python-pip wireshark rkhunter \
smplayer vlc vlc-* ubuntu-restricted-extras gstreamer-plugins* openshot gimp gthumb graphicsmagick kazam gaupol ttf-wqy-microhei \
psensor indicator-cpufreq rdesktop virt-manager virt-viewer lua5.2 lua-bitop \
docker.io apache2 php5 apache2-utils cgroup-bin \
openvpn network-manager-openvpn network-manager-openvpn-gnome 
if [[ $? != 0 ]];then
    echo "Exit!"
    exit 100
fi
echo 

_pwd=$(dirname `readlink -f $0`)
echo $_pwd
echo "Local Configuration"
sudo bin/cp -p ./scripts/* /usr/local/bin/ 
/bin/cp -p ./deb/*.deb /home/app/iso/packages/ 
echo 

echo "/etc/bash.bashrc Custom aliases"
sudo /bin/cp /etc/bash.bashrc /etc/bash.bashrc.bak
sudo cat ./bash.bashrc >> /etc/bash.bashrc

echo "Modifying /etc/skel/.bashrc"
sudo /bin/cp -p /etc/skel/.bashrc /etc/skel/.bashrc.bak.`date +%F_%H%M`
sudo sed -i /"alias ll"/d /etc/skel/.bashrc
sudo sed -i 's/]:/] \\t /g' /etc/skel/.bashrc
sudo sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/g' /etc/skel/.bashrc
echo 

echo "vimrc.local"
sudo /bin/cp ./vimrc.local /etc/vim/

echo "zz_custom_env.sh to /etc/profile.d/"
sudo /bin/cp zz_custom_env.sh /etc/profile.d/
source /etc/profile
source /etc/bash.bashrc
source ~/.bashrc
echo 

echo "Theme tweak"
sudo /bin/cp -p /usr/share/themes/Ambiance/gtk-3.0/gtk-widgets.css /usr/share/themes/Ambiance/gtk-3.0/gtk-widgets.css.bak
sudo sed -i '1212s/bg_color,/selected_bg_color,/' /usr/share/themes/Ambiance/gtk-3.0/gtk-widgets.css
#":1212	background-color: shade (@bg_color, 1.02);"

echo "Blocking wo.com.cn"
sudo /bin/cp -p /etc/ufw/before.rules /etc/ufw/before.rules.`date +%F_%H%M`
_IFS=$IFS
IFS=$'\n'
for x in `cat blocking.wo.com.cn`; do
    sudo sed -i /"$x"/d /etc/ufw/before.rules
done
sudo sed -i "/End required lines/r blocking.wo.com.cn" /etc/ufw/before.rules
IFS=$_IFS
echo 

# ufw settings
echo "ufw"
sudo ufw enable
sudo ufw default deny
sudo ufw allow 80/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 1080/tcp
#sudo ufw allow 443/tcp
#sudo ufw allow 3306/tcp
#sudo ufw allow 10001/tcp
#sudo ufw allow 10002/tcp
echo

echo "Modifying ~/.bashrc"
/bin/cp -p ~/.bashrc ~/.bashrc.bak.`date +%F_%H%M`
sed -i /'alias ll'/d ~/.bashrc
sed -i 's/]:/] \\t /g' ~/.bashrc
sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/g' ~/.bashrc
echo 

echo "App dir: /home/app"
sudo mkdir -p /home/app/iso/packages
sudo chown -R $_user_name:$_user_name /home/app

/bin/cp ./Unicode2hanzi.html ~/

# python pip & tools
echo "pip install memcached-cli, httpie"
sudo pip install --upgrade pip
sudo pip install memcached-cli httpie mycli
echo

# node.js , whistle
#sudo curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
#sudo apt-get install node
#npm install cnpm -g --registry=https://registry.npm.taobao.org
#cnpm install -g whistle
echo "nodejs & wps,virtualbox (2017-03)"
cd /home/app/iso/packages
wget -N https://atom-installer.github.com/v1.15.0/atom-amd64.deb
wget -N https://nodejs.org/dist/v6.10.0/node-v6.10.0-linux-x64.tar.xz
wget -N http://kdl.cc.ksosoft.com/wps-community/download/a21/wps-office_10.1.0.5672~a21_amd64.deb
wget -N http://download.virtualbox.org/virtualbox/5.1.16/virtualbox-5.1_5.1.16-113841~Ubuntu~trusty_amd64.deb
wget -N http://download.virtualbox.org/virtualbox/5.1.16/Oracle_VM_VirtualBox_Extension_Pack-5.1.16-113841.vbox-extpack

cd /home/app
tar Jxvf /home/app/iso/packages/node-v6.10.0-linux-x64.tar.xz && ln -sf /home/app/node-v6.10.0-linux-x64 /home/app/node
echo 

echo "Installing node packages"
export PATH=$PATH:/home/app/node/bin/
npm install -g whistle
npm install -g anyproxy
echo 

echo "Installing deb packages"
cd /home/app/iso/packages/
for x in *.deb; do sudo dpkg -i $x; done
echo 

# Update the entire file properties database
rkhunter --propupd

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

# Blocking wo.com.cn 
#for x in `seq 1 9`; do nslookup lndnserror$x.wo.com.cn|grep "Address: "|sort|uniq|sed 's/Address: //g'; done
#for x in `seq 1 9`; do nslookup jldnserror$x.wo.com.cn|grep "Address: "|sort|uniq|sed 's/Address: //g'; done

# atom packages: atom-beautify convert-to-utf8 escape-utils
