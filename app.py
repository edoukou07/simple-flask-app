from flask import Flask, render_template, request, jsonify
import datetime

# Créer l'application Flask
app = Flask(__name__)

# Configuration de base
app.config['SECRET_KEY'] = 'your-secret-key-change-in-production'

# Route principale - Page d'accueil
@app.route('/')
def index():
    """Page d'accueil avec un message de bienvenue"""
    current_time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    return render_template('index.html', current_time=current_time)

# Route pour afficher des informations
@app.route('/about')
def about():
    """Page à propos"""
    app_info = {
        'name': 'Simple Flask App',
        'version': '1.0.0',
        'description': 'Une application Flask simple et propre',
        'author': 'Votre nom'
    }
    return render_template('about.html', app_info=app_info)

# Route pour un formulaire simple
@app.route('/contact', methods=['GET', 'POST'])
def contact():
    """Page de contact avec formulaire"""
    if request.method == 'POST':
        name = request.form.get('name')
        email = request.form.get('email')
        message = request.form.get('message')
        
        # Ici, vous pourriez traiter le formulaire (envoyer un email, sauvegarder en base, etc.)
        return render_template('contact.html', 
                             success=True, 
                             name=name)
    
    return render_template('contact.html')

# API Route - Retourne du JSON
@app.route('/api/time')
def api_time():
    """API qui retourne l'heure actuelle en JSON"""
    return jsonify({
        'current_time': datetime.datetime.now().isoformat(),
        'timestamp': datetime.datetime.now().timestamp(),
        'formatted_time': datetime.datetime.now().strftime('%d/%m/%Y à %H:%M:%S')
    })

# Route pour les utilisateurs avec paramètre
@app.route('/user/<username>')
def user_profile(username):
    """Page de profil utilisateur"""
    return render_template('user.html', username=username)

# Route de test de santé
@app.route('/health')
def health():
    """Point de contrôle de santé de l'application"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.datetime.now().isoformat(),
        'application': 'Simple Flask App'
    })

# Gestionnaire d'erreur 404
@app.errorhandler(404)
def page_not_found(error):
    """Gestionnaire d'erreur pour les pages non trouvées"""
    return render_template('404.html'), 404

# Gestionnaire d'erreur 500
@app.errorhandler(500)
def internal_error(error):
    """Gestionnaire d'erreur pour les erreurs internes"""
    return render_template('500.html'), 500

if __name__ == '__main__':
    # Configuration pour le développement
    app.run(debug=True, host='0.0.0.0', port=5000)