#!/bin/bash
# Script para crear aplicación SSH en Cloudflare Access usando la API

echo "========================================="
echo "Configurando Cloudflare Access para SSH"
echo "========================================="
echo ""

# Verificar si hay token de API
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "⚠️  Necesitas un token de API de Cloudflare"
    echo ""
    echo "Para obtenerlo:"
    echo "1. Ve a https://dash.cloudflare.com/profile/api-tokens"
    echo "2. Crea un token con permisos:"
    echo "   - Zone:Zone:Read"
    echo "   - Zone:DNS:Edit"
    echo "   - Account:Cloudflare Tunnel:Edit"
    echo "   - Zero Trust:Edit"
    echo "3. Copia el token y ejecuta:"
    echo "   export CLOUDFLARE_API_TOKEN='tu_token_aqui'"
    echo "   ./create-access-app.sh"
    echo ""
    read -p "¿Tienes un token de API? Si es así, escríbelo aquí (o presiona Enter para salir): " API_TOKEN
    
    if [ -z "$API_TOKEN" ]; then
        echo "Saliendo..."
        exit 1
    fi
    
    export CLOUDFLARE_API_TOKEN="$API_TOKEN"
fi

# Obtener Account ID y Zone ID
echo "Obteniendo información de la cuenta..."

# Primero obtener el Account ID del túnel
TUNNEL_ID="e52e727a-be0f-43dc-907b-911008473236"
ZONE="mordum.loan"

# Obtener Zone ID
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$ZONE_ID" ]; then
    echo "❌ Error: No se pudo obtener el Zone ID"
    exit 1
fi

echo "✓ Zone ID: $ZONE_ID"

# Obtener Account ID
ACCOUNT_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" | grep -o '"account":{"id":"[^"]*' | cut -d'"' -f4)

if [ -z "$ACCOUNT_ID" ]; then
    echo "⚠️  No se pudo obtener Account ID del zone, intentando otra forma..."
    # Intentar desde los tunnels
    ACCOUNT_INFO=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts" \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      -H "Content-Type: application/json")
    ACCOUNT_ID=$(echo "$ACCOUNT_INFO" | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
fi

if [ -z "$ACCOUNT_ID" ]; then
    echo "❌ Error: No se pudo obtener el Account ID"
    echo "Por favor, verifica tu token de API"
    exit 1
fi

echo "✓ Account ID: $ACCOUNT_ID"
echo ""

# Crear la aplicación SSH en Cloudflare Access
echo "Creando aplicación SSH en Cloudflare Access..."

APP_NAME="SSH Roster Access"
APP_DOMAIN="sshroster.mordum.loan"

# Verificar si ya existe
EXISTING_APP=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/apps" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json")

if echo "$EXISTING_APP" | grep -q "$APP_DOMAIN"; then
    echo "⚠️  La aplicación ya existe para $APP_DOMAIN"
    echo "¿Deseas actualizarla? (s/n)"
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
        echo "Saliendo..."
        exit 0
    fi
    ACTION="update"
else
    ACTION="create"
fi

# Crear/actualizar la aplicación
if [ "$ACTION" = "create" ]; then
    RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/apps" \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "{
        \"name\": \"$APP_NAME\",
        \"domain\": \"$APP_DOMAIN\",
        \"type\": \"self_hosted\",
        \"session_duration\": \"24h\",
        \"allowed_idps\": [],
        \"auto_redirect_to_identity\": false,
        \"enable_binding_cookie\": false,
        \"http_only_cookie_attribute\": false,
        \"service_auth_401_redirect\": false,
        \"options\": {
          \"allowed_idps\": []
        }
      }")
else
    # Para actualizar necesitaríamos el APP_ID primero
    echo "Para actualizar, necesitas el APP_ID. Creando una nueva aplicación..."
    RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/apps" \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "{
        \"name\": \"$APP_NAME\",
        \"domain\": \"$APP_DOMAIN\",
        \"type\": \"self_hosted\",
        \"session_duration\": \"24h\"
      }")
fi

# Verificar respuesta
if echo "$RESPONSE" | grep -q '"success":true'; then
    echo "✓ ¡Aplicación creada exitosamente!"
    echo ""
    echo "Ahora necesitas:"
    echo "1. Ir a Cloudflare Zero Trust > Access > Applications"
    echo "2. Encontrar '$APP_NAME'"
    echo "3. Configurar las políticas de acceso (quién puede acceder)"
    echo ""
    echo "Luego podrás conectarte con:"
    echo "  ssh msedek@sshroster.mordum.loan"
    echo ""
    echo "O desde el cliente configurando ~/.ssh/config:"
    echo "  Host sshroster.mordum.loan"
    echo "    ProxyCommand cloudflared access ssh --hostname %h"
else
    echo "❌ Error al crear la aplicación:"
    echo "$RESPONSE" | grep -o '"message":"[^"]*' | cut -d'"' -f4 || echo "$RESPONSE"
fi

