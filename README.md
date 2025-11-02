# Configuración SSH vía Cloudflare Tunnel

Esta documentación describe la configuración completa para acceder al servidor SSH mediante Cloudflare Tunnel usando el dominio `sshroster.mordum.loan`.

## Resumen de la Configuración

- **Dominio SSH**: `sshroster.mordum.loan`
- **Túnel Cloudflare**: `mordum-loan-tunnel`
- **Puerto SSH local**: 22
- **Sistema Operativo**: Ubuntu 24.04.3 LTS

## Componentes Instalados y Configurados

### 1. OpenSSH Server

El servidor SSH ha sido instalado y configurado:

- **Paquete**: `openssh-server`
- **Servicio**: `ssh.service` (habilitado para inicio automático)
- **Puerto**: 22 (puerto estándar)
- **Configuración**: `/etc/ssh/sshd_config`

**Comandos de gestión:**
```bash
# Verificar estado
sudo systemctl status ssh

# Iniciar servicio
sudo systemctl start ssh

# Detener servicio
sudo systemctl stop ssh

# Reiniciar servicio
sudo systemctl restart ssh

# Habilitar inicio automático
sudo systemctl enable ssh
```

### 2. Cloudflare Tunnel

El túnel de Cloudflare está configurado para enrutar el tráfico SSH.

#### Archivos de Configuración

**Configuración del túnel**: `/etc/cloudflared/config.yml`
```yaml
tunnel: mordum-loan-tunnel
credentials-file: /etc/cloudflared/credentials.json

ingress:
  # SSH Access - sshroster.mordum.loan
  - hostname: sshroster.mordum.loan
    service: ssh://localhost:22
  
  # Roster Data API - Prioridad alta (debe estar primero)
  - hostname: roster.mordum.loan
    service: http://localhost:3000
  
  # Raid Groups - raids.mordum.loan
  - hostname: raids.mordum.loan
    service: http://localhost:3001
  
  # Catch-all rule - debe estar al final
  - service: http_status:404
```

**Credenciales del túnel**: `/etc/cloudflared/credentials.json`
- Este archivo contiene las credenciales necesarias para autenticar el túnel con Cloudflare.

#### Servicio Systemd

**Archivo de servicio**: `/etc/systemd/system/cloudflared.service`
```ini
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/cloudflared tunnel --config /etc/cloudflared/config.yml run
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

**Comandos de gestión:**
```bash
# Verificar estado
sudo systemctl status cloudflared

# Iniciar servicio
sudo systemctl start cloudflared

# Detener servicio
sudo systemctl stop cloudflared

# Reiniciar servicio
sudo systemctl restart cloudflared

# Habilitar inicio automático (ya configurado)
sudo systemctl enable cloudflared

# Ver logs
sudo journalctl -u cloudflared -f
```

#### DNS Configuration

El registro DNS CNAME ha sido configurado automáticamente mediante:
```bash
cloudflared tunnel route dns mordum-loan-tunnel sshroster.mordum.loan
```

Esto crea un registro CNAME que apunta `sshroster.mordum.loan` al túnel.

## Cómo Conectarse

### Desde un cliente SSH estándar

```bash
ssh usuario@sshroster.mordum.loan
```

### Desde un cliente usando cloudflared (alternativa)

Si prefieres usar cloudflared directamente desde el cliente:

```bash
cloudflared access ssh --hostname sshroster.mordum.loan
```

## Verificación de la Configuración

### 1. Verificar que SSH está corriendo
```bash
sudo systemctl status ssh
```

Deberías ver: `Active: active (running)`

### 2. Verificar que Cloudflare Tunnel está corriendo
```bash
sudo systemctl status cloudflared
```

Deberías ver: `Active: active (running)` y conexiones registradas.

### 3. Verificar las conexiones del túnel
```bash
cloudflared tunnel info mordum-loan-tunnel
```

### 4. Probar la conexión SSH
```bash
ssh -v usuario@sshroster.mordum.loan
```

## Persistencia Después de Reinicio

Ambos servicios están configurados para iniciarse automáticamente después del reinicio:

1. **SSH Service**: Habilitado con `systemctl enable ssh`
2. **Cloudflare Tunnel**: Habilitado con `systemctl enable cloudflared`

Para verificar:
```bash
# Verificar SSH
systemctl is-enabled ssh  # Debe mostrar: enabled

# Verificar Cloudflare Tunnel
systemctl is-enabled cloudflared  # Debe mostrar: enabled
```

## Solución de Problemas

### El servicio cloudflared no inicia

1. Verificar los logs:
   ```bash
   sudo journalctl -u cloudflared -n 50
   ```

2. Verificar que los archivos de configuración existen:
   ```bash
   ls -la /etc/cloudflared/config.yml
   ls -la /etc/cloudflared/credentials.json
   ```

3. Verificar permisos:
   ```bash
   sudo chmod 600 /etc/cloudflared/credentials.json
   sudo chmod 644 /etc/cloudflared/config.yml
   ```

### No puedo conectarme vía SSH

1. Verificar que el servicio SSH está corriendo:
   ```bash
   sudo systemctl status ssh
   ```

2. Verificar que el túnel está activo:
   ```bash
   sudo systemctl status cloudflared
   ```

3. Verificar que el DNS está resuelto correctamente:
   ```bash
   dig sshroster.mordum.loan
   ```

4. Verificar los logs del túnel para errores:
   ```bash
   sudo journalctl -u cloudflared -f
   ```

### El túnel se desconecta frecuentemente

El servicio está configurado con `Restart=on-failure` y `RestartSec=5s`, lo que significa que se reiniciará automáticamente si falla.

Para verificar conexiones activas:
```bash
cloudflared tunnel info mordum-loan-tunnel
```

## Archivos Importantes

- `/etc/cloudflared/config.yml` - Configuración del túnel
- `/etc/cloudflared/credentials.json` - Credenciales del túnel (NO compartir)
- `/etc/systemd/system/cloudflared.service` - Servicio systemd
- `/etc/ssh/sshd_config` - Configuración SSH
- `/home/msedek/.cloudflared/config.yml` - Configuración de usuario (respaldo)

## Notas Importantes

⚠️ **SEGURIDAD**:
- El archivo `credentials.json` contiene credenciales sensibles. NO compartirlo públicamente.
- Asegúrate de tener contraseñas seguras o autenticación por clave SSH configurada.
- Considera deshabilitar login root si no es necesario.

⚠️ **BACKUP**:
- Mantén una copia de seguridad de los archivos de configuración.
- El archivo `credentials.json` es único y necesario para el túnel.

## Reinstalación Completa (si el servidor se reinicia desde cero)

1. Instalar OpenSSH Server:
   ```bash
   sudo apt-get update
   sudo apt-get install -y openssh-server
   sudo systemctl enable ssh
   sudo systemctl start ssh
   ```

2. Instalar Cloudflared (si no está instalado):
   ```bash
   # Descargar y instalar cloudflared
   wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
   sudo mv cloudflared-linux-amd64 /usr/local/bin/cloudflared
   sudo chmod +x /usr/local/bin/cloudflared
   ```

3. Crear directorios y archivos de configuración:
   ```bash
   sudo mkdir -p /etc/cloudflared
   # Copiar config.yml y credentials.json a /etc/cloudflared/
   ```

4. Configurar el servicio systemd:
   ```bash
   # Copiar el archivo cloudflared.service a /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable cloudflared
   sudo systemctl start cloudflared
   ```

5. Configurar DNS (si es necesario):
   ```bash
   cloudflared tunnel route dns mordum-loan-tunnel sshroster.mordum.loan
   ```

6. Verificar todo está funcionando:
   ```bash
   sudo systemctl status ssh
   sudo systemctl status cloudflared
   ```

---

**Fecha de configuración**: 2 de noviembre de 2025
**Configurado por**: Sistema automatizado

