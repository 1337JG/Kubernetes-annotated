![Repository Banner](/assets/k8s.png)

This repository contains the scripts i used while learning Kubernetes. Every script is annotated to explain what each command does, why it exists and what concept it belongs to.

The idea isn't just to end up with a working cluster. It's to understand what is actually happening while the cluster is being built.

Current Kubernetes version: **v1.36.3**

I'll try to keep the scripts updated but kubenetes updates are FAST.

---

Right now the repository covers the complete installation process including node preparation, containerd, kubeadm, kubelet, kubectl, the control plane, worker nodes and Calico networking.

I'll keep expanding it with notes on etcd, Raft, quorum, Paxos, CRDs, the scheduler, the controller manager, CoreDNS, kube-proxy and eventually whatever distributed systems rabbit hole Kubernetes sends me into next.

This isn't meant to be another repository where you copy a script, run it once and forget it exists. there are many out there.

I wanted to understand why swap has to be disabled, what `br_netfilter` actually does, why a container runtime is needed, how the kubelet talks to the API server, why CNI plugins exist and what etcd is really storing. Those are the kinds of questions these notes try to answer.

---

## How to actually use these scripts?

### Prerequisites.

1. Two plus Virtual machines
2. SSH level access to those VMs
3. root permissions inside those VMs
4. Instance Naming: Set the name explicitly based on its role (e.g., k8s-master or k8s-worker).
5. OS Selection: Preferably use Ubuntu LTS.
6. Region: Pick the geographically closest region to minimize latency.
7. Sizing Requirements: Minimum specs for a sandbox cluster: 30 GB storage, 2 vCPUs, and 4 GB RAM per VM.

### Main Guide

1. either download the repo head to /main-scripts folder and copy the scripts inside your home directory.
2. make those scripts executable using this command `sudo chmod +x "script name.sh"`
3. execute the script with root permissions using this command `sudo "./script name.sh"`
4. use the node prep script on both VMs. then run the master node script on the VM you want to become the control plane and the worker node script on... well... the worker node.
5. even if those scripts show installation successfull do not trust them, you MUST verify it using these commands

`kubectl get pods -A` — this command list pods across all the namespaces on the whole cluster

`kubectl get nodes` — this command list all nodes. in both the nodes you must see ready. if it says anything else time to debug it.

![sample](/assets/cluster.png)

--- 

## ⚠️ warning

these scripts were written for learning.

they work and you can actually explore the clusters i built using these scripts here: http://35.200.179.137:30080

yeah you will get a warning if you have HTTPS only enabled.

use this token to login to headlamp.
*You only have viewing permissions. you can't deploy anything.*

```

eyJhbGciOiJSUzI1NiIsImtpZCI6IkFWRzRrQzktYklvVVpvZDhwSEIweFo4QlJJRnZsRGVCRVNVR2F5VEJVRU0ifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxODE2NzEyNTc0LCJpYXQiOjE3ODUxNzY1NzQsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiNmY5Y2ExZjAtNzhkNC00MzI5LTg4Y2UtOWM3NTZmZWM5Y2ViIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJkZWZhdWx0Iiwic2VydmljZWFjY291bnQiOnsibmFtZSI6InJlYWRvbmx5LXVzZXIiLCJ1aWQiOiIwMzhkYWY5Yy1kNGI3LTRjZGYtYTE5ZS1mOWMyZjcwYTExNjMifX0sIm5iZiI6MTc4NTE3NjU3NCwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6cmVhZG9ubHktdXNlciJ9.M23RDjHjiWBeovsbED-IFF8KlTKyNSxFqvzq0OtRZMaLmoSE-XuF-dDJgkwznWNLR4vKDHHvPKGRy3x3eq4BFMP-6n1CXz84Pd_NovjQ2gnMyqGENPtfN1jVigRzcjnDd91dM59LDOEBaxcVAxZCcBvA-En5PKSJJwejgXcO6ybtQd1ep77Emeevv656wpRKYek4FYtCTmEzzDd0TIebbk-mWsKyMcpWYBQxhzCz46YK7SuB-dTA97uArFQy4Dk1O0pejbD4-5hISEFTW63xRnbatumxf0dAc7zvq0me0_d7X8CkkQZQk4yoxzFHljNmb0T1EW2K5atcjOeYftmE2w

```

If you actually use this in production enviroment and stuff breaks don't hesitate in contacting me. I am learning too.