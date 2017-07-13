if [[ -z ${EZDPL_HOME} ]]; then
    _dir=$(dirname `readlink -f $0`)
    cd $_dir && cd ..
    EZDPL_HOME=`pwd`
fi
