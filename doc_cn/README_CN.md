# 服务器配置工具 ezdpl

## 简介

### ezdpl 实现原理

ezdpl 是一套批量配置/管理/监控服务器的脚本工具

- 借鉴了Ansible的实现
- scp 上传/下载服务器上的重要文件
- ssh 连接服务器执行指令或运行脚本
- 操作机必须配置为可公钥（免密码）登录服务器

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

## 文件和目录

### 主目录

文件           | 说明
------------ | ------------------
`bin/`       | 通用管理脚本
`conf/`      | 配置文件
`ezdpl`      | 服务器初始化配置脚本
`local/`     | 项目独有的管理脚本
`log.txt`    | ezdpl执行日志
`operation/` | 运维文件
`README.md`  | 手册
`servers/`   | 服务器配置信息（ezpdl脚本使用）
`todo.txt`   | 备忘录

#### bin/ 通用管理脚本

脚本                 | 说明
------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
`batch.sh`           | 服务器批量处理，从`conf/hosts.lst`读取服务器信息，执行 `conf/batch.include` 里编写的命令
`buildhtml`          | 构建静态页web应用，从 `conf/html.lst` 和 `conf/htmlservers.lst` 读取html项目信息和对应的服务器信息，从git服务器拉取代码并修改参数（执行 `conf/mkhtml.sh` 内的命令），部署到 `conf/deploy.include` 文件定义的目录
`buildwar`           | 构建war包应用，从 `conf/war.lst` 和 `conf/webserver.lst` 读取java项目信息和对应的服务器信息，从git服务器拉取代码，将`conf/_config/` 下的生产配置文件替换后，构建java web应用；或从待发布目录复制已构建的war包，替换war包内的配置文件，部署到 `conf/deploy.include` 文件定义的目录。
`chkngxlog`         | 统计指定nginx 访问日志的状态码和URL，IP
`chkres`             | 从 `conf/hosts.lst`读取服务器信息，检查服务器的资源状况和监听端口
`chktcp`             | 从 `conf/hosts.lst`读取服务器信息，检查服务器是否有大量未关闭的TCP连接
`dephtml`            | 从 `conf/html.lst` 和 `conf/htmlservers.lst` 读取html项目信息和对应的服务器信息，将指定目录的静态页项目发布到对应的服务器。
`depwar`             | 从 `conf/war.lst` 和 `conf/webservers.lst` 读取java web项目信息和对应的服务器信息，将指定目录的静态页项目发布到对应的服务器。
`monitor_webapps.sh` | 从 `conf/war.lst` 和 `conf/webservers.lst` 读取java web项目信息和对应的服务器信息，监控java web应用是否处于运行状态，可根据情况启动相应的应用。
`readsql`            | 从 `ezdpl.include` 读取mysql服务器信息，以只读方式访问。
`scs`                | ssh 登录其他服务器，或上传/下载文件。

#### conf/ 配置文件

配置文件               | 说明
------------------ | -------------------------------
`batch.include`    | `bin/batch.sh`执行的具体指令
`_config/`         | web应用的生产配置文件，部署前注入到目的war包中
`deploy.include`   | `bin/` 构建、部署脚本的共享变量
`ezdpl.home.sh`    | 获取`EZDPL_HOME`的脚本片段，很多脚本需要这个功能
`ezdpl.include`    | 通用管理脚本的共享变量
`hosts.lst`        | 需要管理的主机、IP、用户名、端口等信息
`html.lst`         | 静态网页部署信息
`htmlservers.lst`  | 静态网页的服务器信息
`japp.include`     | java应用管理脚本（japp,tmc)的共享变量
`mkhtml.sh`        | 静态网页部署前的参数替换脚本，由bin/buildhtml调用
`nginx.lst`        | nginx配置文件信息
`nginxservers.lst` | nginx服务器信息
`release.include`  | 待管理的服务器基础共享变量，在目标服务器上运行
`war.lst`          | war包部署信息
`webservers.lst`   | war包对应的服务器信息

#### 其他辅助目录

脚本运行中需要的工作目录，以下为惯常使用的目录名。完全可以使用其他目录名，但必须与 conf/ 配置文件设定的一致。

目录                     | 说明
---------------------- | ---------------------------------------
`/opt/html`            | 静态页面目录
`/opt/javaapp`         | jar包运行目录（japp.include配置，japp管理）
`/opt/jdk`             | 默认jdk链接
`/opt/logs`            | 应用日志目录（本地）
`/opt/report`          | 报告、计划任务日志
`/opt/wars`            | war包处理目录
`/opt/webs`            | tomcat 目录（japp.include配置，tmc管理）
`/data/backupmysql`    | mysql备份（nfs)
`/data/logs`           | 应用日志目录 (nfs)
`/data/mysql`          | mysql数据目录
`/data/webShare/read`  | web应用程序共享的只读目录，含共享的配置文件、html、war包等(nfs)
`/data/webShare/write` | web应用程序共享的读写目录，含用户上传的各种文件(nfs)

## 使用和配置方法

### 1\. ezdpl 使用方法

`./ezdpl <ip address>:[port] <ServerType/Operation> [reboot Y|N(N)] [username(root)]`

参数                       | 说明
------------------------ | -----------------------------------------------------------------------------------------------------------------
`<ip address>:[port]`    | 目的服务器IP/主机名，如果服务器sshd端口为22则无需带`:[port]`
`<ServerType/Operation>` | servers/ 目录的两级子目录，比如要为目标服务器配置 servers/common/init/ 下的内容 ，则使用 common/init，common 属于 ServerType ， init 属于 Operation
`[reboot]`               | 配置完后是否需要重启目标服务器。可选，默认为N
`[username(root)]`       | 目标服务器用户名。可选，默认为root。

### 2\. servers/ 配置方法

servers/ 目录典型结构

```
servers/common/init
├── files
│   ├── etc
│   │   ├── lvs_vip.conf
│   │   ├── mail.rc
│   │   ├── profile.d/
│   │   └── security/
│   └── usr
│       └── local/
├── fin.sh
└── pre.sh
```

ezdpl 对目标服务器做三件事：

1. 上传 pre.sh 脚本并执行，在上传 files 下的文件前做些准备
2. 上传 files 下的所有文件到根目录，文件主要包含一些配置文件和通用的脚本
3. 上传 fin.sh 脚本并执行，一般是进行主要配置工作

注意事项：

1. 如果某个目录下没有可上传的文件，则只需要写 pre.sh 或 fin.sh 两者其一。
2. pre.sh 和 fin.sh 都属于通过ssh远程执行的脚本，所以脚本中的命令最好使用全路径，并且绝不可带有交互命令（比如 read），或者其他需要确认、填写信息的命令（比如 yum install 不带 -y 选项）。

servers目录举例（文件和pre.sh fin.sh 脚本请参考代码）

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
└── javasrv/
    ├── firewall/
    │   └── pre.sh
    ├── init/
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
```

- 其中的`$_ip $_port $_user`从 `conf/hosts.lst` 中读取
- `bin/batch.sh` 默认会对 hosts.lst 中的所有服务器执行命令，如果只需要批量操作部分服务器，需要在batch.include中自行添加 if 条件
- 这里可以单独写 ssh/scp 指令，也可以使用`${EZDPL_HOME}/ezdpl`进行服务器初始部署

#### `_config/目录`

这里保存war包生产配置文件，目录结构为 warName/src/main/resources

#### deploy.include

变量                      | 说明
----------------------- | ------------------------
`_DEP_WORK_USER`        | 构建和部署脚本的运行帐号
`_OPER_PATH`            | war包处理目录
`_WARS_RUN`             | 生产war包保存目录
`_HTML_RUN`             | 生产html静态页保存目录
`_WAR_LST_FILE`         | 指定 war.lst 文件的位置
`_WEBSERVERS_LST_FILE`  | 指定 webservers.lst 文件的位置
`_WAR_DEPLOY_DELAY`     | web服务器部署war包后的等待时间（秒）
`_HTML_LST_FILE`        | 指定 html.lst 文件的位置
`_HTMLSERVERS_LST_FILE` | 指定 htmlservers.lst 文件的位置
`_HTML_DEPLOY_DELAY`    | web服务器部署html文件后的等待时间（秒）

#### ezdpl.home.sh

很多脚本需要判断自己所在ezdpl项目的根目录，来确定 `$EZDPL_HOME` 变量，这段代码需要放在脚本最开头。

也可以在bash环境变量里定义 `EZDPL_HOME`。

#### ezdpl.include

管理脚本需要的通用变量

变量                   | 说明
-------------------- | -----------------------------
`_MEM_WATER_MARK`    | `bin/chkres` 脚本中，服务器内存的水位值（%）
`_MYSQL_SERVER_READ` | `bin/readsql` 脚本中的默认MYSQL服务器
`_NOTIFY_*`          | 警报脚本中需要的发送邮件参数

#### hosts.lst

服务器信息

```
#ip   #host    #user    #port    #Listening ports    #purpose    #TAG
即 IP 地址， 主机名， 用户名，ssh端口， 应用监听端口， 服务器作用， 标签
```

- 字段间必须用`<tab>`分隔
- 应用监听端口示例： `80:8080:443` ，中间不可有空格
- 服务器作用示例：`api_server` ，中间不可有空格
- 标签示例：`_WEB_SERVER_ _API_SERVER` ，标签数量不限，中间需要空格，在某些脚本中需要根据标签来确定处理哪些服务器

#### html.list

html信息

```
#htmlDeployName|htmlDevName|htmlPort|gitBranch|gitRepo
sales|salesFront|80|master|http://server:port/path/to/salesFront.git
portal|portalFront|80|deploybranch|ssh://user@server:sshport/path/to/portalFront.git
```

- 字段间用`|`分隔
- `htmlDeployName` ： 部署名称（`$_HTML_RUN/html/`下的目录名称）,buildhtml和dephtml脚本以本字段作为参数
- `htmlDevName`： 开发名称（一般与git代码库目录名相同，暂时仅起到记录作用）
- `htmlPort` ： web服务器监听端口（暂时仅起到记录作用）
- `gitBranch` ： git分支名称
- `gitRepo` : git 代码库地址

#### htmlservers.lst

html服务器信息

```
  #htmlDeployName|serverIp|serverUser|serverPort
  sales|172.16.2.1|root|22
```

`htmlDeployName` 必须与 `html.list` 中对应。

#### japp.include

java共通配置信息，为tmc,japp脚本所使用。

默认部署位置为java应用服务器`/usr/local/bin/`目录。

变量                    | 说明
--------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
`_WORK_USER`          | java 应用运行帐号
`_HOME_DIR`           | tomcat公用`CATALINA_HOME`目录，适合一台服务器部署多个tomcat时共享一套`CATALINA_HOME`。（灵活度不足，拟废弃）
`_BASES_DIR`          | tomcat`CATALINA_BASE`部署目录，tmc脚本会在此目录查找tomcat，每个tomcat使用一个子目录，子目录名即war.lst中的webName。子目录之前仅包含`CATALINA_BASE`部分，目前应为完整tomcat。子目录可以包含`java_env`文件，用于指定不同于 `japp.include` 的JAVA环境变量（使用export命令）；可以包含`home_def`文件，用于单独指定 `CATALINA_HOME`（完整路径写在文件第一行）。
`_WAR_RUNNING_PATH`   | 应用服务器上war包部署的路径，由`deployWebxml`使用。
`_MAX_SHUTDOWN_RETRY` | tomcat 无法正常关闭时的最大重试次数，由 `tmc`使用。
`_MAX_TRY`            | jar包应用启动时的最大重试次数，
`_MAX_WAIT`           | jar包应用启动时重试间隔
`_LANG`               | 环境变量LANG
`_LC_ALL`             | 环境变量`LC_ALL`
`_APP_PATH`           | jar包部署目录，每个jar包使用一个目录，目录名和jar包名必须一致（不含`.jar`扩展名）。子目录可以包含`java_env`文件，用于指定不同于 `japp.include` 的JAVA环境变量（使用export命令）；可以包含`java_opts`文件，用于指定单独的`JAVA_OPTS`（完整选项写在文件第一行，比如 `-Djava.ext.dirs=$JRE_HOME/lib/ext:/opt/javaapp/a/lib` ）。
`_LOG_PATH`           | jar包日志目录
`_JAVA_OPTS`          | 公用的`JAVA_OPS`

#### war.list

war包信息

```
#warDevName|warDeployName|needRestart|webName|webPort|configFilesPath|gitBranch|gitRepo
salesweb|ROOT|Y|Sales|8090|WEB-INF/classes||
backendapi|api|Y|BackEnd|8080|src/main/resources|master|ssh://user@server:sshport/path/to/backendapi.git
```

- 字段间用`|`分隔
- `warDevName`： 开发名称，buildwar和depwar脚本以本字段作为参数
- `warDeployName` ： 部署名称（`$_WARS_RUN/webapps/webName/` 下的目录名称）
- `needRestart` ： 部署war包后是否需要重启tomcat（Y是，N否）
- `webPort` ： web服务器监听端口（暂时仅起到记录作用）
- `configFilesPath` ： 保存生产配置文件的路径（主要部分）
- `gitBranch` ： git分支名称
- `gitRepo` : git 代码库地址

如果`gitBranch`和`gitRepo`，`buildwar`脚本即按照war包重写来处理，没有下载代码和构建环节。

#### webservers.lst

web服务器信息

```
#webName|serverName|serverUser|serverPort
Sales|172.16.2.1|root|22
```

`webName`必须与 `war.list` 中对应。

### 4\. bin/ 脚本使用方法
