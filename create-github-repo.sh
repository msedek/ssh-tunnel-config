#!/bin/bash
# Script para crear el repositorio en GitHub y subir la configuración

REPO_NAME="ssh-tunnel-config"

echo "========================================="
echo "Creando repositorio en GitHub: $REPO_NAME"
echo "========================================="
echo ""

# Verificar si gh está autenticado
if gh auth status &> /dev/null; then
    echo "✓ GitHub CLI está autenticado"
else
    echo "⚠ GitHub CLI no está autenticado"
    echo ""
    echo "Por favor, autentícate con:"
    echo "  gh auth login"
    echo ""
    echo "O si prefieres usar un token:"
    echo "  gh auth login --with-token < token.txt"
    echo ""
    read -p "¿Deseas autenticarte ahora? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[SsYy]$ ]]; then
        gh auth login
    else
        echo ""
        echo "Para crear el repositorio manualmente:"
        echo "1. Autentícate con: gh auth login"
        echo "2. Ejecuta este script de nuevo"
        echo ""
        echo "O crea el repositorio en GitHub.com y luego:"
        echo "  git remote add origin https://github.com/TU_USUARIO/$REPO_NAME.git"
        echo "  git push -u origin main"
        exit 1
    fi
fi

# Verificar autenticación de nuevo
if ! gh auth status &> /dev/null; then
    echo "❌ Error: No se pudo autenticar con GitHub"
    exit 1
fi

# Obtener el usuario de GitHub
USERNAME=$(gh api user -q .login)
echo "✓ Usuario: $USERNAME"
echo ""

# Crear el repositorio
echo "Creando repositorio en GitHub..."
if gh repo create $REPO_NAME --public --source=. --remote=origin --push; then
    echo ""
    echo "========================================="
    echo "✓ ¡Repositorio creado exitosamente!"
    echo "========================================="
    echo ""
    echo "URL del repositorio:"
    echo "  https://github.com/$USERNAME/$REPO_NAME"
    echo ""
else
    echo ""
    echo "⚠ Error al crear el repositorio"
    echo ""
    echo "El repositorio podría ya existir. Intentando agregar remote y push..."
    
    # Intentar agregar remote si no existe
    if ! git remote get-url origin &> /dev/null; then
        git remote add origin https://github.com/$USERNAME/$REPO_NAME.git
    fi
    
    # Intentar hacer push
    if git push -u origin main; then
        echo ""
        echo "✓ Push exitoso"
    else
        echo ""
        echo "❌ No se pudo hacer push. Verifica que:"
        echo "  1. El repositorio existe en GitHub"
        echo "  2. Tienes permisos para escribir en él"
    fi
fi

