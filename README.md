# ezdpl
=====

# Version 3.0
## 中文文档
Mar 9,2018

https://github.com/Panblack/ezdpl/blob/master/doc_cn/README_CN.md

## Almost there
Finally, the scripts in `bin/` are almost ready. Whiles `servers/*` are not.
And detailed documentation is comming soon...

Mar 1, 2018


## How version 3.0 started
Version 2.0 worked pretty well on my first project, a comparatively large system. Scripts grew in tremendous scale, of course, only some of them were shared in this repo. 

When the second project came, I found that I had to make lots of modifications to the scripts. Server and application info started to be stored in simple text files, instead of MySql server, for the data was hard to modify and I was lazy enough to write a data management application. 

The second project went smooth after those modifications. But real nightmare came with the third project last year. I had many new ideas for  ezdpl, especially on java web and static html deployment. I would like to upgrade the previous two projects and syncronize this repo at the same time. It was hard. The hardest part was that modifications to the scripts were still required when ezdpl was deployed to a new project. It could hardly be called 'ez' any more. 

So, the version 3.0 is targeted to one major improvement --- to be configuration oriented. When deployed to a new operating project, I don't have to modify the scripts. I just modify the configurations files. 

Another improvement is the new way of application deployment. Java web applications are deployed via tomcat context xml files( e.g.  ${catalina.base}/conf/Catalina/localhost/YourApplication.xml ). War files are built on the operating server and stored in a nfs share, each version in a new directory. When you need to update an application, rewrite the context xml file. If a rollback is needed, just rewrite the context xml file again. 

Version 3.0 is still on the way. The whole infrastructure needs to be rebuilt. Previous versions were writen, while this version needs to be designed.

BTW, LwMon was moved here. 

Feb 1, 2018

# Version 2.0

* Server info stored in MySQL
* More operations are done by scripts
* Add some everyday tools scritps, like java web auto deployment tool
* Add sample web application config files 

Mar 24, 2017 

#Version 1.2

* Add logging feature.
* Use server.list and batch.sh for multiple servers.
* Add some app/version samples.

Dec 23, 2015

#Version 1.1

* Merged ezdpl.sh and ezdpl_auto.sh, added a parameter before ip_address to make it run in silent mode.
* Support server sshd port other than 22.
* Auto deploy multipule servers with scripts like auto.sh .

##Important!
Warning: This project is not 'Out of the box'. 

Always make your own changes, and use with EXTREME CAUTION.

Oct 22 2015


#Version 1.0
Easy deployment of linux server apps.

Use simple ssh and shell scripts to deploy, upgrade, rollback and reconfigure linux servers.

##Important!
   Warning: This project is still being tested. Read README carefully and try it at your own risk.

   Best practice: Allways make your own modifications according to your production environment, and do test it before deploying it.

##Manual:

###ezdpl design

####Why ezdpl?
   It is popular to use puppet or some other tools to automate system configuration jobs. Working with puppet is convenient, efficient and predictable. Most of the jobs are reduced to writing puppet scripts and puppet will do the rest automatically. It makes it easy to manage hundreds of servers.

   Someone's just not into it. Maybe there are not so many servers to manage. Maybe it's a burden to learn another "system" to manage the systems at hand. Well, those are apt to my case. What's more, I'd prefer to do the job in the "raw and simple" way. No agents, no plugins, no modules, no playbooks. I must know exactly how the server is configured and how the configuration files are written, always. What can I do to some other servers when there is no puppet available? That's not comforting.

   But automated management IS neccessary. How do we manage many servers without puppet or some other tools?  Yes, the shell scripts will do. All we need is an operation server, which stores the initializing or upgrading scripts, configuration files, and apps to be deployed or upgraded. Everything are in their original form. The operation server has the trusted ssh access to the target servers with root priviledges in order to do the jobs automatically, with only one script. 

   "Wait a minute, man. Ansible does it. You're rebuilding the wheel, unwisely." You laughed. 

   Yes, I am rebuilding the wheel, a much more simple one, for fun. And I don't worry about losing the ultimate power of command line and shell scripts. That's comforting. :)

####Do things in a raw and simple way.
Ezdpl is very very simple, it does the job with:
  * Well organized directories and files
  * scp ( like 'scp -r SomeDir root@TargetServer:/ ')
  * ssh ( like 'ssh root@TargetServer Some Command ')

####The basic directory infrastructure has 3 levels: 
Level0: ezdpl files<br>
Level1: apps<br>
Level2: versions<br>
Any modifications/updates to the servers will be configured in a new directory in versions level.<br>
If rollback is required, just use the previous version as an argument of the main script.

####Senario:
  * All servers(operation server,target servers) are installed Centos6 x86_64.<br>
  * Target servers are configured only IP addresses and hostnames.<br>
  * The operation server need to have the trusted ssh access to all target servers. If not, you will have to enter password each time you run the main script. <br>
  * ezdpl is deployed at /home/ezdpl on operation server<br>
  * The operation server's ssh key is better to be protected by a passphrase.<br>
  * All the apps are to be deployed in /opt .<br>

####Provisioning the apps dir
You can build the files in ./apps/SomeApps from scratch or copy them from a running production server. Commands below  may be helpful.
```
[root@java_c-server /] mkdir -p /tmp/java_c
[root@java_c-server /] /bin/cp -r --parents /etc/logrotate.d/java_c /tmp/java_c
[root@java_c-server /] /bin/cp -r --parents /home/operuser/bin /tmp/java_c
[root@java_c-server /] /bin/cp -r --parents /opt/java_c /tmp/java_c
[root@java_c-server /] find /opt/logs/ -type d -exec mkdir -p /tmp/java_c/{} \;
[root@java_c-server /] scp -r /tmp/java_c/* root@operation-server:/home/ezdpl/apps/java_c/current/
```

####Directory infrastructure:
```
Directory Level 0,1
ezdpl		
├── apps			[Level 0]
│   ├── common	[Level 1, app common: not really an app, but configs & scripts for all servers.]
│   ├── web_a		[Level 1, tomcat webapp a, requires one or more servers.]
│   ├── web_b		[Level 1, tomcat webapp b, requires one or more servers.]
│   └── java_c	[Level 1, java app c, requires 3 servers, each needs some extra ifcfg-eth0* configuration files.]
├── ezdpl.sh		[Level 0, main script]
├── ezdpl_auto.sh	[Level 0, main script, silent mode]
└── README		[Level 0, no comment ;)]


Directory Level 2
common/
├── 20150720			[Level 2, version 20150720(now empty)]
└── current
    ├── files
    │   ├── etc
    │   │   ├── cron.daily
    │   │   │   └── ntp_sync.sh
    │   │   └── sysconfig
    │   │       ├── iptables
    │   │       └── static-routes
    │   └── tmp			[individual packages to be installed]
    │       └── jdk-7u75-linux-x64.rpm
    ├── finish.sh		[runs after files copied]
    └── prepare.sh		[runs before files copied]

web_a/
├── 20150817			[Level 2, version 20150713 ]
    ├── files
    │   └── opt
    │       └── tomcat6-web_a
    │       	└── webapps	[tomcat webapps]
    └── prepare.sh		[runs before files copied]
            └── bin

....

#####The main script, ezdpl.sh, does the following:
  * Scp prepare.sh to the target server and runs it.
  * Copies the dedicated files(./apps/app_name/version/files) to the target server
  * Scp finish.sh to the target server and runs it.
  * Reboot the target server as you command, default is not to reboot.
  * Target server user name can be specified, default is root.

ezdpl_auto.sh is almost the same as ezdpl.sh, but in silent mode. It is used for batch deployment jobs, like:
web_a_deploy.sh

sh ezdpl_auto.sh 10.1.1.1 web_a/20150817 &
sh ezdpl_auto.sh 10.1.1.2 web_a/20150817 &
sh ezdpl_auto.sh 10.1.1.3 web_a/20150817 &
sh ezdpl_auto.sh 10.1.1.4 web_a/20150817 &
