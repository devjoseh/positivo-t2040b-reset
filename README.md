# positivo-t2040b-reset

Recuperação do tablet Positivo T2040B: reflash da ROM oficial, bloqueio do provisionamento Android Enterprise, remoção de aplicativos pré-instalados e ajustes de desempenho.

Documentação e scripts para devolver o aparelho ao estado de fábrica e deixá-lo utilizável, incluindo o roteiro para uso como dispositivo reserva.

---

## O que este repositório resolve

| Problema | Solução documentada aqui |
|---|---|
| PIN esquecido, sem conta Google e sem nota fiscal | Reflash com o pacote oficial do fabricante |
| Recovery sem a opção de apagar dados | Explicação da causa e caminho alternativo |
| `fastboot -w` sem efeito e sem mensagem de erro | Diagnóstico do bootloader Unisoc travado |
| Ferramenta oficial falha com `E_MTK_DETECT_DEVICE_TIMEOUT` | Causa raiz: driver de 2015 bloqueado no Windows 11 |
| Após o reset aparece "Este dispositivo pertence à sua organização" | Identificação e bloqueio do provisionamento |
| Sistema lento com 2 GB de RAM e muitos aplicativos | Lista de 49 pacotes removidos, com script e reversão |

---

## Compatibilidade

Modelo validado:

| Item | Valor |
|---|---|
| Marca e modelo | Positivo T2040B (nome comercial T2040) |
| Codinome interno | `t2040b` |
| Build de fábrica | `positivo/T2040/T2040B:11/R01005/URBB2022033101:user/release-keys` |
| Android | 11 |
| SoC | Unisoc SC9863A |
| RAM | 2 GB |
| Armazenamento | 64 GB |
| Arquitetura | 32 bits (`armeabi-v7a`) |
| Patch de segurança | 2022-02-05 |
| Número de peça | 01300-22-03589 |

Não aplicar em outro modelo. T2040C, Q10 e Pro X são aparelhos diferentes, com ROM própria. O manual técnico do fabricante informa que a ROM funciona apenas no modelo correspondente, e o flash de pacote incorreto pode inutilizar o aparelho.

---

## Avisos

1. O processo apaga todos os dados do tablet.
2. O aparelho precisa ser de sua propriedade.
3. O reflash usa a ROM oficial obtida pelo instalador do fabricante.
4. O uso é de responsabilidade de quem executa.

---

## Início rápido

Requisitos:

- PC com Windows 10 ou 11
- Cabo USB de dados
- 30 a 45 minutos
- 6 GB livres em disco, para o instalador de 1,5 GB e a extração de 3,6 GB

Sequência:

1. Baixe este repositório e extraia em uma pasta curta, por exemplo `C:\positivo-t2040b-reset`.
2. Execute `scripts-bat/1-verificar-ambiente.bat`. Ele confere o que falta.
3. Execute `scripts-bat/2-baixar-instalador.bat`. Baixa 1,5 GB e confere o SHA-256.
4. Execute `scripts-bat/3-extrair.bat`. Extrai o `.pac` de 3,2 GB e as ferramentas.
5. Execute `scripts-bat/4-reflashar.bat` e siga as instruções na tela.
6. No primeiro boot, não conecte o Wi-Fi. Execute `scripts-bat/5-pos-setup.bat` antes de qualquer conexão.
7. Com o aparelho configurado e a depuração USB ativa, execute `scripts-bat/6-remover-apps.bat` e `scripts-bat/7-ajustes.bat`.

Erros durante o processo estão catalogados em [docs/09-troubleshooting.md](docs/09-troubleshooting.md), com a mensagem exata de cada um.

Detalhamento: [docs/00-guia-rapido.md](docs/00-guia-rapido.md).

---

## Estrutura do repositório

```
positivo-t2040b-reset/
├── README.md                     este arquivo
├── CHANGELOG.md                  histórico de versões
├── COMO-PUBLICAR.md              como subir para o GitHub
├── LICENSE                       MIT
├── docs/                         documentação completa
│   ├── 00-guia-rapido.md         sequência completa de execução
│   ├── 01-requisitos.md          ambiente, tempo e conceitos básicos
│   ├── 02-diagnostico.md         identificação do aparelho e do estado
│   ├── 03-driver-windows.md      o bloqueio do driver no Windows 11
│   ├── 04-reflash.md             reflash em detalhe
│   ├── 05-setup-offline.md       configuração sem internet e bloqueio
│   ├── 06-debloat.md             remoção de aplicativos
│   ├── 07-performance.md         ajustes de desempenho
│   ├── 08-kit-emergencia.md      uso como dispositivo reserva
│   ├── 09-troubleshooting.md     mensagens de erro e soluções
│   ├── 10-anatomia-e-faq.md      hardware, partições, perguntas frequentes
│   ├── 11-zero-touch.md          o aviso de organização que retorna após reset
│   └── imagens/                  capturas de tela do processo
├── scripts/                      PowerShell, um por etapa
│   ├── lib-common.ps1            funções compartilhadas
│   ├── 00-verificar-ambiente.ps1
│   ├── 01-baixar-instalador.ps1
│   ├── 02-extrair-payload.ps1
│   ├── 03-reflash.ps1
│   ├── 04-bloquear-provisionamento.ps1
│   ├── 05-remover-apps.ps1
│   ├── 06-ajustes-performance.ps1
│   ├── 07-diagnostico.ps1
│   └── 99-restaurar-apps.ps1
├── scripts-bat/                  atalhos de duplo clique
│   ├── 1-verificar-ambiente.bat
│   ├── 2-baixar-instalador.bat
│   ├── 3-extrair.bat
│   ├── 4-reflashar.bat
│   ├── 5-pos-setup.bat
│   ├── 6-remover-apps.bat
│   ├── 7-ajustes.bat
│   ├── 8-diagnostico.bat
│   └── 9-restaurar-apps.bat
├── dados/                        listas e parâmetros usados pelos scripts
│   ├── pacotes-remover.txt       os 49 pacotes, por categoria
│   ├── pacotes-desativar.txt     os 3 que ficam desativados
│   ├── pacotes-nunca-remover.txt o que não pode sair
│   ├── ajustes-settings.txt      ajustes de sistema aplicados
│   └── dispositivo.md            ficha técnica
├── ferramentas/                  onde ficam os binários
│   └── LEIA-ME.md
└── logs/                         exemplos de saída, para comparação
    └── exemplos-de-logs.md
```

---

## Arquivos que não estão no repositório

Binários grandes ficam fora por tamanho e por não serem redistribuíveis:

| Arquivo | Tamanho | Como obter |
|---|---|---|
| `PositivoRescuerInstaller_T2040B_11178165.exe` | 1,49 GB | Script `01-baixar-instalador.ps1` |
| `Positivo_T2040B_V001_03312022.pac` | 3,18 GB | Extraído no script `02-extrair-payload.ps1` |
| `platform-tools` (ADB) | 10 MB | Script `00-verificar-ambiente.ps1` |
| `7-Zip` | 2 MB | Script `00-verificar-ambiente.ps1` ou 7-zip.org |

O SHA-256 do instalador está em [dados/dispositivo.md](dados/dispositivo.md) e é conferido no download.

---

## Como o reflash funciona

O instalador do fabricante é um envelope 7-Zip com três componentes: a ROM `.pac`, o gravador Unisoc `CmdDloader.exe` e o driver de comunicação. O gravador acessa o Boot ROM do SC9863A pelo modo download, que executa antes do bootloader e não obedece ao bloqueio dele. O processo usa o `CmdDloader.exe` direto, com o `.pac` e a porta serial correta, em vez do assistente gráfico, que falha por um bug de detecção.

Detalhes em [docs/04-reflash.md](docs/04-reflash.md).

---

## Resultado esperado

| Antes | Depois |
|---|---|
| Travado no PIN, sem recuperação | Tela de boas-vindas do Android, sem bloqueio |
| 268 pacotes instalados | 219 pacotes |
| 12 aplicativos pré-instalados de fábrica em execução | 0 |
| Provisionamento Android Enterprise ativo | Bloqueado em três frentes |
| Animações em 1,0x | Animações em 0,5x |
| Varredura de Wi-Fi e Bluetooth em segundo plano | Desativada |
| 73 MB de RAM livre | Cerca de 1,2 GB disponível, incluindo cache |

---

## Licença

MIT. Consulte [LICENSE](LICENSE).

Positivo, Android, Unisoc e Google são marcas de seus respectivos titulares. Este trabalho é independente e não possui vínculo com o fabricante.
