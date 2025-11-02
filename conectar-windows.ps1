# Script PowerShell para Windows - Conectar a SSH

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Conexión SSH vía Cloudflare Tunnel" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si cloudflared está instalado
$cloudflared = Get-Command cloudflared -ErrorAction SilentlyContinue

if (-not $cloudflared) {
    Write-Host "❌ cloudflared no está instalado" -ForegroundColor Red
    Write-Host ""
    Write-Host "Para instalar:" -ForegroundColor Yellow
    Write-Host "  winget install cloudflare.cloudflared" -ForegroundColor Green
    Write-Host ""
    Write-Host "O descarga desde: https://github.com/cloudflare/cloudflared/releases" -ForegroundColor Yellow
    Write-Host ""
    $install = Read-Host "¿Quieres que intente instalarlo con winget? (S/N)"
    
    if ($install -eq "S" -or $install -eq "s") {
        Write-Host "Instalando cloudflared..." -ForegroundColor Yellow
        winget install cloudflare.cloudflared
        Write-Host ""
        Write-Host "Reinicia PowerShell y ejecuta este script de nuevo." -ForegroundColor Yellow
        exit
    } else {
        Write-Host "Por favor instala cloudflared primero." -ForegroundColor Red
        exit 1
    }
}

Write-Host "✓ cloudflared encontrado" -ForegroundColor Green
Write-Host ""

# Conectar
Write-Host "Conectando a sshroster.mordum.loan..." -ForegroundColor Yellow
Write-Host ""

cloudflared access ssh --hostname sshroster.mordum.loan

