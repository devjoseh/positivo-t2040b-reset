# Exemplos de logs

Saidas reais, coletadas durante o caso que originou este repositorio.
Servem para comparar com o que aparece na sua tela. Dados pessoais mascarados.

---

## 1. Handshake com o Boot ROM

Teste feito com um script de sonda que abre a porta serial e envia 0x7E.
Quando o driver esta funcionando, esta e a resposta:

```
GetPortNames = [COM4]
COM4 ABRIU OK -> PORTA FUNCIONAL
COM4 bytes lidos = 14
RESPOSTA BROM = 7E 00 81 00 06 53 50 52 44 33 00 57 0A 7E
                              \_____________/
                              "SPRD3" em ASCII
```

O que significa: `53 50 52 44 33` e a string "SPRD3", identificacao do Boot ROM
da Spreadtrum. Se aparecer isso, o canal esta vivo.

---

## 2. Descompactacao do PAC

Saida do script de monitoramento, a cada 5 segundos:

```
[16:09:58] CmdDloader PID = 8944
[16:10:03] proc=True | ImageFiles=285.0 MB
[16:10:08] proc=True | ImageFiles=285.0 MB
[16:10:13] proc=True | ImageFiles=285.0 MB
[16:10:18] proc=True | ImageFiles=2144.6 MB
[16:10:33] proc=True | ImageFiles=3254.6 MB
[16:10:38] proc=False | ImageFiles=0 MB | result=... FAIL
```

O crescimento em saltos e normal: o gravador grava em blocos grandes.
`ImageFiles=0` no final significa que ele limpou a pasta temporaria.

---

## 3. Gravacao com sucesso

Trecho do log `BootModeOpr_COM_4_AAAA-MM-DD.log`, no fim da operacao:

```
16:23:18:569(563.370271)  Download (0x000B8000): Success.
16:23:19:192(563.993409)  Download (0x000B8334): Success.
16:23:19:285(564.087141)  End Data: Success.
16:23:19:287(564.088083)  [INFO] FileID=_RESET_, operations for file type Reset
16:23:19:287(564.089527)  Reset: Success.
16:23:19:289(564.090933)  Disconnect Channel ---
16:23:19:290(564.092281)  Finish Successful.
```

Numeros do caso real:

| Metrica | Valor |
|---|---|
| Duracao | 564 segundos, cerca de 9 minutos e meio |
| Blocos com `Success` | 89.587 linhas |
| Resultado final | `Finish Successful` |

Arquivo `download_result.txt`:

```
2026-11-20 16:23:19[COM4]	IMEI:<IMEI>	PASS
```

Arquivo `result.txt`:

```
success
```

---

## 4. Falha por tablet fora do modo download

```
16:10:34:559(0.002018)  Connect Channel +++
16:10:34:574(0.017349)  [INFO] FileID=FDL, operations for file type FDL
16:10:34:631(0.073475)  Check Baudrate: Fail. [142:Wait input time out]
16:10:34:666(0.109217)  Check Baudrate: Fail. [142:Wait input time out]
...
16:10:36:774(2.217545)  Write channel fail.
16:10:37:277(2.720671)  Check Baudrate: Fail. [262:User cancel]
16:10:37:278(2.721113)  Fail at end FDL---ConnectRom operation
16:10:37:279(2.722304)  Finish Failed.
```

O que aconteceu: a porta existia, o gravador escreveu, ninguem respondeu. O
tablet havia saido do modo download.

Solucao: desligar de verdade, segurar VOLUME + e conectar de novo, com o
gravador ja esperando.

---

## 5. Falha por link caindo no meio

```
16:12:05:807(10.963195)  Download (0x0141F000): Success.
16:12:05:840(10.995328)  Download (0x01447000): Success.
16:12:05:859(11.014329)  Write channel fail.
16:12:05:859(11.014728)  Download (0x0144C000): Fail. [257:Uart send error]
16:12:05:867(11.023176)  Stop Boot Mode Operation +++
16:12:05:875(11.030665)  Fail at end CODE2---DownloadByID operation
```

O que aconteceu: gravacao comecou bem, cerca de 180 KB transferidos, e o cabo
ou o link caiu. `Uart send error` e sempre queda de comunicacao.

Solucao: repetir, sem mexer no cabo, preferindo porta USB direto no PC.

---

## 6. Falha de deteccao no assistente da Positivo

```
Instalando drivers... Pronto.
Iniciando o sistema de gravacao de imagem.
Mantenha a tecla [Volume +] pressionada e
    conecte o Smartphone na porta USB...

FALHA: E_MTK_DETECT_DEVICE_TIMEOUT (108)
```

O que aconteceu: o driver nao carregou, entao nenhuma porta COM foi criada, e o
script esperou 60 segundos por uma porta que nunca apareceu.

Solucao: docs/03-driver-windows.md.

---

## 7. Estado do driver com problema

Saida de `pnputil /enum-devices /instanceid ... /properties`:

```
Status:                     Problema
Codigo do Problema:         52 (0x34) [CM_PROB_UNSIGNED_DRIVER]
Status do Problema:         0xC0000428
Nome do Driver:             oem236.inf
```

Evento 3004 do CodeIntegrity:

```
Windows is unable to verify the image integrity of the file
\Device\HarddiskVolume3\Windows\System32\drivers\sprdvcom.sys
because file hash could not be found
```

Evento 219 do Kernel-PnP:

```
O driver \Driver\sprdvcom falhou ao carregar.
Device: USB\VID_1782&PID_4D00
Status: 0xC0000428
```

---

## 8. Estado do driver funcionando

Depois de iniciar o Windows sem exigir assinatura:

```
Status:      Iniciado
GetPortNames = [COM4]
sprdvcom   = Running
```

---

## 9. Bloqueio do provisionamento

Antes:

```
$ pm list packages -d
package:com.android.nfc
package:com.sprd.powersavemodelauncher
```

Depois:

```
$ pm list packages -d
package:com.android.nfc
package:com.google.android.partnersetup
package:com.sprd.powersavemodelauncher
package:com.android.managedprovisioning

$ pm list packages | grep -i autoinstall
(nada)
```

---

## 10. Notificacao de zero-touch

```
NotificationRecord: pkg=com.google.android.gms
  tag=ZeroTouchForcedFactoryResetNotification
  channel=ZeroTouchNotificationChannel
  flags=0x2
  android.title=Dispositivo gerenciado pelo administrador
  android.text=A reinicializacao automatica sera feita em breve
```

O que fazer com isso: docs/11-zero-touch.md.
