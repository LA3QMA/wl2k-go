#!/bin/sh
#
# This script is written to help configure an axport to use as a winlink node.
# It sets AX.25 and KISS params appropriate to the given HBAUD (link baudrate) and
# prints kissattach's pid after it is daemonized.
#
set -e
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
  then echo "Usage: $0 [tty] [axport] [1200/9600]"
  exit 1;
fi
if [ "$3" -eq "9600" ]; then
  /usr/local/bin/tmd710_tncsetup -B 1 -S $1 -b $3 -i 1
  /usr/local/bin/tmd710_tncsetup -B 1 -S $1 -b $3
  /usr/sbin/kissattach $1 $2 -m 256
  /usr/sbin/kissparms -p $2 -t 100 -l 10 -s 12 -r 80 -f n
  echo 4      > /proc/sys/net/ax25/ax0/standard_window_size  # 2-7 (max frames)
  echo 256    > /proc/sys/net/ax25/ax0/maximum_packet_length # 1-512 (paclen)
  echo 3100   > /proc/sys/net/ax25/ax0/t1_timeout            # (Frack /1000 = seconds)
  echo 800    > /proc/sys/net/ax25/ax0/t2_timeout            # (RESPtime /1000 = seconds)
  echo 300000 > /proc/sys/net/ax25/ax0/t3_timeout            # (Check /1000 = seconds)
  echo 100000  > /proc/sys/net/ax25/ax0/idle_timeout         # (/10000(?) = seconds)
  echo 5      > /proc/sys/net/ax25/ax0/maximum_retry_count   # n
  echo 2      > /proc/sys/net/ax25/ax0/connect_mode          # 0 = None, 1 = Network, 2 = All
elif [ "$3" -eq "1200" ]; then
  /usr/local/bin/tmd710_tncsetup -B 1 -S $1 -b $3 -i 1
  /usr/local/bin/tmd710_tncsetup -B 1 -S $1 -b $3
  /usr/sbin/kissattach $1 $2 -m 128
  /usr/sbin/kissparms -p $2 -t 150 -l 10 -s 12 -r 80 -f n
  echo 4      > /proc/sys/net/ax25/ax0/standard_window_size
  echo 128    > /proc/sys/net/ax25/ax0/maximum_packet_length
  echo 2000   > /proc/sys/net/ax25/ax0/t1_timeout
  echo 1000   > /proc/sys/net/ax25/ax0/t2_timeout
  echo 300000 > /proc/sys/net/ax25/ax0/t3_timeout
  echo 100000   > /proc/sys/net/ax25/ax0/idle_timeout
  echo 5      > /proc/sys/net/ax25/ax0/maximum_retry_count
  echo 2      > /proc/sys/net/ax25/ax0/connect_mode
else
  echo "Invalid HBAUD $3"
  return 1;
fi

#APRS beacon: /usr/sbin/beacon -l -d "APK102 WIDE2-2" tmd710 '!6010.80N/00523.84E]Winlink P2P @ 144.800MHz 1200bd'
