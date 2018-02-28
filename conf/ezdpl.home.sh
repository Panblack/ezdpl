# get EZDPL_HOME
if [[ -z ${EZDPL_HOME} ]]; then
    _dir=$(dirname `readlink -f $0`)
    _last_dir=` echo "$_dir"|awk -F'/' '{print $NF}'`
    EZDPL_HOME=`echo "$_dir"|sed 's/\/'$_last_dir'//g'`
fi
