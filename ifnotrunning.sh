#!/bin/bash
proc=`ps -A|grep "$1"`
if [ -z "$proc" ]
then
  echo "$*"
  $*
else
  echo "Running"
fi
