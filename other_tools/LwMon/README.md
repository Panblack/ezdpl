LwMon
=====

Lightweight Monitor for Linux

Use simple ssh and webpages to monitor multiple Linux servers. Keep it simple, keep it lightweight.

##Platform:

CentOS 6/7

##Manual:

1. Copy mon/ into the directory where you want to put it in, /home/ for example.
2. Make sure apache httpd is installed and starts when system boots.
3. Edit your own server.list file in "ip-address,hostname" format. Make sure the server that runs LwMon can log into the servers in the list without password. Try 'ssh-keygen -t rsa', 'ssh-copy-id root@YourServerIp' .
4. Run install.sh script. 
5. Open the url 'http://YourMonitorSever/lwmon' with you web browser.

Enjoy!


##Credits:

* DokuWiki https://www.dokuwiki.org
* Dong Yu(a colleague of mine)

Started on Nov. 4th, 2014
