# Push Rápido a GitHub

Todo está listo para subir a GitHub. Solo necesitas autenticarte una vez.

## Opción 1: Autenticación Interactiva (Recomendada)

```bash
cd ~/ssh-tunnel-config
gh auth login
# Sigue las instrucciones para autenticarte

# Una vez autenticado, ejecuta:
./create-github-repo.sh
```

## Opción 2: Autenticación con Token

Si tienes un token de GitHub (Personal Access Token):

```bash
cd ~/ssh-tunnel-config
echo "TU_TOKEN_AQUI" | gh auth login --with-token

# Luego ejecuta:
./create-github-repo.sh
```

## Opción 3: Crear Repositorio Manualmente

1. Ve a https://github.com/new
2. Crea un repositorio llamado: `ssh-tunnel-config`
3. **NO** inicialices con README, .gitignore o licencia
4. Luego ejecuta:

```bash
cd ~/ssh-tunnel-config
git remote add origin https://github.com/TU_USUARIO/ssh-tunnel-config.git
git push -u origin main
```

## Opción 4: Usar SSH (si tienes claves configuradas)

Si prefieres usar SSH en lugar de HTTPS:

```bash
cd ~/ssh-tunnel-config
git remote add origin git@github.com:TU_USUARIO/ssh-tunnel-config.git
git push -u origin main
```

---

Una vez que el repositorio esté creado, todos los archivos de configuración estarán disponibles en GitHub para futuras reinstalaciones.

