# Script ultra-simple pour creer la tache ACR
Write-Host "Creation tache ACR simple..." -ForegroundColor Cyan

# Commande basique sans triggers
az acr task create `
    --registry myflaskregistry `
    --name simple-flask-app-task `
    --image simple-flask-app:latest `
    --context https://github.com/edoukou07/simple-flask-app.git#feature/docker-containerization `
    --file Dockerfile `
    --commit-trigger-enabled false `
    --pull-request-trigger-enabled false

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Tache creee!" -ForegroundColor Green
    
    # Lister les taches pour verification
    Write-Host "`nTaches disponibles:" -ForegroundColor Yellow
    az acr task list --registry myflaskregistry --output table
    
    # Executer la tache manuellement
    Write-Host "`nExecution manuelle de la tache..." -ForegroundColor Yellow
    az acr task run --registry myflaskregistry --name simple-flask-app-task
    
} else {
    Write-Host "[ERREUR] Echec creation tache" -ForegroundColor Red
}