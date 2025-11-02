#!/bin/bash
# Script para crear aplicación SSH en Cloudflare Access

ACCOUNT_TAG="86e3f6920fffed1b4184e66215e06a0b"
ZONE="mordum.loan"
APP_DOMAIN="sshroster.mordum.loan"

echo "========================================="
echo "Crear aplicación SSH en Cloudflare Access"
echo "========================================="
echo ""
echo "Account Tag: $ACCOUNT_TAG"
echo "Dominio: $APP_DOMAIN"
echo ""

if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "⚠️  Necesitas un token de API de Cloudflare"
    echo ""
    echo "📋 Para obtenerlo:"
    echo "   1. Ve a: https://dash.cloudflare.com/profile/api-tokens"
    echo "   2. Click en 'Create Token'"
    echo "   3. Usa el template 'Edit Cloudflare Tunnel' o crea uno personalizado con:"
    echo "      - Zone:Zone:Read"
    echo "      - Zone:DNS:Edit"
    echo "      - Account:Cloudflare Tunnel:Edit"
    echo "      - Zero Trust:Edit"
    echo "   4. Copia el token"
    echo ""
    read -p "Pega tu token aquí: " API_TOKEN
    export CLOUDFLARE_API_TOKEN="$API_TOKEN"
fi

echo "Obteniendo Zone ID..."
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['result'][0]['id'] if data.get('success') and data.get('result') else '')")

if [ -z "$ZONE_ID" ]; then
    echo "❌ Error: No se pudo obtener Zone ID. Verifica tu token."
    exit 1
fi

echo "✓ Zone ID: $ZONE_ID"
echo ""

# Obtener Account ID desde el zone
echo "Obteniendo Account ID..."
ACCOUNT_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['result']['account']['id'] if data.get('success') else '')")

if [ -z "$ACCOUNT_ID" ]; then
    echo "⚠️  Usando Account Tag como Account ID..."
    ACCOUNT_ID="$ACCOUNT_TAG"
fi

echo "✓ Account ID: $ACCOUNT_ID"
echo ""

# Verificar si ya existe
echo "Verificando si la aplicación ya existe..."
EXISTING=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/apps" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json")

if echo "$EXISTING" | python3 -c "import sys, json; data=json.load(sys.stdin); apps=[a['domain'] for a in data.get('result', []) if a.get('domain') == '$APP_DOMAIN']; sys.exit(0 if apps else 1)" 2>/dev/null; then
    echo "⚠️  La aplicación ya existe para $APP_DOMAIN"
    echo "Puedes actualizarla desde: https://one.dash.cloudflare.com/$ACCOUNT_ID/access/applications"
    exit 0
fi

echo "Creando aplicación SSH..."
RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/apps" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data "{
    \"name\": \"SSH Roster Access\",
    \"domain\": \"$APP_DOMAIN\",
    \"type\": \"self_hosted\",
    \"session_duration\": \"24h\"
  }")

SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print('OK' if data.get('success') else data.get('errors', [{}])[0].get('message', 'Unknown error'))" 2>/dev/null)

if [ "$SUCCESS" = "OK" ]; then
    APP_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['result']['id'] if data.get('success') else '')" 2>/dev/null)
    echo ""
    echo "✅ ¡Aplicación creada exitosamente!"
    echo ""
    echo "APP ID: $APP_ID"
    echo ""
    echo "📝 Próximos pasos:"
    echo "   1. Ve a: https://one.dash.cloudflare.com/$ACCOUNT_ID/access/applications"
    echo "   2. Busca 'SSH Roster Access'"
    echo "   3. Configura las políticas de acceso (quién puede conectarse)"
    echo "   4. Desde tu cliente, usa:"
    echo "      ssh msedek@sshroster.mordum.loan"
    echo ""
    echo "   O configura ~/.ssh/config:"
    echo "   Host sshroster.mordum.loan"
    echo "     ProxyCommand cloudflared access ssh --hostname %h"
else
    echo "❌ Error: $SUCCESS"
    echo ""
    echo "Respuesta completa:"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
fi

