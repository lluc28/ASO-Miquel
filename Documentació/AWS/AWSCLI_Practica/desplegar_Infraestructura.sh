#!/bin/sh

# Comprovar el número d'arguments
if [ $# -ne 6 ]; then
    echo "Error: El número d'arguments és incorrecte."
    echo "Al document de README.md del GitHub hi ha com executar-ho"
    exit 1
fi

# Assignació d'arguments
DOMAIN=""
CLIENTS=0
USERS_PASS=""

while [ $# -gt 0 ]; do
    case $1 in
        -d)
            DOMAIN=$2
            shift 2
            ;;
        -c)
            CLIENTS=$2
            if [ $CLIENTS -gt 10 ] || [ $CLIENTS -lt 1 ]; then
                echo "Error: El nombre de clients ha de ser entre 1 i 10."
                exit 1
            fi
            shift 2
            ;;
        -u)
            USERS_PASS=$2
            shift 2
            ;;
        *)
            echo "Error: Argument no reconegut."
            exit 1
            ;;
    esac
done

# Crear grup de seguretat
echo "Creant grup de seguretat..."
SG_ID=$(./grupsdeseguretat.sh | grep "Grup de seguretat creat amb ID" | awk '{print $NF}')

if [ -z "$SG_ID" ]; then
    echo "Error: No s'ha pogut crear el grup de seguretat."
    exit 2
fi
echo "Grup de seguretat creat amb ID: $SG_ID"

# Crear instància Windows Server
echo "Creant instància Windows Server..."
WS_AMI="ami-05f283f34603d6aed" # AMI de Windows Server
WS_ID=$(aws ec2 run-instances \
  --image-id "$WS_AMI" \
  --key-name "vockey" \
  --instance-type "t2.micro" \
  --network-interfaces '{"DeviceIndex":0,"Groups":["'"$SG_ID"'"]}' \
  --credit-specification '{"CpuCredits":"standard"}' \
  --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"WS"}]}' \
  --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":true,"EnableResourceNameDnsAAAARecord":false}' \
  --count "1" \
  --query 'Instances[0].InstanceId' \
  --output text)

if [ -z "$WS_ID" ]; then
    echo "Error: No s'ha creat el Windows Server."
    exit 2
fi
echo "Instància Windows Server creada amb ID: $WS_ID"

# Crear clients Debian
echo "Creant $CLIENTS clients Debian..."
DEBIAN_AMI="ami-064519b8c76274859" # AMI de Debian

for i in $(seq 1 $CLIENTS); do
    CLIENT_ID=$(aws ec2 run-instances \
      --image-id "$DEBIAN_AMI" \
      --key-name "vockey" \
      --instance-type "t2.micro" \
      --network-interfaces '{"DeviceIndex":0,"Groups":["'"$SG_ID"'"]}' \
      --credit-specification '{"CpuCredits":"standard"}' \
      --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"Debian-Client-'$i'"}]}' \
      --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":true,"EnableResourceNameDnsAAAARecord":false}' \
      --count "1" \
      --query 'Instances[0].InstanceId' \
      --output text)

    if [ -z "$CLIENT_ID" ]; then
        echo "Error: No s'ha pogut crear el client Debian $i."
        continue
    fi
    echo "Client $i creat"
done

