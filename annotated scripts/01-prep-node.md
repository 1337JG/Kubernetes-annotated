# Node Prep Script

## This script is needed to alter some things in kernel, disable swap memory along with other things.

---

## step 1

`set -e`

**What?**

this makes the script terminate immediately if it runs into any errors.

**Why?**

this is a good thing to turn on because if the script runs into some errors and it still continues the VM can be corrupted or installation can be incomplete resulting in a useless VM and wasted time.

---

## step 2

```bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo"
    exit 1
fi

```

**What?**
This Checks whether we have root permissions or not before executing the rest of the script.

**Why?**
if we don't have proper root permissions doing kernel level changes is not possible. to ensure smooth installation this is mandatory.

**The Concept of ROOT PERMISSSIONS:** root permissions means the highest number of permissions one can have to make changes in a Virtual machine. with root permissions we can do whatever changes we feel like.

---

## step 3

` swapoff -a `

**What?**
disables swap memory. 

**Why?** 
kubernetes needs swap memory to permanently disabled so the node agent can manage container allocation memory properly.

**The Concept of swap memory:** Swap memory facilitates memory management by temporarily storing inactive data on the disk.

---

## step 4

`sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab`

**What?** This command permanently disables swap memory for the VM. 

**Why?** Earlier, swapoff -a disabled swap only for the current session. If the machine reboots, Linux reads /etc/fstab and enables swap again.

By commenting out the swap entry, we make the change persistent, ensuring swap remains disabled across reboots.

**Background**

**sed:** sed stands for Stream editor.

**fstab:** this stands for file system table. it's a configuration file which tells linux which partitions should be mounted and which to ignore.

---

## step 5

```bash
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```

**What?**

this creates a config file which tells linux to automatically load the `overlay` and `br_netfilter` kernel modules every time the vm boots.

**Why?**

kubernetes needs these modules for networking and container management. by putting them inside this file we don't have to manually load them after every reboot.

**The Concepts**

**kernel modules:** kernel modules are small pieces of code which can be loaded into the linux kernel whenever needed. they add extra functionality without changing or rebuilding the whole kernel.

**overlay:** this module enables overlayfs, a filesystem used by container runtimes like containerd. it helps containers share image layers instead of storing duplicate copies which saves disk space.

**br_netfilter:** this module allows network traffic passing through linux bridges to be seen by iptables. kubernetes networking depends on this so firewall rules can be applied to pod traffic.

---

## step 6

```bash
modprobe overlay
modprobe br_netfilter
```

**What?**

these commands load the `overlay` and `br_netfilter` kernel modules into the running linux kernel.

**Why?**

in the previous step we only told linux to load them during boot. these commands load them right now so we don't have to restart the vm before continuing the installation.

**The concept of "modprobe":**

**modprobe:** modprobe is a linux command used to load kernel modules into memory. if a module depends on other modules, modprobe loads those as well automatically.

---

## step 7

```bash
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

**What?**

this creates a config file which stores some kernel networking settings required by kubernetes.

**Why?**

kubernetes does a lot of networking between pods, services and nodes. these settings make sure network packets go through iptables and also allow the node to forward packets between different networks. without them pod networking may not work properly.

**The Concepts:**

**sysctl:** sysctl is a linux utility used to view or change kernel settings. instead of changing the kernel manually we can change different parameters using sysctl.

**iptables:** iptables is a linux utility used to configure the kernel's firewall (Netfilter). kubernetes uses it to create rules for routing traffic between pods and services.

**ip forwarding:** ip forwarding allows a linux machine to receive a network packet on one interface and send it out through another. kubernetes nodes need this because they constantly route traffic between pods and other nodes.

---

## step 8

```bash
sysctl --system
```

**What?**

this command reloads all the sysctl configuration files and applies the settings to the running system.

**Why?**

creating the config file alone doesn't change anything. this command tells linux to read those files and apply all the new kernel settings immediately instead of waiting for a reboot.

**The Concept of applying sysctl settings:**

linux reads the files inside `/etc/sysctl.d/` during boot. `sysctl --system` does the same thing while the system is already running, so the new settings become active instantly.

---

## step 9

```
apt-get update
apt-get install -y containerd
```

**What?**
these commands check and download updates for ubuntu if they are available.

`apt-get install -y containerd`: This command installs the container runtime containerd in our VM.

**Why?**

we update the VM before installing applications in it to ensure we have latest version of applications/dependencies needed to run the app we are downloding. 

We install container runtime (containerD) because kubernetes is a container orchatestration system and to run containers we need a runtime.

**The Concept of Container Runtime:** kubernetes is very flexible, it gives us multiple options when installing a container runtime. runtime means the core software that's responsible for pulling, unpacakaging and executing/running container images.
most widely used runtimes are containerd and CRI-O

---

## step 10

```bash
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml > /dev/null
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
```

**What?**

the first command creates the containerd config directory if it doesn't already exist.

the second command generates the default configuration file for containerd and saves it as `config.toml`.

the third command changes one setting inside that file so containerd uses `systemd` for managing cgroups.

**Why?**

containerd works with its default config, but kubernetes recommends using the systemd cgroup driver. this way both kubelet and containerd manage resources in the same way which avoids weird resource management issues.

**The Concept of "cgroups":**

**cgroups:** cgroups stands for control groups. it's a linux kernel feature used to control how much cpu, memory and other resources a process or container is allowed to use.

**systemd cgroup driver:** this tells containerd to let systemd handle cgroups. since kubelet also uses systemd on most linux distributions, both of them stay in sync while managing containers.

---

## step 11

```bash
systemctl restart containerd
systemctl enable containerd
```

**What?**

the first command restarts the containerd service.

the second command makes sure containerd starts automatically every time the vm boots.

**Why?**

we restart it because we changed its configuration in the previous step. if we don't restart it, containerd will continue using the old settings.

enabling the service means we don't have to manually start it after every reboot.

**The Concept of "systemd services":**

**systemd:** systemd is the service manager used by most linux distributions. it is responsible for starting, stopping and managing background services.

**restart:** stops a service and starts it again so any new configuration takes effect.

**enable:** registers the service to automatically start whenever the operating system boots.

---

## step 12

```bash
apt-get install -y apt-transport-https ca-certificates curl gpg
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
```

**What?**

the first command installs the tools needed to securely download packages from the internet.

the second command creates a directory where apt stores repository keys.

the third command downloads kubernetes' official gpg key and stores it in that directory.

the last command adds the official kubernetes repository to apt.

**Why?**

ubuntu's default repositories don't always have the latest kubernetes packages. by adding the official repository we make sure apt downloads the packages directly from the kubernetes project.

the gpg key is used to verify that the packages actually came from kubernetes and were not modified by someone else.

**The Concept of repositories:**

**repository:** a repository is basically an online storage where linux downloads software packages from.

**gpg key:** a gpg key is used to verify the authenticity of packages before installing them. this helps make sure the software hasn't been tampered with.

**apt keyring:** this is where apt stores trusted keys used to verify software repositories.

---

## step 13

```bash
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
```

**What?**

the first command updates the package list.

the second command installs `kubelet`, `kubeadm` and `kubectl`.

the third command locks these packages so apt won't automatically upgrade them.

**Why?**

these are the core kubernetes tools needed on every node.

`kubelet` is responsible for talking to the container runtime and making sure pods are running properly.

`kubeadm` is used to initialize a new kubernetes cluster or join a node to an existing one.

`kubectl` is the command line tool used to communicate with the kubernetes api server and manage cluster resources.

we hold these packages because kubernetes components are designed to work with specific versions. if apt upgrades one of them automatically while the others stay the same, it can cause compatibility issues or break the cluster.

**The Concept of holding packages:** holding a package tells apt not to upgrade it automatically. this helps keep all kubernetes components on compatible versions until we intentionally decide to upgrade the cluster.





