# steamcmd
steamcmd container image

Guide recommendations:

* [Podman](https://podman.io/)
* [jq](https://jqlang.github.io/jq/download/)

You can obviously use docker if you prefer. docker-compose instructions are not included, in favor of kube play.

## >>> [Examples](github.com/steamutils/steamcmd/examples) <<<

## Quickstart: Manual

#### Create a volume to store your app

```
#!/bin/bash

$MY_VOLUME=$(podman volume create steamapp-123456)
```

#### Verify your volume is there
```
$  podman volume ls -f name=$MY_VOLUME
DRIVER      VOLUME NAME
local       steamapp-123456
```

#### Check if it's empty
```
$  du -hs $(podman volume inspect $MY_VOLUME | jq -r '.[].Mountpoint')
0	/home/username/.local/share/containers/storage/volumes/steamapp-123456/_data
```

#### Download and install your application
```
$  podman run --name steamcmd \
        -v $MY_VOLUME:/app:Z \
        quay.io/steamutils/steamcmd:latest \
        +@sSteamCmdForcePlatformType windows +force_install_dir /app +login anonymous +app_update 123456 -public validate +quit
```
* Refer to https://developer.valvesoftware.com/wiki/SteamCMD#Automating_SteamCMD for more steamcmd arguments

#### Prune leftover container
```
podman container prune
```

#### Validate that your application was downloaded
```
$  du -hs $(podman volume inspect $MY_VOLUME | jq -r '.[].Mountpoint')

13G	/home/username/.local/share/containers/storage/volumes/steamapp-123456/_data

# Optionally if you want to see the contents:
cd $(podman volume inspect $MY_VOLUME | jq -r '.[].Mountpoint') && ls -la
```

---

## Guide: Podman Kube Play (Kubernetes Manifest)

This is the compose/declarative method. You will need to replace the values with your appropriate desired Steam App IDs.

#### Create your manifest
```
cat <<EOT > deployment.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: steamapp-123456
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: steamcmd
        image: quay.io/steamutils/steamcmd:latest
        volumeMounts:
        - mountPath: /mnt/app
          name: appvol
        args: ["+@sSteamCmdForcePlatformType","windows","+force_install_dir","/mnt/app","+login","anonymous","+app_update","123456","-public","validate"]
      volumes:
      - name: appvol
        persistentVolumeClaim:
          claimName: steamapp-123456
EOT
```
#### Run deployment
```
podman kube play deployment.yaml
```

#### Watch the log output of the pod
```
podman logs -f $(podman ps -a -f name='steamapp-*' --format json | jq -r '.[].Names[]')
```
Output
```
tid(6) burning pthread_key_t == 0 so we never use it
WARNING: setlocale('en_US.UTF-8') failed, using locale: 'C'. International characters may not work.
Redirecting stderr to '/root/Steam/logs/stderr.txt'
Logging directory: '/root/Steam/logs'
minidumps folder is set to /tmp/dumps
[  0%] Checking for available updates...
[----] Verifying installation...
UpdateUI: skip show logoSteam Console Client (c) Valve Corporation - version xxxxxxxxxx
-- type 'quit' to exit --
Loading Steam API...OK
"@sSteamCmdForcePlatformType" = "windows"

Connecting anonymously to Steam Public...OK
Waiting for client config...OK
Waiting for user info...OK
Success! App '123456' already up to date.
```
Ctrl+C to cancel tailing log output when you either see the download complete, or the `Success! App '123456' already up to date.` message in the end of the log.

#### Spin down the deployment

```
podman kube down deployment.yaml
```

#### Validate volume is populated 
```
du -hs $(podman volume inspect steamapp-123456 | jq -r '.[].Mountpoint')

13G	/home/username/.local/share/containers/storage/volumes/steamapp-123456/_data
```

---