# Simple Flask Application

Une application Flask simple et complète avec interface Bootstrap.

## Fonctionnalités

- ✅ **Page d'accueil** avec informations de base
- ✅ **Page À propos** avec détails de l'application
- ✅ **Formulaire de contact** fonctionnel
- ✅ **Profils utilisateur** dynamiques
- ✅ **API REST** avec endpoints JSON
- ✅ **Gestion d'erreurs** 404 et 500
- ✅ **Interface Bootstrap** responsive

## Structure du projet

```
simple-flask-app/
├── app.py              # Application Flask principale
├── requirements.txt    # Dépendances Python
├── README.md          # Documentation
└── templates/         # Templates HTML
    ├── base.html      # Template de base
    ├── index.html     # Page d'accueil
    ├── about.html     # Page à propos
    ├── contact.html   # Formulaire de contact
    ├── user.html      # Profil utilisateur
    ├── 404.html       # Erreur 404
    └── 500.html       # Erreur 500
```

## Installation et lancement

### 1. Créer un environnement virtuel (recommandé)
```bash
python -m venv venv
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate
```

### 2. Installer les dépendances
```bash
pip install -r requirements.txt
```

### 3. Lancer l'application
```bash
python app.py
```

L'application sera accessible sur : http://localhost:5000

## Routes disponibles

- `/` - Page d'accueil
- `/about` - À propos de l'application
- `/contact` - Formulaire de contact
- `/user/<username>` - Profil utilisateur
- `/api/time` - API JSON avec l'heure
- `/health` - Point de contrôle de santé

## API Endpoints

### GET /api/time
Retourne l'heure actuelle en format JSON :
```json
{
  "current_time": "2025-09-19T16:30:00.123456",
  "timestamp": 1695140200.123456,
  "formatted_time": "19/09/2025 à 16:30:00"
}
```

### GET /health
Point de contrôle de santé :
```json
{
  "status": "healthy",
  "timestamp": "2025-09-19T16:30:00.123456",
  "application": "Simple Flask App"
}
```

## Personnalisation

### Modifier les informations de l'application
Éditez les variables dans la route `/about` dans `app.py` :
```python
app_info = {
    'name': 'Votre App',
    'version': '1.0.0',
    'description': 'Votre description',
    'author': 'Votre nom'
}
```

### Ajouter de nouvelles routes
```python
@app.route('/nouvelle-route')
def nouvelle_fonction():
    return render_template('nouveau_template.html')
```

### Modifier le style
L'application utilise Bootstrap 5. Vous pouvez :
- Modifier le CSS dans `templates/base.html`
- Ajouter un fichier CSS personnalisé dans un dossier `static/`

## Production

Pour utiliser en production, modifiez dans `app.py` :
```python
app.config['SECRET_KEY'] = 'votre-clé-secrète-sécurisée'
app.run(debug=False, host='0.0.0.0', port=80)
```

## Technologies utilisées

- **Python 3.8+**
- **Flask 2.3.3** - Framework web
- **Bootstrap 5.1.3** - Interface utilisateur
- **Jinja2** - Moteur de templates

---

**Auteur** : Créé pour l'apprentissage Flask
**Licence** : MIT