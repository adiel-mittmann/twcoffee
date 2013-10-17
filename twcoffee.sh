#!/bin/bash

t1=`mktemp`
t2=`mktemp`

function cleanup()
{
  rm -rf $t1
  rm -rf $t2
}

function sigint()
{
  echo "Saindo."
  cleanup
  exit 0
}

trap sigint SIGINT

touch -d "-15 minutes" $t1

base="${0%/*}"

script -c "t stream timeline -l" /dev/null | grep --line-buffered "o café está pronto" | {
  while read line; do
    echo $line
    date=`echo $line | sed -e 's#^[0-9]* \([^@]*\) @.*$#\1#'`
    touch -d "$date" $t2
    if [ $t2 -nt $t1 ]; then
      xmessage -nearmouse "COFFEE" &>/dev/null &
      mplayer -really-quiet -ao pulse -vo null $base/coffee.ogg &>/dev/null
    fi
  done
}

cleanup
