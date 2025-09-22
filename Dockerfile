# Multi-stage build pour optimiser la taille de l'image
FROM python:3.11-slim as builder

# Variables d'environnement pour optimiser Python dans un conteneur
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Créer un utilisateur non-root pour la sécurité
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Répertoire de travail
WORKDIR /app

# Copier les fichiers de dépendances en premier pour optimiser le cache Docker
COPY requirements.txt .

# Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code de l'application
COPY . .

# Changer le propriétaire des fichiers vers l'utilisateur non-root
RUN chown -R appuser:appuser /app

# Basculer vers l'utilisateur non-root
USER appuser

# Port sur lequel l'application écoute
EXPOSE 5000

# Variables d'environnement pour Flask en production
ENV FLASK_APP=app.py \
    FLASK_ENV=production \
    PYTHONPATH=/app

# Commande de santé pour vérifier le statut du conteneur
HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5000/health')" || exit 1

# Commande par défaut pour démarrer l'application
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=5000"]