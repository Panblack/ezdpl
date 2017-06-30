#!/bin/bash
if [[ -n $1 ]]; then
    echo "About to initializing $1"
    read -p "Enter Y to continue:" _go
    if [[ $_go = Y ]]; then
    	./ezdpl Y $1 common/init
    	./ezdpl Y $1 appsrv/init
    fi
else
    echo "Usage: $0 <ip:ssh-port>"
fi
#./ezdpl Y 139.196.112.245:22 appsrv/msm2
