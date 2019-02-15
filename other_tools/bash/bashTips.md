# Bash Tips 


## lsof
```
lsof /path/to/file
lsof -nP -iTCP:2139 -sTCP:ESTABLISHED
lsof -i:2139

```

## tcpkill
`tcpkill -i wlan0 host 192.168.1.214`

## Centos/Windows dual system recovers Windows grub entry
```
yum install epel-release
yum install ntfs-3g
grub2-mkconfig -o /boot/grub2/grub.conf
```

## virt-manager for ubuntu tweak
```
sudo sed -i '/_iter.*Hypervisor default/s/Hypervisor default/none/g' /usr/share/virt-manager/virtManager/addhardware.py
sudo sed -i '/alloc = default_cap/s/alloc = default_cap/alloc = default_alloc/g' /usr/share/virt-manager/virtManager/createvol.py

```

## ffmpeg
```
sudo apt-get install lame

#append audio
ffmpeg -i timenow.wav -i pm.wav -i 6.wav -i point.wav -i end.mp3 -filter_complex '[0:0] [1:0] [2:0] [3:0] [4:0] concat=n=5:v=0:a=1 [a]' -map [a] 1800.mp3

#mix audio 
ffmpeg -i first.mp3 -i second.mp3 -filter_complex amix=inputs=2:duration=first:dropout_transition=2 -f mp3 third.mp3

#extract audio
ffmpeg -i apple.mp4 -f mp3 -vn apple.mp3

#video convert
ffmpeg -i /tmp/test.yuv /tmp/out.avi

#image2video
ffmpeg -f image2 -framerate 12 -i foo-%03d.jpeg -s WxH foo.avi

#and ...
man ffmpeg 
/Examples
```

## when server hangs due to NFS server unavailable: 
```
/etc/fstab
192.168.0.1:/data/share      /mnt       nfs4    defaults,soft,timeo=60,retrans=2,noresvport 0 0 

fuser -vmu /path/to/your/filename
fuser -k -i /path/to/your/filename

umount ... device is busy:
fuser -km /opt/resources
```


## timestamp to datetime
`date --date='@1537929830'`
`date --date '@1543202441.608'`

## 获得ssh-rsa公钥校验和
```
cat .ssh/id_rsa.pub    |
    awk '{ print $2 }' | # Only the actual key data without prefix or comments
    base64 -d          | # decode as base64
    sha256sum          | # SHA256 hash (returns hex)
    awk '{ print $1 }' | # only the hex data
    xxd -r -p          | # hex to bytes
    base64               # encode as base64

Cenots:/var/log/secure , Ubuntu:/var/log/auth.log
Nov 13 15:24:37 ubuntu-pc sshd[27298]: Accepted publickey for root from 127.0.0.1 port 36572 ssh2: RSA SHA256:f+.........95SCs
```


## openssl sign/verify
```
#文件签名和验证
openssl dgst -sign   private.pem -sha1       -out test.pdf_sha1_sign
openssl dgst -verify  public.pem -sha1 -signature test.pdf_sha1_sign test.pdf

openssl dgst -ecdsa-with-SHA1    -out signature.bin      -sign private.pem   test.pdf
openssl dgst -ecdsa-with-SHA1 -verify public.pem    -signature signature.bin test.pdf

#验证server密钥和证书
openssl rsa  -modulus -noout -in www.example.com.key | md5sum
openssl x509 -modulus -noout -in www.example.com.cer | md5sum 

#12位随机密码
openssl rand -base64 12

#转换加密key
openssl rsa -in old_server_key.pem -out new_server_key.pem

```


## UUID
`uuidgen | tr a-z A-Z`

## vertical <-> horizonal
#v2h
`cat white_list.txt | awk '{printf $0" "}';echo`

#h2v
`echo "1.119.184.94 2.119.184.94 3.119.184.94 4.119.184.94" | sed 's/ /\n/g'`

## xclip

`echo "Hello, world. Save this in GNOME Clipboard." | xclip -selection clipboard`

## split

`/usr/bin/split -l line_limit -a 4 --numeric-suffixes=0007 raw_file file_name_prefix`

## Bash History

```
echo 'export HISTTIMEFORMAT="%F %T `whoami` "' >> ~/.bashrc
echo 'history &>> ~/.history.`whoami`.`date +%F_%H%M`.log' >> ~/.bash_logout

Sample:
   42  2017-06-18 15:05:00 root cat ifcfg-br0 
   43  2017-06-18 15:05:04 root cat ifcfg-eth0
   44  2017-06-18 15:05:09 root cat ifcfg-enp2s0 
   45  2017-06-18 15:05:34 root ip a
   46  2017-06-18 15:06:11 root cat /etc/udev/rules.d/70-persistent-ipoib.rules 
   47  2017-06-18 15:06:35 root cd
```

## for: step=3
```
for ((i=0;i<=15;i+=3));do
    echo $i
done

#or
i=0
while [[ $i -le 15 ]]; do
    echo $i
    i=$(($i+3))
done

```


## Centos6 python2.7
```
yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel
wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tar.xz
tar xf Python-2.7.13.tar.xz
cd Python-2.7.13
./configure --prefix=/usr/local
make && make altinstall
`ll /usr/bin/python*`

ln -sf /usr/local/bin/python2.7 /usr/bin/python
rm /usr/local/lib/pythone2.7/site-packages -rf
ln -sf /usr/lib/python2.6/site-packages/ /usr/local/lib/python2.7/site-packages 
sed -i 's#/usr/bin/python#/usr/bin/python2.6#g' /usr/bin/yum
pip install mycli
```


## Centos7 timezone
```
timedatectl list-timezones 	# 列出所有时区
timedatectl set-local-rtc 1 	# 将硬件时钟调整为与本地时钟一致, 0 为设置为 UTC 时间
timedatectl set-timezone Asia/Shanghai # 设置系统时区为上海
```

## Centos6 TimeZone
```
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

## Mount a dir to another dir
```
mount --bind /data/ftpext/frontend/ /home/samba/frontend/
```

## mysql secret file
```
mysql_config_editor set --login-path=client --host=localhost --user=local_user --password
mysql_config_editor set --login-path=remote --host=remote.example.com --user=remote_user --password
```

## Firewall-cmd
```
firewall-cmd --permanent --add-rich-rule="rule family=ipv4 source address=43.229.53.61 reject"
firewall-cmd --permanent --add-rich-rule="rule family=ipv4 source address=172.17.30.59 service name=mysql accept"
firewall-cmd --reload
```

## Show git status with Chinese file names
```
git config --global core.quotepath false
```

## Removing a file added in the most recent unpushed commit
```
git rm --cached giant_file
# Stage our giant file for removal, but leave it on disk

git commit --amend -CHEAD
# Amend the previous commit with your change
# Simply making a new commit will not work, as you need
# to remove the file from the unpushed history as well

git push
# Push our rewritten, smaller commit

```

## Removing sensitive/mistaken files from git commit history
We recommend merging or closing all open pull requests before removing files from your repository.  
```
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch PATH-TO-YOUR-FILE-WITH-SENSITIVE-DATA' --prune-empty --tag-name-filter cat -- --all
git push origin master --force

echo "YOUR-FILE-WITH-SENSITIVE-DATA" >> .gitignore
git add .gitignore
git commit -m "Add YOUR-FILE-WITH-SENSITIVE-DATA to .gitignore"
```

## Remove a commit from remote
```
git reset --hard HEAD~1
git push --force origin master
```

## diff local origin
```
git commit ...
git fetch origin
git diff master origin/master

```

## git commit & tag
```
git rev-parse HEAD
git tag --points-at HEAD
```


## IFS
```
IFS=$' \t\n'
ORGIFS=$IFS
NEWIFS=$'\n'

old solution:
NEWIFS="
"

```

## tail -f highligting rows

`tail -f localhost_access_log.2017-03-30.txt |awk '{if(match($9,404))print "\033[35m"$0"\033[0m"; else print $0}'`

## Internet IP
```
ip a|grep "inet "|egrep -v ' 127.0.0.1| inet 10.| 172.1[6-9]| 172.2[0-9]| 172.3[0-1]| 192.168'|awk '{print $2}'|awk -F/ '{print $1}'
```

## Memory percentage
`free -m | awk '/cache:/ { printf("%d%\n",$3/($3+$4)*100)}'`

## awk column match
```
awk '{if($9==500)print "\033[35m"FILENAME" # "FNR" : \033[0m"$0}' localhost_access_log.2017-03-28.txt
awk '{if (substr($7,1,13)=="/api/valicode") print $1}' access.log | sort -n|uniq -c|sort -nr > apirequestIP.txt
```

## awk sum
`awk '{print $1}' file.txt | awk '{sum+=$1}END{print sum}'`

## awk remove some columns
`awk -F: 'OFS=":"{$NF="";$(NF-1)="";print}' file.txt`

## mysqlbinlog tool
```
mysqlbinlog logbin.000009 > logbin.000009.sql
mysqlbinlog --database=smartdb --start-datetime='2016-09-18 08:00:00' --stop-datetime='2016-09-18 10:00:00' logbin.000022 > smartdb.logbin.000022.

show binary logs; 
flush logs; 
purge binary logs to 'mysql-bin.000xxx'; 

```

## iptables
`iptables -I INPUT 6 -s 1.2.3.4 -j ACCEPT`

## Backup/Restore permissions
```
getfacl dir > permissions.txt
setfacl --restore=permissions.txt
```

## 清空磁盘缓存
```
sync && echo 1 > /proc/sys/vm/drop_caches
```

## rsync 备份 gitbucket
```
rsync -a /home/gituser/.gitbucket -e "ssh -p22" root@1.2.3.4:/data/gitbucket/
rsync -rtzl -n .gitbucket/ --exclude .gitbucket/tmp

git clone ssh://root@1.2.3.4:22/path/to/project.git/
```

## seq
```
seq -f'app%02g' 1 12
app01
app02
app03
app04
app05
app06
app07
app08
app09
app10
app11
app12
```


## cut
```
显示passwd文件第一列
cut -d: -f1 /etc/passwd

获取hostname/domainname
hostname | cut -d. -f1
dygpc15

hostname | cut -d. -f2
localdomain

```

## Text edit:

https://www.cnblogs.com/frydsh/p/3261012.html  

http://www.cnblogs.com/me115/p/3427319.html

### tr
```
#remove \n from lines
cat p_tables.txt | tr -d '\n'

#remove all spaces and tabs
tr -d [:blank:]

#lower to upper
cat anaconda-ks.cfg | tr [a-z] [A-Z]

```

### Bash字符操作
```
#https://www.cnblogs.com/frydsh/p/3261012.html
#从变量str第m个字符之后起，取n个字符 ${str:m:n}, m=0 1 2..
_str="123456789"
_str=${_str:1:2}
echo $_str
23

#计算字符串长度
char="I am a teacher ."
expr length "${char}"
echo ${#char}
echo ${char} | wc -L
echo ${char} | awk '{print length ($0)}'

```

### 按实际数字和K/M/G排序
```
sort,uniq
du -sch /var | sort -h
```

### sed:
```
删除空格和TAB
sed 's/[ \t]//g'

一次做多个替换
sed 's/and/\&/g; s/^I/You/g' ahappychild.txt

删除#开头的行和空行
sed '/^#\|^$/d' apache2.conf

删除指定的行范围
sed -i  'm,n d'  file

在第1行、第3行和第5行、第6行到最后一行 后加入行，内容为‘add one line’
sed '1a\add one line' test.txt
sed '3,5a\add one line' test.txt
sed '6,$a\add one line' test.txt

a 追加内容 sed '/匹配词/a\要加入的内容' example.file（将内容追加到匹配的目标行的下一行位置）
i 插入内容 sed '/匹配词/i\要加入的内容' example.file 将内容插入到匹配的行目标的上一行位置）
示例：
#我要把文件的包含“chengyongxu.com”这个关键词的行前或行后加入一行，内容为“allow chengyongxu.cn”
1	#行前插入
2	sed -i '/allow chengyongxu.com/i\allow chengyongxu.cn' the.conf.file
3	#行后追加
4	sed -i '/allow chengyongxu.com/a\allow chengyongxu.cn' the.conf.file#

# tomcat 配置文件编辑：

sed 's/Define an AJP 1.3 Connector on port 8009 -->//g' conf/server.xml
sed '/port="8009"/a\    -->' conf/server.xml


在hostname 开头的行后追加 echo
sed -i '/^hostname/a\echo' fin.sh

在hostname 开头的行前插入 echo
sed -i '/^hostname/i\echo' fin.sh

匹配five 的行内替换i为I
sed -i '/five/s/i/I/g' test.txt

删除匹配行之后的所有内容
sed -i '/<\/html>/q' login.htm

替换单引号
sed s#\'#\"#g test	最外层使用#分隔，里面使用转义单引号，转义双引号
sed "s/'/\"/g" test	最外层使用双引号，里面使用单引号，转义双引号
sed "s/^/'/g; s/$/',/g" to_be_sql.txt 行首加 ' ,行尾加 ',

添加换行
`sed 's/<\/html><SCRIPT/<\/html>\n<SCRIPT/g'`

remove_utf8_bom
sed -i '1 s/^\xef\xbb\xbf//' 

使用shell变量
sed 's/AB/'$x'/g' sample.txt

---------------------------------------------------
1、删除指定行的上一行
sed -i -e :a -e '$!N;s/.*\n\(.*ServerName abc.com\)/\1/;ta' -e 'P;D' $file
2、删除指定字符串之间的内容
sed -i '/ServerName abc.com/,/\/VirtualHost/d' $file

```

## wget 
```
#Recursivly download webpages, level=1
wget -d -p -r --level=1 URL
wget -c -r -np -k -L -p URL
wget -b --mirror --no-host-directories --no-parent URL 

```

## nc
```
#端口扫描
nc -v -w 1 150.95.132.152 -z 1-9000

#检测TCP/UDP
nc -zv  <HOST> <PORT>
nc -uzv <HOST> <PORT>
```


## lv extend
```
lsblk
fdisk /dev/xvdb
pvcreate /dev/xvdb1
vgextend VolGroup /dev/xvdb1
vgdisplay
lvextend -l +5118 /dev/VolGroup/lv_root -t
lvextend -l +5118 /dev/VolGroup/lv_root
resize2fs /dev/VolGroup/lv_root
xfs_growfs /dev/VolGroup/lv_root 
df -hTP


[root@localhost:/root]# df -hTP
Filesystem                   Type   Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup-lv_root ext4    38G  1.9G   35G   6% /
tmpfs                        tmpfs  1.9G     0  1.9G   0% /dev/shm
/dev/xvda1                   ext4   485M   54M  406M  12% /boot
[root@localhost:/root]# vgdisplay
  --- Volume group ---
  VG Name               VolGroup
  System ID             
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  5
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               39.50 GiB
  PE Size               4.00 MiB
  Total PE              10112
  Alloc PE / Size       10112 / 39.50 GiB
  Free  PE / Size       0 / 0   
  VG UUID               5obsNq-I3pp-P0Ah-ugzD-3N1m-fCwi-CC00Dt
   
[root@localhost:/root]# lsblk
NAME                        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvdb                        202:16   0   20G  0 disk 
└─xvdb1                     202:17   0   20G  0 part 
  └─VolGroup-lv_root (dm-0) 253:0    0 38.5G  0 lvm  /
xvda                        202:0    0   20G  0 disk 
├─xvda1                     202:1    0  500M  0 part /boot
└─xvda2                     202:2    0 19.5G  0 part 
  ├─VolGroup-lv_root (dm-0) 253:0    0 38.5G  0 lvm  /
  └─VolGroup-lv_swap (dm-1) 253:1    0  992M  0 lvm  [SWAP]
[root@localhost:/root]# 

/opt分区扩容
umount /opt
lvremove /dev/VolGroup/lv_opt
vgreduce VolGroup /dev/xvdb
pvremove /dev/xvdb

fdisk /dev/xvdb
pvcreate /dev/xvdb1
vgextend VolGroup /dev/xvdb1
vgdisplay
lvcreate -n lv_opt -l +25599 VolGroup

```

## tcpdump
```
tcpdump tcp dst port 8080 or src port 8080 -nn -c 4000 -X -w 20160427.1445.pcap
tcpdump -i eth0 port 80 -nn -vv -tttt  -w /opt/`date +%F_%H%M%S`.cap 
tcpdump -i eth0 -w lvs.pcap

```


## /proc
```
echo 0 > /proc/sys/kernel/hung_task_timeout_secs
```

## Max open files
```
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=9cfe015aa424b3c003baba3841a60dd9b5ad319b
cat /proc/sys/fs/nr_open
```


## iptraf logging
```
iptraf -i eth0 -B -L /var/log/iptraf/ip_traffic-s-eth0.20161212.log
```

## grep <tab> character
```
grep -P "\t" t.xml
```


## Mysql-ce for ubuntu 
```
/etc/mysql/mysql.conf.d/mysqld.cnf
/etc/mysql/conf.d/mysql.cnf
```

## Term2svg
`pip3 install pyte python-xlib svgwrite termtosvg`

## RabbitMQ 
```
`rabbitmqctl eval 'rabbit_amqqueue:declare({resource, <<"/">>, queue, <<"queue_command">>}, true, false, [], none).' `
`rabbitmqctl eval 'rabbit_exchange:declare({resource, <<"/">>, exchange, <<"amqpExchangeWeb">>}, fanout, true, false, false, []).' `
`rabbitmqctl eval 'rabbit_binding:add({binding, {resource, <<"/">>, exchange, <<"test-topic">>}, <<"*.com.cn">>, {resource, <<"/">>, queue, <<"test-queue">>}, []}).'  `

```

## IP 
` ip a show enp0s25 |grep 'inet '|awk -F'/' '{print $1}'|awk '{print $2}' `

