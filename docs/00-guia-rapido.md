# Guia rapido

O caminho completo, sem teoria. Se voce nunca fez isso, siga na ordem.
Tempo total estimado: 40 a 60 minutos, sendo 15 de download.

---

## Antes de comecar

- [ ] Tablet **T2040B** com bateria acima de 40 por cento
- [ ] PC Windows 10 ou 11 com 4 GB livres em disco
- [ ] Cabo USB que transmita dados (o de carregar sozinho nao serve)
- [ ] Paciencia: 1,5 GB de download e 10 minutos de gravacao

---

## Etapa 1: preparar o PC

Abra `scripts-bat/1-verificar-ambiente.bat`.

O script confere:

- PowerShell 5.1 ou superior
- 7-Zip instalado
- `adb.exe` e `fastboot.exe` disponiveis
- Espaco em disco
- Conexao com a internet

Se faltar algo, ele diz exatamente o que instalar e onde.

---

## Etapa 2: baixar o instalador oficial

Abra `scripts-bat/2-baixar-instalador.bat`.

- Baixa `PositivoRescuerInstaller_T2040B_11178165.exe` (1,49 GB)
- Confere o SHA-256 automaticamente
- Guarda em `ferramentas/`

Se o servidor recusar, o script tenta o link alternativo e explica como pedir o arquivo pela pagina da Positivo usando o numero de serie.

---

## Etapa 3: extrair o que interessa

Abra `scripts-bat/3-extrair.bat`.

Extrai do instalador:

| Item | Para que serve |
|---|---|
| `Positivo_T2040B_V001_03312022.pac` | a ROM oficial de 3,18 GB |
| `CmdDloader.exe` | o gravador por linha de comando |
| `UpgradeDownload.exe` | o gravador com interface, alternativa |
| `Drivers_S545` | driver de comunicacao com o Boot ROM |

O script tambem aplica dois ajustes nos arquivos `.ini` do gravador. O documento [04-reflash.md](04-reflash.md) explica cada ajuste.

---

## Etapa 4: reflashar

Abra `scripts-bat/4-reflashar.bat` e responda as perguntas.

O que acontece, em ordem:

1. O script inicia o gravador e espera a extracao da ROM (cerca de 40 segundos).
2. Quando a tela mostrar **PRONTO PARA CONECTAR**, faca:
   - Desligue o tablet (segure POWER por 15 segundos)
   - Segure **VOLUME +**
   - Encaixe o cabo USB mantendo o Volume + pressionado
   - Conte ate 15 e solte
3. A gravacao comeca sozinha. Duram cerca de 9 minutos.
4. **Nao mexa em nada** durante a gravacao.
5. No final aparece `PASS` na tela do script.

O tablet reinicia sozinho e cai na tela de boas-vindas do Android.

> Se der erro, va direto para [09-troubleshooting.md](09-troubleshooting.md). Os cinco erros possiveis estao mapeados la, com a solucao exata.

---

## Etapa 5: configurar SEM internet

Esta e a etapa que muita gente erra, e ela e a mais importante de todas.

1. Ligue o tablet e **nao conecte o Wi-Fi**.
2. Na tela de rede, procure **Pular** ou **Configurar depois**.
3. Pule conta Google, pule copiar dados, pule tudo que pede rede.
4. Coloque um PIN que voce lembre.
5. Chegue ate a area de trabalho.
6. Ative as opcoes de desenvolvedor: Ajustes, Sobre o tablet, toque 7 vezes em **Numero da versao**.
7. Volte, entre em **Sistema**, **Opcoes do desenvolvedor**, ligue **Depuracao USB**.
8. Conecte o cabo e aceite o aviso no tablet, marcando **Sempre permitir**.

Agora abra `scripts-bat/5-pos-setup.bat`. Ele bloqueia o provisionamento em
tres frentes e mostra o resultado.

So depois disso conecte o Wi-Fi.

Motivo de tudo isso em [05-setup-offline.md](05-setup-offline.md).

---

## Etapa 6: limpar o sistema

Com o tablet conectado e autorizado:

1. `scripts-bat/6-remover-apps.bat`
   Remove 49 pacotes: apps da escola, ferramentas de fabrica, bloat da Google.
   Mostra tabela de resultado e grava um script de restauracao.

2. `scripts-bat/7-ajustes.bat`
   Animações em 0,5x, varredura de Wi-Fi e Bluetooth desligada, fontes
   desconhecidas bloqueadas, tempo de tela em 2 minutos.

3. `scripts-bat/8-diagnostico.bat`
   Tira um retrato do aparelho: RAM, armazenamento, pacotes, provisionamento.
   Guarde a saida para comparar no futuro.

---

## Etapa 7: usar como aparelho de emergencia

Leia [08-kit-emergencia.md](08-kit-emergencia.md). O resumo:

1. **Antes de qualquer login**, imprima os codigos de backup da sua conta Google.
2. Entre com a conta no tablet.
3. Instale o autenticador e teste a recuperacao.
4. Ative o Find My Device.
5. Desligue a depuracao USB.
6. Defina uma rotina de recarga a cada 3 ou 4 semanas.

---

## Mapa dos modos do aparelho

Confunde muito, entao vale memorizar:

| Modo | Tela | Como entrar | Serve para |
|---|---|---|---|
| Android normal | sistema ligado | POWER | uso diario |
| Recovery | menu com letras grandes | POWER + VOLUME + | tentar wipe, ver logs |
| Fastboot | logo com "FASTBOOT MODE" | Recovery, opcao Reboot to bootloader | comandos fastboot |
| Modo download (BROM) | **tela preta, nada aparece** | desligado, VOLUME +, conectar cabo | gravar a ROM |

Regra de ouro: **tela preta com o cabo conectado, no modo download, e sucesso.**
Se aparecer logo da Positivo ou icone de bateria, o modo download nao entrou.
