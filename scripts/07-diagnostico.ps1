# 07-diagnostico.ps1
# Coleta um retrato completo do aparelho e salva em logs.
# Nao altera nada. Dados pessoais sao mascarados.

. "$PSScriptRoot\lib-common.ps1"

Write-Titulo "reset-t2040 - diagnostico"

$estado = Get-EstadoDispositivo
if ($estado -ne 'device') {
    Write-Erro ("Tablet nao esta pronto. Estado atual: " + $estado)
    Write-Info "Sem ADB o diagnostico nao funciona. Veja docs/02-diagnostico.md"
    return
}

$saida = Join-Path $DirLogs ("diagnostico-" + (Get-Date -Format 'yyyy-MM-dd-HHmm') + ".txt")
$sb = New-Object System.Text.StringBuilder
function Add($t) { [void]$sb.AppendLine([string]$t) }
function S($c) { return (Invoke-Adb 'shell' $c) }

Add "RELATORIO DE DIAGNOSTICO - T2040B"
Add ("Data: " + (Get-Date -Format 'dd/MM/yyyy HH:mm'))
Add ('=' * 62)

Add ""
Add "## IDENTIFICACAO"
Add ("modelo         : " + (S 'getprop ro.product.model'))
Add ("dispositivo    : " + (S 'getprop ro.product.device'))
Add ("fingerprint    : " + (S 'getprop ro.build.fingerprint'))
Add ("android        : " + (S 'getprop ro.build.version.release'))
Add ("patch          : " + (S 'getprop ro.build.version.security_patch'))
Add ("abi            : " + (S 'getprop ro.product.cpu.abilist'))
Add ("boot verificado: " + (S 'getprop ro.boot.verifiedbootstate'))
Add ("build type     : " + (S 'getprop ro.build.type'))
Add ("debuggable     : " + (S 'getprop ro.debuggable'))

Add ""
Add "## HARDWARE"
Add (S 'cat /proc/meminfo | head -1')
$df = S 'df -h /data'
Add (($df -split "`n") | Select-Object -Last 1)

Add ""
Add "## PROVISIONAMENTO"
Add ("device_provisioned  : " + (S 'settings get global device_provisioned'))
Add ("user_setup_complete : " + (S 'settings get secure user_setup_complete'))
$dp = S 'dumpsys device_policy'
($dp -split "`n") | Where-Object { $_ -match 'Enabled Device Admins|Device Owner|mPasswordOwner|provisioningState' } | ForEach-Object { Add ("  " + $_.Trim()) }

Add ""
Add "## PACOTES"
Add ("total     : " + ((S 'pm list packages') -split "`n" | Where-Object { $_ -match '^package:' }).Count)
Add ("terceiros : " + ((S 'pm list packages -3') -split "`n" | Where-Object { $_ -match '^package:' }).Count)
Add "desativados:"
(S 'pm list packages -d') -split "`n" | Where-Object { $_ } | ForEach-Object { Add ("  " + $_) }

Add ""
Add "## RASTROS DE ESCOLA"
$sed = S "pm list packages | grep -iE 'educa|seduc|escola|autoinstall'"
if ($sed) { ($sed -split "`n") | ForEach-Object { Add ("  " + $_) } } else { Add "  nenhum" }

Add ""
Add "## AJUSTES"
foreach ($k in @('window_animation_scale', 'transition_animation_scale', 'animator_duration_scale', 'wifi_scan_always_enabled', 'ble_scan_always_enabled', 'install_non_market_apps')) {
    Add ("global." + $k.PadRight(26) + " : " + (S ("settings get global " + $k)))
}
Add ("system.screen_off_timeout            : " + (S 'settings get system screen_off_timeout'))
Add ("global.wifi_on                       : " + (S 'settings get global wifi_on'))

Add ""
Add "## APLICATIVOS NA GAVETA"
$l = S 'cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER'
foreach ($ln in ($l -split "`n")) {
    if ($ln -match '^\s*([a-zA-Z0-9_.]+)/') { Add ("  " + $matches[1]) }
}

Add ""
Add "## DISPOSITIVOS USB VISIVEIS NO WINDOWS"
try {
    $pnp = & pnputil /enum-devices /connected 2>&1
    ($pnp | Select-String -Pattern 'VID_1782|VID_18D1' -Context 0,4) | ForEach-Object {
        Add ("  " + $_.Line.Trim())
        $_.Context.PostContext | ForEach-Object { Add ("     " + $_.Trim()) }
    }
} catch { Add "  nao foi possivel consultar" }

$sb.ToString() | Out-File $saida -Encoding utf8
Write-Ok ("Diagnostico salvo em: " + $saida)
Write-Host ''
Write-Info "Resumo rapido:"
($sb.ToString() -split "`n") | Where-Object { $_ -match 'modelo|fingerprint|total     |terceiros |mPasswordOwner' } | ForEach-Object { Write-Info ("  " + $_) }
Write-Log ("diagnostico salvo em " + $saida)
