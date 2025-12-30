# Manual preparation of the Oneprovider node 

In order to ensure optimum performance of the Oneprovider service,
several low-level settings need to be tuned on the host machine. This applies
to both Docker based and package based installations, in particular to
nodes where Couchbase database instance are deployed.

## Increase maximum number of opened files

In order to install Oneprovider service on one of the supported operating systems, first make sure that the maximum
limit of opened files is sufficient (preferably 63536, but below `/proc/sys/fs/file-max`). The limit can be checked
using:

```sh
ulimit -n
```

If necessary, increase the limit using:

```sh
sudo sh -c 'echo "* soft nofile 63536" >> /etc/security/limits.conf'
sudo sh -c 'echo "* hard nofile 63536" >> /etc/security/limits.conf'
```

::: tip
It might be also necessary to set up the limit in `/etc/systemd/system.conf`:

```sh
sudo sh -c 'echo DefaultLimitNOFILE=65536 >> /etc/systemd/system.conf'
sudo systemctl daemon-reexec
```

:::

## Swap preference settings

Make sure that the swap preference (i.e. *swappiness*) is set to `0` (or at most `1` — see [here][install-swap-space]
for details):

```sh
cat /proc/sys/vm/swappiness
```

and if necessary, decrease it using:

```sh
sudo sh -c 'echo "vm.swappiness=0" >> /etc/sysctl.d/50-swappiness.conf'
sudo systemctl restart systemd-sysctl
```

## Disable Transparent Huge Pages feature

By default, many Linux machines have the Transparent Huge Pages feature enabled, which somewhat improves
the performance of machines running multiple application at once (e.g. desktop operating systems), however it
deteriorates the performance of most database-heavy applications, such as Oneprovider.

These settings can be checked using the following commands (the output shown below presents the expected settings):

```sh
cat /sys/kernel/mm/transparent_hugepage/enabled
# Expected output: always madvise [never]
```

```sh
cat /sys/kernel/mm/transparent_hugepage/defrag
# Expected output: always madvise [never]
```

If any of the settings is different from the above, they should be changed permanently, which can be achieved for
instance by creating a simple **systemd** unit file `/etc/systemd/system/disable-thp.service`:

::: tip NOTE
If the output is `cat: /sys/kernel/mm/transparent_hugepage/enabled: No such file or directory` then
THP feature is not configured in the kernel and no further action is required.
:::

```systemd
[Unit]
Description=Disable Transparent Huge Pages

[Service]
Type=oneshot
ExecStart=/bin/sh -c "/bin/echo 'never' | /usr/bin/tee /sys/kernel/mm/transparent_hugepage/enabled"
ExecStart=/bin/sh -c "/bin/echo 'never' | /usr/bin/tee /sys/kernel/mm/transparent_hugepage/defrag"

[Install]
WantedBy=multi-user.target
```

and enabling it on system startup using:

```sh
sudo systemctl enable disable-thp.service
sudo systemctl start disable-thp.service
```

## Node hostname

Make sure that the machine has a resolvable, domain-style hostname (it can be Fully Qualified Domain Name or just
a proper entry in `/etc/hostname` and `/etc/hosts`) — for this tutorial it is set to `oneprovider-example.com`.

Following command examples assumes an environment variable `ONEPROVIDER_HOST` is available, for instance:

```sh
export ONEPROVIDER_HOST="oneprovider-example.com"
```

::: tip NOTE
You can check the proper setting of hostname with the hostname command, for example:
:::

```sh
hostname
# Example output: oneprovider-example
hostname -f
# Example output: oneprovider-example.com
```

## Docker

The Docker software needs to be installed on the machine. It can be done by using the convenience
script from `get.docker.com`:

```sh
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

## Set kernel parameters

It is recommended to set some kernel parameters. The network memory limits influence the file transfer performance.

```sh
echo "net.core.wmem_max = 16777216" | sudo tee -a /etc/sysctl.conf
echo "net.core.rmem_max = 16777216" | sudo tee -a /etc/sysctl.conf
echo "kernel.unprivileged_userns_clone = 0" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## Prepare persistence volume

The following commands require an empty block device to be available. The existing data on
the block device will be lost. A logical volume will be created on this block device. It is intended to store
the persistent data of Onedata services. Using an LVM volume allows for better management of the deployment,
especially when doing snapshot-based live backups.

```sh
# Replace sdX with your actual block device
BLOCK_DEVICE=/dev/sdX
```

```sh
sudo mkdir -p /opt/onedata
sudo chmod 0755 /opt/onedata
sudo pvcreate ${BLOCK_DEVICE}
sudo vgcreate onedata_vg ${BLOCK_DEVICE}
sudo lvcreate -l 80%VG -n lvol0 onedata_vg
sudo mkfs.ext4 /dev/onedata_vg/lvol0
sudo mount /dev/onedata_vg/lvol0 /opt/onedata
echo '/dev/onedata_vg/lvol0 /opt/onedata ext4 defaults 0 0' | sudo tee -a /etc/fstab
```

After these settings are modified, the machine needs to be rebooted.

<!-- references -->

[install-swap-space]: https://developer.couchbase.com/documentation/server/current/install/install-swap-space.html
