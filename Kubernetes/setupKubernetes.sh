#!/bin/bash

# Configuració del Master amb les IPs, Nom i Versions que ja teniem
MASTER_IP="192.168.0.10"
MASTER_NAME="master01A.asix.local"
KUBE_VERSION="1.32.0"

# Desactivo la memòria swap, pk he trobat que sense swap es garanteix estabilitat i predicibilitat en el funcionament del cluster
# En el meu cas no ho faig ja que ja ho tenim configurat des que vam crear la màuqina
# swapoff -a
# sed -i '/ swap / s/^/#/' /etc/fstab

# Faig una verificació per avisar a l'usuari de que si swap esta activat executi la comanda per desactivarho
if free -h | grep -q "Swap: 0B"; then
    echo "[OK] Swap desactivat"
else
    echo "[ERROR] Swap actiu - Executa: sudo swapoff -a"
    exit 1
fi

# Aquí primer faig un update i començo a instal·lar kubernetes i le sdiferents eines que utilitzare
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Descarrega de la clau de la firma i afegir el repositori de Kubernetes
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Instal·lació de kubernetes amb unes versions específiques per evitar incompatibilitats
sudo apt update
sudo apt install -y kubelet=$KUBE_VERSION-00 kubeadm=$KUBE_VERSION-00 kubectl=$KUBE_VERSION-00
# He buscat a internet i he trobat que bloquejar les versions va bé per prevenir actualitzacions no desitjades que ho poguéssin desconfigurar 
sudo apt-mark hold kubelet kubeadm kubectl

# Configuració del hostname
sudo hostnamectl set-hostname $MASTER_NAME
echo "$MASTER_IP $MASTER_NAME" | sudo tee -a /etc/hosts

# Configuració del kernel tal i com vam fer al master de l'insti
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# Configurar el containerd
sudo apt install -y containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Aquí provo d'inicialitzar el cluster
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --control-plane-endpoint $MASTER_NAME

# Configurar accés usuari
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Instal·lació de xarxa Calico per tindre comunicació entre pods i aplicar politiques de xarxa
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Comprovacions finals
echo "L'script està verificant l'estat del cluster, espera"
# Faig un sleep 20 pk el cluster s'acabi engegant
sleep 20

# Aqui comprovo que el port de l'API de Kubernetes estigui actiu
if netstat -tuln | grep -q ':6443'; then
    echo "[OK] Port API 6443 accessible"
else
    echo "[ERROR] Port API no disponible"
fi

# i finalment verifico que el node master estigui en estat 'Ready'
if kubectl get nodes | grep -q Ready; then
    echo "[OK] Cluster operatiu"
else
    echo "[ERROR] Cluster no preparat"
    kubectl get nodes
fi

# Aquesta comanda genera la comanda per afegir nodes workers al cluster que ha d'executar el user als workers
echo -e "\nExecuta aquesta comanda per unir els workers:"
kubeadm token create --print-join-command
