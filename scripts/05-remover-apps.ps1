# 05-remover-apps.ps1
# Remove os pacotes da lista dados/pacotes-remover.txt.
# Grava relatorio e um script de restauracao automatico.

param(
    [switch]$Simular
)

. "$PSScriptRoot\lib-common.ps1"

Write-Titulo "positivo-t2040b-reset - remocao de aplicativos"

$estado = Get-EstadoDispositivo
if ($estado -ne 'device') {
    Write-Erro ("Tablet nao esta pronto. Estado atual: " + $estado)
    Write-Info "Desbloqueie, ligue a depuracao USB e aceite o aviso"
    return
}

$lista = Join-Path $DirDados 'pacotes-remover.txt'
if (-not (Test-Path $lista)) {
    Write-Erro "Lista nao encontrada: $lista"
    return
}

# ---------------------------------------------------------------
# 1. Ler a lista
# ---------------------------------------------------------------
$pacotes = @()
foreach ($linha in (Get-Content $lista)) {
    $t = $linha.Trim()
    if ($t -eq '' -or $t.StartsWith('#')) { continue }
    $pacotes += $t
}
Write-Info ("Pacotes na lista: " + $pacotes.Count)

$antes = (Invoke-Adb 'shell' 'pm' 'list' 'packages')
$totalAntes = ($antes -split "`n" | Where-Object { $_ -match '^package:' }).Count
Write-Info ("Pacotes instalados agora: " + $totalAntes)

if ($Simular) {
    Write-Host ''
    Write-Aviso "MODO SIMULACAO: nada sera alterado"
    foreach ($p in $pacotes) { Write-Info ("  " + $p) }
    return
}

Write-Host ''
Write-Info "Iniciando remocao. Nao desconecte o cabo."
Write-Host ''

# ---------------------------------------------------------------
# 2. Remover
# ---------------------------------------------------------------
$removidos = @()
$desativados = @()
$falharam = @()

foreach ($p in $pacotes) {
    $r = Invoke-Adb 'shell' 'pm' 'uninstall' '--user' '0' $p
    if ($r -match 'Success') {
        $removidos += $p
        Write-Host ("  [removido]   " + $p) -ForegroundColor Green
        continue
    }
    $d = Invoke-Adb 'shell' 'pm' 'disable-user' '--user' '0' $p
    if ($d -match 'disabled|new state') {
        $desativados += $p
        Write-Host ("  [desativado] " + $p) -ForegroundColor Yellow
    } else {
        $falharam += $p
        Write-Host ("  [falhou]     " + $p) -ForegroundColor DarkGray
        Write-Log ("falha em " + $p + " :: " + $r.Trim() + " / " + $d.Trim())
    }
}

# ---------------------------------------------------------------
# 3. Relatorio
# ---------------------------------------------------------------
$depois = (Invoke-Adb 'shell' 'pm' 'list' 'packages')
$totalDepois = ($depois -split "`n" | Where-Object { $_ -match '^package:' }).Count

Write-Host ''
Write-Titulo "Resultado"
Write-Ok ("Removidos   : " + $removidos.Count)
Write-Ok ("Desativados : " + $desativados.Count)
if ($falharam.Count -gt 0) { Write-Aviso ("Falharam    : " + $falharam.Count) }
Write-Info ("Pacotes: " + $totalAntes + " antes, " + $totalDepois + " depois")

# ---------------------------------------------------------------
# 4. Script de restauracao
# ---------------------------------------------------------------
$stamp = Get-Date -Format 'yyyy-MM-dd-HHmm'
$restore = Join-Path $DirLogs ("restaurar-" + $stamp + ".ps1")
$linhas = @()
$linhas += "# Restauracao gerada por 05-remover-apps.ps1 em " + (Get-Date -Format 'dd/MM/yyyy HH:mm')
$linhas += "# Uso: .\logs\" + (Split-Path -Leaf $restore)
$linhas += ""
$linhas += '$repo = Split-Path -Parent $PSScriptRoot'
$linhas += '. (Join-Path $repo "scripts\lib-common.ps1")'
$linhas += ""
$linhas += "# Reinstalar pacotes removidos"
foreach ($p in $removidos) { $linhas += ("Invoke-Adb 'shell' 'cmd' 'package' 'install-existing' '" + $p + "'") }
$linhas += ""
$linhas += "# Reativar pacotes desativados"
foreach ($p in $desativados) { $linhas += ("Invoke-Adb 'shell' 'pm' 'enable' '" + $p + "'") }
$linhas += ""
$linhas += 'Write-Ok "Restauracao concluida"'
$linhas | Out-File $restore -Encoding utf8

$relatorio = Join-Path $DirLogs ("debloat-" + $stamp + ".txt")
$relatorioLinhas = @()
$relatorioLinhas += "RELATORIO DE REMOCAO - " + (Get-Date -Format 'dd/MM/yyyy HH:mm')
$relatorioLinhas += "Pacotes antes  : $totalAntes"
$relatorioLinhas += "Pacotes depois : $totalDepois"
$relatorioLinhas += ""
$relatorioLinhas += "REMOVIDOS (" + $removidos.Count + ")"
$relatorioLinhas += ($removidos | ForEach-Object { "  " + $_ })
$relatorioLinhas += ""
$relatorioLinhas += "DESATIVADOS (" + $desativados.Count + ")"
$relatorioLinhas += ($desativados | ForEach-Object { "  " + $_ })
$relatorioLinhas += ""
$relatorioLinhas += "FALHARAM (" + $falharam.Count + ")"
$relatorioLinhas += ($falharam | ForEach-Object { "  " + $_ })
$relatorioLinhas | Out-File $relatorio -Encoding utf8

Write-Host ''
Write-Info ("Relatorio      : " + $relatorio)
Write-Info ("Restauracao    : " + $restore)
Write-Info "Proximo passo  : 7-ajustes.bat"
Write-Log ("debloat concluido: removidos=" + $removidos.Count + " desativados=" + $desativados.Count + " falhas=" + $falharam.Count)
