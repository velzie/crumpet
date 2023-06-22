#!/bin/bash

gwid(){
  while [ -z $WID ]; do
    echo selecting wid
    WID=$(xdotool search --onlyvisible ".*" | tail -1)
    xdotool getwindowpid $WID || WID=
  done
}
# gwid
GEO=$(xdotool getdisplaygeometry)

W=${GEO% *}
H=${GEO#* }

while true; do
  while read -r WID; do
  xdotool windowmove $WID 0 0
  xdotool windowsize $WID $((W - 1)) $((H - 1))
  done <<<"$(xdotool search --onlyvisible ".*" 2>/dev/null)"
  sleep 0.5
done
