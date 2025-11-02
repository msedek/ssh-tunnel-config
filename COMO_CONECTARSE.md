# 🚀 Cómo Conectarse al Servidor SSH

## ✅ Todo está configurado y listo

El servidor está configurado con:
- ✅ SSH Server corriendo
- ✅ Cloudflare Tunnel activo
- ✅ DNS configurado (sshroster.mordum.loan)
- ✅ Persistencia después de reinicio

## 📱 Desde tu computadora (cliente)

### Opción 1: Usar cloudflared directamente (MÁS FÁCIL)

**Instala cloudflared en tu PC:**

- **Linux/Mac:**
  ```bash
  wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
  chmod +x cloudflared-linux-amd64
  sudo mv cloudflared-linux-amd64 /usr/local/bin/cloudflared
  ```

- **Windows:**
  - Descarga desde: https://github.com/cloudflare/cloudflared/releases
  - O usa: `winget install cloudflare.cloudflared`

**Conéctate:**
```bash
cloudflared access ssh --hostname sshroster.mordum.loan
```

**Si te pide autenticación:**
- Te pedirá que ingreses a una URL en el navegador
- Inicia sesión con tu cuenta de Cloudflare
- Luego podrás conectarte

### Opción 2: Configurar SSH normal (Recomendado)

**Crea/edita `~/.ssh/config` en tu PC:**
```bash
Host sshroster.mordum.loan
  ProxyCommand cloudflared access ssh --hostname %h
  User msedek
```

**Luego conecta normalmente:**
```bash
ssh sshroster.mordum.loan
# O simplemente:
ssh msedek@sshroster.mordum.loan
```

### Opción 3: Sin Access (Puede tener timeout)

Si no has configurado Cloudflare Access:
```bash
ssh msedek@sshroster.mordum.loan
```

⚠️ **Nota**: Esta opción puede dar timeout. Es mejor usar las opciones 1 o 2.

## 🔧 Si tienes problemas

### Error: "connection timeout"
1. Verifica que el túnel esté corriendo:
   ```bash
   # En el servidor
   sudo systemctl status cloudflared
   ```

2. Configura Cloudflare Access (requerido para SSH):
   - Ve a: https://one.dash.cloudflare.com
   - Access → Applications → Add application
   - Dominio: `sshroster.mordum.loan`
   - Tipo: Self-hosted
   - Configura políticas de acceso

### Error: "cloudflared: command not found"
Instala cloudflared en tu PC (ver Opción 1 arriba)

### Error: "Permission denied"
Verifica tu usuario y contraseña en el servidor

## 📝 Verificar que todo funciona

**En el servidor:**
```bash
# Ver estado del túnel
sudo systemctl status cloudflared

# Ver logs del túnel
sudo journalctl -u cloudflared -f

# Verificar SSH
sudo systemctl status ssh
```

**En tu PC:**
```bash
# Verificar DNS
dig sshroster.mordum.loan
# O
nslookup sshroster.mordum.loan
```

## 🎯 Resumen Rápido

**Solo necesitas:**
1. Instalar `cloudflared` en tu PC (una vez)
2. Ejecutar: `cloudflared access ssh --hostname sshroster.mordum.loan`
3. ¡Listo! Estás conectado

---

**Servidor configurado:** ✅  
**Túnel activo:** ✅  
**DNS configurado:** ✅  
**Solo falta:** Instalar cloudflared en tu PC y conectarte

