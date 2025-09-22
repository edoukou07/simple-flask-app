# Simple Flask App 🚀

Une application Flask simple et moderne avec containerisation Docker complète et options de déploiement cloud.

## 📋 Vue d'ensemble

Cette application démontre les meilleures pratiques pour :
- ✅ Développement d'applications Flask modernes
- ✅ Containerisation avec Docker (dev & production)
- ✅ Déploiement sur Azure (Container Instances, App Service, AKS)
- ✅ CI/CD avec GitHub Actions
- ✅ Configuration multi-environnement

## 🏗️ Structure du projet

```
simple-flask-app/
├── 📄 app.py                    # Application Flask principale
├── 📋 requirements.txt          # Dépendances Python
├── 🐳 Dockerfile               # Image Docker développement
├── 🐳 Dockerfile.production    # Image Docker production optimisée
├── 📝 docker-compose.yml       # Orchestration Docker
├── 🔧 nginx.conf              # Configuration Nginx reverse proxy
├── 📚 README_DOCKER.md        # Guide complet Docker & déploiement
├── 🚀 deploy.sh / deploy.bat   # Scripts de déploiement automatisé
└── 📁 templates/              # Templates HTML Jinja2
    ├── base.html
    ├── index.html
    ├── about.html
    ├── contact.html
    ├── user.html
    ├── 404.html
    └── 500.html
```

## 🚀 Démarrage rapide

### 1. Développement local
```bash
# Cloner le repository
git clone https://github.com/votre-username/simple-flask-app.git
cd simple-flask-app

# Installer les dépendances
pip install -r requirements.txt

# Lancer l'application
python app.py
```

L'application sera accessible sur http://localhost:5000

### 2. Avec Docker (Recommandé)
```bash
# Build de l'image
docker build -t simple-flask-app:dev .

# Lancement du conteneur
docker run -d --name simple-flask-dev -p 5000:5000 simple-flask-app:dev

# Ou avec Docker Compose
docker-compose up -d
```

### 3. Production avec Docker Compose + Nginx
```bash
# Lancement en mode production
docker-compose --profile production up -d
```

Accessible sur http://localhost (port 80)

## 🔧 Fonctionnalités

### Application Flask
- **Page d'accueil** : Interface moderne et responsive
- **Page À propos** : Informations sur l'application
- **Page Contact** : Formulaire de contact (exemple)
- **Page Utilisateur** : Profil utilisateur dynamique
- **API Health Check** : `/health` pour la surveillance
- **API Time** : `/api/time` pour tests API

### Routes disponibles
```
GET /                 # Page d'accueil
GET /about           # À propos
GET /contact         # Contact
GET /user/<name>     # Profil utilisateur
GET /health          # Health check
GET /api/time        # API time
```

### Containerisation Docker
- **Image de développement** : Flask development server
- **Image de production** : Gunicorn + utilisateur non-root
- **Docker Compose** : Orchestration dev & prod
- **Nginx** : Reverse proxy pour production
- **Health checks** : Surveillance automatique

## ☁️ Déploiement Cloud

### Azure Container Instances (ACI)
```bash
# Déploiement rapide
./deploy.sh aci
```

### Azure App Service
```bash
# Déploiement App Service
./deploy.sh appservice
```

### Azure Kubernetes Service (AKS)
```bash
# Déploiement Kubernetes
kubectl apply -f k8s/
```

Consultez [README_DOCKER.md](README_DOCKER.md) pour les guides détaillés.

## 🔧 Configuration

### Variables d'environnement
```bash
FLASK_ENV=development          # Mode Flask (development/production)
SECRET_KEY=your-secret-key     # Clé secrète Flask
PORT=5000                      # Port d'écoute
```

### Fichiers de configuration
- `.dockerignore` : Optimisation du contexte Docker
- `docker-compose.yml` : Orchestration multi-services
- `nginx.conf` : Configuration reverse proxy
- `k8s/deployment.yaml` : Manifeste Kubernetes

## 🛡️ Sécurité

- ✅ Utilisateur non-root dans les conteneurs
- ✅ Images basées sur `python:slim`
- ✅ Variables d'environnement pour les secrets
- ✅ Health checks pour la surveillance
- ✅ Gunicorn pour la production (pas le dev server)
- ✅ Gestion d'erreurs personnalisées (404, 500)

## 🧪 Tests et développement

### Tests locaux
```bash
# Test de l'application
curl http://localhost:5000/health
curl http://localhost:5000/api/time
```

### Tests Docker
```bash
# Test automatisé avec Docker
docker run --rm -p 5000:5000 simple-flask-app:prod &
sleep 10
curl -f http://localhost:5000/health && echo "✅ Health check passed"
```

## 📊 Monitoring

### Logs Docker
```bash
# Voir les logs en temps réel
docker logs -f simple-flask-dev

# Statistiques du conteneur
docker stats simple-flask-dev
```

### Métriques de santé
- `/health` : Status de l'application
- Logs structurés avec timestamps
- Gestion d'erreurs centralisée

## 🤝 Contribution

1. **Fork** le projet
2. **Créer** une branche feature (`git checkout -b feature/amazing-feature`)
3. **Commit** vos changements (`git commit -m 'Add amazing feature'`)
4. **Push** vers la branche (`git push origin feature/amazing-feature`)
5. **Ouvrir** une Pull Request

## 📚 Documentation

- [README_DOCKER.md](README_DOCKER.md) - Guide complet Docker et déploiement
- [Dockerfile](Dockerfile) - Configuration développement
- [Dockerfile.production](Dockerfile.production) - Configuration production
- [docker-compose.yml](docker-compose.yml) - Orchestration Docker

## 🏷️ Versions

- **v1.0.0** - Application Flask de base
- **v2.0.0** - Containerisation Docker complète
- **v2.1.0** - Déploiement cloud Azure
- **v2.2.0** - CI/CD GitHub Actions

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👥 Auteurs

- **Votre Nom** - *Développement initial* - [VotreGitHub](https://github.com/votre-username)

## 🙏 Remerciements

- Flask pour le framework web Python
- Docker pour la containerisation
- Azure pour l'hébergement cloud
- GitHub Actions pour CI/CD

---

⭐ **N'hésitez pas à starred ce projet si il vous a été utile !** ⭐