# 04-bloquear-provisionamento.ps1
# Bloqueia o provisionamento Android Enterprise em tres frentes.
# Rode com o tablet ja configurado e SEM internet.

. "$PSScriptRoot\lib-common.ps1"

Write-Titulo "reset-t2040 - bloqueio do provisionamento"

$estado = Get-EstadoDispositivo
if ($estado -ne 'device') {
    Write-Erro ("Tablet nao esta pronto. Estado atual: " + $estado)
    Write-Info "Desbloqueie o tablet, ligue a depuracao USB e aceite o aviso"
    return
}

Write-Info "Etapas anteriores a esta:"
Write-Info "  1. reflash concluido"
Write-Info "  2. configuracao inicial feita SEM internet"
Write-Info "  3. depuracao USB ligada"
Write-Host ''

# ---------------------------------------------------------------
# 1. Diagnostico antes
# ---------------------------------------------------------------
Write-Info "Estado antes do bloqueio"
$owner = Invoke-Adb 'shell' 'dumpsys' 'device_policy'
$temOwner = ($owner -match 'Device Owner.*ComponentInfo') -or ($owner -match 'Device Owner:')
if ($temOwner) {
    Write-Erro "Ja existe um device owner ativo!"
    Write-Info "O bloqueio nao vai remover o que ja foi aplicado."
    Write-Info "Nesse caso o caminho e reflashar e repetir sem internet."
    $resp = Read-Host "  Continuar mesmo assim? (s/N)"
    if ($resp -notmatch '^[Ss]') { return }
} else {
    Write-Ok "Nenhum device owner ativo"
}

$wifi = Invoke-Adb 'shell' 'settings' 'get' 'global' 'wifi_on'
if ($wifi.Trim() -eq '1') {
    Write-Aviso "O Wi-Fi esta ligado"
    Write-Info "Se possivel, desligue agora: o bloqueio ideal e feito offline."
    $resp = Read-Host "  Desligar o Wi-Fi agora? (S/n)"
    if ($resp -eq '' -or $resp -match '^[Ss]') {
        Invoke-Adb 'shell' 'svc' 'wifi' 'disable' | Out-Null
        Write-Ok "Wi-Fi desligado"
    }
}

# ---------------------------------------------------------------
# 2. Aplicar o bloqueio
# ---------------------------------------------------------------
Write-Host ''
Write-Info "Aplicando as tres acoes"

$autoinstall = 'android.autoinstalls.config.positivo.T2040B'
$parceiro    = 'com.google.android.partnersetup'
$provision   = 'com.android.managedprovisioning'

$saida = Invoke-Adb 'shell' 'pm' 'uninstall' '--user' '0' $autoinstall
if ($saida -match 'Success') { Write-Ok ("Removido: " + $autoinstall) }
else { Write-Aviso ($autoinstall + " -> " + $saida.Trim()) }

foreach ($p in @($parceiro, $provision)) {
    $r = Invoke-Adb 'shell' 'pm' 'disable-user' '--user' '0' $p
    if ($r -match 'disabled|new state') { Write-Ok ("Desativado: " + $p) }
    else { Write-Aviso ($p + " -> " + $r.Trim()) }
}

# ---------------------------------------------------------------
# 3. Verificacao
# ---------------------------------------------------------------
Write-Host ''
Write-Info "Verificando resultado"

$listaDesativados = Invoke-Adb 'shell' 'pm' 'list' 'packages' '-d'
$listaAuto = Invoke-Adb 'shell' 'pm' 'list' 'packages'
$ownerDepois = Invoke-Adb 'shell' 'dumpsys' 'device_policy'

$okProvision = $listaDesativados -match 'managedprovisioning'
$okParceiro  = $listaDesativados -match 'partnersetup'
$okAuto      = -not ($listaAuto -match 'autoinstalls')
$okSemOwner  = -not ($ownerDepois -match 'Device Owner.*ComponentInfo')

if ($okProvision) { Write-Ok "managedprovisioning desativado" } else { Write-Erro "managedprovisioning NAO esta desativado" }
if ($okParceiro)  { Write-Ok "partnersetup desativado" }       else { Write-Erro "partnersetup NAO esta desativado" }
if ($okAuto)      { Write-Ok "pacote de auto-install removido" } else { Write-Erro "pacote de auto-install ainda presente" }
if ($okSemOwner)  { Write-Ok "nenhum device owner" }            else { Write-Erro "device owner apareceu" }

# ---------------------------------------------------------------
# 4. Proximo passo
# ---------------------------------------------------------------
Write-Host ''
if ($okProvision -and $okParceiro -and $okAuto -and $okSemOwner) {
    Write-Ok "BLOQUEIO APLICADO COM SUCESSO"
    Write-Host ''
    Write-Info "Agora sim pode conectar o Wi-Fi."
    Write-Info "Se aparecer 'Dispositivo gerenciado pelo administrador',"
    Write-Info "silencie o canal. Detalhes em docs/11-zero-touch.md"
    Write-Info ""
    Write-Info "Proximo passo: 6-remover-apps.bat"
} else {
    Write-Erro "Alguma acao nao foi aplicada"
    Write-Info "Revise a saida acima e tente de novo"
}
Write-Log ("bloqueio: provision=$okProvision parceiro=$okParceiro autoinstall=$okAuto semOwner=$okSemOwner")
