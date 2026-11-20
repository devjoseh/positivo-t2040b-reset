# Diagnostico

Antes de gravar qualquer coisa, vale entender em que estado o aparelho esta.
Este documento ensina a olhar, e a interpretar o que voce viu.

Tempo: 10 minutos. Nao altera nada no tablet.

---

## 1. Identificar o modelo

### Pelo recovery

Recovery e o menu de manutencao. Para entrar:

1. Desligue o tablet (segure POWER por 15 segundos).
2. Segure **POWER + VOLUME +** ate aparecer o logo da Positivo.
3. Solte os dois.

Se nao entrar, tente **POWER + VOLUME -**. O manual oficial da Positivo usa
VOLUME -, mas o T2040B respondeu a VOLUME + no caso real.

O cabecalho do menu mostra:

```
android recovery
positivo/t2040/t2040b
11/R01005/URBR2022112901
user/release-keys
```

Traduzindo: produto `t2040`, dispositivo `t2040b`, Android 11, build
`R01005/URBR2022112901`, assinatura de release.

### Por ADB, com o sistema ligado

```powershell
adb shell getprop ro.build.fingerprint
adb shell getprop ro.product.cpu.abilist
adb shell cat /proc/meminfo
adb shell df -h /data
```

---

## 2. Ler o menu do recovery

O menu do T2040B tem estas opcoes:

```
Reboot system now
Reboot to bootloader
Enter fastboot
Apply update from ADB
Apply update from SD card
Mount /system
View recovery logs
Run graphics test
Run locale test
Enter rescue
Power off
```

**O que chama atencao:** nao existem `Wipe data/factory reset` nem
`Wipe cache partition`. Nao e defeito, nao e menu cortado, nao e tela
desatualizada. A Positivo removeu essas opcoes de proposito, porque faz parte
da politica educacional do aparelho: "protege-se contra a restauracao de
fabrica".

Consequencia pratica: **nao existe hard reset por menu neste tablet.** Esse e
o motivo de precisar de reflash.

---

## 3. Testar o fastboot

Fastboot serve para conversar com o bootloader. No recovery, escolha
**Reboot to bootloader** e confirme com POWER.

A tela fica preta ou mostra um texto pequeno com "FASTBOOT MODE". No PC:

```powershell
fastboot devices
```

Esperado no T2040B:

```
<NUMERO_DE_SERIE>    fastboot
```

Se aparecer, faca os testes de leitura:

```powershell
fastboot getvar product
fastboot getvar unlocked
fastboot getvar secure
fastboot oem device-info
```

No T2040B, todos retornam **vazio**, e o `oem device-info` retorna
`unknown cmd.`. Isso indica que o fastboot e um stub, sem implementacao real
dos comandos.

Teste destrutivo, que deve falhar num aparelho travado:

```powershell
fastboot erase userdata
```

Resposta real do T2040B:

```
FAILED (remote: 'Flashing Lock Flag is locked. Please unlock it first!')
```

Testes de destravamento:

```powershell
fastboot flashing unlock
fastboot oem unlock
```

Respostas reais:

```
FAILED (remote: 'unknown cmd.')
FAILED (remote: 'Unlock bootloader fail.')
```

**Cuidado com uma pegadinha:** `fastboot -w` responde `Finished` em alguns
aparelhos mesmo sem apagar nada. No T2040B ele terminou em 0,001 segundo e nao
apagou coisa alguma. Nunca confie nesse comando como prova de wipe. Use sempre
o `erase userdata` explicito para ver o erro verdadeiro.

### Resumo do diagnostico de fastboot

| Comando | Resposta | Interpretacao |
|---|---|---|
| `getvar *` | vazio | fastboot stub, sem dados |
| `erase userdata` | Flashing Lock Flag is locked | bootloader travado |
| `flashing unlock` | unknown cmd | sem suporte a desbloqueio |
| `oem unlock` | Unlock bootloader fail | sem chave de desbloqueio |
| `oem wipe`, `oem reset`, `oem format`, outros | unknown cmd | conjunto de comandos oem inexistente |

Conclusao: **fastboot nao resolve o problema neste modelo.** Nem com o
aparelho destravado, porque o proprio fastboot nao esta implementado.

---

## 4. Testar o ADB

ADB funciona apenas com o Android ligado e a **Depuracao USB** ativa.

Para ligar: Ajustes, Sobre o tablet, toque 7 vezes em **Numero da versao**.
Depois: Sistema, Opcoes do desenvolvedor, **Depuracao USB**.

```powershell
adb devices -l
```

Estados possiveis:

| Estado | Significado | O que fazer |
|---|---|---|
| `device` | pronto para uso | pode rodar comandos |
| `unauthorized` | faltou autorizar no tablet | ver o aviso na tela e tocar em Permitir |
| `offline` | conexao travada | `adb kill-server`, depois `adb devices` |
| `sideload` | em modo de instalacao de atualizacao | nao serve para shell |
| vazio | sem conexao | cabo, driver ou modo errado |

### Detalhe importante sobre `unauthorized`

O aviso de autorizacao do ADB **nao aparece com a tela bloqueada** em várias
versoes do Android. Se o tablet estiver no PIN, o `adb devices` fica em
`unauthorized` para sempre e nao ha o que fazer. E preciso desbloquear, ou
reflashar.

No caso real que originou este repositorio, esse foi um beco sem saida
importante: o aparelho tinha depuracao USB ligada, mas o aviso ficava atras da
tela de bloqueio.

---

## 5. Diagnosticar o modo download

O modo download e o que importa para o reflash. Caracteristicas:

- Tablet **desligado**
- Segurar **VOLUME +**
- Conectar o cabo USB
- **A tela fica preta.** Se aparecer logo da Positivo ou icone de bateria, nao
  entrou.
- Dura cerca de 16 segundos se ninguem do PC conversar com ele. Depois disso o
  Boot ROM desiste e reinicia.

No PC, o dispositivo aparece assim:

```
USB\VID_1782&PID_4D00
Descricao: SPRD U2S Diag (COM4)
Classe: Ports
Fabricante: DriverCoding Corporation
```

Comandos uteis para acompanhar:

```powershell
# ver o dispositivo
pnputil /enum-devices /connected | Select-String "VID_1782" -Context 0,4

# ver as portas seriais que o Windows enxerga
[System.IO.Ports.SerialPort]::GetPortNames()

# ver o estado do driver, quando o dispositivo estiver presente
pnputil /enum-devices /instanceid "USB\VID_1782&PID_4D00\..." /properties
```

O teste decisivo e este: **se `GetPortNames()` retornar vazio com o dispositivo
presente, o driver nao carregou.** Esse era o problema. Detalhes em
[03-driver-windows.md](03-driver-windows.md).

---

## 6. Script pronto

Tudo isso automatizado:

```
scripts-bat/8-diagnostico.bat
```

Ele coleta modelo, build, ABI, RAM, armazenamento, portas, estado do
provisionamento e lista de pacotes, e grava um arquivo em `logs/`.
