# Manifestes Kubernetes

Le Secret `workshop-organizer-db-secret` (identifiants PostgreSQL) n'est pas versionné : un Secret
Kubernetes n'est qu'encodé en base64, pas chiffré. Il est créé au déploiement, avant les autres manifestes :

```bash
kubectl create secret generic workshop-organizer-db-secret \
  --from-literal=username=<utilisateur> \
  --from-file=password=../secrets/db_password.txt
kubectl apply -f .
```

Clés attendues par `deployment-db.yaml` et `deployment-app.yaml` : `username`, `password`.
`k8s/secret.yaml` est ignoré par git (`.gitignore`) pour éviter de commiter un Secret par erreur.
