# 06-ajustes-performance.ps1
# Aplica os ajustes de desempenho e bateria listados em dados/ajustes-settings.txt

. "$PSScriptRoot\lib-common.ps1"

Write-Titulo "positivo-t2040b-reset - ajustes de desempenho"

$estado = Get-EstadoDispositivo
if ($estado -ne 'device') {
    Write-Erro ("Tablet nao esta pronto. Estado atual: " + $estado)
    return
}

$arquivo = Join-Path $DirDados 'ajustes-settings.txt'
if (-not (Test-Path $arquivo)) {
    Write-Erro "Arquivo nao encontrado: $arquivo"
    return
}

# ---------------------------------------------------------------
# 1. Aplicar
# ---------------------------------------------------------------
$validos = @('global', 'secure', 'system')
$aplicados = 0
$ignorados = 0

Write-Info "Aplicando ajustes"
foreach ($linha in (Get-Content $arquivo)) {
    $t = $linha.Trim()
    if ($t -eq '' -or $t.StartsWith('#')) { continue }

    $partes = $t -split '\s+'
    if ($partes.Count -lt 3) { continue }

    $espaco = $partes[0]
    $chave  = $partes[1]
    $valor  = ($partes[2..($partes.Count - 1)] -join ' ')

    if ($validos -notcontains $espaco) {
        Write-Aviso ("Namespace invalido, ignorado: " + $t)
        $ignorados++
        continue
    }

    Invoke-Adb 'shell' 'settings' 'put' $espaco $chave $valor | Out-Null
    $lido = (Invoke-Adb 'shell' 'settings' 'get' $espaco $chave).Trim()
    if ($lido -eq $valor) {
        Write-Ok ($espaco + "." + $chave + " = " + $lido)
        $aplicados++
    } else {
        Write-Aviso ($espaco + "." + $chave + " nao aplicou (lido: " + $lido + ")")
        $ignorados++
    }
}

# ---------------------------------------------------------------
# 2. Encerrar processos pesados abertos
# ---------------------------------------------------------------
Write-Host ''
Write-Info "Encerrando processos desnecessarios"
foreach ($pkg in @('com.android.vending', 'com.google.android.apps.maps', 'com.android.chrome')) {
    $r = Invoke-Adb 'shell' 'am' 'force-stop' $pkg
    Write-Info ("  parado: " + $pkg)
}

# ---------------------------------------------------------------
# 3. Resumo
# ---------------------------------------------------------------
Write-Host ''
Write-Titulo "Resumo"
Write-Ok ("Ajustes aplicados: " + $aplicados)
if ($ignorados -gt 0) { Write-Aviso ("Ignorados: " + $ignorados) }

Write-Host ''
Write-Info "Efeito esperado:"
Write-Info "  animacoes pela metade do tempo"
Write-Info "  varredura de Wi-Fi e Bluetooth em segundo plano desligada"
Write-Info "  instalacao de APK fora da loja bloqueada"
Write-Info "  tela apaga em 2 minutos"
Write-Host ''
Write-Info "Para reverter os ajustes, edite dados/ajustes-settings.txt e rode de novo,"
Write-Info "ou use: adb shell settings put global window_animation_scale 1.0"
Write-Log ("ajustes aplicados: " + $aplicados + " ignorados: " + $ignorados)
