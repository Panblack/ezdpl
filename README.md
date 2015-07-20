# ezdpl
=====
Easy deployment of linux server apps.

Use simple ssh and shell scripts to deploy, upgrade, rollback, reconfigure linux servers.

#Important!
   Warning: This project is still being tested. Read README carefully and try it at your own risk.

   Best practice: Allways make your own modifications according to your production environment, and do test it before deploying it.

#Manual:

##ezdpl design

###Why ezdpl?
   It is popular to use puppet or some other tools to automate system configuration jobs. Working with puppet is convenient, efficient and predictable. Most of the jobs are reduced to writing puppet scripts and puppet will do the rest automatically. It makes it easy to manage hundreds of servers.

   Someone's just not into it. Maybe there are not so many servers to manage. Maybe it's a burden to learn another "system" to manage the systems at hand. Well, those are apt to my case. What's more, I'd prefer to do the job in the "raw and simple" way. No agents, no plugins, no modules, no playbooks. I must know exactly how the server is configured and how the configuration files are written, always. What can I do to some other servers when there is no puppet available? That's not comforting.

   But automated management IS neccessary. How do we manage many servers without puppet or some other tools?  Yes, the shell scripts will do. All we need is an operation server, which stores the initializing or upgrading scripts, configuration files, and apps to be deployed or upgraded. Everything are in their original form. The operation server has the trusted ssh access to the target servers with root priviledges in order to do the jobs automatically, with only one script. 

   "Wait a minute, man. Ansible does it. You're rebuilding the wheel, unwisely." You laughed. 

   Yes, I am rebuilding the wheel, a much more simple one, for fun. And I don't worry about losing the ultimate power of command line and shell scripts. That's comforting. :)

###Do things in a raw and simple way.
Ezdpl is very very simple, it does the job with:
  * Well organized directories and files
  * scp ( like 'scp -r SomeDir root@TargetServer:/ ')
  * ssh ( like 'ssh root@TargetServer Some Command ')

###The basic directory infrastructure has 3 levels: 
Level0: ezdpl files<br>
Level1: apps<br>
Level2: versions<br>
Any modifications/updates to the servers will be configured in a new directory in versions level.<br>
If rollback is required, just use the previous version as an argument of the main script.

###Provisioning of apps dir


###Senario:
All servers(operation server,target servers) are installed Centos6 x86_64.<br>
Target servers are configured only IP addresses and hostnames.<br>
The operation server need to have the trusted ssh access to all target servers. If not, you will have to enter password each time you run the main script. <br>
The operation server's ssh key is better to be protected by a passphrase.<br>
All the apps are to be deployed in /opt .<br>

###Directory infrastructure:
```
Directory Level 0,1
ezdpl		
├── apps			[Level 0]
│   ├── common	[Level 1, app common: not really an app, but configs & scripts for all servers.]
│   ├── web_a		[Level 1, tomcat webapp a, requires one or more servers.]
│   ├── web_b		[Level 1, tomcat webapp b, requires one or more servers.]
│   └── java_c	[Level 1, java app c, requires 3 servers, each needs some extra ifcfg-eth0* configuration files.]
├── ezdpl.sh		[Level 0, main script]
└── README		[Level 0, no comment ;)]


Directory Level 2
common/					
├── 20150720			[Level 2, version 20150720(now empty)]
└── current			[Level 2, current version]
    ├── etc				
    │   ├── cron.daily
    │   │   └── ntp_client.sh
    │   └── sysconfig
    │       ├── iptables
    │       └── static-routes
    ├── runme.sh		[init script]
    └── tmp			[individual packages to be installed]
        └── jdk-7u75-linux-x64.rpm

web_a/
├── 20150406					[Level 2, version 20150406]
│   └── opt
│       └── tomcat-web_a
│           └── webapps		[tomcat webapps]
└── current					[Level 2, current version]
    ├── etc
    │   └── logrotate.d
    │       └── web_a
    ├── opt
    │   ├── logs
    │   │   └── web_a		[log position for web_a(configured in tomcat-web_a/conf/logging.properties]
    │   └── tomcat-web_a
    │       ├── bin
    │       ├── conf
    │       ├── lib
    │       ├── LICENSE
    │       ├── NOTICE
    │       ├── RELEASE-NOTES
    │       ├── RUNNING.txt
    │       ├── temp
    │       ├── webapps
    │       └── work
    └── root
        └── bin	[scripts for web_a]
            ├── showlog
            ├── shutdown_web_a
            └── start_web_a

web_b/
(ommited)

java_c/
├── current
│   ├── etc
│   │   └── logrotate.d
│   │       └── java_c
│   ├── home
│   │   └── operuser		[java_c requires a none root user]
│   │       └── bin		[scripts for java_c]
│   │           ├── showlog
│   │           ├── shutdown_java_c
│   │           └── start_java_c
│   ├── opt
│   │   ├── logs
│   │   │   └── java_c
│   │   └── java_c
│   │       ├── conf
│   │       ├── lib
│   │       ├── output
│   │       └── java_c.jar
│   └── runme.sh
├── java_c1
│   ├── etc
│   │   └── sysconfig
│   │       └── network-scripts	[ip config files for java_c1]
│   └── runme.sh		
├── java_c2
│   ├── etc
│   │   └── sysconfig
│   │       └── network-scripts
│   └── runme.sh
└── java_c3
    ├── etc
    │   └── sysconfig
    │       └── network-scripts
    └── runme.sh
```

####The main script, ezdpl.sh, does the following:
  * Copies the dedicated files(./apps/app_name/version) to the target server
  * Runs an initial script, if any, remotedly on the target server.
  * Target server user name can be specified, default is root.
  * Reboot the target server as you command, default is not to reboot.

