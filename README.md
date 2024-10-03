# Projet Terracloud

## Aperçu du Projet

Terracloud est un projet d'infrastructure-as-code utilisant Terraform pour déployer et gérer une architecture d'application multi-niveaux dans Azure. Le projet met en place un environnement complet comprenant :

- Un réseau virtuel avec plusieurs sous-réseaux
- Des machines virtuelles (VM) Frontend, Backend et Base de données
- Des équilibreurs de charge pour le Frontend et le Backend
- Des groupes de sécurité réseau pour chaque niveau
- Azure Bastion pour un accès sécurisé aux VM

Le projet utilise un tfstate hébergé dans un workspace HCP (HashiCorp Cloud Platform) pour une gestion sécurisée et collaborative de l'état de l'infrastructure.

## Structure du Projet

- `main.tf` : Contient la configuration Terraform principale du projet, y compris la configuration du backend HCP.
- `variables.tf` : Définit les variables utilisées dans la configuration Terraform.
- `outputs.tf` : Spécifie les sorties après l'application de la configuration Terraform.
- `start_bastion_tunnels.sh` : Script pour démarrer les tunnels Bastion pour toutes les VM.

## Configuration

### Gestion de l'État Terraform

Ce projet utilise un backend Terraform Cloud pour stocker et gérer l'état de l'infrastructure (tfstate). Cela offre plusieurs avantages :

- Stockage sécurisé de l'état
- Collaboration facilitée entre les membres de l'équipe
- Versioning de l'état
- Exécution à distance des opérations Terraform

La configuration du backend se trouve dans le fichier `main.tf` :

```hcl
terraform {
  cloud {
    organization = "tcloud-901"
    workspaces {
      name = "terracloud"
    }
  }
}
```

Assurez-vous d'avoir les autorisations nécessaires pour accéder à ce workspace HCP avant de commencer à travailler sur le projet.

## Pour Commencer

1. Assurez-vous d'avoir Terraform installé et configuré pour utiliser Terraform Cloud.
2. Clonez ce dépôt.
3. Mettez à jour le fichier `variables.tf` avec vos valeurs spécifiques.
4. Connectez-vous à Terraform Cloud :
   ```
   terraform login
   ```
5. Initialisez le projet Terraform :
   ```
   terraform init
   ```
6. Exécutez `terraform plan` pour voir le plan d'exécution.
7. Exécutez `terraform apply` pour créer l'infrastructure dans Azure.

## Connexion aux VM

Nous utilisons Azure Bastion pour un accès sécurisé à nos VM. Il existe deux méthodes pour se connecter :

### Méthode 1 : Accès à une VM individuelle

1. Connectez-vous à Azure CLI :
   ```
   az login
   ```

2. Démarrez un tunnel Bastion pour la VM spécifique à laquelle vous souhaitez accéder :
   ```
   az network bastion tunnel --name "bastion-host" --resource-group "rg-terracloud-dev" --target-resource-id $(az vm show -g "rg-terracloud-dev" -n "NOM_DE_VOTRE_VM" --query id -o tsv) --resource-port 22 --port 50022
   ```
   Remplacez `NOM_DE_VOTRE_VM` par le nom de la VM à laquelle vous voulez accéder.

3. Connectez-vous à la VM en utilisant SSH :
   ```
   ssh -i ~/.ssh/id_rsa adminuser@localhost -p 50022
   ```

### Méthode 2 : Accès à toutes les VM (Recommandée)

1. Assurez-vous d'être connecté à Azure CLI :
   ```
   az login
   ```

2. Assurez-vous d'avoir le script `start_bastion_tunnels.sh` dans votre répertoire de projet.

3. Rendez le script exécutable (optionel peut etre deja executable) :
   ```
   chmod +x start_bastion_tunnels.sh
   ```

4. Exécutez le script :
   ```
   ./start_bastion_tunnels.sh
   ```

5. Le script affichera les ports locaux attribués à chaque VM. Vous pouvez ensuite vous connecter à n'importe quelle VM en utilisant :
   ```
   ssh -p PORT adminuser@localhost
   ```
   Remplacez `PORT` par le numéro de port approprié pour la VM à laquelle vous voulez accéder.

6. Pour fermer tous les tunnels, revenez au terminal exécutant le script et appuyez sur Ctrl+C.

## Note

N'oubliez pas d'exécuter `terraform destroy` lorsque vous avez terminé pour éviter des frais Azure inutiles.

Pour tout problème ou amélioration, veuillez ouvrir une issue dans le dépôt du projet.