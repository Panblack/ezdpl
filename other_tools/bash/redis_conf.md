## Redis 3

### redis.conf
```
appendonly yes
bind 192.168.1.45 127.0.0.1
daemonize yes
dir "/opt/data-6379"
logfile "/var/log/redis-6379.log"
masterauth MyPassWord
pidfile "/var/run/redis-6379.pid"
port 6379
requirepass MyPassWord
slave-read-only yes
#slaveof 192.168.1.45 6379

``` 

### sentinel.conf
```
daemonize yes
dir "/opt/data-6379"
logfile "/var/log/redis-sentinel.log"
port 26379
sentinel monitor mymaster 192.168.1.45 6379 1
sentinel auth-pass mymaster MyPassWord
sentinel client-reconfig-script mymaster /opt/data-6379/redis-client-reconfig.sh
sentinel down-after-milliseconds mymaster 3000

```

### Jedis
http://www.cnblogs.com/xujishou/p/6511111.html


