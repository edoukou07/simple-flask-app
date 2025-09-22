#!/bin/bash

# Script de déploiement rapide pour Simple Flask App
# Usage: ./deploy.sh [dev|prod|aci|aks]

set -e  # Arrêter le script en cas d'erreur

# Configuration
APP_NAME="simple-flask-app"
REGISTRY_NAME="myflaskregistry"
RESOURCE_GROUP="simple-flask-rg"
LOCATION="francecentral"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# Fonction pour vérifier si Docker est installé
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker n'est pas installé. Veuillez l'installer avant de continuer."
    fi
    log "✅ Docker détecté"
}

# Fonction pour vérifier si Azure CLI est installé
check_azure_cli() {
    if ! command -v az &> /dev/null; then
        error "Azure CLI n'est pas installé. Veuillez l'installer avant de continuer."
    fi
    log "✅ Azure CLI détecté"
}

# Fonction pour build l'image Docker
build_image() {
    local mode=$1
    log "🏗️ Construction de l'image Docker pour $mode..."
    
    if [ "$mode" = "dev" ]; then
        docker build -t ${APP_NAME}:dev .
    elif [ "$mode" = "prod" ]; then
        docker build -f Dockerfile.production -t ${APP_NAME}:prod .
    else
        error "Mode de build invalide: $mode (utilisez 'dev' ou 'prod')"
    fi
    
    log "✅ Image construite avec succès"
}

# Fonction pour déploiement local
deploy_local() {
    local mode=$1
    log "🚀 Déploiement local en mode $mode..."
    
    # Arrêter le conteneur existant s'il existe
    if [ "$(docker ps -q -f name=${APP_NAME}-${mode})" ]; then
        log "🛑 Arrêt du conteneur existant..."
        docker stop ${APP_NAME}-${mode}
        docker rm ${APP_NAME}-${mode}
    fi
    
    # Démarrer le nouveau conteneur
    if [ "$mode" = "dev" ]; then
        docker run -d \
            --name ${APP_NAME}-${mode} \
            -p 5000:5000 \
            -e FLASK_ENV=development \
            ${APP_NAME}:dev
    elif [ "$mode" = "prod" ]; then
        docker run -d \
            --name ${APP_NAME}-${mode} \
            -p 5000:5000 \
            --restart unless-stopped \
            -e FLASK_ENV=production \
            ${APP_NAME}:prod
    fi
    
    log "✅ Application démarrée sur http://localhost:5000"
    log "🔍 Test de santé..."
    sleep 5
    curl -s http://localhost:5000/health || warning "Le test de santé a échoué"
}

# Fonction pour déploiement sur Azure Container Instances
deploy_aci() {
    check_azure_cli
    log "☁️ Déploiement sur Azure Container Instances..."
    
    # Se connecter à Azure
    log "🔐 Connexion à Azure..."
    az login --output none
    
    # Créer le groupe de ressources s'il n'existe pas
    if ! az group show --name $RESOURCE_GROUP &> /dev/null; then
        log "📦 Création du groupe de ressources $RESOURCE_GROUP..."
        az group create --name $RESOURCE_GROUP --location $LOCATION --output none
    fi
    
    # Créer l'Azure Container Registry s'il n'existe pas
    if ! az acr show --name $REGISTRY_NAME --resource-group $RESOURCE_GROUP &> /dev/null; then
        log "🏪 Création d'Azure Container Registry..."
        az acr create \
            --resource-group $RESOURCE_GROUP \
            --name $REGISTRY_NAME \
            --sku Basic \
            --output none
    fi
    
    # Se connecter au registry
    log "🔑 Connexion au registry..."
    az acr login --name $REGISTRY_NAME --output none
    
    # Tagger et pousser l'image
    log "📤 Push de l'image vers ACR..."
    docker tag ${APP_NAME}:prod ${REGISTRY_NAME}.azurecr.io/${APP_NAME}:latest
    docker push ${REGISTRY_NAME}.azurecr.io/${APP_NAME}:latest
    
    # Obtenir les credentials du registry
    local registry_password=$(az acr credential show --name $REGISTRY_NAME --query passwords[0].value --output tsv)
    
    # Déployer sur ACI
    log "🚀 Déploiement sur Azure Container Instances..."
    az container create \
        --resource-group $RESOURCE_GROUP \
        --name ${APP_NAME}-aci \
        --image ${REGISTRY_NAME}.azurecr.io/${APP_NAME}:latest \
        --registry-login-server ${REGISTRY_NAME}.azurecr.io \
        --registry-username $REGISTRY_NAME \
        --registry-password "$registry_password" \
        --dns-name-label ${APP_NAME}-$(date +%s) \
        --ports 5000 \
        --cpu 1 \
        --memory 1 \
        --restart-policy Always \
        --output none
    
    # Obtenir l'URL publique
    local public_url=$(az container show \
        --resource-group $RESOURCE_GROUP \
        --name ${APP_NAME}-aci \
        --query ipAddress.fqdn \
        --output tsv)
    
    log "✅ Application déployée sur Azure Container Instances"
    log "🌐 URL publique: http://$public_url:5000"
}

# Fonction pour déploiement sur AKS
deploy_aks() {
    check_azure_cli
    log "☁️ Déploiement sur Azure Kubernetes Service..."
    
    # Vérifier si kubectl est installé
    if ! command -v kubectl &> /dev/null; then
        error "kubectl n'est pas installé. Veuillez l'installer avant de continuer."
    fi
    
    # Se connecter à Azure
    log "🔐 Connexion à Azure..."
    az login --output none
    
    # Créer le cluster AKS s'il n'existe pas
    if ! az aks show --name ${APP_NAME}-aks --resource-group $RESOURCE_GROUP &> /dev/null; then
        log "🎛️ Création du cluster AKS (cela peut prendre quelques minutes)..."
        az aks create \
            --resource-group $RESOURCE_GROUP \
            --name ${APP_NAME}-aks \
            --node-count 2 \
            --enable-addons monitoring \
            --generate-ssh-keys \
            --attach-acr $REGISTRY_NAME \
            --output none
    fi
    
    # Se connecter au cluster
    log "🔗 Connexion au cluster AKS..."
    az aks get-credentials --resource-group $RESOURCE_GROUP --name ${APP_NAME}-aks --overwrite-existing --output none
    
    # Déployer l'application
    log "🚀 Déploiement de l'application sur Kubernetes..."
    kubectl apply -f k8s/deployment.yaml
    
    # Attendre que les pods soient prêts
    log "⏳ Attente du démarrage des pods..."
    kubectl wait --for=condition=ready pod -l app=simple-flask-app --timeout=300s
    
    # Obtenir l'IP externe du service
    log "🔍 Récupération de l'adresse IP externe..."
    external_ip=""
    while [ -z $external_ip ]; do
        log "⏳ Attente de l'assignation de l'IP externe..."
        external_ip=$(kubectl get service simple-flask-service --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
        [ -z "$external_ip" ] && sleep 10
    done
    
    log "✅ Application déployée sur AKS"
    log "🌐 URL publique: http://$external_ip"
}

# Affichage de l'aide
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commandes disponibles:"
    echo "  dev     - Build et déploiement local en mode développement"
    echo "  prod    - Build et déploiement local en mode production"
    echo "  aci     - Déploiement sur Azure Container Instances"
    echo "  aks     - Déploiement sur Azure Kubernetes Service"
    echo "  help    - Affiche cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 dev      # Déploiement local pour le développement"
    echo "  $0 prod     # Déploiement local pour la production"
    echo "  $0 aci      # Déploiement sur Azure Container Instances"
    echo "  $0 aks      # Déploiement sur Azure Kubernetes Service"
}

# Programme principal
main() {
    local command=${1:-help}
    
    case $command in
        dev)
            check_docker
            build_image "dev"
            deploy_local "dev"
            ;;
        prod)
            check_docker
            build_image "prod"
            deploy_local "prod"
            ;;
        aci)
            check_docker
            build_image "prod"
            deploy_aci
            ;;
        aks)
            check_docker
            build_image "prod"
            deploy_aks
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Commande inconnue: $command. Utilisez '$0 help' pour voir les options disponibles."
            ;;
    esac
}

# Exécuter le programme principal
main "$@"