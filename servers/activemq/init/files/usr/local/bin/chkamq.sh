#!/bin/bash
if ss -lntp|grep java|grep 61616; then
    echo "amq ok"
else
    /usr/local/bin/amq up
fi

