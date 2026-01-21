Write-Host "🚀 Démarrage de la mise à jour globale..." -ForegroundColor Cyan

# 1. Mise à jour du package de logique
Write-Host "📦 Étape 1: Envoi de la logique (ouv_logic)..." -ForegroundColor Yellow
cd packages/ouv_logic
git add .
git commit -m "upd: automatique logic update $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push origin main

# 2. Retour à l'app principale
cd ../..
Write-Host "📱 Étape 2: Mise à jour de l'application principale..." -ForegroundColor Yellow
git add .
git commit -m "build: sync app with latest logic $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push origin main

Write-Host "✅ Tout est en ligne sur GitHub !" -ForegroundColor Green

# Pour lancer le script
# ./init_git_sous.ps1

# Pour la commande de secours : La commande que tu as citée
# à la fin est parfaite si ton PC est "en retard" par rapport à GitHub :

# git submodule foreach --recursive 'git fetch origin && git reset --hard origin/main'
