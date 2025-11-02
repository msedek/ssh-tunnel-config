#!/bin/bash
# Script para crear el repositorio en GitHub y subir la configuración

REPO_NAME="ssh-tunnel-config"
USERNAME="msedek"  # Cambia esto por tu usuario de GitHub

echo "Creando repositorio en GitHub..."

# Opción 1: Si tienes GitHub CLI instalado y autenticado
if command -v gh &> /dev/null; then
    echo "Usando GitHub CLI..."
    gh repo create $REPO_NAME --public --source=. --remote=origin --push
    exit $?
fi

# Opción 2: Usando la API de GitHub (necesitas un token)
# Si tienes un token de GitHub, úsalo así:
# GITHUB_TOKEN="tu_token_aqui"
# curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user/repos -d "{\"name\":\"$REPO_NAME\",\"public\":true}"

# Opción 3: Manual - Crear el repositorio en GitHub.com y luego:
echo ""
echo "Para crear el repositorio manualmente:"
echo "1. Ve a https://github.com/new"
echo "2. Crea un repositorio llamado: $REPO_NAME"
echo "3. NO inicialices con README, .gitignore o licencia"
echo "4. Luego ejecuta estos comandos:"
echo ""
echo "   git remote add origin https://github.com/$USERNAME/$REPO_NAME.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""

