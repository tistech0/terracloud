# Projet Terracloud

## Aperçu du Projet

Terracloud est un projet d'infrastructure-as-code utilisant Terraform pour déployer et gérer une architecture d'application multi-niveaux dans Azure. Le projet met en place un environnement complet comprenant :

- Un réseau virtuel avec plusieurs sous-réseaux
- Des machines virtuelles (VM) Frontend, Backend et Base de données
- Prometheus et Grafana pour la supervision

Le projet utilise un tfstate hébergé dans un compte de stockage Azure.

## Structure du Projet

```
.
├── terraform/
│   ├── main.tf
│   ├── providers.tf
│   ├── outputs.tf
│   └── modules/
│       └── compute/
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
├── ansible/
│   ├── inventory.ini
│   ├── install_docker.yml
│   ├── install_secure_postgres.yml
│   ├── install_prometheus.yml
│   ├── install_grafana.yml
│   └── templates/
│       ├── prometheus.yml.j2
│       ├── prometheus.service.j2
│       └── node_exporter.service.j2
└── deploy_infra.sh
```

## Partie Terraform

La partie Terraform du projet est responsable de la création de l'infrastructure Azure. Elle comprend :

1. Configuration du backend Azure pour stocker l'état Terraform
2. Définition des ressources Azure DevTest Lab
3. Création de machines virtuelles pour le frontend, le backend et la base de données

### Fichiers principaux :

- `main.tf` : Définit les ressources principales
- `providers.tf` : Configure le fournisseur Azure
- `outputs.tf` : Définit les sorties Terraform
- `modules/compute/main.tf` : Module pour créer les machines virtuelles

### Configuration du backend Azure

Le backend Azure est configuré dans le fichier `main.tf` :


```1:8:terraform/maint.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "t-clo-901-nts-0"
    storage_account_name = "atclo901nts03632"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```


### Création des machines virtuelles

Les machines virtuelles sont créées à l'aide du module `compute` :


```23:51:terraform/maint.tf
module "bdd" {
  source = "./modules/compute"

  name                    = "ubuntu-vm-nts-0-bdd"
  lab_name                = data.azurerm_dev_test_lab.lab.name
  lab_resource_group_name = data.azurerm_dev_test_lab.lab.resource_group_name
  lab_virtual_network_id  = data.azurerm_dev_test_virtual_network.lab_network.id
  lab_subnet_name         = "t-clo-901-nts-0Subnet"
}

module "back" {
  source = "./modules/compute"

  name                    = "ubuntu-vm-nts-0-back"
  lab_name                = data.azurerm_dev_test_lab.lab.name
  lab_resource_group_name = data.azurerm_dev_test_lab.lab.resource_group_name
  lab_virtual_network_id  = data.azurerm_dev_test_virtual_network.lab_network.id
  lab_subnet_name         = "t-clo-901-nts-0Subnet"
}

module "front" {
  source = "./modules/compute"

  name                    = "ubuntu-vm-nts-0-front"
  lab_name                = data.azurerm_dev_test_lab.lab.name
  lab_resource_group_name = data.azurerm_dev_test_lab.lab.resource_group_name
  lab_virtual_network_id  = data.azurerm_dev_test_virtual_network.lab_network.id
  lab_subnet_name         = "t-clo-901-nts-0Subnet"
}
```


## Partie Ansible

La partie Ansible du projet est responsable de la configuration des machines virtuelles. Elle comprend :

1. Installation et configuration de Docker
2. Installation et sécurisation de PostgreSQL
3. Installation et configuration de Prometheus pour la surveillance
4. Installation et configuration de Grafana pour la visualisation

### Playbooks principaux :

- `install_docker.yml` : Installe Docker sur toutes les machines
- `install_secure_postgres.yml` : Installe et sécurise PostgreSQL sur le serveur de base de données
- `install_prometheus.yml` : Installe Prometheus sur les serveurs de surveillance
- `install_grafana.yml` : Installe Grafana sur les serveurs de surveillance

## Exécution du Projet

Pour déployer l'infrastructure et configurer les machines virtuelles, suivez ces étapes :

1. Assurez-vous d'avoir installé Terraform, Ansible, Azure CLI et jq sur votre machine locale.

2. Configurez vos identifiants Azure en vous connectant via Azure CLI :
   ```
   az login
   ```

3. Naviguez vers le répertoire racine du projet et exécutez le script de déploiement :
   ```
   ./deploy_infra.sh
   ```

Ce script effectuera les actions suivantes :
- Exécuter Terraform pour créer l'infrastructure
- Générer dynamiquement l'inventaire Ansible
- Exécuter les playbooks Ansible pour configurer les machines virtuelles

## Variables à Adapter

Avant d'exécuter le projet, assurez-vous d'adapter les variables suivantes :

1. Dans `terraform/providers.tf` :
   - `subscription_id`
   - `tenant_id`
   - `client_id`
   - `client_secret`

2. Dans `terraform/main.tf` :
   - Noms des ressources Azure (si vous souhaitez les personnaliser)

3. Dans `ansible/inventory.ini` :
   - `ansible_user` (si différent de "AnsibleUser")
   - `ansible_ssh_private_key_file` (chemin vers votre clé SSH privée)

4. Dans les playbooks Ansible :
   - Versions des logiciels (par exemple, `postgresql_version`, `prometheus_version`, `grafana_version`)
   - Mots de passe et configurations spécifiques (par exemple, `grafana_admin_password`)

5. Dans `terraform/modules/compute/variables.tf` :
   - `ssh_key` (chemin vers votre clé SSH publique)
   - `ssh_user` (nom d'utilisateur SSH par défaut)

6. Editer le ansible vault password

```
ansible-vault edit ansible/group_vars/all/vault.yml
```

Assurez-vous également que votre clé SSH publique est correctement configurée dans Azure pour permettre l'accès aux machines virtuelles.

## Remarque

Ce projet est conçu pour un environnement de développement/test. Pour un environnement de production, des mesures de sécurité supplémentaires devraient être mises en place.
