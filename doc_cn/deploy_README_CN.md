# 服务器配置工具 ezdpl

## web应用构建和发布详解

`buildhtml, dephtml, buildwar, depwar` 这四个脚本用于web应用部署，是ezdpl中最复杂的一部分，所以单独成文。

### 前提假设
- 操作机上的工作用户叫 dpl
- EZDPL_HOME=/home/dpl/myezdpl
- NFS服务器为`192.168.0.1`，输出了 `192.168.0.1:/webShare/read` , `192.168.0.1:/webShare/write` ， `192.168.0.1/appLogs` 三个目录。
- 有两个war包项目，warName=backendapi 和 salesapi
- 有两个静态页项目，htmlName=portal 和 sales
- 个性化配置文件已经按照运维项目要求重新配置

### 基础配置文件
deploy.include ，除了`_DEP_WORK_USER="dpl"`，其他的都是默认配置
```
# depwar.include
# requires EZDPL_HOME env variable
_DEP_WORK_USER="dpl"
...（略）...
```

japp.include , 根据需要修改javaweb运行用户`_WORK_USER`的值，如果决定用root运行则不需要修改，其他变量采用默认值
```
_WORK_USER="root"
...（略）...

```

release.include
- 根据需要修改`_JDK_TYPE`的值，推荐使用默认值为`open`，对应用服务器配置 `websrv/javasrv` 时将下载安装openjdk
- 根据需要修改`_NFS_SERVER_IP`和`_WEBSRV_FSTAB`，本例中不用修改
- 修改`_USE_NFS`的值为1，启用NFS
```
_JDK_TYPE=open

_NFS_SERVER_IP="192.168.0.1"

## websrv/init
_USE_NFS=1
_WEBSRV_FSTAB="
${_NFS_SERVER_IP}:/appLogs/`hostname -s`    /data/logs             nfs4    defaults,soft,timeo=60,retrans=2,noresvport  0 0
${_NFS_SERVER_IP}:/webShare/read  /data/webShare/read    nfs4    defaults,soft,timeo=60,retrans=2,noresvport  0 0
${_NFS_SERVER_IP}:/webShare/write /data/webShare/write   nfs4    defaults,soft,timeo=60,retrans=2,noresvport  0 0
"
```

conf/war.lst，根据需要修改`warName`的配置信息，比如：
- 项目backendapi的`warDeployName`为api，即部署后名称为api.war
- 项目backendapi的`webName`为BackEnd，即应用服务器上的tomcat目录应该为 `/opt/webs/BackEnd`
- 项目backendapi的`configFilesPath`为`src/main/resources`，此为java web项目的默认值
- 项目backendapi的`gitBranch`为master
- 项目backendapi的代码库在 `192.168.0.2`，目录为`/home/dev/.gitbucket/repositories/java/backendapi.git`下，所以`gitRepo`见下文
- 项目backendapi的真正代码目录为backend，构建时不需要运行test

- 项目salesweb的`warDeployName`为ROOT，即部署后名称为ROOT.war
- 项目salesweb的`webName`为Sales，即应用服务器上的tomcat目录应该为 `/opt/webs/Sales`
- 项目salesweb的`configFilesPath`为`WEB-INF/classes`，此为war包默认值
- 项目salesweb没有配置分支和代码库，这样它将使用重写war包的方式构建，它的待发布war包需要复制到操作机的`/opt/wars/todeploy`中，即`/opt/wars/todeploy/salesweb.war`

```
#warName|warDeployName|webName|configFilesPath|gitBranch|gitRepo|codeDir|runTest
backendapi|api|BackEnd|src/main/resources|master|ssh://dev@192.168.0.2:22/home/dev/.gitbucket/repositories/java/backendapi.git|backend|N
salesweb|ROOT|Sales|WEB-INF/classes||||N
```

conf/webservers.lst，根据需要修改`webName`的服务器配置信息，比如：
- backendapi对应的tomcat目录为BackEnd，部署到 web01 和 web02 服务器上，使用xml方式部署，tomcat需要在部署后重启
- salesweb对应的tomcat目录为Sales，部署到 web01 服务器上，与web01的BackEnd端口相区别，使用war方式部署，tomcat在部署后不用重启
```
#webName|serverName|ServerIp|serverUser|serverPort|targetPath|deployMode(war/xml)|needRestart|webPort
BackEnd|web01|192.168.0.11|root|22||xml|Y|8080
BackEnd|web02|192.168.0.12|root|22||xml|Y|8080
Sales|webs01|192.168.0.11|root|22|/opt/webs/sales|war|N|8090
```

conf/html.lst，根据需要修改`htmlName`的配置信息，比如：
- `portal`项目的代码库名字为`portalFront`，分支`deploybranch`，构建后的文件路径为dist，这是典型的node项目
- `sales`项目的代码库名字为`salesFront`，分支为master，无`codeDir`和`builtPath`

```
#htmlName|htmlDevName|gitBranch|gitRepo|codeDir|builtPath
portal|portalFront|deploybranch|ssh://user@server:sshport/path/to/portalFront.git||dist
sales|salesFront|master|ssh://dev@192.168.0.2:22/home/dev/.gitbucket/repositories/html/salesFront.git||
```

conf/htmlserver.lst，根据需要修改`htmlName`的服务器配置信息，比如：
- `portal`项目要部署到 web01 和 web02 服务器上，没有指定`targetPath`，因此使用软链接方式部署，即在`/opt/html`下建立`/data/webShare/html/portal/xxxx`的软链接
- `sales`项目要部署到 web01 服务器，指定了`targetPath`为`/opt/html/sales`，因此部署时将删除应用服务器上的`/opt/html/sales`，重新上传`/data/webShare/html/sales/yyyy`到`/opt/html/sales`
- 端口都是80，因为nginx可以在同一端口下部署不同的站点，这是另一个话题，本文暂不详述
```
#htmlName|serverName|serverIp|serverUser|serverPort|targetPath|htmlPort
portal|web01|192.168.0.11|root|22||80
portal|web02|192.168.0.12|root|22||80
sales|webs01|192.168.0.11|root|22|/opt/html/sales|80
```

`mkhtml.sh`

需要按照 ezdpl 代码中的 conf/mkhtml.sh 范例编写，主要目的是替换html项目中后端的服务器地址，需要熟练掌握sed命令。

### 操作机上的目录和文件
```
# 构建目录
/opt/wars/
├── build   #源码编译目录，war.lst 中的条目指定了git repo时，buildwar将在这里clone代码构建war包。每个warName 需要一个对应的目录
│   ├── backendapi  # backendapi的构建目录
│   └── salesapi    # slaesapi的构建目录
├── cook     #buildwar 将把todeploy下指定的war包复制到这里，并将`conf/_config/`下相应的配置文件注入到war包
└── todeploy #war.lst 中不指定git repo时，buildwar 将到这个目录里查找已有的war包

# 运行目录
/data/webShare/
├── read             #挂载了 192.168.0.1:/webShare/read，读写
│    ├── webapps     #java web 的运行目录
│    │   ├── backendapi  #backendapi的运行目录
│    │   └── salesapi    #slaesapi的运行目录
│    └── html        #静态html 的运行目录
│        ├── portal      #portal的运行目录
│        └── sales       #slaesapi的运行目录
├── write            #挂载了 192.168.0.1:/webShare/write，只读
└── logs             #挂载了 192.168.0.1/appLogs，只读

# war包的生产配置文件
/home/dpl/myezdpl/conf/_config
├── backendapi
│   └── src
│       └── main
│           └── resources
│               ├── application-prod.yml
│               └── application.yml
└── salesapi
    └── WEB-INF
        └── classes
            ├── config.properties
            └── jdbc.properties
```

创建目录的命令参考：
```
#在操作机root用户下执行：
source /home/dpl/myezdpl/conf/deploy.include
mkdir -p $_OPER_PATH $_OPER_PATH/cook $_OPER_PATH/build $_OPER_PATH/todeploy $_OPER_PATH/_config $_OPER_PATH/archive $_OPER_PATH/backup
mkdir -p /opt/wars/build/backendapi /opt/wars/build/salesapi
mkdir -p /data/webShare/read/ /data/webShare/write /data/logs
chown -R dpl:dpl $_OPER_PATH
chown -R dpl:dpl /data/webShare/read/

#编辑/etc/fstab，添加如下内容：
192.168.0.1:/webShare/read   /data/webShare/read   nfs4    defaults,soft,timeo=60,retrans=2,noresvport  0 0
192.168.0.1:/webShare/write  /data/webShare/write  nfs4    ro,soft,timeo=60,retrans=2,noresvport  0 0
192.168.0.1:/appLogs          /data/logs            nfs4    ro,soft,timeo=60,retrans=2,noresvport  0 0

#挂载共享目录：
mount -a -t nfs4

#在/data/webShare/read下创建war包目录
mkdir -p /data/webShare/read/webapps/backendapi
mkdir -p /data/webShare/read/webapps/salesapi
mkdir -p /data/webShare/read/html/portal
mkdir -p /data/webShare/read/html/sales

#在dpl用户下执行：
mkdir -p /home/dpl/myezdpl/conf/_config/backendapi/src/main/resources /home/dpl/myezdpl/conf/_config/salesapi/WEB-INF/classes

#将 backendapi 和 salesapi 的生产配置文件复制到相应的目录
cp application-prod.yml /home/dpl/myezdpl/conf/_config/backendapi/src/main/resources/
cp application.yml /home/dpl/myezdpl/conf/_config/backendapi/src/main/resources/
cp config.properties /home/dpl/myezdpl/conf/_config/salesapi/WEB-INF/classes/
cp jdbc.properties /home/dpl/myezdpl/conf/_config/salesapi/WEB-INF/classes/
```

### 初始化应用服务器
新的服务器初始化过程，比如要初始化 web01 （192.168.0.11），命令如下：

```
cd /home/dpl/myezdpl
./ezdpl 192.168.0.11 common/init
./ezdpl 192.168.0.11 websrv/init
./ezdpl 192.168.0.11 websrv/javasrv
```

> - 注意：初始化过程将删除目的服务器上的相关目录，正在运行的生产服务器 **绝不可以** 重复初始化。
> - 部分应用服务器脚本或文件如果有更新，只能以手工方式上传到生产应用服务器。

### 应用服务器上的脚本文件和目录
#### 应用服务器上的脚本文件
以下脚本在用 ezdpl 配置完 websrv/init 和 websrv/javasrv 后，将位于应用服务器的 `/usr/local/bin/`

配置文件             | 说明
------------------ | -------------------------------
`chg-tmc-port`     | 修改 tomcat 默认端口
`deployWebxml`     | 应用服务器上的java应用部署脚本，初始化服务器(websrv/javasrv)时会上传到目标服务器的`/usr/local/bin/`。当java web项目配置为 xml 方式部署时，`depwar`会在应用服务器上执行此脚本
`japp.include`      | 应用服务器上的java应用管理脚本，`japp`,`tmc` 的共享变量，初始化服务器(websrv/javasrv)时会上传到目标服务器的`/usr/local/bin/`
`japp`              | jar 包运行管理工具
`javamonitor`       | 查看java进程详情
`psj`               | java 进程和监听端口查看脚本
`psn`               | http 服务器进程和监听端口查看脚本
`tmc`               | tomcat 管理脚本
`verWebxml`         | 查看 xml 部署方式下的当前war包版本
`tomcat-*`          | 旧的 tomcat 管理脚本，只能在 tomcat 目录内执行，**已废弃**

#### 应用服务器上的目录
```
/opt/
├── apache-maven-3.5.0
├── backup
├── html
├── javaapp
├── jdk -> ./jdk1.8.0_144
├── jdk1.8.0_144
├── libs
├── logs
├── maven -> ./apache-maven-3.5.0
├── packages
├── wars
│   ├── archive
│   ├── backup
│   ├── build
│   ├── _config
│   ├── cook
│   └── todeploy
└── webs
    └── app-8.0.53
        ├── bin
        ├── conf
        ├── lib
        ├── logs
        ├── temp
        ├── webapps
        └── work

# 运行目录结构同操作机
/data/webShare/
├── read             #挂载了 192.168.0.1:/webShare/read，读写
│    ├── webapps     #java web 的运行目录
│    │   ├── backendapi  #backendapi的运行目录
│    │   └── salesapi    #slaesapi的运行目录
│    └── html        #静态html 的运行目录
│        ├── portal      #portal的运行目录
│        └── sales       #slaesapi的运行目录
├── write            #挂载了 192.168.0.1:/webShare/write，只读
└── logs             #挂载了 192.168.0.1/appLogs，只读
```

我们需要手工修改tomcat目录名和端口，在 web01 上需要两个tomcat，BackEnd 和 Sales，Sales 需要更改端口为8090。命令如下：

> - 注意：如果 japp.include 中 `_WORK_USER`不是 root，则需要切换到相应的用户下进行如下操作。  
> - 在root下切换用户使用 `su - 用户名`

```
cd /opt/webs
cp -rp app-8.0.53 BackEnd
mv app-8.0.53 Sales
cd /opt/webs/BackEnd
chg-tmc-port 8080
cd /opt/webs/Sales
chg-tmc-port 8090
```

修改后的/opt/webs目录
```
/opt/webs
├── BackEnd
│   ├── bin
│   ├── conf
│   │   └── Catalina
│   │       └── localhost
│   ├── lib
│   ├── logs
│   ├── temp
│   ├── webapps
│   └── work
└── Sales
    ├── bin
    ├── conf
    │   └── Catalina
    │       └── localhost
    ├── lib
    ├── logs
    ├── temp
    ├── webapps
    └── work
```

如果此时运行 `tmc` 脚本，输出内容如下：
```
Usage: tmc <base> <oper> [roll output y/n]
<oper> :
up	Start
down	Shutdown
rs	Restart
ps	Show tomcat process & ports & threads.
log	Show catalina.out/catalina.<date>.log
loga	Show access log

Availible bases in /opt/webs:
BackEnd
Sales

```

运行 `tmc BackEnd up` 和 `tmc Sales up`将启动两个tomcat

> 注意：如果当前登录用户不是 japp.include 中 `_WORK_USER`（即root），会得到提示 `please 'su - root'`

```
[root@localhost 21:43:53 ~]# tmc BackEnd up

CATALINA_HOME=/opt/webs/BackEnd -> /opt/webs/BackEnd
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
Using CATALINA_BASE:   /opt/webs/BackEnd
Using CATALINA_HOME:   /opt/webs/BackEnd
Using CATALINA_TMPDIR: /opt/webs/BackEnd/temp
Using JRE_HOME:        /opt/jdk/jre
Using CLASSPATH:       /opt/webs/BackEnd/bin/bootstrap.jar:/opt/webs/BackEnd/bin/tomcat-juli.jar
Tomcat started.
root      7308  0.0  0.3 2221056 12268 pts/0   Sl+  21:43   0:00 /opt/jdk/jre/bin/java
 -Dcatalina.base=/opt/webs/BackEnd
 -Dcatalina.home=/opt/webs/BackEnd

OOM_SCORE    : 0
OOM_ADJ      : -17
OOM_SCORE_ADJ: -1000

Thread: 16
Uptime: 21:44:00 up  5:37,  1 user,  load average: 0.00, 0.01, 0.05
[root@localhost 21:44:00 ~]# tmc Sales up

CATALINA_HOME=/opt/webs/Sales -> /opt/webs/Sales
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
Using CATALINA_BASE:   /opt/webs/Sales
Using CATALINA_HOME:   /opt/webs/Sales
Using CATALINA_TMPDIR: /opt/webs/Sales/temp
Using JRE_HOME:        /opt/jdk/jre
Using CLASSPATH:       /opt/webs/Sales/bin/bootstrap.jar:/opt/webs/Sales/bin/tomcat-juli.jar
Tomcat started.
root      7532  0.0  0.2 2221056 10540 pts/0   Sl+  21:44   0:00 /opt/jdk/jre/bin/java
 -Dcatalina.base=/opt/webs/Sales
 -Dcatalina.home=/opt/webs/Sales

OOM_SCORE    : 0
OOM_ADJ      : -17
OOM_SCORE_ADJ: -1000

Thread: 16
Uptime: 21:44:06 up  5:38,  1 user,  load average: 0.00, 0.01, 0.05

```

运行`psj`将看到：
```
[root@localhost 21:44:01 ~]# psj
Java processes & Listening ports:

root      7857  124  3.2 4800648 130348 pts/0  Sl   21:46   0:02 /opt/jdk/jre/bin/java
 -Xms1024m
 -Xmx1024m
 -classpath /opt/webs/BackEnd/bin/bootstrap.jar:/opt/webs/BackEnd/bin/tomcat-juli.jar
 -Dcatalina.base=/opt/webs/BackEnd
 -Dcatalina.home=/opt/webs/BackEnd
tcp6       0      0 127.0.0.1:18080         :::*                    LISTEN      7857/java           
tcp6       0      0 :::8080                 :::*                    LISTEN      7857/java           
OOM_SCORE: 0

root      7532  4.5  3.1 4800648 129108 pts/0  Sl   21:44   0:02 /opt/jdk/jre/bin/java
 -Xms1024m
 -Xmx1024m
 -classpath /opt/webs/Sales/bin/bootstrap.jar:/opt/webs/Sales/bin/tomcat-juli.jar
 -Dcatalina.base=/opt/webs/Sales
 -Dcatalina.home=/opt/webs/Sales
tcp6       0      0 127.0.0.1:18090         :::*                    LISTEN      7532/java           
tcp6       0      0 :::8090                 :::*                    LISTEN      7532/java           
OOM_SCORE: 0
```

停止 Sales
```
[root@localhost 21:49:08 ~]# tmc Sales down

CATALINA_HOME=/opt/webs/Sales -> /opt/webs/Sales
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
Using CATALINA_BASE:   /opt/webs/Sales
Using CATALINA_HOME:   /opt/webs/Sales
Using CATALINA_TMPDIR: /opt/webs/Sales/temp
Using JRE_HOME:        /opt/jdk/jre
Using CLASSPATH:       /opt/webs/Sales/bin/bootstrap.jar:/opt/webs/Sales/bin/tomcat-juli.jar
Call tomcat to stop .. ( within 2 seconds )

[localhost] /opt/webs/Sales shutdown OK!
```

如果此时再运行`psj`，只能看到一个tomcat在运行了。

再看看`psn`的输出
```
[root@localhost 21:49:22 ~]# psn
Nginx/Node/Httpd/PHP Process & Listening Ports...
root      4339  0.0  0.0  57640  1260 ?        Ss   18:15   0:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
nginx     4340  0.0  0.7  85816 29908 ?        S    18:15   0:00 nginx: worker process
nginx     4341  0.0  0.7  85816 30152 ?        S    18:15   0:00 nginx: worker process
nginx     4342  0.0  0.7  85816 30152 ?        S    18:15   0:00 nginx: worker process
nginx     4343  0.0  0.7  85816 30144 ?        S    18:15   0:00 nginx: worker process
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      4339/nginx: master
```


### buildwar 执行过程
脚本本身具备一些注释，这里增加一些更详细的内容

使用方法： buildwar warName 提交号
如果没有提供参数则输出使用方法和可构建的warName（从war.lst中获得）

1. 取得${EZDPL_HOME}
1. 引用${EZDPL_HOME}/conf/deploy.include，获取必要的变量 `_OPER_PATH _WARS_RUN _WAR_LST_FILE`
1. 如果存在${EZDPL_HOME}/conf/war.lst 文件，则获取所有warName的列表，保存到_usage变量，用于显示帮助信息；如果文件不存在，则输出错误信息并退出
1. 检查参数是否足够，第一个参数为 `warName`，第二个参数是git提交号，可选，默认是使用最新的代码版本
1. 获取并输出`warName`的信息，如果war.lst中有同名的条目，只取第一条，如果参数给出的warName在`war.lst`中不存在，则输出错误信息并退出
1. 检查`conf/_config/warName`目录是否存在，如果不存在则给出错误信息并退出
1. 检查`/data/webShare/read/webapps/warName`目录是否存在，如果不存在则输出错误信息并退出
1. 参数给出的`warName`含有git repo，使用源码构建war包
  - 判断`/opt/wars/build/`目录是否存在，如果不存在则输出错误信息并退出
  - 进入`/opt/wars/build/`，clone代码，如果clone失败则输出错误信息并退出
  - 切到指定的分支，如果参数里指定了提交号则reset，如果reset失败则输出错误信息并退出
  - 创建部署目录`/data/webShare/read/webapps/warName/日期时间_TAG_提交号`
  - 在`/data/webShare/read/webapps/warName/versions`文件里记录本次版本信息
  - 复制生产配置文件到部署目录（以备检查）
  - 更换源码中的生产配置文件，记录版本信息到源码配置文件位置
  - maven构建，根据`runTest`决定是否运行test
  - war包构建成功后复制到部署目录`/data/webShare/read/webapps/warName/日期时间_TAG_提交号`，如果war包构建失败则输出错误信息并退出
  - 计算构建目录和部署目录的两个war包的 md5 校验和，确保文件一致
1. 参数给出的`warName`没有git repo，使用重写war包的方式构建
  - 判断`/opt/wars/todeploy/warName.war`是否存在，如果不存在则输出错误信息并退出
  - 创建部署目录`/data/webShare/read/webapps/warName/日期时间`
  - 复制war包到`/opt/wars/cook`，将生产配置文件注入到war包
  - 复制到部署目录`/data/webShare/read/webapps/warName/日期时间`
  - 计算两个war包的 md5 校验和，确保文件一致
1. 显示部署目录名，即 `日期时间_TAG_提交号` 或 `日期时间`，这一行信息可以为 `depwar` 做参数

### depwar 执行过程
脚本本身具备一些注释，这里增加一些更详细的内容

使用方法： depwar warName d|u 部署目录名 确认n|y
如果没有提供参数则输出使用方法和部署目录内容

1. 取得${EZDPL_HOME}
1. 引用`${EZDPL_HOME}/conf/deploy.include`，获取必要的变量 `_OPER_PATH _WARS_RUN _WAR_LST_FILE _WEBSERVERS_LST_FILE _WAR_DEPLOY_DELAY`
1. 检查参数是否足够，第一个参数为 `warName`，第二个参数是 d 或者 u，即部署或者撤下，第三个参数是部署目录名，第四个参数是部署前确认与否，默认为y
1. 检查`/data/webShare/read/webapps/warName/部署目录名`是否存在，如果不存在则输出错误信息并退出
1. 部署日志路径`/opt/wars/depwar.log`
1. 获取并输出`warName`的信息，如果 war.lst 中有同名的条目，只取第一条，如果参数给出的 warName 在`war.lst`中不存在，则输出错误信息并退出
1. 获取并输出 warName 对应的 webservers 信息，如果 webservers.lst 中没有找到，则输出错误信息并退出
1. 如果第四个参数为空或者不等于 n ，则显示确认提示，输入Y并回车继续，其他字符并回车退出
1. 等待5秒，如果操作错误，这时候可以Ctrl+c退出
1. 根据 webservers.lst 中找到的服务器信息，依次执行部署操作，每个服务器部署完毕后会有一段等待时间
   - 显示war包和服务器信息
   - xml方式部署：调用应用服务器上的 `/usr/local/bin/deployWebxml`, 传递 `webName deployName war包路径 是否重启tomcat` 参数，deployWebxml 将根据参数信息在对应的 tomcat中写入xml配置文件 `/conf/Catalina/localhost/deployName.xml`，xml文件内容指向部署目录的war包，即使不重启tomcat，也会触发tomcat卸载原war包，启动新的war包。
   - war方式部署：直接上传war包到远程服务器的 targetPath ，根据配置决定是否重启tomcat
   - 如果deployMode即不是xml也不是war，则输出错误信息并退出
   - u 参数目前没有遇到使用场景，暂且不表

### buildwar 和 depwar 的整合
`depwar warName d $( buildwar warName | tail -1 )`

先运行`buildwar warName`，然后取输出的最后一行，把结果带入到 depwar 的参数中。

### buildhtml 执行过程
脚本本身具备一些注释，这里增加一些更详细的内容

使用方法： buildhtml htmlName 提交号
如果没有提供参数则输出使用方法和部署目录内容（ _此处有待修改，应该从html.lst中获得列表_ ）

1. 取得${EZDPL_HOME}
1. 引用`${EZDPL_HOME}/conf/deploy.include`，获取必要的变量 `_HTML_RUN _HTML_LST_FILE`，引用 `${EZDPL_HOME}/conf/mkhtml.sh`
1. 检查参数是否足够，第一个参数为 `htmlName`，第二个参数是git提交号，可选，默认是使用最新的代码版本
1. 检查`/data/webShare/read/webapps/htmlName`目录是否存在，如果不存在则输出错误信息并退出
1. 如果存在 `${EZDPL_HOME}/conf/html.lst` 文件，则获取并输出 htmlName 信息，如果文件不存在，则输出错误信息并退出
1. 如果 html.lst 中有同名的条目，只取第一条，如果参数给出的 htmlName 在`html.lst` 中不存在，则输出错误信息并退出
1. 创建 building 目录 `/data/webShare/read/html/htmlName/building`
1. 在 building 目录里检查是否已有代码库，如果没有则重新 clone,，如果有则 pull 最新代码，切到指定的分支，如果 clone 和切分支失败，则输出错误信息并退出
1. 如果参数中有提交号，则 reset 到提交号，如果失败则输出错误信息并退出
1. 提取代码版本信息
1. 如果没有`builtPath`，则清除代码中的敏感内容，一般是各种 `.` 开头的配置文件，README.md等，这些文件不可以发布到web服务器上
1. 运行 `mkhtml.sh`，更新配置文件
1. 复制文件到部署目录 `/data/webShare/read/html/htmlName/日期_提交号`
1. 记录版本信息（ _此处有信息泄露风险，需要将文件名修改为随机字符_ ）
1. 显示部署目录名，即 `日期时间_提交号`，这一行信息可以为 `dephtml` 做参数

### dephtml 执行过程
脚本本身具备一些注释，这里增加一些更详细的内容

使用方法： dephtml htmlName 部署目录名 确认n|y
如果没有提供参数则输出使用方法和部署目录内容

1. 取得${EZDPL_HOME}
1. 引用${EZDPL_HOME}/conf/deploy.include，获取必要的变量 `_OPER_PATH _HTML_RUN _HTML_LST_FILE _HTMLSERVERS_LST_FILE _HTML_DEPLOY_DELAY`
1. 检查`/data/webShare/read/html/htmlName/部署目录名`是否存在，如果不存在则输出错误信息并退出
1. 检查参数是否足够，第一个参数为 `htmlName`，第二个参数是部署目录名，第三个参数是部署前确认与否，默认为y
1. 部署日志路径`/opt/wars/dephtml.log`
1. 如果存在`${EZDPL_HOME}/conf/html.lst` 和 `htmlservers.lst` 文件，则获取并输出 htmlName 和服务器信息，如果文件不存在，则输出错误信息并退出
1. 如果 html.lst 中有同名的条目，只取第一条，如果参数给出的 htmlName 在`html.lst`中不存在，则输出错误信息并退出
1. 获取并输出 htmlName 对应的 htmlservers 信息，如果 htmlservers.lst 中没有找到，则输出错误信息并退出
1. 如果第三个参数为空或者不等于 n ，则显示确认提示，输入Y并回车继续，其他字符并回车退出
1. 等待5秒，如果操作错误，这时候可以Ctrl+c退出
1. 根据 htmlservers.lst 中找到的服务器信息，依次执行部署操作，每个服务器部署完毕后会有一段等待时间
  - 如果配了`targetPath`，则删除应用服务器上的目标目录，将新文件复制为目标目录，比如`/opt/html/htmlName`
  - 如果配了`targetPath`，则删除应用服务器上的软链接，新建软链接指向新的html部署目录，比如`/opt/html/htmlName -> /data/webShare/read/html/htmlName/日期_提交号`


### buildhtml 和 dephtml 的整合
`dephtml htmlName $( buildhtml htmlName | tail -1 )`

先运行`buildhtml htmlName`，然后取输出的最后一行，把结果带入到 dephtml 的参数中。
