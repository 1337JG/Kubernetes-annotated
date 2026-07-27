#!/bin/bash
# Script 3: Worker Node Onboarding Script
# Run AFTER 01-prep-node.sh

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo"
    exit 1
fi

# Accepts join command via argument: sudo ./03-worker-node.sh "kubeadm join 10.x.x.x:6443 --token..."
# Or prompts interactively if no argument is passed.
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

echo "========================================================================="
echo " Worker node successfully joined the cluster!"
echo " Verify on master node by running: kubectl get nodes"
echo "========================================================================="