#!/bin/bash
cd $HOME
chattr +i .ssh/authorized_keys
chattr +i .ssh/id_rsa*
chattr +i .ssh
chattr +i .bashrc .bash_profile .bash_logout
