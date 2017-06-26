alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cp='/bin/cp -i --preserve=timestamps'
alias df='/bin/df -hTP'
alias du='/usr/bin/du -hx --max-depth=1'
alias ll='/bin/ls -lh --color=auto --time-style=long-iso 2>/dev/null'
alias lt='/bin/ls -lhtr --color=auto --time-style=long-iso 2>/dev/null'
alias lynx='lynx -accept_all_cookies'
alias mysql='mysql --default-character-set=utf8'
alias tless='less `ls -tr1|tail -1`'
alias ttail='tail -f `ls -tr1|tail -1`'
alias ftail='tail -f'
alias grep='grep --color=auto'
alias stl='systemctl'
alias stlu='systemctl start'
alias stld='systemctl stop'
alias stlr='systemctl restart'
alias stlrl='systemctl reload'
alias stlst='systemctl status'
alias stll='systemctl list-unit-files'
alias fwd='firewall-cmd'
alias fwdsv='firewall-cmd --runtime-to-permanent'
alias fwdrl='firewall-cmd --reload'
alias fwdlt='firewall-cmd --list-ports; firewall-cmd --list-rich-rules'

unset MAILCHECK

if [[ `id -u` = "0" ]]; then
    PS1='[\u@\h \t \w]# '
else
    PS1='[\u@\h \t \w]$ '
fi

export HISTTIMEFORMAT="%F %T `whoami` "
