# Script pour deployer l'image depuis ACR
param(
    [string]$ResourceGroup = "simple-flask-rg",
    [string]$AcrName = "myflaskregistry",
    [string]$ImageName = "simple-flask-app:latest",
    [string]$ContainerName = "simple-flask-container"
)

Write-Host "DEPLOIEMENT DEPUIS ACR" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan

Write-Host "Registry: $AcrName" -ForegroundColor Gray
Write-Host "Image: $ImageName" -ForegroundColor Gray
Write-Host "Resource Group: $ResourceGroup" -ForegroundColor Gray

# 1. Verifier que l'image existe dans ACR
Write-Host "`n1. Verification de l'image dans ACR..." -ForegroundColor Yellow
$imageExists = az acr repository show --repository simple-flask-app --name $AcrName
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Image trouvee dans ACR" -ForegroundColor Green
} else {
    Write-Host "[ERREUR] Image non trouvee" -ForegroundColor Red
    exit 1
}

# 2. Creer un Azure Container Instance
Write-Host "`n2. Deploiement sur Azure Container Instances..." -ForegroundColor Yellow
$containerInstance = "flask-app-$(Get-Random -Maximum 9999)"

az container create `
    --resource-group $ResourceGroup `
    --name $containerInstance `
    --image "$AcrName.azurecr.io/$ImageName" `
    --dns-name-label $containerInstance `
    --ports 5000 `
    --cpu 1 `
    --memory 1 `
    --os-type Linux `
    --registry-login-server "$AcrName.azurecr.io" `
    --registry-username $AcrName `
    --registry-password $(az acr credential show --name $AcrName --query "passwords[0].value" -o tsv)

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Container Instance cree!" -ForegroundColor Green
    
    # Obtenir l'URL publique
    $fqdn = az container show --resource-group $ResourceGroup --name $containerInstance --query "ipAddress.fqdn" -o tsv
    Write-Host "`nURL de l'application:" -ForegroundColor Cyan
    Write-Host "http://$fqdn:5000" -ForegroundColor White
    Write-Host "Health check: http://$fqdn:5000/health" -ForegroundColor White
    Write-Host "API Time: http://$fqdn:5000/api/time" -ForegroundColor White
    
    # Afficher les logs
    Write-Host "`nLogs du container (5 dernieres lignes):" -ForegroundColor Yellow
    az container logs --resource-group $ResourceGroup --name $containerInstance --tail 5
    
} else {
    Write-Host "[ERREUR] Echec du deploiement" -ForegroundColor Red
}

Write-Host "`nCommandes utiles:" -ForegroundColor Cyan
Write-Host "- Voir les logs: az container logs --resource-group $ResourceGroup --name $containerInstance" -ForegroundColor White
Write-Host "- Supprimer: az container delete --resource-group $ResourceGroup --name $containerInstance --yes" -ForegroundColor White