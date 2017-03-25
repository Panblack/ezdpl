# scripts for appservers:

  #scon $_host u "/opt/ezdpl/servers/appsrv/init/files/usr/local/bin/japp*" /usr/local/bin/ 
  #scon $_host u "/opt/ezdpl/servers/appsrv/init/files/usr/local/bin/psj"  /usr/local/bin/ 
  #scon $_host u "/opt/ezdpl/servers/appsrv/init/files/usr/local/bin/japp*" /usr/local/bin/ 

  #scon $_host e "find /opt/webs -name logging.properties |xargs grep 'localhost\.'"
  #scon $_host u ./servers/appsrv/init/files/usr/local/bin/tmc /usr/local/bin/
  #ezdpl/servers/appsrv/init/files/usr/local/bin/psj 
  #scp -p ./servers/appsrv/init/files/usr/local/bin/tmc root@$_host:/usr/local/bin/
  #ssh -p $_port root@$_host 'ls -l /opt/app/tomcat/lib/memcached-session-manager* ; ls -l /opt/app/tomcat/lib/jedis* ;'
  #ssh -p $_port root@$_host 'ln -sf /opt/jdk1.8 /opt/jdk'

  #ssh -p $_port root@$_host 'mkdir -p /opt/app; mkdir -p /opt/webs; '
  #scon $_host up /opt/apache-tomcat-8.5.6/ /opt/app
  #scon $_host up /opt/apache-tomcat-8.5.9/ /opt/app
  #scon $_host u  /home/dpl/ezdpl/servers/appsrv/init/files/usr/local/bin/tmc /usr/local/bin/
  #ssh -p $_port root@$_host 'ln -sf /opt/app/apache-tomcat-8.5.6/ /opt/app/tomcat ; ls -l /opt/app/ ; ls -l /opt/webs'
  #scon $_host u  /home/dpl/ezdpl/servers/appsrv/init/files/usr/local/bin/tmc /usr/local/bin/

  #./ezdpl Y $_host:$_port common/init
  #./ezdpl Y $_host:$_port appsrv/init
  #./ezdpl Y $_host:$_port appsrv/msm2

  #ssh -p $_port root@$_host 'grep  UseG1GC /opt/tomcat7/bin/catalina.sh '
  #ssh -p $_port root@$_host 'ls -l /opt; echo;echo dirs; find /opt/tomcat7/webapps/ -type d -name resources; echo;echo'  
