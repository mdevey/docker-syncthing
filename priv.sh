#!/bin/bash
set -e

if [ "$HOME" = '/home/user' ]; then
	echo >&2 'uh oh, HOME=/home/user'
	exit 1
fi

mkdir -p "$HOME/Sync"
mkdir -p "$HOME/.config/syncthing"

set -x
docker run -d \
	--privileged \
	--name syncthing \
	--restart always \
	--user "$(id -u):$(id -g)" \
	-v "$HOME/Sync:$HOME/Sync" \
	-v "$HOME/.config/syncthing:/home/user/.config/syncthing" \
	-p 8384:8384 \
	-p 22000:22000 \
	-p 21027:21027/udp \
	mdevey/syncthing "$@"
timeout 10s docker logs -f syncthing || true
