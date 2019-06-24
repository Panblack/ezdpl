# 服务器配置工具 ezdpl

## 一. 简介

### ezdpl 实现原理

ezdpl 是一套在操作机/堡垒机上批量配置/管理/监控服务器的脚本工具

- 借鉴了Ansible的实现
- scp 上传/下载服务器上的重要文件
- ssh 连接服务器执行指令或运行脚本
- 操作机 **只能是Linux**，并且必须配置为可公钥（免密码）登录项目管理的所有服务器

### ezdpl 设计目标

- 在配置文件中记录运维项目服务器和应用程序的基本信息
- 脚本依据配置文件中的基本信息运行
- 适应不同类型的运维项目，既可以进行通用的服务器初始化配置，也可以针对项目实现个性化需求
- 具备基本的通用系统资源监控、应用监控、应用部署、批量配置等功能

### 声明

- ezdpl 可以解决部分运维场景中遇到的部分问题，还远远没有达到"通用"的标准。运维项目中的个性化需求需要单独编写相应的脚本。
- 本项目使用Apache2授权协议发布，任何人都可以自由下载、使用、修改、传播，但请遵循授权协议。
- 如果不能完全理解各脚本和配置文件的工作方式，不建议配置到生产环境。
- 任何使用者需要完全对脚本的使用自担风险，对产生的后果自行负责。

## 二. 文件和目录

### 主目录

文件           | 说明
------------ | ------------------
`bin/`       | 通用管理脚本
`conf/`      | 配置文件
`ezdpl`      | `ezdpl`脚本，服务器初始化配置脚本
`local/`     | 项目独有的管理脚本
`ezdpl.log`  | ezdpl执行日志
`operation/` | 运维文件
`README.md`  | 手册
`servers/`   | 服务器配置信息（ezpdl脚本使用）
`todo.txt`   | 备忘录

#### bin/ 通用管理脚本

ezdpl公用脚本，任何ezdpl管理的项目里，必须保证此目录下的文件完全一致！

脚本                 | 说明
------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
`batch.sh`           | 服务器批量处理，从`conf/hosts.lst`读取服务器信息，执行 `conf/batch.include` 里编写的命令（#开头的不会执行）。错误的配置将造成重大灾难，**慎用！**
`buildhtml`          | 构建静态页web应用，从 `conf/html.lst` 和 `conf/htmlservers.lst` 读取html项目信息和对应的服务器信息，从git服务器拉取代码并修改参数（执行 `conf/mkhtml.sh` 内的命令），部署到 `conf/deploy.include` 文件定义的目录
`buildwar`           | 构建war包应用，从 `conf/war.lst` 和 `conf/webserver.lst` 读取java项目信息和对应的服务器信息，从git服务器拉取代码，将`conf/_config/` 下的生产配置文件替换后，构建java web应用；或从待发布目录复制已构建的war包，替换war包内的配置文件，部署到 `conf/deploy.include` 文件定义的目录。
`chkngxlog`         | 分析nginx 访问日志，不带参数时显示帮助说明： 如 `chkngxlog status 日志文件` --- 统计http状态码
`chkres`             | 检测项目内服务器的资源、监听端口和yum重要更新，依赖 `conf/hosts.lst` `conf/ezdpl.include`
`chktcp`             | 从 `conf/hosts.lst`读取服务器信息，检查带有`_WEB_SERVER_`标签的服务器是否有大量未关闭的TCP连接
`dephtml`            | 从 `conf/html.lst` 和 `conf/htmlservers.lst` 读取html项目信息和对应的服务器信息，将指定目录的静态页项目发布到对应的服务器。
`depwar`             | 从 `conf/war.lst` 和 `conf/webservers.lst` 读取java web项目信息和对应的服务器信息，将指定目录的java web项目发布到对应的服务器。
`monitor_webapps.sh` | 从 `conf/war.lst` 和 `conf/webservers.lst` 读取java web项目信息和对应的服务器信息，监控java web应用是否处于运行状态，可根据情况启动相应的应用。（已废弃，**勿用！**）
`readsql`            | 项目中对数据库的只读访问，依赖`conf/ezdpl.include`，需要提前用`mysql_config_editor`配置Mysql免密码访问
`scs`                | ssh 登录其他服务器，或上传/下载文件。
`ssht`               | ssh 隧道工具
`tail_ngx_log`       | 跟踪nginx访问日志，过滤特定关键字和http状态码，不带参数时显示帮助说明
`web_login_test`     | jwt web 登录测试，不带参数时显示帮助说明
`website_response_monitor.sh` | 监测网站反应，依赖`conf/websites.lst`

#### conf/ 配置文件

配置文件               | 说明
------------------ | -------------------------------
`batch.include`    | 操作机上的`bin/batch.sh`执行的具体指令。错误的配置将造成重大灾难，**慎用！**
`deploy.include`   | 操作机上的构建、部署脚本（`buildwar,buildhtml,depwar,dephtml`）的共享变量
`ezdpl.home.sh`    | 操作机上的获取`EZDPL_HOME`的脚本片段，需要这个功能时需要把此片段粘贴到脚本开头部分
`ezdpl.include`    | 操作机上的脚本的共享变量
`hosts.lst`        | 操作机上的需要管理的主机、IP、用户名、端口等信息
`html.lst`         | 静态网页项目部署信息
`htmlservers.lst`  | 静态网页项目对应的服务器信息
`mkhtml.sh`        | 静态网页项目部署前的参数替换脚本，由`bin/buildhtml`使用
`war.lst`          | war包项目部署信息
`webservers.lst`   | war包项目对应的服务器信息
`japp.include`     | 应用服务器上的java应用管理脚本，`japp`,`tmc` 的共享变量，初始化服务器(websrv/javasrv)时会上传到目标服务器的 `/usr/local/bin/`
`release.include`  | 应用服务器上的基础共享变量，初始化服务器（common/init）时会上传到目标服务器的 `/usr/local/bin/`
`_config/`         | 操作机上的java web应用的生产配置文件，部署前替换到代码中，或者注入到war包中。由`bin/buildwar`使用


#### 其他辅助目录

操作机需要的工作目录

目录                    | 说明
---------------------- | ---------------------------------------
`/opt/report`          | 操作机的报告、计划任务日志
`/opt/wars`            | 操作机的war包处理目录，即 `deploy.include` 中的 `_OPER_PATH`
`/data/webShare/read`  | 操作机的部署目录，含发布的html、war包等(NFS)


目标服务器需要的工作目录，部分可以在配置文件中修改，但是强烈建议 **不要修改**。

目录                    | 说明
---------------------- | ---------------------------------------
`/opt/html`            | 应用服务器上的静态页面目录，固定目录，目前无法配置
`/opt/javaapp`         | 应用服务器上的jar包运行目录（japp.include配置，由`japp`使用）
`/opt/jdk`             | 应用服务器上的默认jdk链接，可由japp.include重新配置
`/opt/logs`            | 应用服务器上的日志目录，可由japp.include重新配置
`/opt/webs`            | 应用服务器上的tomcat 目录（japp.include中的`_BASES_DIR`，由`tmc`使用）
`/data/logs`           | 应用服务器上的日志目录 (NFS共享目录)
`/data/webShare/read`  | 应用程序共享的只读目录，含共享的配置文件、html、war包等(NFS)
`/data/webShare/write` | 应用程序共享的读写目录，含用户上传的各种文件(NFS)
`/data/backupmysql`    | 数据库服务器上的mysql备份（可以是NFS共享目录)
`/data/mysql`          | 数据库服务器上的mysql数据目录

## 三. 使用和配置方法

以下提到的目录结构以 `EZDPL_HOME` 为基准，例如把ezdpl clone 到 /home/dpl/myezdpl :

`[dpl@localhost ~]# git clone https://github.com/Panblack/ezdpl.git myezdpl`

clone下了ezdpl的代码，首先要修改 `git remote` 到 **自己的git服务器repo** 上，然后继续定制以适应您的生产环境。

- `$EZDPL_HOME` 即： `/home/dpl/myezdpl/`
- `servers/common/init` 即 `/home/dpl/ezdpl/servers/common/init`
- 操作机需要在环境变量PATH中添加 `$EZDPL_HOME/bin` 和 `$EZDPL_HOME/local`，本例中即`export PATH=$PATH:/home/dpl/myezdpl/bin:/home/dpl/myezdpl/local`，这样即可在操作机任何目录执行 bin/ 和 local/ 下的脚本

### 1\. ezdpl 使用方法

`./ezdpl <ip address>:[port] <ServerType/Operation> [reboot Y|N(N)] [username(root)]`

参数                      | 说明
------------------------ | -----------------------------------------------------------------------------------------------------------------
`<ip address>:[port]`    | 目的服务器IP/主机名，如果服务器sshd端口为22则无需带`:[port]`
`<ServerType/Operation>` | servers/ 目录的两级子目录，比如要为目标服务器配置 servers/common/init/ 下的内容 ，则使用 common/init，common 属于 ServerType ， init 属于 Operation
`[reboot]`               | 配置完后是否需要重启目标服务器。可选，默认为N
`[username(root)]`       | 目标服务器用户名。可选，默认为root。

### 2\. servers/ 配置方法

servers/ 目录典型结构

```
servers/common/init/
├── files
│   ├── etc
│   │   ├── cron.daily
│   │   │   └── logrotate
│   │   ├── mail.rc
│   │   ├── profile.d
│   │   │   └── zz_custom_env.sh
│   │   └── security
│   │       └── limits.conf
│   └── usr
│       └── local
│           └── bin
│               ├── ban_ftp.sh
│               ├── ban_ssh.sh
│               ├── chkservices
│               ├── color.sh
│               ├── compress-log.sh
│               ├── cutfile
│               ├── dic
│               ├── filediff
│               ├── gencert.sh
│               ├── get_pub_key_checksum
│               ├── ipq
│               ├── iptables-iport
│               ├── log-iptraf.sh
│               ├── nst
│               ├── protect_home_rc.sh
│               ├── pymail.py
│               ├── release.include -> ../../../../../../../conf/release.include
│               ├── tcpping
│               ├── upgit
│               └── urlcode
├── fin.sh
└── pre.sh

```

`ezdpl`脚本 对目标服务器做三件事：

1. 上传 `pre.sh` 脚本并执行，为上传 `files` 下的文件做些准备
2. 上传 `files` 下的所有文件到根目录，文件主要包含一些配置文件和通用的脚本，files下的文件目录结构要完全与`/`相符合，并且要配置合适的文件权限，比如脚本文件需要带有可执行属性
3. 上传 `fin.sh` 脚本并执行，一般是进行主要配置工作

例如：
```
./ezdpl 172.16.2.3 common/init

# 初始化172.16.2.3服务器，具体效果为：
## 上传 `servers/common/init/pre.sh` 到 `172.16.2.3:/tmp` 并在`172.16.2.3`上执行
## 上传 `servers/common/init/files/` 下所有文件到 `172.16.2.3` 的根目录
## 上传 `servers/common/init/fin.sh` 到 `172.16.2.3:/tmp` 并在`172.16.2.3`上执行
## 最后，172.16.2.3将会更新rpm包，安装必要的包，配置系统环境变量（多数变量和配置文件内容在 release.include 中定义）
```


注意事项：

1. 如果某个目录下没有可上传的文件，则只需要写 `pre.sh` 或 `fin.sh` 两者其一。
2. `pre.sh` 和 `fin.sh` 都属于通过ssh远程执行的脚本，所以脚本中的命令最好使用全路径，不可使用alias，并且绝不可带有交互命令（比如 read），或者其他需要确认、填写信息的命令（比如 yum install 不带 -y 选项）。

servers目录举例（文件和 `pre.sh` `fin.sh` 脚本请参考代码）

```
servers/
├── common/
│   ├── firewall/
│   │   └── pre.sh
│   ├── init/
│   │   ├── files/
│   │   ├── fin.sh
│   │   └── pre.sh
│   ├── lvsrs/
│   │   └── files/
│   └── zabbix/
│       └── fin.sh
├── docker/
│   └── init/
│       └── fin.sh
├── haproxy/
│   └── init/
│       ├── files
│       ├── fin.sh
│       └── pre.sh
└── websrv/
    ├── init/
    │   ├── files
    │   ├── fin.sh
    │   └── pre.sh
    ├── javasrv/
    │   ├── files
    │   ├── fin.sh
    │   └── pre.sh
    └── jmx/
        └── pre.sh
```

### 3\. conf/配置方法

#### batch.include

```
#${EZDPL_HOME}/ezdpl $_ip:$_port common/init N $_user
#ssh -p$_port $_user@$_ip "crontab -l"
#scp -P$_port $_user@$_ip:/var/log/iptraf/* .
#ssh -p$_port $_user@$_ip "egrep '(DNS|GSS)' /etc/ssh/sshd_config"
#scs $_host e "SOME COMMANDS;;;"
```

- `bin/batch.sh`脚本从`conf/hosts.lst` 中读取`$_host $_ip $_port $_user`，读取本文件，按照每服务器依次执行本文件中的命令，#开头的行不执行，建议写注释
- 默认会对 hosts.lst 中的所有服务器执行命令，如果只需要批量操作部分服务器，需要在batch.include中自行添加 if 条件
- 也可以后面添加TAG参数，比如 `batch.sh _WEB_SERVER_`，即挑选所有带 `_WEB_SERVER_`的 host 进行操作
- 这里可以单独写 ssh/scp 指令，也可以使用`ezdpl`脚本进行服务器初始部署
- 错误的配置将造成重大灾难，**慎用！**

#### deploy.include

操作机上的部署配置文件

变量                     | 说明
----------------------- | ------------------------
`_DEP_WORK_USER`        | 构建和部署脚本的运行用户，一般就是操作机/堡垒机上使用 `ezdpl` 的用户
`export JAVA_HOME=`     | 如果没有系统全局环境变量、或者全局变量不符合要求，这里必须给出适当的配置（非常重要！）
`export JRE_HOME=`      | 如果没有系统全局环境变量、或者全局变量不符合要求，这里必须给出适当的配置（非常重要！）
`export PATH=`          | 如果没有系统全局环境变量、或者全局变量不符合要求，这里必须给出适当的配置（非常重要！）
`_OPER_PATH`            | war包处理目录，主要有 `$_OPER_PATH/build` 构建，`$_OPER_PATH/todeploy` 待发布包，`$_OPER_PATH/cook`重新打包，注意，这个目录的所有者必须是`$_DEP_WORK_USER`
`_WARS_RUN`             | 生产war包保存目录，一般是NFS共享的挂载目录，这个目录的必须是`$_DEP_WORK_USER`可以写入的
`_HTML_RUN`             | 生产html静态页保存目录，一般是NFS共享的挂载目录，这个目录的必须是`$_DEP_WORK_USER`可以写入的
`_WAR_LST_FILE`         | 指定 war.lst 文件路径，默认是 $EZDPL_HOME/conf/war.lst
`_WEBSERVERS_LST_FILE`  | 指定 webservers.lst 文件路径，默认是 $EZDPL_HOME/conf/webservers.lst
`_WAR_DEPLOY_DELAY`     | web服务器war包部署完成后的等待时间（秒）
`_HTML_LST_FILE`        | 指定 html.lst 文件路径，默认是 $EZDPL_HOME/conf/html.lst
`_HTMLSERVERS_LST_FILE` | 指定 htmlservers.lst 文件路径，默认是 $EZDPL_HOME/conf/htmlservers.lst
`_HTML_DEPLOY_DELAY`    | web服务器html部署完成后的等待时间（秒）

#### `ezdpl.home.sh`

很多脚本需要判断自己所在ezdpl项目的根目录，来确定 `$EZDPL_HOME` 变量，这段代码需要放在脚本最开头。

也可以在bash环境变量里定义 `EZDPL_HOME`。

#### ezdpl.include

操作机脚本需要的通用变量

变量                   | 说明
-------------------- | -----------------------------
`_MEM_WATER_MARK`    | `bin/chkres` 脚本中，服务器内存的水位值（%）
`_MYSQL_SERVER_READ` | `bin/readsql` 脚本中的默认MYSQL服务器
`_NOTIFY_*`          | 警报脚本中需要的发送邮件参数，`_NOTIFY_SENDER_PASS`的加密方式是BASE64

#### hosts.lst

服务器信息，由 `scs`,`batch.sh`等使用。

```
#ip   #host    #user    #port    #Listening ports    #purpose    #TAG
即 IP 地址， 主机名， 用户名，ssh端口， 应用监听端口， 服务器作用， 标签
```

- 字段间必须用`<tab>`分隔
- 应用监听端口示例： `80:8080:443` ，中间不可有空格
- 服务器作用示例：`api_server` ，中间不可有空格
- 标签示例：`_WEB_SERVER_ _API_SERVER` ，标签数量不限，中间需要空格，在某些脚本中需要根据标签来确定处理哪些服务器

同一个服务器如果需要用多个用户登录，可重复配置，用 host 名区分，比如：
```
#ip         #host    #user    #port    #Listening ports    #purpose    #TAG
172.16.0.2	mydb	   root	    22	     3306			           db_server    	_CHKERS_ _MYSQL_SERVER_ _MYSQL_MASTER_
172.16.0.2	mydbus	 user	    22	     3306			           db_server_normalUser

```
#### html.list

html信息，由 `buildhtml`和`dephtml` 使用。

```
#htmlName|htmlDevName|gitBranch|gitRepo|codeDir|builtPath
sales|salesFront|master|`http://server:port/path/to/salesFront.git`|html|dist
portal|portalFront|deploybranch|ssh://user@server:22/path/to/portalFront.git||
```

- 字段间用`|`分隔
- `htmlName`   ： 部署名称（`$_HTML_RUN/html/`下的目录名称）,buildhtml和dephtml脚本以本字段作为参数
- `htmlDevName`： 开发名称（一般与git代码库目录名相同，暂时仅起到记录作用）
- `gitBranch` ： git分支名称
- `gitRepo`   ： git 代码库地址
- `codeDir`   ： git 代码库中真正代码的子目录
- `builtPath` ： node web 项目运行`npm run build`之后生成的目标目录，一般为`dist`

#### htmlservers.lst

html服务器信息，由`dephtml` 使用，定义html项目的发布服务器。

```
#htmlName|serverName|serverIp|serverUser|serverPort|targetPath|htmlPort
sales|webs01|172.16.2.1|root|22|/opt/html/sales|80
sales|webs01|172.16.2.4|root|22|/opt/html/sales|80
portal|backs01|172.16.3.1|root|22||80
```

- 字段间用`|`分隔
- `htmlName`   ： 部署名称，同上，必须与 `html.list` 中对应，多个相同的`htmlName`代表一个项目要部署到多个服务器上
- `serverName` ： 目标服务器名称，仅起到记录作用
- `serverIp`   ： 目标服务器IP
- `serverUser` ： 目标服务器SSH用户名
- `serverPort` ： 目标服务器SSH端口
- `targetPath` ： 目标服务器静态页发布目录，如果有值，则替换目标目录；如果留空，则使用共享目录发布，在目的服务器上建立指向共享目录的软链接
- `htmlPort`   ： 目标服务器本项目http监听端口（仅起到记录作用）

#### `mkhtml.sh`
  由 `buildhtml` 使用，用于更改html项目中js中的配置文件，每个项目各有不同，case选项名必须与`html.lst`中的`htmlName`对应，（示例见`conf/mkhtml.sh`文件）。

#### war.list

war包信息，由`buildwar`和`depwar`使用。

```
#warName|warDeployName|webName|configFilesPath|gitBranch|gitRepo|codeDir|runTest
salesweb|ROOT|Sales|WEB-INF/classes||||N
backendapi|api|BackEnd|src/main/resources|master|ssh://user@server:sshport/path/to/backendapi.git|backend|N
```

- 字段间用`|`分隔
- `warName`       ： war包名称，buildwar和depwar脚本以本字段作为参数，也是`$_WARS_RUN/webapps/` 下的目录名称
- `warDeployName` ： 部署名称，即发布后war包的最终名称，也是xml部署方式的context xml文件名
- `webName`       ： `$_BASES_DIR/webName`，目标应用服务器的tomcat目录名
- `configFilesPath` ： 保存生产配置文件的路径（主要部分）
- `gitBranch`     ： git分支名称
- `gitRepo`       ： git代码库地址，推荐ssh://地址
- `codeDir`       ： git 代码库中真正代码的子目录
- `runTest`       ： maven是否要运行test代码,（Y是，N否）

如果`gitBranch`和`gitRepo`，`buildwar`脚本即按照war包重写来处理，没有下载代码和构建环节。

#### webservers.lst

web服务器信息，由`depwar`使用，定义war包的发布服务器。

```
#webName|serverName|ServerIp|serverUser|serverPort|targetPath|deployMode(war/xml)|needRestart|webPort
Sales|webs03|172.16.2.3|root|22|/opt/webs/sales|war|N|8080
Sales|webs04|172.16.2.4|root|22|/opt/webs/sales|war|N|8080
BackEnd|backs01|172.16.3.1|root|22||xml|Y|8080
```

- `webName`    ： 必须与 `war.list` 中对应。
- `serverName` ： 目标服务器名称，仅起到记录作用
- `serverIp`   ： 目标服务器IP
- `serverUser` ： 目标服务器SSH用户名
- `serverPort` ： 目标服务器SSH端口
- `targetPath` ： 如果用war方式部署，这里用来指定war包上传目录
- `deployMode(war/xml)` ： 定义部署方式，war是直接上传，xml是修改目标服务器指定tomcat（即 `$_BASES_DIR/webName`）的context xml文件，比如 /opt/webs/Sales/conf/Catalina/localhost/ROOT.xml 。
- `needRestart`： 部署war包后是否需要重启tomcat（Y是，N否）
- `webPort`    ： web服务器监听端口（暂时仅起到记录作用）

#### japp.include

java共通配置信息，初始化服务器时会上传到应用服务器上的`/usr/local/bin/`目录，由`tmc`,`japp`脚本所使用。

变量                   | 说明
--------------------- | ----------------
`_WORK_USER`          | java 应用运行帐号
`_HOME_DIR`           | tomcat公用`CATALINA_HOME`目录，适合一台服务器部署多个tomcat时共享一套`CATALINA_HOME`。（灵活度不足，已废弃！），默认为空`""`
`_BASES_DIR`          | tomcat`CATALINA_HOME`和`CATALINA_BASE`部署目录，tmc脚本会认为此目录中每个子目录为一个tomcat，子目录名即war.lst中的`webName`。子目录之前仅包含`CATALINA_BASE`部分，目前应为完整tomcat。子目录可以包含`java_env`文件，用于指定不同于 `japp.include` 的JAVA环境变量（使用export命令配置JAVA环境变量）。    
`_LANG`               | 环境变量LANG
`_LC_ALL`             | 环境变量`LC_ALL`
`_WAR_RUNNING_PATH`   | 应用服务器上war包保存的路径，由应用服务器上的`deployWebxml`使用。默认为挂载的共享目录`/data/webShare/read/webapps`，与`deploy.include`中`_WARS_RUN`必须指向同一个共享存储，在操作机和应用服务器上一般使用相同的目录名。
`_MAX_SHUTDOWN_RETRY` | tomcat 无法正常关闭时的最大重试次数，由 `tmc`使用。
`_MAX_TRY`            | `japp`使用，jar包应用启动时的最大重试次数，
`_MAX_WAIT`           | `japp`使用，jar包应用启动时重试间隔
`_APP_PATH`           | `japp`使用，jar包部署目录，每个jar包使用一个目录，目录名和jar包名必须一致（不含`.jar`扩展名）。子目录可以包含`java_env`文件，用于指定不同于 `japp.include` 的JAVA环境变量（使用export命令）；可以包含`java_opts`文件，用于指定单独的`JAVA_OPTS`（完整选项写在文件第一行，比如 `-Djava.ext.dirs=$JRE_HOME/lib/ext:/opt/javaapp/a/lib` ）。
`_LOG_PATH`           | `japp`使用，jar包日志目录
`_JAVA_OPTS`          | 公用的`JAVA_OPS`（已废弃，改由jar包应用的`java_opts`配置 ）
`# Notify email config` | 这些变量已不再使用

#### release.include
  ezdpl脚本初始化服务器时会上传此文件到目标服务器`/usr/local/bin/`，用于
- 判断服务器发行版
- 提供配置文件内容或配置参数
- 为`backupmysql.sh`脚本设置数据库备份选项
- 为php服务器提供必要信息

#### `_config/目录`

这里保存war包生产配置文件。

目录结构例子：
- warName/src/main/resources/，从项目代码构建时使用，以实际代码目录为准。
- warName/WEB-INF/classes ，重新打war包时使用，以war包目录为准。


### 4\. bin/ 脚本使用方法

#### `batch.sh`
注意：错误的配置将造成重大灾难，**慎用！**

假设我们想看一下项目里所有KVM虚拟化服务器的内核版本，步骤如下：
编辑 conf/batch.sh，顶部添加如下内容：
```
#20190623 所有KVM虚拟化服务器的内核版本
scs $_host e "hostname; uname -a"
```

执行 `batch.sh`，带上 `_KVM_`参数，在`hosts.lst`文件中，kvm虚拟化服务器需要配上 `_KVM_` TAG，结果如下：
```
batch.sh _KVM_
EZDPL_HOME : /path/to/ezdpl

2019-06-23_09:55:37 START

<hosts.lst文件内带有 _KVM_ 的部分>

Commands:
scs $_host e "hostname; uname -a"

Press Y to continue:
```
- 首先列出本次批量处理涉及到的服务器列表
- `Commands:` 下显示的是本次要执行的命令
- `Press Y to continue:` 这时需要输入大写 Y 并回车才能继续。如果不想继续，可直接回车或输入任何其他字符并回车。

执行结果(略)

#### chkngxlog

参数     | 说明
---     | ---
status  | 统计http状态码数量
url     | 统计http状态码1xx/2xx/3xx，输出内容为 数量 URL http方法 远程IP 真实IP（如果无则为 - ） http状态码
urlr    | 同上，如果nginx accesslog配置在结尾增加了 $request ，则必须使用本参数。
url45   | 统计http状态码为非1xx/2xx/3xx，输出内容为 数量 URL http方法 远程IP 真实IP（如果无则为 - ） http状态码
url45r  | 同上，如果nginx accesslog配置在结尾增加了 $request ，则必须使用本参数。
trans   | 统计http流量，单位MB
```
Usage: chkngxlog <status|url> <nginx_access_log_file>
status       : Statistics for all http status
url/urlr     : Statistics for URL and X-Forwarded-For IP
url45/url45r : Statistics for URL and X-Forwarded-For IP of none 20x/30x requests
trans        : Statistics total data transfered in MB

例子：
[root@localhost 10:10:04 ~]# chkngxlog status /var/log/nginx/access.log
    113  200
      3  302
    306  304
      1  404

```

#### chkres
读取 `conf/hosts.lst` ，选择带有 `_CHKRES_` TAG 的条目，检查服务器资源、监听端口和yum重要更新。

`conf/ezdpl.include` 中的 `_MEM_WATER_MARK` 是内存水位，超过此水位的内存使用率以红色显示。

参数       | 说明
---       | ---
chkres r  | 检查服务器资源，输出为 主机名（前7位）系统（Centos7类的显示C7)	CPU数量	运行时间（无单位时代表天数）1分钟、5分钟、15分钟的CPU负载	内存	内存使用百分比	使用率超过50%的分区
chkres p  | 检查服务器监听端口，依据是`hosts.lst`中定义的端口，未开启的会以减号和红色显示
chkres y  | 检查服务器是否有重要的包更新，只适合Cenots系列（含红帽、亚马逊Amazon Linux）
chkres    | 显示帮助信息
```
Query resources/listening ports/yumInfo in servers tagged '_CHKRES_' in hosts.lst.
MEM_WATER_MARK defined in ezdpl.include.
Usage:    
chkres r					Query resources only
chkres p					Query ports only
chkres y					Query yum updateinfo security only
chkres						Show this help
chkres r|p|y 'IP Host User SSHPort LsnPorts'	Qurey one server

例子：
Server Resource:
Host	System	CPUs	UpTime	    CPU_load_1_5_15min	    Mem	    Used%	DiskUsage
web01   C7      1       2       0.06, 0.13, 0.13        3789    68%
web02   C7      4       24      0.01, 0.03, 0.05        7983    2%         
web03   C7      8       24      0.00, 0.01, 0.05        7982    13%        
web04   C7      16      25      0.00, 0.02, 0.05        32150   15%        
web05   C7      16      25      0.54, 0.43, 0.43        32150   76%        
web06   C7      8       25      0.09, 0.16, 0.17        32060   40%     /data 50%  
```

#### chktcp

从 `conf/hosts.lst`读取服务器信息，检查带有`_WEB_SERVER_`标签的服务器是否有大量未关闭的TCP连接

```
例子
$ chktcp
web-01 root@192.168.30.51:22
Netid  State      Recv-Q Send-Q Local Address:Port               Peer Address:Port              
tcp    TIME-WAIT  0      0      192.168.30.51:33372              140.205.172.21:443                 timer:(timewait,56sec,0)
tcp    TIME-WAIT  0      0      192.168.30.51:80                 100.116.128.64:14263               timer:(timewait,15sec,0)

web-02 root@192.168.30.52:22
Netid  State      Recv-Q Send-Q Local Address:Port               Peer Address:Port              
tcp    TIME-WAIT  0      0      192.168.30.52:80                 100.116.128.78:44504               timer:(timewait,15sec,0)

fxtest root@192.168.30.59:22
Netid  State      Recv-Q Send-Q Local Address:Port               Peer Address:Port
```

#### `monitor_webapps.sh`

从 `conf/war.lst` 和 `conf/webservers.lst` 读取java web项目信息和对应的服务器信息，监控java web应用是否处于运行状态，可根据情况启动相应的应用。（已废弃，**勿用！**）

#### readsql

在生产环境中访问数据库，最佳实践是用只读用户查询，不可直接用读写用户连接，以避免意外。  
Mysql 提供了 mysql_config_editor 工具，可以在 `~/.mylogin.cnf`中加密保存用户名和密码，readsql使用这个这个方式进行mysql用户验证，需要提前运行mysql_config_editor。  
数据库服务器地址在 `conf/ezdpl.include`中的 `_MYSQL_SERVER_READ`定义。

参数                      | 说明
---                      | ---
readsql                  | 登录数据库服务器，不选择库
readsql 数据库名          | 登录数据库服务器，选择库
readsql 数据库名 "SQL文"   | 登录数据库服务器，选择库，执行SQL查询
readsql 数据库名 SQL文件名 | 登录数据库服务器，选择库，执行`SQL文件名`中编写的查询

#### scs
scs 是为了简化登录服务器、上传下载文件的操作而编写的。

参数                      | 说明
---                      | ---
`scs web01`                | 登录`conf/hosts.lst`中定义的 web01 服务器
`scs web01 e 'uname -a'`   | 在`conf/hosts.lst`中定义的 web01 服务器上执行 `uname -a`命令，结果显示在操作机命令行下，不会登录到服务器。不可以用alias，不可以运行交互命令。
`scs web01 d /dir/file.txt /tmp/` | 将 `conf/hosts.lst`中定义的 web01 上的 `/dir/file.txt` 文件下载到操作机的 `/tmp/` 目录
`scs web01 dp /dir /tmp/`         | 将 `conf/hosts.lst`中定义的 web01 上的 `/dir` 目录下载到操作机的 `/tmp/` 目录
`scs web01 u ./file.txt /tmp/`  | 将 `./file.txt` 上传到 `conf/hosts.lst`中定义的 web01 的 `/tmp/` 目录
`scs web01 up ./dir /tmp/`      | 将 `./dir` 目录上传到 `conf/hosts.lst`中定义的 web01 的 `/tmp/` 目录
`scs some_user@192.168.50.20:2112` | 登录 `conf/hosts.lst` 中未定义的服务器，用户 some_user , IP 192.168.50.20 , 服务器ssh端口 2112

```
Usage:
scs [user@]<hostname>[:port] 						SSH login
scs [user@]<hostname>[:port] e  'command'
scs [user@]<hostname>[:port] d  'remote_src_file' 'local_dst_path' 	Download file(s)
scs [user@]<hostname>[:port] dp 'remote_src_path' 'local_dst_path' 	Download dir(s)
scs [user@]<hostname>[:port] u  'local_src_file'  'remote_dst_path' 	Upload   file(s)
scs [user@]<hostname>[:port] up 'local_src_path'  'remote_dst_path' 	Upload   dir(s)

If 'local_dst_path' is omitted, ' . ' will apply.

<conf/hosts.lst文件内容>

```

#### ssht

ssh 隧道工具，说明略

#### tail_ngx_log

跟踪nginx日志，可过滤特定关键字和http状态码

```
Usage:
tail_ngx_log <nginx_access_log_file> <key_word_in_url> [1|2|3|4|5]

例子：
#跟踪/var/log/nginx/access.log日志，过滤关键字/login，只显示4xx的结果
tail_ngx_log /var/log/nginx/access.log "/login" 4
```

#### web_login_test

jwt web 登录测试，编写curl测试网站功能时可以参考本文件，说明略

#### `website_response_monitor.sh`

监测网站反应，依赖`conf/websites.lst`，说明略


#### buildhtml, dephtml, buildwar, depwar

这四个脚本用于web应用部署，是ezdpl中最复杂的一部分，将以 deploy_README_CN.md 另文说明。
