#!/bin/bash

# Paràmetres d'entrada
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Ús: $0 <MASTER_IP> <MASTER_NAME> [KUBE_VERSION]" >&2
    echo "Ús: $0 <MASTER_IP> <MASTER_NAME> [KUBE_VERSION]" >> "/var/log/kube/setup.log"
    exit 1
fi

MASTER_IP="$1"
MASTER_NAME="$2"
KUBE_VERSION="${3:-1.32.0}"  # Valor per defecte si no s'especifica

# Configuració inicial
LOG_FILE="/var/log/kube/setup.log"
CONFIG_FILE="/etc/kube_config.conf"

# Aqui carrego la configuració externa del fitxer backup.conf
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Fitxer de configuració no trobat: $CONFIG_FILE" >&2
    exit 2  # Codi d'error ajustat
fi
source "$CONFIG_FILE"

# Si el fitxer log passa de la mida màxima que es defineix al fitxer backup.conf el fitxer log es renombra i es crea un nou fitxer amb el mateix nom que l'original
MIDA_ACTUAL=$(wc -c < "$LOG_FILE" 2>/dev/null)
if [ "$MIDA_ACTUAL" -ge "$LOG_MAX_MIDA" ]; then
    NOU_NOM="/var/log/kube/historic-$(date +%Y%m%d-%H%M%S).log"
    mv "$LOG_FILE" "$NOU_NOM"
    touch "$LOG_FILE"
    chmod 640 "$LOG_FILE"
fi

# Desactivo la memòria swap, pk he trobat que sense swap es garanteix estabilitat i predicibilitat en el funcionament del cluster
# En el meu cas no ho faig ja que ja ho tenim configurat des que vam crear la màuqina
# swapoff -a
# sed -i '/ swap / s/^/#/' /etc/fstab

# Faig una verificació per avisar a l'usuari de que si swap esta activat executi la comanda per desactivarho
echo "Comprovant swap..." | tee -a "$LOG_FILE"
if free -h | grep -q "Swap: 0B"; then
    echo "[OK] Swap desactivat" | tee -a "$LOG_FILE"
else
    echo "Error: Swap actiu - Executa: sudo swapoff -a" >&2
    echo "Error: Swap actiu - Executa: sudo swapoff -a" >> "$LOG_FILE"
    exit 2
fi

# Actualitzar sistema
echo "Actualitzant paquets..." | tee -a "$LOG_FILE"
if ! sudo apt-get update; then
    echo "ERROR: Fallida en apt-get update (codi: $?)" >&2
    echo "ERROR: Fallida en apt-get update (codi: $?)" >> "$LOG_FILE"
    exit 3
fi

# Instal·lar dependències
if ! sudo apt-get install -y apt-transport-https ca-certificates curl; then
    echo "ERROR: Fallida instal·lació dependències (codi: $?)" >&2
    echo "ERROR: Fallida instal·lació dependències (codi: $?)" >> "$LOG_FILE"
    exit 4
fi

# Descarrega de la clau de la firma i afegir el repositori de Kubernetes
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg
if [ $? -ne 0 ]; then
    echo "ERROR: Descàrrega clau GPG fallida (codi: $?)" >&2
    echo "ERROR: Descàrrega clau GPG fallida (codi: $?)" >> "$LOG_FILE"
    exit 5
fi

echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
if [ $? -ne 0 ]; then
    echo "ERROR: Configuració repositori fallida (codi: $?)" >&2
    echo "ERROR: Configuració repositori fallida (codi: $?)" >> "$LOG_FILE"
    exit 6
fi

# Instal·lació de kubernetes amb unes versions específiques per evitar incompatibilitats
sudo apt update
sudo apt install -y kubelet=$KUBE_VERSION-00 kubeadm=$KUBE_VERSION-00 kubectl=$KUBE_VERSION-00
if [ $? -ne 0 ]; then
    echo "ERROR: Instal·lació Kubernetes fallida (codi: $?)" >&2
    echo "ERROR: Instal·lació Kubernetes fallida (codi: $?)" >> "$LOG_FILE"
    exit 7
fi
# He buscat a internet i he trobat que bloquejar les versions va bé per prevenir actualitzacions no desitjades que ho poguéssin desconfigurar 
sudo apt-mark hold kubelet kubeadm kubectl

# Configuració del hostname
sudo hostnamectl set-hostname $MASTER_NAME
echo "$MASTER_IP $MASTER_NAME" | sudo tee -a /etc/hosts
if [ $? -ne 0 ]; then
    echo "ERROR: Configuració hostname fallida (codi: $?)" >&2
    echo "ERROR: Configuració hostname fallida (codi: $?)" >> "$LOG_FILE"
    exit 8
fi

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
if [ $? -ne 0 ]; then
    echo "ERROR: Configuració containerd fallida (codi: $?)" >&2
    echo "ERROR: Configuració containerd fallida (codi: $?)" >> "$LOG_FILE"
    exit 10
fi

# Aquí provo d'inicialitzar el cluster
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --control-plane-endpoint $MASTER_NAME
if [ $? -ne 0 ]; then
    echo "ERROR: Inicialització cluster fallida (codi: $?)" >&2
    echo "ERROR: Inicialització cluster fallida (codi: $?)" >> "$LOG_FILE"
    exit 11
fi

# Configurar accés usuari
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
if [ $? -ne 0 ]; then
    echo "ERROR: Configuració accés fallida (codi: $?)" >&2
    echo "ERROR: Configuració accés fallida (codi: $?)" >> "$LOG_FILE"
    exit 12
fi

# Instal·lació de xarxa Calico per tindre comunicació entre pods i aplicar politiques de xarxa
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
if [ $? -ne 0 ]; then
    echo "ERROR: Instal·lació Calico fallida (codi: $?)" >&2
    echo "ERROR: Instal·lació Calico fallida (codi: $?)" >> "$LOG_FILE"
    exit 13
fi

# Comprovacions finals
echo "L'script està verificant l'estat del cluster, espera"
# Faig un sleep 20 pk el cluster s'acabi engegant
sleep 30

# Comprovació única de pods en estat Running
if ! kubectl get pods -n kube-system | grep -q Running; then
    echo "ERROR: Pods del sistema no funcionals" >&2
    echo "ERROR: Pods del sistema no funcionals" >> "$LOG_FILE"
    kubectl get pods -n kube-system >> "$LOG_FILE"
    exit 14
fi

# Aqui comprovo que el port de l'API de Kubernetes estigui actiu
if ! netstat -tuln | grep -q ':6443'; then
    echo "ERROR: Port API no accessible" >&2
    echo "ERROR: Port API no accessible" >> "$LOG_FILE"
    exit 15
fi

# i finalment verifico que el node master estigui en estat 'Ready'
if ! kubectl get nodes | grep -q Ready; then
    echo "ERROR: Cluster no preparat" >&2
    echo "ERROR: Cluster no preparat" >> "$LOG_FILE"
    exit 16
fi

# Aquesta comanda genera la comanda per afegir nodes workers al cluster que ha d'executar el user als workers
DATA=$(date "+%Y-%m-%d %H:%M:%S")
echo "[$DATA] Cluster configurat correctament" >> "$LOG_FILE"
echo -e "\nExecuta aquesta comanda per unir els workers:"
kubeadm token create --print-join-command

# Execució de l'script de backup automàtic
echo "S'està executant el backup..." | tee -a "$LOG_FILE"
BACKUP_SCRIPT="/home/lluc/scripts/Kubernetes/backupKubernetes.sh"

bash "$BACKUP_SCRIPT" >> "$LOG_FILE" 2>&1 && echo "Backup finalitzat" || echo "ERROR: Backup fallit" | tee -a "$LOG_FILE
