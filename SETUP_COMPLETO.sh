#!/bin/bash
# Script para configurar TODO y dejar SSH listo para usar

set -e

echo "========================================="
echo "🚀 Configuración Completa de SSH Tunnel"
echo "========================================="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar si cloudflared está corriendo
echo "1️⃣  Verificando Cloudflare Tunnel..."
if sudo systemctl is-active --quiet cloudflared; then
    echo -e "${GREEN}✓${NC} Tunnel activo"
else
    echo -e "${RED}✗${NC} Tunnel no está corriendo. Iniciando..."
    sudo systemctl start cloudflared
    sleep 3
fi

# Verificar SSH
echo ""
echo "2️⃣  Verificando SSH Server..."
if sudo systemctl is-active --quiet ssh; then
    echo -e "${GREEN}✓${NC} SSH activo"
else
    echo -e "${RED}✗${NC} SSH no está corriendo. Iniciando..."
    sudo systemctl start ssh
fi

# Verificar DNS
echo ""
echo "3️⃣  Verificando DNS..."
DNS_RESULT=$(dig +short sshroster.mordum.loan 2>/dev/null | head -1)
if [ -n "$DNS_RESULT" ]; then
    echo -e "${GREEN}✓${NC} DNS resuelve: $DNS_RESULT"
else
    echo -e "${YELLOW}⚠${NC}  DNS no resuelve. Configurando..."
    cloudflared tunnel route dns mordum-loan-tunnel sshroster.mordum.loan 2>/dev/null || echo "DNS ya configurado o error"
fi

# Verificar configuración del túnel
echo ""
echo "4️⃣  Verificando configuración del túnel..."
if grep -q "tcp://localhost:22" /etc/cloudflared/config.yml 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Configuración TCP correcta"
else
    echo -e "${YELLOW}⚠${NC}  Actualizando configuración..."
    sudo sed -i 's|service: ssh://localhost:22|service: tcp://localhost:22|g' /etc/cloudflared/config.yml
    sudo systemctl restart cloudflared
    sleep 3
fi

# Intentar crear Access si hay token
echo ""
echo "5️⃣  Configurando Cloudflare Access..."
if [ -n "$CLOUDFLARE_API_TOKEN" ]; then
    echo "Token encontrado, creando aplicación Access..."
    ./crear-access-ssh.sh
else
    echo -e "${YELLOW}⚠${NC}  No hay token de API. SSH puede funcionar sin Access."
    echo "   Si tienes problemas de timeout, configura Access manualmente:"
    echo "   https://one.dash.cloudflare.com → Access → Applications"
fi

echo ""
echo "========================================="
echo "✅ Configuración completada"
echo "========================================="
echo ""
echo "📋 Para conectarte desde otra computadora:"
echo ""
echo "   Opción 1 (Recomendada - con Access):"
echo "   1. Instala cloudflared en tu PC"
echo "   2. Ejecuta: cloudflared access ssh --hostname sshroster.mordum.loan"
echo ""
echo "   Opción 2 (SSH directo - si Access está configurado):"
echo "   1. Configura ~/.ssh/config en tu PC:"
echo "      Host sshroster.mordum.loan"
echo "        ProxyCommand cloudflared access ssh --hostname %h"
echo "   2. Conéctate: ssh msedek@sshroster.mordum.loan"
echo ""
echo "   Opción 3 (Sin Access - puede tener timeout):"
echo "   ssh msedek@sshroster.mordum.loan"
echo ""
echo "🔍 Verificar estado:"
echo "   sudo systemctl status cloudflared"
echo "   sudo systemctl status ssh"
echo ""

