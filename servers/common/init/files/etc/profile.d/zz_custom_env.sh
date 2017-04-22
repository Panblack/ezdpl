alias cp='/bin/cp -i --preserve=timestamps'
alias mv='mv -i'
alias rm='rm -i'
alias df='/bin/df -hTP'
alias du='/usr/bin/du -hx --max-depth=1'
alias ll='/bin/ls -lh --color=auto --time-style=long-iso 2>/dev/null'
alias lt='/bin/ls -lhtr --color=auto --time-style=long-iso 2>/dev/null'
alias lynx='lynx -accept_all_cookies'
alias mysql='mysql --default-character-set=utf8'
alias tless='less `ls -tr1|tail -1`'
alias ttail='tail -f `ls -tr1|tail -1`'
alias grep='grep --color=auto'

unset MAILCHECK

if [[ `id -u` = "0" ]]; then
    PS1='[\u@\h \t \w]# '
else
    PS1='[\u@\h \t \w]$ '
fi

export HISTTIMEFORMAT="%F %T `whoami` "
