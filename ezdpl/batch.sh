#!/bin/bash
IFS="
"
for x in `cat server.list`;do
  _host=${x// /}
  echo [ $_host ]
  sh ezdpl Y $_host common/ban_ssh
done

