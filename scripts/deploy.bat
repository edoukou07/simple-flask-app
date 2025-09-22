@echo off
REM Script de déploiement rapide pour Simple Flask App (Windows)
REM Usage: deploy.bat [dev|prod|build]

setlocal EnableDelayedExpansion

REM Configuration
set APP_NAME=simple-flask-app
set REGISTRY_NAME=myflaskregistry
set RESOURCE_GROUP=simple-flask-rg
set LOCATION=francecentral

REM Vérifier les arguments
if "%1"=="" goto :help
if "%1"=="help" goto :help
if "%1"=="-h" goto :help
if "%1"=="--help" goto :help

REM Vérifier si Docker est installé
docker --version >nul 2>&1
if !errorlevel! neq 0 (
    echo [ERROR] Docker n'est pas installé ou n'est pas dans le PATH
    exit /b 1
)
echo [INFO] Docker détecté

goto :%1

:dev
echo [INFO] Build et déploiement en mode développement...
call :build_dev
call :run_dev
goto :end

:prod
echo [INFO] Build et déploiement en mode production...
call :build_prod
call :run_prod
goto :end

:build
echo [INFO] Build des images Docker...
call :build_dev
call :build_prod
goto :end

:build_dev
echo [INFO] Construction de l'image de développement...
docker build -t %APP_NAME%:dev .
if !errorlevel! neq 0 (
    echo [ERROR] Échec du build de l'image de développement
    exit /b 1
)
echo [INFO] Image de développement construite avec succès
goto :eof

:build_prod
echo [INFO] Construction de l'image de production...
docker build -f Dockerfile.production -t %APP_NAME%:prod .
if !errorlevel! neq 0 (
    echo [ERROR] Échec du build de l'image de production
    exit /b 1
)
echo [INFO] Image de production construite avec succès
goto :eof

:run_dev
echo [INFO] Démarrage du conteneur en mode développement...
REM Arrêter le conteneur existant s'il existe
docker stop %APP_NAME%-dev >nul 2>&1
docker rm %APP_NAME%-dev >nul 2>&1

docker run -d ^
    --name %APP_NAME%-dev ^
    -p 5000:5000 ^
    -e FLASK_ENV=development ^
    %APP_NAME%:dev

if !errorlevel! neq 0 (
    echo [ERROR] Échec du démarrage du conteneur
    exit /b 1
)

echo [INFO] Application démarrée sur http://localhost:5000
echo [INFO] Test de santé dans 5 secondes...
timeout /t 5 /nobreak >nul
curl -s http://localhost:5000/health
goto :eof

:run_prod
echo [INFO] Démarrage du conteneur en mode production...
REM Arrêter le conteneur existant s'il existe
docker stop %APP_NAME%-prod >nul 2>&1
docker rm %APP_NAME%-prod >nul 2>&1

docker run -d ^
    --name %APP_NAME%-prod ^
    -p 5000:5000 ^
    --restart unless-stopped ^
    -e FLASK_ENV=production ^
    %APP_NAME%:prod

if !errorlevel! neq 0 (
    echo [ERROR] Échec du démarrage du conteneur
    exit /b 1
)

echo [INFO] Application démarrée sur http://localhost:5000
echo [INFO] Test de santé dans 5 secondes...
timeout /t 5 /nobreak >nul
curl -s http://localhost:5000/health
goto :eof

:help
echo Usage: %0 [COMMAND]
echo.
echo Commandes disponibles:
echo   dev     - Build et déploiement local en mode développement
echo   prod    - Build et déploiement local en mode production  
echo   build   - Build des images Docker (dev et prod)
echo   help    - Affiche cette aide
echo.
echo Exemples:
echo   %0 dev      # Déploiement local pour le développement
echo   %0 prod     # Déploiement local pour la production
echo   %0 build    # Build des deux images
goto :end

:unknown
echo [ERROR] Commande inconnue: %1
echo Utilisez '%0 help' pour voir les options disponibles.
exit /b 1

:end
echo [INFO] Script terminé.