# Requisitos e conceitos basicos

Este documento existe para que uma pessoa sem experiencia consiga entender o
que esta fazendo, e nao apenas apertar botoes.

---

## O que voce precisa ter

### Computador

| Item | Minimo | Recomendado |
|---|---|---|
| Sistema | Windows 10 | Windows 11 |
| Arquitetura | 64 bits | 64 bits |
| Espaco livre | 6 GB | 10 GB |
| Portas | 1 USB | 1 USB 2.0 dedicada |
| Privilegios | administrador | administrador |

O processo inteiro foi validado em Windows 11 build 26300, com Isolamento do
Nucleo ativo. Funciona em Windows 10 com o mesmo procedimento.

### Cabo

Precisa ser cabo de **dados**. Cabos de carregamento puro surgem como
"carregando" no tablet e nao aparecem no PC. Sintoma tipico: o aparelho carrega,
mas `adb devices` fica vazio e nenhum dispositivo novo aparece no Gerenciador
de Dispositivos.

### Tablet

- Positivo **T2040B**
- Bateria acima de 40 por cento no inicio
- Sem senha de tela (se tiver, o reflash resolve)

---

## Quanto tempo leva

| Etapa | Tempo |
|---|---|
| Verificar ambiente | 2 min |
| Baixar instalador | 5 a 20 min, depende da conexao |
| Extrair payload | 1 a 3 min |
| Reflash | 10 min |
| Configuracao inicial offline | 5 min |
| Bloqueio do provisionamento | 2 min |
| Remocao de apps | 3 min |
| Ajustes finais | 1 min |
| **Total** | **30 a 45 min** |

---

## Conceitos, em uma frase cada

**Bootloader**: primeiro programa que roda no aparelho. Decide se o sistema e
confiavel e o que iniciar. No T2040B ele esta **travado**, ou seja, recusa
gravar ou apagar particoes.

**Recovery**: modo de manutencao separado do Android. Tem menu com opcoes como
reboot, apply update e logs. No T2040B, curiosamente, **nao tem** a opcao de
apagar os dados.

**Fastboot**: protocolo de comunicacao com o bootloader pelo cabo USB. Serve
para gravar particoes quando o bootloader esta destravado. No T2040B ele
existe, mas o bootloader recusa quase tudo.

**Modo download (BROM)**: modo especial do chip Unisoc, que roda **antes** do
bootloader. Nao obedece ao bloqueio do bootloader. E por isso que o reflash
funciona mesmo com tudo travado.

**BROM**: sigla de Boot ROM, a memoria somente leitura interna do chip. E ela
que recebe a ROM no modo download.

**FDL**: programa auxiliar que o BROM carrega para conversar com o PC. Vem
dentro do `.pac`, nao precisa baixar separado.

**`.pac`**: arquivo de pacote da Unisoc. Contem a tabela de particoes, a imagem
do sistema, o boot, o modem e os programas FDL. No T2040B sao 3,18 GB.

**ADB**: Android Debug Bridge. Canal de linha de comando para o Android ligado,
usado aqui para remover apps e ler configuracoes.

**Recovery stub**: quando o fastboot nao implementa os comandos de verdade.
E o caso do T2040B: `getvar` retorna vazio e todo comando `oem` responde
`unknown cmd`.

**Android Enterprise**: sistema de gerenciamento corporativo do Android. Quando
um aparelho "pertence a uma organizacao", ele recebe um aplicativo gerenciador
com poderes de dono. Bloqueavel, e este repositorio mostra como.

**HVCI / Isolamento do Nucleo**: recurso de seguranca do Windows que impede
drivers antigos ou sem assinatura valida de carregar. Foi o que impediu o
driver da Unisoc de funcionar.

---

## Avisos de seguranca

1. O processo **apaga tudo**. Fotos, contas, mensagens, jogos, tudo.
2. O aparelho fica **sem atualizacao de seguranca** desde fevereiro de 2022.
   Nao instale aplicativo de banco nele.
3. Nao interrompa a gravacao. Queda de energia ou cabo removido no meio do
   processo pode exigir um segundo reflash, mas raramente inutiliza o aparelho,
   porque o BROM continua acessivel.
4. Nao use ROM de outro modelo. Ja foi dito no README, mas repetir nao custa.
5. Nao faca reset de fabrica depois de tudo pronto. Isso reverte as remocoes e
   traz o provisionamento de volta. Explicado em [05-setup-offline.md](05-setup-offline.md).

---

## Verificacao rapida do modelo

Antes de qualquer coisa, confirme que e um T2040B. No recovery, o cabecalho
mostra a identificacao completa:

```
android recovery
positivo/t2040/t2040b
11/R01005/URBR2022112901
user/release-keys
```

A linha do meio e a que importa: `positivo/t2040/t2040b`. Se o terceiro campo
for outra coisa, **pare**.

Com o Android ligado, tambem funciona:

```powershell
adb shell getprop ro.build.fingerprint
```

Resultado esperado, para a build de fabrica de 2022:

```
positivo/T2040/T2040B:11/R01005/URBB2022033101:user/release-keys
```

Se o texto acima aparecer igual, o aparelho e exatamente o alvo deste guia.
