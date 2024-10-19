#!/bin/bash

# Enregistrer le temps de début
start_time=$(date +%s)

# Définir l'utilisateur Ansible
ansibleUser="azureuser"
# Fonction pour afficher des messages en couleur
print_color() {
    local color=$1
    local message=$2
    case $color in
        "red") echo -e "\033[0;31m$message\033[0m" >&2 ;;
        "green") echo -e "\033[0;32m$message\033[0m" >&2 ;;
        "yellow") echo -e "\033[0;33m$message\033[0m" >&2 ;;
        "blue") echo -e "\033[0;34m$message\033[0m" >&2 ;;
        *) echo "$message" >&2 ;;
    esac
}

# Aller dans le dossier Terraform
cd terraform || { print_color "red" "Erreur: Le dossier terraform n'existe pas."; exit 1; }

# Run Terraform apply
print_color "blue" "Exécution de Terraform apply..."
terraform apply -auto-approve

# Check if Terraform apply was successful
if [ $? -ne 0 ]; then
    print_color "red" "Échec de Terraform apply. Sortie du script."
    exit 1
fi

# Extraire les valeurs requises de la sortie Terraform
LAB_RESOURCE_GROUP=$(terraform output -raw resource_group_name)
LAB_NAME=$(terraform output -raw lab_name)
VM_NAMES=$(terraform output -json vm_names | jq -r '.[]')
VM_FQDNS=$(terraform output -json vm_fqdns | jq -r '.[]')

# Définir le groupe de ressources "items"
ITEMS_RESOURCE_GROUP="${LAB_RESOURCE_GROUP}-items"

# Fonction pour obtenir l'adresse IP publique
get_public_ip() {
    local vm_name=$1
    local ip_name="${vm_name}"
    print_color "blue" "Recherche de l'adresse IP publique pour $vm_name..."
    
    IP_ADDRESS=$(az network public-ip show --resource-group "$ITEMS_RESOURCE_GROUP" --name "$ip_name" --query ipAddress -o tsv 2>/dev/null)
    
    if [ -n "$IP_ADDRESS" ]; then
        echo "$IP_ADDRESS"
        return 0
    else
        print_color "yellow" "Adresse IP publique non trouvée pour $vm_name"
        return 1
    fi
}

# Fonction pour revendiquer la VM
claim_vm() {
    local vm_name=$1
    print_color "blue" "Tentative de revendication de la VM $vm_name..."
    CLAIM_RESULT=$(az lab vm claim --resource-group "$LAB_RESOURCE_GROUP" --lab-name "$LAB_NAME" --name "$vm_name" -o json 2>&1)
    
    if [ $? -eq 0 ]; then
        print_color "blue" "VM $vm_name revendiquée avec succès."
        return 0
    else
        print_color "yellow" "Échec de la revendication de la VM $vm_name. Erreur : $CLAIM_RESULT"
        return 1
    fi
}

# Créer le fichier d'inventaire Ansible
mkdir -p ../ansible
echo "[docker_hosts]" > ../ansible/inventory.ini
echo "[db_servers]" >> ../ansible/inventory.ini
echo "[front]" >> ../ansible/inventory.ini
echo "[back]" >> ../ansible/inventory.ini

# Pour chaque VM
i=0
for VM_NAME in $VM_NAMES; do
    # Tenter de revendiquer la VM
    claim_vm "$VM_NAME"

    # Obtenir l'adresse IP publique
    PUBLIC_IP=$(get_public_ip "$VM_NAME")

    # Ajouter la VM au fichier d'inventaire
    if [ -n "$PUBLIC_IP" ]; then
        echo "$VM_NAME ansible_host=$PUBLIC_IP" >> ../ansible/inventory.ini.tmp
        if [[ $VM_NAME == *"bdd"* ]]; then
            sed -i "/\[db_servers\]/a $VM_NAME ansible_host=$PUBLIC_IP" ../ansible/inventory.ini
        elif [[ $VM_NAME == *"back"* ]]; then
            sed -i "/\[back\]/a $VM_NAME ansible_host=$PUBLIC_IP" ../ansible/inventory.ini
        elif [[ $VM_NAME == *"front"* ]]; then
            sed -i "/\[front\]/a $VM_NAME ansible_host=$PUBLIC_IP" ../ansible/inventory.ini
        fi
        sed -i "/\[docker_hosts\]/a $VM_NAME ansible_host=$PUBLIC_IP" ../ansible/inventory.ini
    else
        print_color "yellow" "Impossible d'ajouter $VM_NAME à l'inventaire car ni l'IP publique ni le FQDN ne sont disponibles."
    fi

    i=$((i+1))
done

# Ajouter les variables globales à l'inventaire
cat << EOF >> ../ansible/inventory.ini

[all:vars]
ansible_user=$ansibleUser
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

print_color "blue" "Le fichier d'inventaire Ansible 'inventory.ini' a été créé."

# Exécuter les playbooks Ansible
print_color "blue" "Exécution du playbook Ansible install_docker..."
cd ../ansible
ansible-playbook -i inventory.ini install_docker.yml -v

print_color "blue" "Exécution du playbook Ansible install_secure_postgres..."
ansible-playbook -i inventory.ini install_secure_postgres.yml -v

# Vérifier si l'exécution d'Ansible a réussi
if [ $? -eq 0 ]; then
    print_color "blue" "Les playbooks Ansible ont été exécutés avec succès."
else
    print_color "red" "Erreur lors de l'exécution des playbooks Ansible."
fi

# Revenir au répertoire initial
cd ..

# Afficher les informations finales
print_color "green" "----------------------------------------"
i=0
for VM_NAME in $VM_NAMES; do
    PUBLIC_IP=$(get_public_ip "$VM_NAME")
    VM_FQDN=$(echo $VM_FQDNS | cut -d' ' -f$((i+1)))
    print_color "green" "VM : $VM_NAME"
    print_color "green" "Adresse IP publique : $PUBLIC_IP"
    print_color "green" "FQDN : $VM_FQDN"
    print_color "green" "----------------------------------------"
    i=$((i+1))
done
print_color "green" "Nom du Lab : $LAB_NAME"
print_color "green" "Groupe de ressources du Lab : $LAB_RESOURCE_GROUP"
print_color "green" "Groupe de ressources des items : $ITEMS_RESOURCE_GROUP"
print_color "green" "----------------------------------------"

# Calculer et afficher le temps d'exécution
end_time=$(date +%s)
execution_time=$((end_time - start_time))
minutes=$((execution_time / 60))
seconds=$((execution_time % 60))
print_color "blue" "Temps d'exécution du script : ${minutes} min ${seconds} sec"