#!/bin/bash

podman volume exists steamapp-$STEAMCMD_APPID && export MY_VOLUME=steamapp-$STEAMCMD_APPID || export MY_VOLUME=$(podman volume create steamapp-$STEAMCMD_APPID)

podman run -it --name steamcmd \
	-v $MY_VOLUME:/mnt/app:Z \
	quay.io/steamutils/steamcmd:latest \
	+@sSteamCmdForcePlatformType windows +force_install_dir /mnt/app +login anonymous +app_update $STEAMCMD_APPID "-$STEAMCMD_BRANCH validate" +quit

podman rm -f steamcmd

cd $(podman volume inspect steamapp-$STEAMCMD_APPID | jq -r '.[].Mountpoint')

du -hs $(podman volume inspect steamapp-$STEAMCMD_APPID | jq -r '.[].Mountpoint')

ls
