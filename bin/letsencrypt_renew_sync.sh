#!/bin/bash
# get EZDPL_HOME
if [[ -z ${EZDPL_HOME} ]]; then
    _dir=$(dirname `readlink -f $0`)
    _last_dir=` echo "$_dir"|awk -F'/' '{print $NF}'`
    EZDPL_HOME=`echo "$_dir"|sed 's/\/'$_last_dir'//g'`
fi
echo "EZDPL_HOME=$EZDPL_HOME"

funRenew() {
    if [[ $_dns = "N" ]]; then
	echo "Renewing $_domain"
	if [[ $_wild = "N" ]]; then
            sh $HOME/acme.sh/acme.sh --renew -d $_domain --force --debug --log $_log_file
	else
	    echo "Wildcard=Y Dnsapi=N not supported."; exit 1
	fi
    else
        echo "Renewing $_domain --dns"
	local _source_dnsapi="$HOME/.acme.sh/dnsapi/${_dns}.sh.${_domain}"
	local _backup_dnsapi="$HOME/.acme.sh/dnsapi/${_dns}.sh.bak"
	local _target_dnsapi="$HOME/acme.sh/dnsapi/${_dns}.sh"
        echo "Copy $_source_dnsapi to $_target_dnsapi"
        /bin/cp -p $_source_dnsapi $_target_dnsapi
        echo "Renew ${_domain}"
	if [[ $_wild = "N" ]]; then
	    sh $HOME/acme.sh/acme.sh --renew --force -d ${_domain} --dns $_dns --log $_log_file
	else
            sh $HOME/acme.sh/acme.sh --renew --force -d ${_domain} -d "*.${_domain}" --dns $_dns --log $_log_file
	fi
        echo "Restore $_target_dnsapi"
        /bin/cp -p $_backup_dnsapi $_target_dnsapi
    fi
    sed -i '/LOG_FILE=/d' $HOME/.acme.sh/account.conf
    _cer_date=`stat --format=%y $HOME/.acme.sh/${_domain}/fullchain.cer |awk '{print $1}'`
    if [[ $_cer_date = $_today ]] ;then
        chmod 600 $HOME/.acme.sh/${_domain}/fullchain.cer
    else
	echo "Renew failed"
	return 1 
    fi
}

funSyncCerts() {
    if [[ -f ${EZDPL_HOME}/conf/hosts.lst ]]; then
        local _domain_to_sync=$1
        local _servers=`grep '_SSL_SERVER_' ${EZDPL_HOME}/conf/hosts.lst`
        IFS=$'\n'
        for x in $_servers;do
	    _ip=`  echo $x|awk '{print $1}'`
	    _host=`echo $x|awk '{print $2}'`
	    _user=`echo $x|awk '{print $3}'`
	    _port=`echo $x|awk '{print $4}'`
	    echo "${_host} ${_user}@${_ip}:${_port}"
	    ssh -p${_port} ${_user}@${_ip} "mkdir -p /root/.acme.sh"
    	    scp -P${_port} -p $HOME/.acme.sh/${_domain_to_sync}/fullchain.cer   ${_user}@${_ip}:/root/.acme.sh/${_domain_to_sync}/
    	    echo "Reloading nginx ..."
    	    ssh -p${_port} ${_user}@${_ip} "nginx -t && systemctl reload nginx"
	    echo 
	done
    fi
}

#main
_log_file="$HOME/.acme.sh/renew_`date +%Y%m%d`.log"
_today=`date +%F`
if [[ $# -lt 3 ]]; then
    echo "Usage: letsencrypt_renew_sync.sh Domain Wildcard(Y|N) Dnsapi(e.g. dns_ali|N)"
    echo "Customized dnsapi files should be in ~/.acme.sh/dnsapi"
    exit 1
fi
_domain=$1
_wild=$2
_dns=$3
if [[ ! -d $HOME/.acme.sh/${_domain} ]]; then
    echo "${_domain} not issued yet."; exit 1
fi
if [[ $_wild != "Y" ]] && [[ $_wild != "N" ]]; then
    _wild="N"
fi
if [[ $_dns != "N" ]] && [[ ! -f $HOME/.acme.sh/dnsapi/${_dns}.sh.${_domain} ]]; then
    echo "$HOME/.acme.sh/dnsapi/${_dns}.sh.${_domain} does not exist."; exit 1
fi
echo "`date +%F_%T` Let's renew $_domain wildcard=$_wild dnsapi=$_dns ..."
if funRenew $_domain $_wild $_dns ; then
    funSyncCerts $_domain
fi
