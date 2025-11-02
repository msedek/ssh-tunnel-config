# Configurar Cloudflare Access para SSH

Para que SSH funcione sin timeout, necesitas crear una aplicación en Cloudflare Access.

## Opción 1: Usar el script automatizado

```bash
cd ~/ssh-tunnel-config
export CLOUDFLARE_API_TOKEN='tu_token_aqui'
./create-access-app.sh
```

Para obtener el token:
1. Ve a https://dash.cloudflare.com/profile/api-tokens
2. Crea un token con permisos:
   - Zone:Zone:Read
   - Zone:DNS:Edit  
   - Account:Cloudflare Tunnel:Edit
   - Zero Trust:Edit

## Opción 2: Usar Cloudflare CLI (wrangler) - Alternativa

Si tienes wrangler instalado:

```bash
npm install -g wrangler
wrangler login
wrangler access application create --name "SSH Roster" --domain sshroster.mordum.loan
```

## Opción 3: Desde el panel de Cloudflare (Más fácil)

1. Ve a https://one.dash.cloudflare.com
2. **Access** > **Applications** > **Add an application**
3. Selecciona **Self-hosted**
4. Configura:
   - **Application name**: SSH Roster Access
   - **Session Duration**: 24h
   - **Application domain**: `sshroster.mordum.loan`
   - **Path**: Dejar en blanco o poner `*`
5. En **Policies**, agrega una política:
   - **Action**: Allow
   - **Include**: Agrega tu email o grupo
6. Guarda

## Después de configurar Access

Una vez configurada la aplicación, desde tu cliente (otro equipo):

```bash
# Instalar cloudflared si no lo tienes
# Luego configurar ~/.ssh/config:
Host sshroster.mordum.loan
  ProxyCommand cloudflared access ssh --hostname %h

# O conectarte directamente:
cloudflared access ssh --hostname sshroster.mordum.loan
```

---

**Nota**: El CNAME ya está configurado. Solo falta crear la aplicación Access.

