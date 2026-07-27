#!/bin/bash
# Script 2: Control Plane Initialization Script
# Run AFTER 01-prep-node.sh

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo"
    exit 1
fi

echo "[1/4] Initializing Kubernetes control-plane..."
kubeadm init --pod-network-cidr=192.168.0.0/16

echo "[2/4] Setting up non-root kubeconfig environment..."
TARGET_USER=${SUDO_USER:-$(whoami)}
TARGET_HOME=$(eval echo ~$TARGET_USER)

mkdir -p "$TARGET_HOME/.kube"
cp -i /etc/kubernetes/admin.conf "$TARGET_HOME/.kube/config"
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.kube"

echo "[3/4] Deploying Calico Container Network Interface (CNI)..."
SU_EXEC="sudo -u $TARGET_USER"
$SU_EXEC kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml

echo "[4/4] Installing Helm package manager..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

echo "========================================================================="
echo " Control plane initialization completed successfully!"
echo " Copy the 'kubeadm join ...' command printed above and pass it to"
echo " 03-worker-node.sh on your worker nodes."
echo "========================================================================="