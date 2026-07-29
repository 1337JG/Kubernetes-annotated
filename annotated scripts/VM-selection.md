In the Main readme.md file i have a section named prerequisites. let's actually understand them first before building the main cluster(s).
i'll explain line by line what each and every prerequisite means and why it's a necessity.

## Prerequisites.

1. Two plus Virtual machines
2. SSH level access to those VMs
3. root permissions inside those VMs
4. Instance Naming: Set the name explicitly based on its role (e.g., k8s-master or k8s-worker).
5. OS Selection: Preferably use Ubuntu LTS.
6. Region: Pick the geographically closest region to minimize latency.
7. Sizing Requirements: Minimum specs for a sandbox cluster: 30 GB storage, 2 vCPUs, and 4 GB RAM per VM.


### 1. 2+ VMs

**Why they are needed?** 
We need two plus virtual machines because we are trying to simulate a small scale kubernetes cluster. the problem with one node cluster is that you never actually get to feel how things actually work in production environment. 

one virtual machine becomes the master node and another one becomes the slave node. 

**What exactly are virtual machines?** 
simply put virtual machines are computers running ontop of computers. they have their own set of logically partitoned hardware. 
supposedly you have a machine with 16gb ram, 4 core cpu, 512gb ssd. for a virtual machine you can dedicate any number of ram, any number of cpu cores and storage to it. 

same thing happens in the cloud enviroment. cloud providers have tons of storage, memory and CPUs. 

the main component for a VM is a hypervisor.

**Hypervisor:**  is a software, firmware, or hardware that creates and runs virtual machines by dividing physical hardware resources like CPU, memory, and storage among multiple guest operating systems

**Types of HypervisorsType 1 (Bare-Metal):** Runs directly on the host hardware without a separate operating system; offers high performance and security for enterprise data centers. Examples include VMware ESXi and Microsoft Hyper-V.

**Type 2 (Hosted):** Runs as an application on top of a standard host operating system; ideal for personal testing and desktop use. Examples include Oracle VM VirtualBox and VMware Workstation.

cloud providers have their own propreitary hypervisor.

---

### 2. SSH level access to those VMs

**what is SSH?** ssh simply means secure shell. it's used to log into remote computers, execute commands and transfer files. 
SSH is a replacement for telnet.

**why we need it?** we need it to log in to the VMs. if we don't have SSH access how will you deploy resources in those VMs? 

**How does SSH work?** 

SSH (Secure Shell) works by establishing a cryptographically secured client-server connection to allow safe communication over unsecure networks. It utilizes a combination of asymmetric encryption, symmetric encryption, and hashing algorithms across distinct phases to protect usernames, passwords, and transmitted commands from interception.   
The complete SSH connection workflow operates through the following sequential steps:

1. TCP Connection and Negotiation 

**Port 22 Contact:** The client initiates a standard TCP handshake with the server, targeting port 22 by default. 

**Protocol Version Exchange:** Both systems share their supported protocol versions (e.g., SSH 2.0) to establish a compatible base. 

**Algorithm Agreement:** The parties share lists of supported cryptographic primitives to choose mutually compatible algorithms for key exchange and encryption.  

2. The Key Exchange (KEX) 

**Asymmetric Setup:** The client and server use an asymmetric mechanism, typically Diffie-Hellman, to safely establish a shared secret. 

**Ephemeral Key Generation:** Both sides generate temporary, one-time public and private key pairs.

**Independent Computation:** They trade public keys and compute the exact same mathematical secret independently without sending the final key over the network. 

**Perfect Forward Secrecy:** Because these keys are ephemeral, compromise of a single session's key does not endanger older recordings of historical traffic.  

3. Symmetric Encryption Activation 

**Symmetric Transition:** The derived shared secret serves as the symmetric session key for the duration of the connection. 

**High-Speed Security:** Unlike asymmetric encryption, symmetric encryption is highly efficient and blindingly fast for processing bulk data streams. 

**Full Session Masking:** Every single piece of data sent afterward—including user credentials and terminal interactions—is fully scrambled using this session key. [4, 6]  

4. Client Authentication 
   
Once a secure, symmetrically encrypted tunnel is running, the server authenticates the client via one of two common paths: 

**Password Authentication:** The client submits a traditional username and password. This travels safely inside the encrypted tunnel, though it remains vulnerable to guessing or brute-force attacks. 

**SSH Key Pair Authentication (Recommended):** The user registers a static public key inside the server's  file. The client signs the unique session identifier using its matching local private key. The server verifies this signature with the stored public key to safely grant entry without passwords.

1. Data Transmission and Channel Multiplexing 

**Logical Channels:** The session builds out an organized connection layer capable of multiplexing single encrypted pipelines into distinct individual streams. 

**Multi-Service Capability:** Through these distinct channels, a single SSH link can simultaneously run an interactive command terminal, securely clone folders using SFTP or SCP, and pipe unrelated application traffic via SSH local port forwarding. 

**Integrity Checks:** Hashing algorithms generate a Message Authentication Code (MAC) for each payload packet to guarantee that no data was altered mid-transit.  

---

### 3. root permissions inside those VMs

please refer to the node-prep.md inside annotated-scripts.

---

## *i am skipping number 4 & 5*

---

### 6. Region

**what's a region?** a region is geographical place which exists on the planet earth in which the cloud provider has created a data centre there. inside the data centre there are tons of server racks. those server racks mostly have RAM, CPU, Storage, GPUs, and networking equipment. 

**why closest region?** it's preferred to select the region closest to your physical presence because we want to minimise latency. if you are in mumbai and you are using AWS when deploying a EC2 instance in the region just select ap-south-1.

**what is latency?** latency means how much time it takes for one thing to talk with another thing. if you are in say amsterdam and you deploy your instance in middle east region you will have high latency. every time you ssh into your VM or execute a task all those packets have to travel from your laptop/desktop to the cloud provider's data centre.

Total network latency (or Round Trip Time, RTT) is the sum of four key components: Propagation Delay, Transmission Delay, Queuing Delay, and Processing Delay.  
$$ \text{Total Latency} = \text{Propagation Delay} + \text{Transmission Delay} + \text{Queuing Delay} + \text{Processing Delay}$$  
Here is a quick breakdown of how to calculate each specific delay: 

**Propagation Delay:** The time it takes for a bit to travel from source to destination.
$$ \text{Propagation Delay} = \frac{\text{Distance}}{\text{Propagation Speed}} $$ (Propagation speed through a medium like fiber optic or copper is generally about $\approx 2 \times 10^8 \text{ meters/second}) $

**Transmission Delay:** The time required to push all the data bits into the network link.
$$\text{Transmission Delay} = \frac{\text{Packet Size (bits)}}{\text{Bandwidth (bps)}}$$

**Queuing Delay:** The time data packets spend waiting in the router/switch buffer before being transmitted. (Variable based on current network congestion).

**Processing Delay:** The time it takes routers/switches to process the packet header, determine the route, and check for bit-level errors. 

for each and everytime you SSH into your cloud provider's VM all your packets go through a networking model called TCP/IP. before TCP/IP we used OSI model but now it's old. this occurs on the client side as well as on the server side. 

### All layers of TCP/IP

The TCP/IP model layers explained

The TCP and IP protocol is structured into four layers, also known as the TCP/IP stack: the Network Access Layer, Internet Layer, Transport Layer and Application Layer. Each layer has specific responsibilities and works in harmony with the others.
 

**Application Layer:** This is the topmost layer, directly interacting with software applications and end users. The application layer in TCP/IP provides functionality for email, web browsing, file transfers and other user-facing activities. Well-known protocols in this layer include HTTP (web browsing), FTP (file transfer) and SMTP (email). They make sure that data is presented in a format that is understandable to humans.

**Transport Layer:** The Transport Layer ensures reliable communication between sender and receiver by dividing large amounts of data into packets and reassembling them at the destination. TCP operates in this layer, providing error correction, sequencing and flow control.

**Internet Layer:** Responsible for addressing and routing, the Internet Layer ensures data packets are sent to the correct destination, even across multiple networks. The Internet Protocol (IP) plays a crucial role here, enabling device identification and packet delivery.

**Network Access Layer:** This is the lowest layer, managing the physical connection between devices. It handles data transmission on the hardware level, including the conversion of data into electrical signals and access to the physical network. Examples of protocols here include Ethernet and Wi-Fi.

---

### 7. minimum requirements

**from official docs:** The absolute minimum requirements for a standard Kubernetes cluster (using kubeadm) are 2 CPUs and 2 GB of RAM per node. A functional cluster requires at least one control plane node and one worker node, alongside full network connectivity and a configured container runtime (e.g., containerd)

i am telling more requirements because we may in the future install heavy applications like prometheus + grafana? may run database instances for learning purposes? to prevent future trouble it's advised to overprovision a little bit in learning environments.
