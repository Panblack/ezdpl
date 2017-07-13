#!/bin/bash
#Statistics for tomcat access logs, by panblack@126.com
#server.xml must be modified like this:
#        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
#               prefix="localhost_access_log" suffix=".txt"
#               pattern="%h %l %u %t &quot;%r&quot; %s %b %D %S %{X-Forwarded-For}i %{Referer}i" />
#1.direct IP 2.login 3.user 4.Access time 5.TimeZone "6.method 7.URI 8.protocol" 9.StatusCode 10.bytes 11.miliseonds 12.SessionID 13.Real IP 14.Referer
#
#DateOfLog       Server  IP      Request Error   Session
#2017-01-14      app01   23      7624    9       33
#2017-01-14      app02   30      3345    6       34
#2017-01-14      app03   11      138     0       5
#2017-01-14      app04   2       5       0       1
#2017-01-14      app05   0       0       0       0
#2017-01-14      app06   28      1785    0       30
#2017-01-14      app07   31      1961    83      43
#2017-01-14      app08   33      597     37      40

# Determine ezdpl home
if [[ -z ${EZDPL_HOME} ]]; then
    _dir=$(dirname `readlink -f $0`)
    cd $_dir && cd ..
    EZDPL_HOME=`pwd`
fi
echo "EZDPL_HOME : ${EZDPL_HOME}"

if [[ -n $1 ]]; then
    # Date format: yyyy-mm-dd
    _date=$1
    _year=`echo $_date|awk -F'-' '{print $1}'`
else
    _date=`date +%F`
    _year=`date +%Y`
fi
_report_file="/opt/report/access_stats/access_${_year}.txt"
_raw_file_path="/mnt/nfsdata/logs"
_log_file_name="localhost_access_log.${_date}.txt"

if [[ ! -f $_report_file ]];then
  echo -e "Date\tApp\tServer\tIP\tError4\tError5\tSession\tRequest" > $_report_file
fi

#for x in `seq -f"app%02g" 1 8`;do

_SQL="SELECT srvname , webname  FROM v_srvweb "
_servers=`${EZDPL_HOME}/bin/sqlezdpl "$_SQL" 2>/dev/null |egrep -v 'srvname'`
IFS=$'\n'
for x in $_servers ;do
  _srv=`echo $x|awk -F'\t' '{print $1}'`
  _web=`echo $x|awk -F'\t' '{print $2}'`
  _log_file_raw="$_raw_file_path/$_srv/$_web/$_log_file_name"

  echo "$_web , $_srv , $_log_file_raw"
  if [[ $_web = webservice ]]; then
      # Internal access counts for service
      _log_file=`cat $_log_file_raw`
      _ip_request=`echo "$_log_file"|awk '{print $1}'`
  else
      # search for lines started with ip addresses of Load Balancers.
      _log_file=`cat $_log_file_raw |egrep '(^10.1.1.1|^10.1.1.2|^10.1.1.3)'`
      _ip_request=`echo "$_log_file"   |sed 's/, /,/g'|awk '{print $13}'|egrep -v "-"`
  fi
  _ip_count=`echo "$_ip_request"      |sort|uniq|wc -l`
  _request_count=`echo "$_ip_request" |wc -l`
  _error_count4=`echo  "$_log_file"   |awk '{print $9}' |egrep ^4 |wc -l`
  _error_count5=`echo  "$_log_file"   |awk '{print $9}' |egrep ^5 |wc -l`
  _session_count=`echo "$_log_file"   |awk '{print $12}'|egrep -v "^-$" |sort|uniq|wc -l`

  echo -e "${_date}\t${_web}\t${_srv}\t${_ip_count}\t${_error_count4}\t${_error_count5}\t${_session_count}\t${_request_count}" >> $_report_file

done

