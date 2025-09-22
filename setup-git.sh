#!/bin/bash

# Script de configuration Git pour simple-flask-app
# Ce script configure le repository pour être poussé vers GitHub

echo "🔧 Configuration du repository Git simple-flask-app"
echo "=================================================="

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "app.py" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis le répertoire simple-flask-app"
    exit 1
fi

# Demander à l'utilisateur le nom du repository GitHub
read -p "📝 Entrez le nom du repository GitHub (par défaut: simple-flask-app): " repo_name
repo_name=${repo_name:-simple-flask-app}

read -p "📝 Entrez votre nom d'utilisateur GitHub: " github_username

# Configurer le remote origin
echo "🔗 Configuration du remote origin..."
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/${github_username}/${repo_name}.git"

echo "✅ Remote origin configuré: https://github.com/${github_username}/${repo_name}.git"

# Afficher les informations du repository
echo ""
echo "📊 État du repository:"
echo "====================="
git status

echo ""
echo "📋 Branches disponibles:"
git branch -a

echo ""
echo "🚀 Commandes pour pousser vers GitHub:"
echo "======================================"
echo "1. Créez d'abord le repository '${repo_name}' sur GitHub"
echo "2. Puis exécutez:"
echo "   git push -u origin main"
echo "   git push -u origin feature/docker-containerization"
echo ""
echo "🔗 URL pour créer le repository:"
echo "https://github.com/new"
echo ""
echo "✅ Configuration terminée!"