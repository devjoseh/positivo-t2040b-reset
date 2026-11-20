# O problema do driver no Windows 11

Este foi o obstaculo mais dificil do caso real. Vale entender, porque o sintoma
que aparece na tela nao tem nada a ver com a causa.

---

## O sintoma

Voce coloca o tablet em modo download, segura o Volume +, conecta o cabo, e a
ferramenta da Positivo mostra:

```
Instalando drivers... Pronto.
Iniciando o sistema de gravacao de imagem.
Mantenha a tecla [Volume +] pressionada e
    conecte o Smartphone na porta USB...

FALHA: E_MTK_DETECT_DEVICE_TIMEOUT (108)

Causa:
A ferramenta de gravacao nao conseguiu detectar corretamente o dispositivo USB.
```

E o pior: o tablet **estava** em modo download. O Windows viu o dispositivo.
Ele aparece no Gerenciador de Dispositivos como `SPRD U2S Diag (COM4)`.

---

## A investigacao

### Passo 1: o dispositivo existe?

```powershell
pnputil /enum-devices /connected | Select-String "VID_1782" -Context 0,4
```

Resultado:

```
ID da Instancia:  USB\VID_1782&PID_4D00\5&119e49bf&0&2
Descricao:        SPRD U2S Diag (COM4)
Classe:           Ports
Fabricante:       DriverCoding Corporation
Status:           Problema
```

A palavra `Problema` e a pista.

### Passo 2: qual problema?

```powershell
pnputil /enum-devices /instanceid "USB\VID_1782&PID_4D00\5&119e49bf&0&2" /properties
```

Resultado:

```
Status: Problem
Codigo do Problema: 52 (0x34) [CM_PROB_UNSIGNED_DRIVER]
Status do Problema: 0xC0000428
Nome do Driver: oem236.inf
```

**Codigo 52** significa: o Windows nao conseguiu verificar a assinatura
digital do driver. **0xC0000428** e o codigo de status `STATUS_INVALID_IMAGE_HASH`.

### Passo 3: a porta existe de fato?

Mesmo com o dispositivo presente, este teste retorna vazio:

```powershell
[System.IO.Ports.SerialPort]::GetPortNames()
```

Ou seja: o nome diz "COM4", mas **nao existe porta serial nenhuma**. O driver
anunciou o nome e falhou ao iniciar o servico.

Complemento:

```powershell
Get-Service sprdvcom
```

Resultado: `Stopped`. O driver nunca subiu.

### Passo 4: confirmar nos logs do Windows

```powershell
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 10
```

Evento **3004**:

```
Windows is unable to verify the image integrity of the file
\Device\HarddiskVolume3\Windows\System32\drivers\sprdvcom.sys
because file hash could not be found
```

E no log do sistema, evento **219** do Kernel-PnP:

```
O driver \Driver\sprdvcom falhou ao carregar.
Device: USB\VID_1782&PID_4D00
Status: 0xC0000428
```

---

## A causa raiz

O driver `sprdvcom.sys` e de **2015**, versao 2.0.0.131, assinado por catálogo
pela Spreadtrum. O Windows 11, com **Isolamento do Nucleo (HVCI)** ativo, recusa
carregar drivers antigos cuja cadeia de assinatura nao e compativel com o
padrao atual.

Cadeia de consequencias:

```
HVCI ligado
  -> driver recusado (codigo 52, 0xC0000428)
  -> servico sprdvcom nao inicia
  -> nenhuma porta COM e criada
  -> o script da Positivo espera 60 segundos por uma porta que nunca nasce
  -> E_MTK_DETECT_DEVICE_TIMEOUT
```

Ou seja: o erro nao e do cabo, nao e da tecla, nao e da porta USB, nao e do
tablet. E do Windows bloqueando um driver de 2015.

---

## Solucao A: iniciar o Windows sem exigir assinatura de driver

Esta e a solucao recomendada. E temporaria, vale so para a sessao atual, e
desaparece no proximo reinicio normal.

1. Abra Configuracoes, Sistema, Recuperacao.
2. Em **Opcoes avancadas de inicializacao**, clique em **Reiniciar agora**.
   Atalho: segure SHIFT e clique em Reiniciar no menu Iniciar.
3. O PC reinicia num menu azul. Escolha:
   **Solucao de problemas**, **Opcoes avancadas**, **Configuracoes de
   Inicializacao**, **Reiniciar**.
4. Aparece uma lista numerada. Aperte **7** ou **F7**:
   **Desativar a imposicao de assinatura de driver**.
5. O Windows inicia normalmente, com a verificacao desligada.

Ressalvas:

- Antivirus e alguns utilitarios podem nao carregar nessa sessao.
- O modo vale apenas ate o proximo reinicio.
- Enquanto a sessao estiver assim, o driver do T2040B vai carregar.

### Verificar se funcionou

Com o tablet em modo download e o cabo conectado:

```powershell
[System.IO.Ports.SerialPort]::GetPortNames()
```

Esperado: `COM4`.

E o status do dispositivo deve mudar para `Iniciado`:

```powershell
pnputil /enum-devices /connected | Select-String "VID_1782" -Context 0,4
```

Se aparecer `Status: Iniciado`, esta pronto para gravar.

---

## Solucao B: desligar o Isolamento do Nucleo

Alternativa permanente, que exige reinicio e reduz uma protecao do sistema.

1. Abra **Seguranca do Windows**.
2. **Seguranca do dispositivo**, **Isolamento do nucleo**,
   **Detalhes do isolamento do nucleo**.
3. Desligue **Integridade da memoria**.
4. Reinicie o computador.

Se a interface nao mostrar a opcao, use o registro, em um PowerShell como
administrador:

```powershell
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f
```

Depois reinicie. Para reverter, troque o valor final para `1`.

Esta solucao sobrevive a reinicios, mas deixa a maquina menos protegida.
Use apenas se a Solucao A nao estiver disponivel.

---

## Por que nao basta instalar outro driver

O pacote da Positivo traz varios conjuntos de drivers (`Drivers_S545`,
`Drivers_Q20`, `Drivers_S24026`, `Drivers_S511`, `Drivers_X900`). Todos usam o
mesmo `sprdvcom.sys` de 2015. Instalar de novo nao resolve, porque o problema
nao e instalacao, e carga do driver em tempo de execucao.

A unica forma de contornar sem mexer no Windows seria trocar o driver por
WinUSB e usar um gravador que fale USB direto. Funciona, mas e bem mais
trabalhoso, e o `CmdDloader` que vem no pacote oficial precisa da porta serial.

---

## Checklist

- [ ] Dispositivo aparece como `VID_1782&PID_4D00`
- [ ] Status do dispositivo e `Iniciado`, nao `Problema`
- [ ] `GetPortNames()` retorna `COM4`
- [ ] Servico `sprdvcom` esta `Running`
- [ ] O tablet fica com a tela preta durante o modo download

Se os cinco itens estiverem marcados, o reflash vai funcionar. Se algum falhar,
volte para o inicio deste documento.
