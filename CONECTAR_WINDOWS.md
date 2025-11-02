# 🪟 Conectar desde Windows

## ❌ No funciona así:
```powershell
ssh msedek@sshroster.mordum.loan
```
Esto da timeout porque necesita `cloudflared`.

## ✅ Solución para Windows:

### Paso 1: Instalar cloudflared en Windows

**Opción A - Con winget (Windows 10/11):**
```powershell
winget install cloudflare.cloudflared
```

**Opción B - Con Chocolatey:**
```powershell
choco install cloudflared
```

**Opción C - Descarga manual:**
1. Ve a: https://github.com/cloudflare/cloudflared/releases/latest
2. Descarga: `cloudflared-windows-amd64.exe`
3. Renómbralo a `cloudflared.exe`
4. Colócalo en una carpeta (ej: `C:\cloudflared\`)
5. Agrega esa carpeta al PATH o usa la ruta completa

### Paso 2: Conectarte

**Opción 1 - Directo (más fácil):**
```powershell
cloudflared access ssh --hostname sshroster.mordum.loan
```

**Opción 2 - Configurar SSH (recomendado):**

1. Crea/edita el archivo: `C:\Users\migue\.ssh\config`
   (Si no existe la carpeta `.ssh`, créala)

2. Agrega esto:
```
Host sshroster.mordum.loan
    ProxyCommand C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "& {cloudflared access ssh --hostname %h}"
    User msedek
```

3. Luego conecta:
```powershell
ssh sshroster.mordum.loan
```

**Opción 3 - Script rápido:**

Crea un archivo `conectar.bat`:
```batch
@echo off
cloudflared access ssh --hostname sshroster.mordum.loan
```

Doble clic y listo.

## ⚠️ IMPORTANTE: Configurar Cloudflare Access PRIMERO

**SIN Access configurado, seguirá dando timeout.**

1. Ve a: https://one.dash.cloudflare.com
2. **Access** → **Applications** → **Add an application**
3. Configura:
   - **Application name**: SSH Roster
   - **Domain**: `sshroster.mordum.loan`
   - **Type**: Self-hosted
4. En **Policies**, agrega:
   - **Action**: Allow
   - **Include**: Tu email de Cloudflare
5. **Save**

**Después de configurar Access, funcionará perfectamente.**

## 🔍 Verificar que cloudflared está instalado:

```powershell
cloudflared --version
```

Si dice "comando no reconocido", instálalo primero.

## 📝 Resumen rápido:

1. ✅ Instalar cloudflared: `winget install cloudflare.cloudflared`
2. ✅ Configurar Access en: https://one.dash.cloudflare.com
3. ✅ Conectar: `cloudflared access ssh --hostname sshroster.mordum.loan`

---

**¿Necesitas ayuda?** El servidor está funcionando, solo necesitas:
- cloudflared en Windows
- Access configurado (una vez)
- ¡Listo!

