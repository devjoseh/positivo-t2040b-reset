# 99-restaurar-apps.ps1
# Reverte a remocao de pacotes e reativa os desativados.
# Use quando quiser voltar ao estado anterior, ou se algo parou de funcionar.

param(
    [switch]$IncluirProvisionamento
)

. "$PSScriptRoot\lib-common.ps1"

Write-Titulo "reset-t2040 - restauracao de aplicativos"

$estado = Get-EstadoDispositivo
if ($estado -ne 'device') {
    Write-Erro ("Tablet nao esta pronto. Estado atual: " + $estado)
    return
}

$listaRemover    = Join-Path $DirDados 'pacotes-remover.txt'
$listaDesativar  = Join-Path $DirDados 'pacotes-desativar.txt'

function Get-Lista($caminho) {
    $r = @()
    if (-not (Test-Path $caminho)) { return $r }
    foreach ($linha in (Get-Content $caminho)) {
        $t = $linha.Trim()
        if ($t -eq '' -or $t.StartsWith('#')) { continue }
        $r += $t
    }
    return $r
}

# ---------------------------------------------------------------
# 1. Avisar sobre o provisionamento
# ---------------------------------------------------------------
Write-Info "Esta rotina restaura os aplicativos removidos."
if (-not $IncluirProvisionamento) {
    Write-Aviso "O bloqueio de provisionamento NAO sera revertido"
    Write-Info "Para reverter tambem o provisionamento, use -IncluirProvisionamento"
}
Write-Host ''

$resp = Read-Host "  Confirmar restauracao? (s/N)"
if ($resp -notmatch '^[Ss]') {
    Write-Info "Cancelado"
    return
}

# ---------------------------------------------------------------
# 2. Reinstalar
# ---------------------------------------------------------------
$remover = Get-Lista $listaRemover
$ok = 0
$fail = 0

Write-Host ''
Write-Info ("Reinstalando " + $remover.Count + " pacotes")
foreach ($p in $remover) {
    if ($IncluirProvisionamento -eq $false -and $p -eq 'android.autoinstalls.config.positivo.T2040B') { continue }
    $r = Invoke-Adb 'shell' 'cmd' 'package' 'install-existing' $p
    if ($r -match 'installed') {
        Write-Host ("  [ok]      " + $p) -ForegroundColor Green
        $ok++
    } else {
        Write-Host ("  [ausente] " + $p) -ForegroundColor DarkGray
        $fail++
    }
}

# ---------------------------------------------------------------
# 3. Reativar
# ---------------------------------------------------------------
Write-Host ''
$desativar = Get-Lista $listaDesativar
Write-Info ("Reativando " + $desativar.Count + " pacotes")
foreach ($p in $desativar) {
    if ($IncluirProvisionamento -eq $false -and $p -eq 'com.android.managedprovisioning') { continue }
    if ($IncluirProvisionamento -eq $false -and $p -eq 'com.google.android.partnersetup') { continue }
    $r = Invoke-Adb 'shell' 'pm' 'enable' $p
    Write-Host ("  [ok] " + $p) -ForegroundColor Green
}

# ---------------------------------------------------------------
# 4. Resumo
# ---------------------------------------------------------------
Write-Host ''
Write-Titulo "Resumo"
Write-Ok ("Reinstalados: " + $ok)
if ($fail -gt 0) { Write-Info ("Nao encontrados no sistema: " + $fail) }
Write-Host ''
Write-Info "Reinicie o tablet para que tudo volte ao normal"
Write-Log ("restauracao concluida: ok=" + $ok + " ausentes=" + $fail)
