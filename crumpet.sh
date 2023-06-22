#!/bin/bash

ROOTFS=/home/ce/chromiumos/src/build/images/amd64-generic/R116-15507.0.0-d2023_06_20_143502-a1/rootfs
TTY=9
SELF=$(realpath "$0")
DIR=$(dirname "$SELF")

inside(){
 chroot "$ROOTFS" /usr/bin/env LD_LIBRARY_PATH=/opt/google/chrome:/usr/local/lib64 PATH=/usr/local/bin/:/usr/local/sbin/:/usr/bin/:/usr/sbin/:/bin/:/sbin/ "$@"
}
inside_chronos(){
  chroot "$ROOTFS" sudo -u chronos LD_LIBRARY_PATH=/opt/google/chrome:/usr/local/lib64 PATH=/usr/local/bin/:/usr/local/sbin/:/usr/bin/:/usr/sbin/:/bin/:/sbin/ bash -c "$*"
}


mnt(){
  mkdir -p "$ROOTFS/sys" "$ROOTFS/proc" "$ROOTFS/dev" "$ROOTFS/tmp" "$ROOTFS/run"
  mount --bind /sys "$ROOTFS/sys"
  mount --bind /proc "$ROOTFS/proc"
  mount --bind /dev "$ROOTFS/dev"
  mount --bind /run "$ROOTFS/run"
  mount --bind /tmp "$ROOTFS/tmp"
  inside chmod 1777 /dev/shm
}




unmnt(){
  umount "$ROOTFS/"*
}

xserver(){
  OTTY=$(fgconsole)
  if [[ "$(tty)" == *"/dev/tty"* ]]; then
    clear
    echo starting x
    startx "$SELF" xserver_poststart $OTTY
  else
    openvt -c$TTY -- "$SELF" xserver
  fi
}
stop(){
  kill $(</tmp/crumpet-pid)
  kill $(</tmp/crumpet-ash-pid)
}

startui(){
  . /tmp/crumpet-x
  inside_chronos rm '~/.Xauthority'
  inside_chronos touch '~/.Xauthority'
  while read cookie; do
    inside_chronos xauth -f '~/.Xauthority' add $cookie
  done <<< "$(xauth list)"
  cp "$DIR/kiosk.sh" "$ROOTFS/opt/google/chrome"
  cp "$DIR/launch.sh" "$ROOTFS/opt/google/chrome"
  chvt "$TTY"
  echo $$ > /tmp/crumpet-ash-pid
  inside_chronos /opt/google/chrome/launch.sh
}

xserver_poststart(){
  echo "DISPLAY=$DISPLAY">/tmp/crumpet-x
  echo $$ > /tmp/crumpet-pid
  chvt "$1"
  tail -f /dev/null
}



activate(){
  mnt
  if ! [ -f /tmp/crumpet-pid ] || ! [ -d "/proc/$(</tmp/crumpet-pid)/" ]; then
    xserver 
    echo "X server started! Launch ash with 'crumpet startui', outside of the chroot "
  fi
}

enter-chroot(){
  activate
  inside_chronos bash
}



$@
