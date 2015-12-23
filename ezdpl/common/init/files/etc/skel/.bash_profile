# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs
PS1='[\u@\h:$PWD]$ '

PATH=$PATH:$HOME/bin

export PATH

