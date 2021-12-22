# Gremlin SELinux Policies

The repository contains a set of SELinux policies that can be applied to Linux systems for the purpose of granting various priviledges to Gremlin.


## What is SELinux?

[SELinux][about_selinux] is a security architecture for Linux commonly used in container orchestration systems where security is paramount. It uses policy definitions to enforce access controls for specific applications, processes and files.

## Why do I need to install a Gremlin SELinux Policy?

When Gremlin is installed into an SELinux system as a container (e.g Docker constainer, Kubernetes daemonset), the container runtime that manages Gremlin will run the Gremlin processes under the SELinux process label type `container_t`. Gremlin performs some actions that are not allowed by this process label:

* Install and manipulate files on the host: `/var/lib/gremlin`, `/var/log/gremlin`
* Load kernel modules for manipulating network transactions during network attacks, such as `net_sch`
* Communicate with the container runtime socket (e.g. `/var/run/docker.sock`) to launch containers that carry out attacks
* Read files in `/proc`

**When you install Gremlin as root directly onto your host machines, you likely do not need to install any of these policies**, as Gremlin should run under SELinux process label type `unconfined_t`.

To alleviate the privilege restrictions imposed on `container_t`, you can [allow these privileges to `container_t`][about_allowcontainert], providing Gremlin with everything it needs, but this would also give the same privileges to all other containers on your system, which is not ideal.

This project crates a new process label type `gremlin.process` and adds all the necessary privileges Gremlin needs, so that you can grant them to Gremlin only, and nothing else.

Gremlin builds on the SELinux inheritance patterns set out in [containers/udica][about_containersudica], providing Gremlin privileges on top of standard container privileges. See the policy [here][gremlinpolicy].

## Support

| Policy Version | OpenShift 3.x | OpenShift 4.x |
| -------------- | --------------| ------------- |
| v0.0.1         | ✓             | ✘             |
| v0.0.2         | ✓             | Issue with OpenShift +4.2 ([Issue #3](/gremlin/selinux-policies/issues/3)) |
| v0.0.3         | ✓             | ✓             |

## Installation

You can install the SELinux module by downloading from the [releases page][releases] (or via `curl`)

```shell
curl -fsSL https://github.com/gremlin/selinux-policies/releases/download/v0.0.3/selinux-policies-v0.0.3.tar.gz -o selinux-policies-v0.0.3.tar.gz
tar xzf selinux-policies-v0.0.3.tar.gz
sudo semodule -i selinux-policies-v0.0.3/gremlin-openshift3.cil
```

You you can follow the remaining subsections to install directly from source.

### Install build tools


```shell
yum install git
```

### Build the SELinux policy

```shell
make gremlin-openshift3.cil
```

### Install the SELinux module


```shell
make install-openshift3
```

Or with `semodule` directly

```
semodule -i gremlin-openshift3.cil
```

## Configuration

This policy creates a new SELinux process type `gremlin.process`, you must run your Gremlin containers under this type. Use the section that corresponds to your runtime target.

### Configure: Docker

Pass `--security-opt` to an existing `docker run` command

```shell
docker run -it \
	--security-opt=label=type:gremlin.process \
	-e GREMLIN_IDENTIFIER -e GREMLIN_TEAM_ID -e GREMLIN_TEAM_SECRET \
	-v /var/lib/gremlin:z -v /var/log/gremlin:z -v /var/run/docker.sock \
	gremlin/gremlin daemon
```

### Configure: Kubernetes

To make the Gremlin daemonset run within the `gremlin.process` context, place the following `securityContext` into the existing Gremlin daemonset YAML.

```yaml
...
securityContext:
  seLinuxOptions:
    type: gremlin.process
```

### Configure: OpenShift

Like [the configuration for kubernetes][config_kubernetes], the Gremlin daemonset must run with the `gremlin.process` SELinux context. For openshift, this should be controlled through a [SecurityContextConstraints][about_scc] policy instead of directly through a Kubernetes `securityContext`.

```yaml
apiVersion: security.openshift.io/v1
allowHostDirVolumePlugin: true
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: null
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups: []
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'gremlin provides all the features of the
      restricted SCC but allows host mounts, any UID by a pod, and forces 
      the process to run as the gremlin.process SELinux type. This is intended 
      to be used solely by Gremlin. WARNING: this SCC allows host file
      system access as any UID, including UID 0. Grant with caution.'
  name: gremlin
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
- MKNOD
runAsUser:
  type: RunAsAny
seLinuxContext:
  seLinuxOptions:
    type: gremlin.process
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
volumes:
- configMap
- emptyDir
- hostPath
- persistentVolumeClaim
- secret
```

## Uninstallation

```shell
make uninstall
```

Or with `semodule` directly

```shell
semodule -r gremlin
```

[releases]: https://github.com/gremlin/selinux-policies/releases
[about_selinux]: https://www.redhat.com/en/topics/linux/what-is-selinux
[configuration]: #configuration
[config_kubernetes]: #configure-kubernetes
[configure_kubernetes]: #configure-openshift
[about_scc]: https://docs.openshift.com/container-platform/4.5/authentication/managing-security-context-constraints.html#:~:text=Updating%20an%20SCC-,About%20Security%20Context%20Constraints,what%20resources%20it%20can%20access.
[about_allowcontainert]: https://gremlin.com/docs/security/overview/#bypass-container_t-restrictions
[about_containersudica]: https://github.com/containers/udica
[gremlinpolicy]: https://github.com/gremlin/selinux-policies/blob/master/policies/gremlin_container.cil
