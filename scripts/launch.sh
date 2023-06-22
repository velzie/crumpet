#!/bin/bash


SELF="$(readlink -f "$0")"

DIR=$(dirname "$SELF")

cleanup() {
    pkill -P $$
}

for sig in INT QUIT HUP TERM; do
  trap "
    cleanup
    trap - $sig EXIT
    kill -s $sig "'"$$"' "$sig"
done
trap cleanup EXIT

if [ "$DISPLAY" == "" ]; then
  echo "no display?"
  exit
fi

export GOOGLE_API_KEY="AIzaSyCkfPOPZXDKNn8hhgu3JrA62wIgC93d44k"
export GOOGLE_DEFAULT_CLIENT_ID="77185425430.apps.googleusercontent.com"
export GOOGLE_DEFAULT_CLIENT_SECRET="OTJgUOQcT7lO7GsGZq2G4IlT"
# these are keys stolen from gentoo, for the sole reason that i don't feel like setting them up myself

"$DIR/kiosk.sh" &

while true; do
  "$DIR/chrome_silly" --login-manager --user-data-dir=/home/chronos --no-sandbox &
  # chrome can spawn children, this catches most edge cases
  while pgrep "chrome_silly" >/dev/null; do
    sleep 2.5
  done
done
