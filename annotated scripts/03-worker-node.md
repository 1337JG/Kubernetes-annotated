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

```bash
JOIN_CMD="$*"

if [ -z "$JOIN_CMD" ]; then
    echo "Enter the full 'kubeadm join' command from your control plane output:"
    read -r JOIN_CMD
fi

if [ -z "$JOIN_CMD" ]; then
    echo "Error: No join command provided. Exiting."
    exit 1
fi

echo "Joining cluster..."
eval "$JOIN_CMD"
```

simple if statements that check whether the join command we pasted is correct or not and with that command was the slave node able to join the master node or not? 