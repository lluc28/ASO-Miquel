#!/bin/bash

# Llegir els paràmetres d'entrada
NUM_CLIENTS=$1
shift
USERS_AND_PASSWORDS=("$@")

# Miro que el num de clients no superi els 10
if [ "$NUM_CLIENTS" -gt 10 ]; then
    echo "No es poden crear més de 10 clients."
    exit 1
fi

# Funció per crear les instàncies EC2
create_instance() {
    CLIENT_ID=$1
    IMAGE_ID="ami-0c55b159cbfafe1f0"  # Exemples d'AMI Linux 2 (canvia segons la teva regió)
    INSTANCE_TYPE="t2.micro"
    KEY_NAME="your-key-name"  # Afegeix el nom de la teva clau SSH
    SECURITY_GROUP="your-security-group"  # Afegeix el nom del grup de seguretat
    REGION="us-east-1"  # Canvia la regió segons les teves necessitats

    # Creació de la instància EC2
    echo "Creant instància Linux per al client $CLIENT_ID..."
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $IMAGE_ID \
        --instance-type $INSTANCE_TYPE \
        --key-name $KEY_NAME \
        --security-group-ids $SECURITY_GROUP \
        --count 1 \
        --region $REGION \
        --query 'Instances[0].InstanceId' \
        --output text)
