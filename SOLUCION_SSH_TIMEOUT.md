# Solución para Timeout en SSH

## Problema
El SSH está haciendo timeout cuando intentas conectarte a `sshroster.mordum.loan`.

## Soluciones

### Opción 1: Configurar Cloudflare Access SSH (Recomendado)

Para usar SSH a través de Cloudflare Tunnel, necesitas configurar Cloudflare Access:

1. **En el panel de Cloudflare Zero Trust:**
   - Ve a **Access** > **Applications**
   - Crea una nueva aplicación **Self-hosted**
   - **Application name**: SSH Roster
   - **Session Duration**: 24h (o la que prefieras)
   - **Application domain**: `sshroster.mordum.loan`
   - **Path**: `*` (todos los paths)

2. **Configurar políticas de acceso:**
   - Agrega reglas para permitir acceso (ej: email específico, grupo, etc.)

3. **En el cliente (tu computadora):**
   - Instala `cloudflared` si no lo tienes
   - Configura `~/.ssh/config`:
   ```bash
   Host sshroster.mordum.loan
     ProxyCommand cloudflared access ssh --hostname %h
   ```
   - Conéctate normalmente: `ssh msedek@sshroster.mordum.loan`

### Opción 2: Usar TCP directo (Ya configurado)

La configuración actual usa `tcp://localhost:22`. Para que funcione:

**Desde el cliente, intenta con:**
```bash
ssh -o ProxyCommand="cloudflared access tcp --hostname sshroster.mordum.loan --url tcp://localhost:22" msedek@localhost
```

O más simple, si tienes cloudflared en el cliente:
```bash
cloudflared access ssh --hostname sshroster.mordum.loan
```

### Opción 3: Verificar configuración del túnel

Si el problema persiste, verifica:

```bash
# Ver logs del túnel
sudo journalctl -u cloudflared -f

# Verificar que SSH está escuchando
sudo ss -tlnp | grep :22

# Probar SSH localmente
ssh msedek@localhost
```

### Opción 4: Configuración alternativa del túnel

Si Cloudflare Access no está disponible, puedes intentar cambiar la configuración para usar un puerto diferente o verificar si hay restricciones.

---

**Nota**: La forma más sencilla y segura es usar Cloudflare Access SSH (Opción 1).

