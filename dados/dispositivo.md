# Dispositivo

Ficha do aparelho alvo deste repositorio.

---

## Identificacao

```
Fabricante : Positivo Tecnologia
Nome       : T2040
Modelo     : T2040B
Build      : positivo/T2040/T2040B:11/R01005/URBB2022033101:user/release-keys
Android    : 11
Patch      : 2022-02-05
Peca       : 01300-22-03589
Anatel     : 013002203589
```

## Hardware

```
SoC        : Unisoc SC9863A
RAM        : 2 GB
Storage    : 64 GB
ABI        : armeabi-v7a, armeabi
Tela       : 10 pol, 1280x800
Bateria    : ~6000 mAh
```

## Arquivo de recuperacao oficial

```
Nome   : PositivoRescuerInstaller_T2040B_11178165.exe
Bytes  : 1557124300
SHA256 : 3F6C0A8ABA8CBBF5DB1DCFD1D998FA07EECCA58B01A153CEF93FF41CA105B3A1
```

Conteudo interno relevante:

```
ROM    : Positivo_T2040B_V001_03312022.pac  (3.254,7 MB)
Gravador: CmdDloader.exe / UpgradeDownload.exe (R20.0.0001_+)
Driver : Drivers_S545 (sprdvcom.sys 2.0.0.131, 2015)
```

## Identificadores USB

```
MTP          : VID_1782&PID_4001
ADB          : VID_18D1&PID_4EE8
Modo download: VID_1782&PID_4D00  (SPRD U2S Diag)
Fastboot     : VID_18D1&PID_4EE0
```

## Teclas

```
Recovery       : POWER + VOLUME +  (tambem funciona VOLUME -)
Fastboot       : recovery, opcao "Reboot to bootloader"
Modo download  : aparelho desligado, segurar VOLUME + e conectar o cabo
Desligar       : segurar POWER por 15 segundos
```

## Parametros de gravacao usados

```
CmdDloader.ini        : WaitDUTTimeout = 900000  (original 0)
UpgradeDownload.ini   : EnableFilter = 0         (original 1)
UpgradeDownload.ini   : [Report] enable = 1      (original 0)
UpgradeDownload.ini   : Repartition = 1          (mantido)
UpgradeDownload.ini   : Reset = 1                (mantido)
UpgradeDownload.ini   : EraseAll = 0             (mantido)
Porta serial          : COM4, 460800 baud
```

## Resultado esperado do reflash

```
download_result.txt:  [COM4]  IMEI:<mascarado>  PASS
result.txt:           success
log:                  Finish Successful
```

Observacao: o IMEI e dado pessoal. Nao versione o arquivo de resultado real.
Mascare antes de publicar qualquer log.
