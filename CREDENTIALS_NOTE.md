# ⚠️ NOTA IMPORTANTE: Credenciales del Túnel

El archivo `credentials.json` **NO** está incluido en este repositorio por razones de seguridad.

## ¿Qué es credentials.json?

Este archivo contiene las credenciales necesarias para que el túnel de Cloudflare se autentique. Es único para cada túnel y debe mantenerse seguro.

## Ubicación del archivo en el servidor

```
/etc/cloudflared/credentials.json
```

## ¿Cómo obtener este archivo?

1. **Desde Cloudflare Dashboard**:
   - Ve a Zero Trust → Networks → Tunnels
   - Selecciona tu túnel (`mordum-loan-tunnel`)
   - Descarga las credenciales

2. **Desde el servidor existente** (si tienes acceso):
   ```bash
   sudo cat /etc/cloudflared/credentials.json
   ```

3. **Recrear el túnel** (si es necesario):
   ```bash
   cloudflared tunnel create mordum-loan-tunnel
   ```

## ¿Dónde colocarlo al reinstalar?

Cuando reinstales la configuración, copia el archivo a:
```bash
sudo cp credentials.json /etc/cloudflared/credentials.json
sudo chmod 600 /etc/cloudflared/credentials.json
```

## Seguridad

⚠️ **NUNCA**:
- Compartas este archivo públicamente
- Lo subas a repositorios públicos
- Lo incluyas en emails o mensajes no cifrados

✅ **SÍ**:
- Mantén backups seguros del archivo
- Usa permisos restrictivos (600)
- Almacénalo en un lugar seguro y cifrado si es posible

