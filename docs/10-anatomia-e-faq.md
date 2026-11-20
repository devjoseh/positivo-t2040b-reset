# Anatomia do aparelho e perguntas frequentes

---

## Ficha tecnica

| Item | Valor |
|---|---|
| Fabricante | Positivo Tecnologia |
| Nome comercial | T2040 |
| Modelo interno | T2040B |
| Codinome de build | `t2040b` |
| Numero de peca | 01300-22-03589 |
| Homologacao Anatel | 013002203589 |
| SoC | Unisoc SC9863A |
| CPU | 8 nucleos, 4x 1,6 GHz e 4x 1,2 GHz, Cortex-A55 |
| GPU | PowerVR GE8322 |
| RAM | 2 GB (variantes de 3 e 4 GB existem) |
| Armazenamento | 64 GB eMMC |
| Tela | 10 polegadas, 1280x800 |
| Bateria | 6000 mAh aproximadamente |
| Conectividade | Wi-Fi, Bluetooth, LTE (modem presente, sem chip no caso real) |
| Sistema de fabrica | Android 11 |
| Build | `positivo/T2040/T2040B:11/R01005/URBB2022033101:user/release-keys` |
| Data da build | 31 de marco de 2022 |
| Patch de seguranca | 2022-02-05 |
| ABI | `armeabi-v7a`, `armeabi` (32 bits) |

---

## Particoes relevantes

| Particao | Conteudo | Observacao |
|---|---|---|
| `boot` | kernel e ramdisk | gravado no reflash |
| `recovery` | modo de recuperacao | tem menu sem opcao de wipe |
| `system` | Android base | contem `PlayAutoInstallConfig-br` |
| `system_ext` | extensoes do sistema | contem `CallFireWall` |
| `product` | apps do fabricante | contem `FotaPositivo` e aplicativos do programa educacional |
| `vendor` | drivers do SoC | contem ferramentas Unisoc |
| `misc` | comandos de boot | usado pelo bootloader |
| `persist` | calibracao e IMEI | nao mexer |
| `userdata` | dados do usuario | apagada no reflash |
| `metadata` | metadados de criptografia | apagada no reflash |

O reflash com `Repartition=1` nao reparticiona, apenas garante o mapeamento. O
`EraseAll=0` preserva a tabela de particoes.

---

## Identificacao por modo

| Modo | VID e PID | Nome no Windows | Driver |
|---|---|---|---|
| Android, so carga | varia | nenhum dispositivo | nenhum |
| Android com MTP | `VID_1782&PID_4001` | T2040 | `wpdmtp.inf` |
| Android com ADB | `VID_18D1&PID_4EE8` | ADB Interface e Unisoc Phone | WinUSB |
| Modo download (BROM) | `VID_1782&PID_4D00` | SPRD U2S Diag (COMx) | `sprdvcom.inf` |
| Fastboot | `VID_18D1&PID_4EE0` | Android Bootloader Interface | Android Bootloader |

O identificador do dispositivo fisico e o numero de serie, no formato
`USB\VID_1782&PID_4D00\<serial>`.

---

## Numeros do caso real

| Metrica | Antes | Depois |
|---|---|---|
| Pacotes instalados | 268 | 219 |
| Aplicativos de terceiros | 0 | 0 |
| Aplicativos na gaveta | 23 | 23 |
| Pacotes desativados | 2 | 3 |
| RAM total | 1.934.332 kB | 1.934.332 kB |
| RAM livre | 73 MB | cerca de 1,2 GB disponivel |
| Swap em uso | 257 MB | variavel |
| Blocos gravados no reflash | nao aplicavel | 89.587 |
| Tempo de gravacao | nao aplicavel | 470 segundos |
| Tamanho da ROM | nao aplicavel | 3.254,7 MB |

---

## Links oficiais

| Assunto | Endereco |
|---|---|
| Recuperacao Eletronica Android Positivo | `https://www.meupositivo.com.br/para-voce/suporte-tecnico/recuperacao-android` |
| Manual tecnico com links por modelo | `https://drive.google.com/file/d/1vnIjEM87SUkgpjeM6r7VkTdgCBqRESTd/view` |
| Ficha tecnica oficial | `https://www.positivoempresas.com.br/wp-content/uploads/2021/05/Ficha_Tecnica_Positivo_T2040.pdf` |
| Tutorial oficial de hard reset | `https://midiasstoragesec.blob.core.windows.net/001/2023/08/hardreset-tablet-positivo-t2040.pdf` |
| Android platform tools | `https://developer.android.com/studio/releases/platform-tools` |
| 7-Zip | `https://www.7-zip.org/` |

Links de terceiro que aparecem nas buscas (romprovider, inarguide, needrom,
firmwarefile, clansoft) **nao sao recomendados**. Os pacotes que eles oferecem
sao do Q10 ou do Pro X, nao do T2040B.

---

## Perguntas frequentes

### Preciso de root?

Nao. Nada aqui usa root. Aliás, o aparelho nao tem root e o bootloader e
travado.

### Preciso de conta Google para o reflash?

Nao. O processo e todo local, por cabo USB.

### Preciso de nota fiscal?

Nao. O numero de serie basta para a pagina oficial, e o link do manual nao pede
nada.

### Perco a garantia?

Provavelmente sim, se ainda estivesse na garantia. Aparelhos dessa idade ja
estao fora.

### Posso voltar ao estado de fabrica?

Sim, rodando o reflash de novo. Mas lembre: reset pelas configuracoes **nao**
limpa o provisionamento e **nao** preserva as remocoes. Reflash e o caminho.

### Por que o recovery nao tem "Wipe data"?

Porque a Positivo removeu. Faz parte da politica do fabricante para esse modelo, que inclui
"protege-se contra a restauracao de fabrica". Nao e defeito do seu aparelho.

### Por que o fastboot nao funciona?

Porque o bootloader esta travado **e** o fastboot implementado e um stub. Mesmo
destravando (o que nao e possivel sem exploit especifico), faltariam comandos.

### Por que a ferramenta da Positivo falha?

Por dois motivos somados. O driver de 2015 nao carrega no Windows 11 com
Isolamento do Nucleo, e o erro tem prefixo MTK porque a casca orquestra
ferramentas de varios fabricantes.

### O tablet vai receber atualizacao?

Nao. O atualizador de fabrica foi removido de proposito, e a Positivo nao
publica mais builds para esse modelo. O patch de seguranca esta parado em
fevereiro de 2022.

### Da para instalar LineageOS ou outra ROM?

Nao. Nao existe build para `t2040b`, o bootloader e travado e a comunidade nao
cobre esse modelo.

### É adequado para uso diário?

Como segundo aparelho, leitor, video local e kit de emergencia, sim. Como
aparelho principal em 2026, nao. 2 GB de RAM e 32 bits sao limitantes demais.

### Posso remover mais coisas?

Pode, mas o ganho e marginal. Os 219 pacotes estao proximos do minimo para um
Android com Google. O gargalo e hardware.

### E se eu perder o tablet?

Find My Device resolve o basico: localizar, bloquear, apagar. Se o objetivo for
proteger as contas, o essencial e ter os codigos de backup fora dele e trocar as
senhas dos servicos criticos.

### Os scripts funcionam em Windows 10?

Sim. Foram escritos em PowerShell 5.1, que existe desde o Windows 10.

### E em Linux ou macOS?

O reflash depende de ferramenta Windows (`CmdDloader`). Em Linux existem
alternativas de codigo aberto para chips Unisoc, mas nao estao cobertas aqui.
A parte de ADB, sim, funciona em qualquer sistema.
