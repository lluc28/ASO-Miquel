#!/bin/bash

#!/bin/sh

# Assignar IP del master
IP_MASTER=$1

# 1. Desactivar swap
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# 2. Instal·lar eines bàsiques
apt update && apt install -y apt-transport-https curl

# 3. Afegir repositori Kubernetes
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

# 4. Instal·lar components
apt update && apt install -y kubelet kubeadm kubectl

# 5. Configurar hostname
hostnamectl set-hostname master01A.asix.local
echo "$IP_MASTER master01A.asix.local" >> /etc/hosts

# 6. Instal·lar containerd

# 7. Inicialitzar el clúster

# 8. Reiniciar clúster

