We successfully started a cluster all the pods are running what now? before deploying actual workloads let's understand some concepts and how to properly read outputs of kubectl command line tool.

```shell
jaydevgusani301@k8smaster:~$ kubectl get pods -A
NAMESPACE     NAME                                     READY   STATUS    RESTARTS     AGE
headlamp      my-headlamp-788546658d-stxr7             1/1     Running   0            3d20h
kube-system   calico-kube-controllers-6c8b7bb7-dd2hs   1/1     Running   1 (2m ago)   3d20h
kube-system   calico-node-h4hqk                        1/1     Running   0            3d20h
kube-system   calico-node-h7qv7                        1/1     Running   1 (2m ago)   3d20h
kube-system   coredns-589f44dc88-jlnt8                 1/1     Running   1 (2m ago)   3d20h
kube-system   coredns-589f44dc88-rqgsm                 1/1     Running   1 (2m ago)   3d20h
kube-system   etcd-k8smaster                           1/1     Running   1 (2m ago)   3d20h
kube-system   kube-apiserver-k8smaster                 1/1     Running   1 (2m ago)   3d20h
kube-system   kube-controller-manager-k8smaster        1/1     Running   1 (2m ago)   3d20h
kube-system   kube-proxy-c5xvt                         1/1     Running   1 (2m ago)   3d20h
kube-system   kube-proxy-mhd5c                         1/1     Running   0            3d20h
kube-system   kube-scheduler-k8smaster                 1/1     Running   1 (2m ago)   3d20h
```

## The Concepts

first of all let's start with the concepts.

### Namespaces

**Namespace:** A logical seperation of resources. A namespace is a fundamental concept in kubernetes, every resource must exist in a namespace. think of this as space-time fabric but make it kubernetes.

**why is a namespace needed?** A namespace is needed to properly, logically group resources inside a cluster. we actually make namespaces so that when troubleshooting the inevitable downtime we don't troubleshoot the wrong thing and we contain the blast radius. A pod that went down in namespace A may not exactly affect another pod in namespace B unless pod in namespace B was dependent on a pod in namespace A. and it would be simply wasteful to dedicate a whole cluster per service unless the scale is absolutely huge.
A simple formula to understand this. 

### Blast Radius Formula

To represent the total impact (Blast Radius $B$) when a service inside Namespace $A$ breaks:

$$B(A) = S_A + \sum_{k \neq A} \left( S_k \cdot C_{A \to k} \right)$$

#### Variable Breakdown:

* **$B(A)$**: Total Blast Radius (total number of affected services across the cluster).
* **$S_A$**: Services running internally inside Namespace $A$ (always affected).
* **$S_k$**: Services running inside another Namespace $k$.
* **$C_{A \to k}$**: Cross-namespace coupling factor:

$$C_{A \to k} = \begin{cases} 1 & \text{if Namespace } k \text{ directly depends on Namespace } A \\ 0 & \text{if Namespace } k \text{ is completely decoupled} \end{cases}$$

### Alternative: Failure Probability Formula

If you want to express the **probability of cascading failure** ($P$) in Namespace $B$ when Namespace $A$ crashes:

$$P(\text{Failure in } B \mid \text{Failure in } A) = D_{A \to B} \cdot N_{A \to B}$$

* **$D_{A \to B} \in \{0, 1\}$**: Dependency flag ($1$ if Pod $B$ calls Pod $A$, $0$ if independent).
* **$N_{A \to B} \in \{0, 1\}$**: Network policy flag ($1$ if cross-namespace traffic is allowed, $0$ if blocked by network policy).

> **The Takeaway:** If $D_{A \to B} = 0$ or $N_{A \to B} = 0$, the failure probability drops to $0$, containing the crash entirely inside Namespace $A$.

To create a new namespace simply SSH into the cluster and type 
`kubectl create namespace "namespace name"`

---

### Name

**Name:** a simple name for a pod. it exists so that we can identify a pod easily.

**What's exactly a POD?** a pod is the smallest deployable unit in kubernetes. now a pod can have one container image or multiple container images. a pod's job is to run those container images as requested by the user.

**Container image:** A container image is a collection of the core application, the dependencies (the requirements that are required for the core application to run) all bundled into one a portable file. nowadays container images come with an operating system inside it. most famous is alpine linux.

---

### Ready

**Ready:** this output means how many pods we requested and how many are actually ready. 

**Why this is needed?**
suppose if we wanted 10 pods but only 3 were ready we would get the output `3 / 10`
another reason we need this is to ensure the cluster is working properly or not. if you requested 10 pods but only 3 pods are ready you will need to see what's preventing those other pods from becoming ready?

---

### Status

this shows the status of the pod. there are usually 5 states

**Pending:** The cluster accepted the Pod, but one or more containers are not ready to run. This includes time spent waiting to be scheduled to a node and time downloading container images.

**Running:** The Pod is bound to a node, all containers are created, and at least one container is currently running, starting, or restarting.

**Succeeded:** All containers in the Pod completed their tasks successfully (exited with status code 0) and will not be restarted. This is common for Kubernetes Jobs.

**Failed:** All containers have terminated, but at least one container exited with a non-zero failure code or was terminated by the system.

**Unknown:** The state of the Pod cannot be obtained. This usually happens because the master node lost communication with the worker node where the Pod is hosted

---

### Restarts

shows the amounts of restarts happened. a restart happens everytime we modify the deployment yaml. 

**what counts as a restart?** 

**Container Exit CodesApplication Crashes:** The internal process fails and exits with a non-zero code (e.g., 1).

**Normal Completion:** A container in a standard deployment exits with code 0 (Kubernetes will still restart it if the restartPolicy is set to Always).

**Out of Memory (OOMKilled):** The container exceeds its defined memory limit, and the Linux kernel terminates it (Exit code 137).

**Health Check FailuresLiveness Probes:** The kubelet continuously checks the container's health. If a liveness probe fails consecutively past its threshold, Kubernetes deliberately kills and restarts the container to recover.

**Node and System EventsNode Maintenance:** If a node reboots or goes down, the entire pod is terminated and rescheduled on a different node (this resets the restart count to 0 because it is a brand-new pod).

**Preemption:** High-priority pods can displace lower-priority pods, causing the lower-priority containers to terminate.

---

### Age

simply means how old the pod is.

---

now let's understand all the pods that are running.

```shell
headlamp      my-headlamp-788546658d-stxr7             1/1     Running   0            3d20h
```

the pod is located inside the headlamp namespace. the container is allocated by the kubernetes itself unless we explicitly name it. i requested one pod and one pod is ready hence $ 1/1 $

---

```shell

kube-system   calico-kube-controllers-6c8b7bb7-dd2hs   1/1     Running   1 (2m ago)   3d20h
kube-system   calico-node-h4hqk                        1/1     Running   0            3d20h
kube-system   calico-node-h7qv7                        1/1     Running   1 (2m ago)   3d20h
```

these pods are inside the kube-system namespace. this kube-system is core namespace housing all the necessary components required for the cluster to run smoothly.

let's look at **calico:** a container network interface (CNI). 
without calico or any other plugin the internal cluster networking would simply cease to exist period
calico helps the pod talk with each other as well as containers.

kubernetes by default *does not* have networking baked in.

deeper understanding of calico coming soon.

there are actually many different types of CNIs available. another famous one is cilium. the main difference between calico and cilium is built natively on eBPF for high performance and Calico using traditional Linux routing and iptables.

---

```shell
kube-system   coredns-589f44dc88-jlnt8                 1/1     Running   1 (2m ago)   3d20h
kube-system   coredns-589f44dc88-rqgsm                 1/1     Running   1 (2m ago)   3d20h
```

**coredns:** CoreDNS is the standard DNS server for Kubernetes, acting as the cluster's internal phonebook. It runs as a set of managed pods in the `kube-system` namespace and automatically translates service names into IP addresses, allowing workloads to communicate seamlessly using domain names instead of hardcoded IPs. 

### How CoreDNS Works?

CoreDNS serves DNS records based on the Kubernetes specification by continuously watching the Kubernetes API server for new Services and Pods. 

Whenever a new object is created, CoreDNS builds the corresponding DNS records so that other pods can discover it.
For example, a service named backend in the production namespace will be assigned a resolvable DNS name like: 
`backend.production.svc.cluster.local` 
CoreDNS listens on UDP and TCP port 53 and is typically fronted by a kube-dns Kubernetes Service to provide high availability load balancing across multiple CoreDNS pod replicas.

### Configuration 

(The Corefile )CoreDNS behavior is defined by its Corefile, which is stored and managed as a Kubernetes ConfigMap. 
It uses a modular, plugin-based architecture. A standard configuration includes:

**errors:** Logs errors to stdout.kubernetes: The core plugin that integrates with the Kubernetes API to resolve cluster IPs and endpoints.

**forward:** Forwards unrecognized or external domain queries (e.g., google.com) to upstream nameservers defined in the node's /etc/resolv.conf.

**cache:** Improves performance by caching DNS lookups locally.

**health / ready:** Provides endpoints for Kubernetes liveness and readiness probes.Customization and Troubleshooting you can easily modify the CoreDNS configuration to add custom upstream DNS servers, rewrite queries, or adjust cache sizes by editing the CoreDNS ConfigMap via kubectl edit `configmap coredns -n kube-system`.
If pods are experiencing connection issues, checking the CoreDNS logs is the best place to start: `kubectl logs -l k8s-app=kube-dns -n kube-system`

---

```shell
kube-system   etcd-k8smaster 1/1     Running   1 (2m ago)   3d20h
```

**etcd:** aka the ground reality for the cluster. whatever gets recorded in etcd is considered as the reality for the whole cluster.

etcd is probably the most important concept in a cluster. etcd is written in the GO language. 

**Why is this needed?** it's needed to store the entire state and configuration of your cluster in a single, strongly-consistent key-value database.

Think of `etcd` as the cluster's memory bank. If you run `kubectl create deployment nginx`, the API server doesn't just instantly spin up a pod. It first writes that intent into `etcd`. Once `etcd` confirms "yep, I saved it," that record becomes the absolute source of truth for the entire cluster.

**Key things to know about etcd:**

**It's the cluster's memory:** If it isn't saved in `etcd`, as far as Kubernetes is concerned, it simply does not exist. If your `etcd` database gets corrupted or wiped without a backup, your cluster gets instant amnesia. The container processes might still physically be running on worker nodes, but Kubernetes has no idea what they are or who owns them.
 
**Nobody talks to etcd directly except the API Server:** No worker node, no user pod, and not even `kubectl` touches `etcd`. The `kube-apiserver` is the sole gatekeeper that holds the TLS certificates required to read and write data to `etcd`.

**Consensus (Raft Algorithm):** When you scale up to a high-availability cluster with multiple master nodes, `etcd` runs in a cluster of its own using the **Raft consensus algorithm**. It makes sure all master nodes strictly agree on what the cluster state looks like, preventing split-brain chaos.

**What is Raft?**

Raft is a consensus algorithm that is designed to be easy to understand. It's equivalent to Paxos in fault-tolerance and performance. The difference is that it's decomposed into relatively independent subproblems, and it cleanly addresses all major pieces needed for practical systems. We hope Raft will make consensus available to a wider audience, and that this wider audience will be able to develop a variety of higher quality consensus-based systems than are available today.

**What is consensus?**

Consensus is a fundamental problem in fault-tolerant distributed systems. Consensus involves multiple servers agreeing on values. Once they reach a decision on a value, that decision is final. Typical consensus algorithms make progress when any majority of their servers is available; for example, a cluster of 5 servers can continue to operate even if 2 servers fail. If more servers fail, they stop making progress (but will never return an incorrect result).

Consensus typically arises in the context of replicated state machines, a general approach to building fault-tolerant systems. Each server has a state machine and a log. The state machine is the component that we want to make fault-tolerant, such as a hash table. It will appear to clients that they are interacting with a single, reliable state machine, even if a minority of the servers in the cluster fail. Each state machine takes as input commands from its log. In our hash table example, the log would include commands like set x to 3. A consensus algorithm is used to agree on the commands in the servers' logs. The consensus algorithm must ensure that if any state machine applies set x to 3 as the nth command, no other state machine will ever apply a different nth command. As a result, each state machine processes the same series of commands and thus produces the same series of results and arrives at the same series of states. 

---
```shell
kube-system   kube-apiserver-k8smaster                 1/1     Running   1 (2m ago)   3d20h
kube-system   kube-controller-manager-k8smaster        1/1     Running   1 (2m ago)   3d20h
kube-system   kube-proxy-c5xvt                         1/1     Running   1 (2m ago)   3d20h
kube-system   kube-proxy-mhd5c                         1/1     Running   0            3d20h
kube-system   kube-scheduler-k8smaster                 1/1     Running   1 (2m ago)   3d20h
```

**`kube-apiserver-k8smaster`:** the main server inside kubernetes that's hosting the API endpoint. almost everything inside kubernetes talks with each other through APIs. suppose you wanted to deploy a pod the communication to deploy a pod happens through the API. 

The REST API is the fundamental fabric of Kubernetes. All operations and communications between components, and external user commands are REST API calls that the API Server handles. Consequently, everything in the Kubernetes platform is treated as an API object and has a corresponding entry in the API.

When you make a successful request (like GET /api/v1/namespaces/default/pods/my-pod), the server responds with a 200 OK status and a structured payload. an example:

```json
{
  "kind": "Pod",
  "apiVersion": "v1",
  "metadata": {
    "name": "my-pod",
    "namespace": "default",
    "uid": "1234abcd-5678-efgh-ijkl-90abcdef1234",
    "resourceVersion": "987654",
    "creationTimestamp": "2026-07-29T14:30:00Z"
  },
  "spec": {
    "containers": [
      {
        "name": "nginx",
        "image": "nginx:alpine"
      }
    ]
  },
  "status": {
    "phase": "Running",
    "podIP": "10.244.0.5"
  }
}
```

**` kube-controller-manager`:** The  is a core control plane component in Kubernetes that runs embedded controller loops—such as the node, job, and endpoint controllers to watch the state of the cluster and reconcile actual states with desired specifications.

**How It Works**

**Control Loop:** Continuously observes cluster state through the Kubernetes API Server and triggers corrective actions. 

**Single Binary:** Packs multiple independent controller processes into one unified daemon to reduce complexity. 

**Self-Healing:** Detects drift such as a crashed pod or missing replica and forces adjustments to match configuration targets. 

**Core Built-in Controllers**

**Node Controller:** Monitors worker node health and responds when nodes go offline. 

**Replication/Deployment Controller:** Maintains the exact number of running pod replicas requested. 

**Endpoints & Service Accounts Controllers:** Manages service mappings, network endpoints, and default tokens.

```shell

kube-system   kube-proxy-c5xvt 1/1 Running   1 (2m ago)   3d20h
kube-system   kube-proxy-mhd5c 1/1 Running   0            3d20h
```
**`kube-proxy`:** The cluster's network traffic cop. Notice how there are two pods listed in `kubectl get pods`? That is because `kube-proxy` runs as a **DaemonSet** meaning one instance runs on every single node in the cluster (both master and workers).

**Why Is It Needed?**
Without `kube-proxy`, ClusterIPs, NodePorts, and LoadBalancers wouldn't work. When you send traffic to a Service, `kube-proxy` is what intercepts that traffic and routes it to the actual IP address of a healthy backend pod.

**How It Works**

**Watches the API Server:** Continuously monitors for new Services and Endpoints being created, modified, or deleted.

**Manages Host Network Rules:** Directly manipulates network rules on each host node using underlying OS mechanisms—most commonly `iptables` or `IPVS`.

**Basic Load Balancing:** When multiple pods back a single Service, `kube-proxy` distributes incoming connections across those pod IPs.

**`kube-scheduler`:** The matchmaker of the cluster. Its sole responsibility is to watch for newly created pods that have no assigned node, figure out which node is best suited to run them, and assign them there.

**Why Is It Needed?**
When you deploy a workload, you don't manually pick which VM it runs on. You tell Kubernetes what your application needs (e.g., 2 vCPUs, 4GB RAM), and the scheduler finds a host that can fit it.

**How It Works (The 2-Step Matchmaking Process)**

1. **Filtering (Predicates):** Finds all nodes that *can* run the pod. It discards nodes that don't have enough free CPU/RAM, nodes that are tainted (like master nodes), or nodes that fail `nodeSelector` / affinity rules.
2. **Scoring (Priorities):** Ranks the remaining valid nodes on a scale. It favors nodes with optimal resource usage, good pod anti-affinity spreading, or local storage availability.
3. **Binding:** Writes the chosen node name into the pod's specification and sends it back to the `kube-apiserver`.

> **Crucial Distinction:** The scheduler **only decides** where the pod should go. It does not actually pull the image or start the container once the assignment is saved in `etcd`, the local `kubelet` running on that target node sees the assignment and actually spins up the pod.
