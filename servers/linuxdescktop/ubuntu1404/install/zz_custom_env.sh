alias cp='/bin/cp -i --preserve=timestamps'
alias mv='mv -i'
alias rm='rm -i'
alias df='/bin/df -hTP'
alias du='/usr/bin/du -hx --max-depth=1'
alias ll='/bin/ls -lh --color=auto --time-style=long-iso 2>/dev/null'
alias lt='/bin/ls -lhtr --color=auto --time-style=long-iso 2>/dev/null'
alias mysql='mysql --default-character-set=utf8'
alias tless='less `ls -tr1|tail -1`'
alias ttail='tail -f `ls -tr1|tail -1`'
alias xscp='/usr/bin/scp -P2139 '
alias xssh='/usr/bin/ssh -p2139 '
alias ping='ping -i 0.2 '
alias lynx='lynx -accept_all_cookies '

export JAVA_HOME=/home/app/jdk
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=$CLASSPATH:.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
export MAVEN_HOME="/home/app/maven"
export M2_HOME="$MAVEN_HOME"
export PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$MAVEN_HOME/bin
export PATH=$PATH:/home/app/sqldeveloper/sqldeveloper/bin
export PATH=$PATH:/home/app/node/bin

umask 0022
