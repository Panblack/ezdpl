#!/usr/bin/python3
# -*- coding: UTF-8 -*-
# A simple program to send tcp/udp payload to target server

import time
import sys,socket,getopt  

#Main
if __name__=='__main__':
    def usage():
        print("Useage:pysocket [-h] [-v] -s <socket_server> -p <port> -l <payload> -u")
        sys.exit(3)

    try:
        options,args=getopt.getopt(sys.argv[1:],"huvs:p:l:","--help --udp --verbose --server= --port= --payload=",)
    except getopt.GetoptError:
        usage()
        sys.exit(3)

    _server=None
    _port=None
    _payload=None
    _udp=False
    _verbose=False
    _return=None
    _info=None
    for name,value in options:
        if name in ("-h","--help"):
            usage()
        if name in ("-s","--server"):
            _server=value
        if name in ("-p","--port"):
            _port=value
        if name in ("-l","--payload"):
            _payload=value
        if name in ("-u","--udp"):
            _udp=True
        if name in ("-v","--verbose"):
            _verbose=True
    
    _starttime=time.time()
    if _server and _port and _payload:
        if _udp:
            sockets = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        else:
            sockets = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

        if _verbose:
            print("\nStart Time: %s\tServer: %s:%s\tUDP: %s" %(_starttime,_server,_port,_udp))

        try:
            sockets.settimeout(3)
            sockets.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            sockets.connect((_server, int(_port))) 
            sockets.send(bytes(_payload , encoding='utf8'));
            _return = sockets.recv(1204)
            _info = _return.decode()
            print("%s" %(_info))
        except socket.error:
            print("Request failed")

        _endtime=time.time()
        sockets.close()
        if _verbose:
            print("End   Time: %s" %(_endtime))
    else:
        usage()
#End

