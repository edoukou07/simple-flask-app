# Simple Flask App - Guide Docker et Déploiement

## 📋 Vue d'ensemble
Cette application Flask simple démontre les bonnes pratiques de containerisation avec Docker et les options de déploiement sur différentes plateformes.

## ⚠️ Note importante pour les commandes
Les commandes multilignes dans ce guide utilisent le backtick `` ` `` comme caractère de continuation, adapté pour **PowerShell sur Windows**. 

**Pour d'autres terminaux :**
- **Bash/Zsh (Linux/macOS)** : Remplacez `` ` `` par `\`
- **CMD Windows** : Remplacez `` ` `` par `^`
- **PowerShell** : Utilisez `` ` `` (comme dans ce guide)

## 🏗️ Structure du projet
```
simple-flask-app/
├── app.py                    # Application Flask principale
├── requirements.txt          # Dépendances Python
├── Dockerfile               # Dockerfile pour développement
├── Dockerfile.production    # Dockerfile optimisé pour production
├── docker-compose.yml       # Configuration Docker Compose
├── nginx.conf              # Configuration Nginx pour production
├── .dockerignore           # Fichiers à ignorer lors du build
├── README.md               # Ce fichier
└── templates/              # Templates HTML
    ├── base.html
    ├── index.html
    ├── about.html
    ├── contact.html
    ├── user.html
    ├── 404.html
    └── 500.html
```

## 🐳 Containerisation avec Docker

### 1. Build de l'image Docker

#### Version développement
```bash
# Build de l'image pour le développement
docker build -t simple-flask-app:dev .

# Ou spécifier le Dockerfile explicitement
docker build -f Dockerfile -t simple-flask-app:dev .
```

#### Version production
```bash
# Build de l'image pour la production (avec Gunicorn)
docker build -f Dockerfile.production -t simple-flask-app:prod .
```

### 2. Exécution du conteneur

#### Mode développement
```bash
# Lancer le conteneur en mode développement
docker run -d `
  --name simple-flask-app-dev `
  -p 5000:5000 `
  simple-flask-app:dev

# Avec variables d'environnement personnalisées
docker run -d `
  --name simple-flask-app-dev `
  -p 5000:5000 `
  -e FLASK_ENV=development `
  simple-flask-app:dev
```

#### Mode production
```bash
# Lancer le conteneur en mode production
docker run -d `
  --name simple-flask-app-prod `
  -p 5000:5000 `
  --restart unless-stopped `
  simple-flask-app:prod
```

### 3. Vérification du conteneur
```bash
# Vérifier le statut du conteneur
docker ps

# Voir les logs
docker logs simple-flask-app-dev

# Vérifier la santé de l'application
curl http://localhost:5000/health

# Accéder au conteneur
docker exec -it simple-flask-app-dev bash
```

## 🚀 Utilisation avec Docker Compose

### 1. Développement simple
```bash
# Démarrer l'application
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Arrêter l'application
docker-compose down
```

### 2. Production avec Nginx
```bash
# Démarrer avec le profil production (inclut Nginx)
docker-compose --profile production up -d

# L'application sera accessible sur le port 80 via Nginx
curl http://localhost/health
```

### 3. Rebuild et redémarrage
```bash
# Rebuild l'image et redémarrer
docker-compose up -d --build

# Forcer la recréation des conteneurs
docker-compose up -d --force-recreate
```

## ☁️ Déploiement Cloud

### 1. Azure Container Instances (ACI)

#### Prérequis
```bash
# Se connecter à Azure
az login

# Créer un groupe de ressources
az group create --name simple-flask-rg --location francecentral
```

#### Déploiement direct
```bash
# Déployer sur Azure Container Instances
az container create `
  --resource-group simple-flask-rg `
  --name simple-flask-app `
  --image simple-flask-app:prod `
  --dns-name-label simple-flask-unique-name `
  --ports 5000 `
  --cpu 1 `
  --memory 1 `
  --restart-policy Always
```

#### Avec Azure Container Registry (ACR)
```bash
# Créer un registry Azure Container Registry
az acr create --resource-group simple-flask-rg --name myflaskregistry --sku Basic

# Se connecter au registry
az acr login --name myflaskregistry

# Tagger l'image pour ACR
docker tag simple-flask-app:dev myflaskregistry.azurecr.io/simple-flask-app:latest

# Pousser l'image vers ACR
docker push myflaskregistry.azurecr.io/simple-flask-app:latest

# Déployer depuis ACR
az container create `
  --resource-group simple-flask-rg `
  --name simple-flask-app `
  --image myflaskregistry.azurecr.io/simple-flask-app:latest `
  --registry-login-server myflaskregistry.azurecr.io `
  --registry-username myflaskregistry `
  --registry-password $(az acr credential show --name myflaskregistry --query passwords[0].value --output tsv) `
  --dns-name-label simple-flask-unique-name `
  --ports 5000
```

### 2. Azure App Service (Container)

#### Déploiement via Azure CLI
```bash
# Créer un plan App Service Linux
az appservice plan create `
  --name simple-flask-plan `
  --resource-group simple-flask-rg `
  --sku B1 `
  --is-linux

# Créer l'application web avec conteneur
az webapp create `
  --resource-group simple-flask-rg `
  --plan simple-flask-plan `
  --name simple-flask-webapp-unique `
  --deployment-container-image-name myflaskregistry.azurecr.io/simple-flask-app:latest

# Configurer les paramètres du conteneur
az webapp config appsettings set `
  --resource-group simple-flask-rg `
  --name simple-flask-webapp-unique `
  --settings WEBSITES_PORT=5000
```

### 3. Azure Kubernetes Service (AKS)

#### Fichiers de déploiement Kubernetes
Créer `k8s/deployment.yaml` :
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simple-flask-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: simple-flask-app
  template:
    metadata:
      labels:
        app: simple-flask-app
    spec:
      containers:
      - name: simple-flask-app
        image: myflaskregistry.azurecr.io/simple-flask-app:latest
        ports:
        - containerPort: 5000
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: simple-flask-service
spec:
  selector:
    app: simple-flask-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: LoadBalancer
```

#### Déploiement sur AKS
```bash
# Créer le cluster AKS
az aks create `
  --resource-group simple-flask-rg `
  --name simple-flask-aks `
  --node-count 2 `
  --enable-addons monitoring `
  --generate-ssh-keys `
  --attach-acr myflaskregistry

# Se connecter au cluster
az aks get-credentials --resource-group simple-flask-rg --name simple-flask-aks

# Déployer l'application
kubectl apply -f k8s/deployment.yaml

# Vérifier le déploiement
kubectl get pods
kubectl get services
```

## 📊 Monitoring et Logs

### 1. Surveillance Docker
```bash
# Statistiques en temps réel
docker stats

# Logs avec suivi
docker logs -f simple-flask-app-prod

# Inspection du conteneur
docker inspect simple-flask-app-prod
```

### 2. Surveillance Azure
```bash
# Logs Azure Container Instances
az container logs --resource-group simple-flask-rg --name simple-flask-app

# Surveillance App Service
az webapp log tail --resource-group simple-flask-rg --name simple-flask-webapp-unique
```

## 🔧 Configuration et Variables d'environnement

### Variables disponibles
- `FLASK_APP`: Point d'entrée de l'application (défaut: app.py)
- `FLASK_ENV`: Environnement Flask (development/production)
- `SECRET_KEY`: Clé secrète pour Flask
- `PORT`: Port d'écoute (défaut: 5000)

### Exemple de configuration
```bash
docker run -d `
  --name simple-flask-app `
  -p 5000:5000 `
  -e FLASK_ENV=production `
  -e SECRET_KEY=your-production-secret-key `
  simple-flask-app:prod
```

## 🛡️ Sécurité

### Bonnes pratiques implémentées
- ✅ Utilisation d'un utilisateur non-root dans le conteneur
- ✅ Image basée sur `python:slim` pour réduire la surface d'attaque
- ✅ Variables d'environnement pour les configurations sensibles
- ✅ Health checks pour la surveillance
- ✅ Gunicorn en production au lieu du serveur de développement Flask

### Recommandations supplémentaires
- Utiliser des secrets Azure Key Vault en production
- Implémenter HTTPS avec des certificats SSL
- Configurer un WAF (Web Application Firewall)
- Activer la surveillance et les alertes

## 🧪 Tests

### Tests locaux
```bash
# Test de l'application
curl http://localhost:5000/
curl http://localhost:5000/health
curl http://localhost:5000/api/time
```

### Tests automatisés
```bash
# Test avec Docker
docker run --rm -p 5000:5000 simple-flask-app:prod &
sleep 10
curl -f http://localhost:5000/health && echo "✅ Health check passed"
docker stop $(docker ps -q --filter ancestor=simple-flask-app:prod)
```

## 📚 Ressources utiles
- [Documentation officielle Flask](https://flask.palletsprojects.com/)
- [Best practices Docker](https://docs.docker.com/develop/best-practices/)
- [Azure Container Instances](https://docs.microsoft.com/azure/container-instances/)
- [Azure App Service](https://docs.microsoft.com/azure/app-service/)
- [Azure Kubernetes Service](https://docs.microsoft.com/azure/aks/)

## 🤝 Contribution
1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/amazing-feature`)
3. Commit vos changements (`git commit -m 'Add amazing feature'`)
4. Push vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrir une Pull Request


docker login myflaskregistry.azurecr.io