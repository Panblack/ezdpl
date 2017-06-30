
umask 0022
export HISTTIMEFORMAT="%F %T `whoami` "

export JAVA_HOME=/home/app/jdk
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=$CLASSPATH:.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
export MAVEN_HOME="/home/app/maven"
export M2_HOME="$MAVEN_HOME"
export PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$MAVEN_HOME/bin
export PATH=$PATH:/home/app/sqldeveloper/sqldeveloper/bin
export PATH=$PATH:/home/app/node/bin

