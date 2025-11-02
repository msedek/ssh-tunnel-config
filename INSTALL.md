# Guía de Instalación - SSH vía Cloudflare Tunnel

Esta guía te permite reinstalar completamente la configuración SSH vía Cloudflare Tunnel en un servidor nuevo o reiniciado.

## Prerrequisitos

- Ubuntu 24.04 LTS (u otra distribución Linux compatible)
- Acceso root o sudo
- Cuenta de Cloudflare con un túnel ya creado
- Credenciales del túnel Cloudflare (archivo JSON)

## Paso 1: Instalar OpenSSH Server

```bash
sudo apt-get update
sudo apt-get install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

Verificar instalación:
```bash
sudo systemctl status ssh
```

## Paso 2: Instalar Cloudflared

Si cloudflared no está instalado:

```bash
# Descargar la última versión
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared

# Instalar en sistema
sudo mv cloudflared /usr/local/bin/cloudflared
sudo chmod +x /usr/local/bin/cloudflared

# Verificar instalación
cloudflared --version
```

## Paso 3: Configurar Cloudflare Tunnel

### 3.1 Crear directorio de configuración

```bash
sudo mkdir -p /etc/cloudflared
```

### 3.2 Copiar archivo de configuración

Copia el archivo `config.yml` a `/etc/cloudflared/config.yml`:

```bash
sudo cp config.yml /etc/cloudflared/config.yml
sudo chmod 644 /etc/cloudflared/config.yml
```

### 3.3 Copiar credenciales del túnel

**IMPORTANTE**: Necesitas el archivo `credentials.json` del túnel. Este archivo debe estar en:
- `/etc/cloudflared/credentials.json`

```bash
sudo cp credentials.json /etc/cloudflared/credentials.json
sudo chmod 600 /etc/cloudflared/credentials.json
```

⚠️ **NOTA**: El archivo `credentials.json` NO está incluido en este repositorio por razones de seguridad. Debes obtenerlo desde tu cuenta de Cloudflare o desde un backup seguro.

## Paso 4: Configurar el Servicio Systemd

### 4.1 Copiar el archivo de servicio

```bash
sudo cp cloudflared.service /etc/systemd/system/cloudflared.service
```

### 4.2 Recargar systemd y habilitar el servicio

```bash
sudo systemctl daemon-reload
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

### 4.3 Verificar que el servicio está corriendo

```bash
sudo systemctl status cloudflared
```

Deberías ver `Active: active (running)` y conexiones registradas.

## Paso 5: Configurar DNS (si es necesario)

Si el DNS no está configurado automáticamente, puedes configurarlo manualmente:

```bash
cloudflared tunnel route dns mordum-loan-tunnel sshroster.mordum.loan
```

O configurarlo manualmente en el panel de Cloudflare creando un registro CNAME:
- **Tipo**: CNAME
- **Nombre**: sshroster
- **Contenido**: `<tunnel-id>.cfargotunnel.com` (obtén el tunnel-id con `cloudflared tunnel list`)

## Paso 6: Verificación Final

### 6.1 Verificar servicios

```bash
# SSH Service
sudo systemctl status ssh
systemctl is-enabled ssh  # Debe mostrar: enabled

# Cloudflare Tunnel
sudo systemctl status cloudflared
systemctl is-enabled cloudflared  # Debe mostrar: enabled
```

### 6.2 Verificar conexiones del túnel

```bash
cloudflared tunnel info mordum-loan-tunnel
```

Deberías ver conexiones activas.

### 6.3 Probar conexión SSH

Desde otro equipo:

```bash
ssh usuario@sshroster.mordum.loan
```

## Solución de Problemas Rápida

### El servicio cloudflared no inicia

```bash
# Ver logs detallados
sudo journalctl -u cloudflared -n 50 --no-pager

# Verificar archivos
ls -la /etc/cloudflared/

# Verificar permisos
sudo chmod 600 /etc/cloudflared/credentials.json
sudo chmod 644 /etc/cloudflared/config.yml
```

### No puedo conectarme vía SSH

1. Verificar que SSH está escuchando:
   ```bash
   sudo ss -tlnp | grep :22
   ```

2. Verificar que el túnel está activo:
   ```bash
   sudo systemctl status cloudflared
   ```

3. Verificar DNS:
   ```bash
   dig sshroster.mordum.loan
   ```

### El túnel se desconecta

```bash
# Ver logs en tiempo real
sudo journalctl -u cloudflared -f

# Reiniciar servicio
sudo systemctl restart cloudflared
```

## Comandos Útiles

```bash
# Ver logs del túnel
sudo journalctl -u cloudflared -f

# Reiniciar túnel
sudo systemctl restart cloudflared

# Ver información del túnel
cloudflared tunnel info mordum-loan-tunnel

# Listar todos los túneles
cloudflared tunnel list

# Ver estado de servicios
sudo systemctl status ssh cloudflared
```

## Notas de Seguridad

1. **Credenciales**: Nunca compartas el archivo `credentials.json`. Está excluido del repositorio por seguridad.

2. **SSH Keys**: Configura autenticación por clave SSH para mayor seguridad:
   ```bash
   # En el servidor
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   
   # Copiar clave pública del cliente
   nano ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

3. **Firewall**: Asegúrate de que el firewall permita conexiones SSH si está activo:
   ```bash
   sudo ufw allow ssh
   # O específicamente el puerto 22
   sudo ufw allow 22/tcp
   ```

---

**Última actualización**: 2 de noviembre de 2025

