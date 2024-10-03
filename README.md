# Terracloud
Comment se connecter au vm

Lancer le tunnel bastion pour accéder aux vm:
az login
az network bastion tunnel --name "bastion-host" --resource-group "rg-terracloud-dev" --target-resource-id $(az vm show -g "rg-terracloud-dev" -n "NOM DE LA VM QUE VOUS CHERCHEZ" --query id -o tsv) --resource-port 22 --port 50022

ssh -i ~/.ssh/id_rsa adminuser@localhost -p 50022