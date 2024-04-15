# Examples

In this directory there are two examples:

* `deployment.yaml` which can be used with `podman kube play` or with Kubernetes
* `podman.sh` which can be sourced for an easy and simple method of using this image

## podman.sh Example

### *Required Variables*
|Variable  | Example |
|--|--|
| STEAMCMD_APPID | 123456 |
| STEAMCMD_BRANCH | public |

```
export STEAMCMD_APPID=123456
export STEAMCMD_BRANCH=public

chmod +x podman.sh
source ./podman.sh
```

When the script is done, you should see your app files in the volume mount.