# ✅ TODO LISTO - Cómo Conectarte

## 🎯 Desde tu PC (otra computadora)

### Paso 1: Instala cloudflared (una sola vez)

**Linux:**
```bash
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared-linux-amd64
sudo mv cloudflared-linux-amd64 /usr/local/bin/cloudflared
```

**Mac:**
```bash
brew install cloudflared
```

**Windows:**
```powershell
# Con Chocolatey
choco install cloudflared

# O descarga manual desde:
# https://github.com/cloudflare/cloudflared/releases
```

### Paso 2: Conéctate

```bash
cloudflared access ssh --hostname sshroster.mordum.loan
```

**O configura SSH normal:**

Edita `~/.ssh/config`:
```
Host sshroster.mordum.loan
  ProxyCommand cloudflared access ssh --hostname %h
  User msedek
```

Luego:
```bash
ssh sshroster.mordum.loan
```

## ⚠️ Importante

Si te sale timeout o error, necesitas configurar **Cloudflare Access**:

1. Ve a: https://one.dash.cloudflare.com
2. **Access** → **Applications** → **Add an application**
3. Configura:
   - **Application name**: SSH Roster
   - **Domain**: `sshroster.mordum.loan`
   - **Type**: Self-hosted
4. Agrega políticas de acceso (quién puede conectarse)
5. Guarda

Luego podrás conectarte sin problemas.

---

**Servidor configurado:** ✅  
**Túnel activo:** ✅  
**Persistencia después de reinicio:** ✅  
**Solo necesitas:** cloudflared en tu PC + configurar Access (una vez)

