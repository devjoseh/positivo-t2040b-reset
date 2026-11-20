# Pasta de ferramentas

Os binarios grandes ficam aqui. Eles **nao** estao no repositorio, porque sao
pesados e nao sao redistribuiveis.

## O que vai aqui

```
ferramentas/
├── PositivoRescuerInstaller_T2040B_11178165.exe   1,49 GB  (script 01 baixa)
├── platform-tools/                                  10 MB   (script 00 baixa)
└── rescuer/                                       3,56 GB  (script 02 extrai)
    └── AndroidRescuer/
        ├── ROM_Android/11178165/Positivo_T2040B_V001_03312022.pac
        ├── Gravador_Imagens/Tools/UPGRADEDOWNLOAD_R20.0.0001_+/
        ├── Drivers/Drivers_S545/
        └── Config/
```

## Como preencher

Nao e necessario fazer nada a mao. Os scripts cuidam:

| Script | O que faz |
|---|---|
| `scripts/00-verificar-ambiente.ps1` | baixa o `platform-tools` se nao existir |
| `scripts/01-baixar-instalador.ps1` | baixa o instalador e confere o SHA-256 |
| `scripts/02-extrair-payload.ps1` | extrai o `.pac` e as ferramentas, e corrige os `.ini` |

Se preferir baixar manualmente, coloque o `.exe` com este nome exato:

```
PositivoRescuerInstaller_T2040B_11178165.exe
```

## Requisitos de disco

| Etapa | Espaco necessario |
|---|---|
| Instalador | 1,5 GB |
| Extracao | 3,6 GB |
| Total durante o processo | 5,1 GB |
| Pode apagar o `.exe` depois | recupera 1,5 GB |

## 7-Zip

A extracao usa o 7-Zip. Instale em `C:\Program Files\7-Zip\`.

```powershell
winget install 7zip.7zip
```

Ou baixe em `https://www.7-zip.org/`.

## O que NAO colocar aqui

- ROM de outro modelo (Q10, T2040C, Pro X). Nao funciona e pode inutilizar o
  aparelho.
- Pacotes `.pac` de site de terceiro.
- Qualquer instalador que nao tenha o SHA-256 conferido.

## Limpeza

Depois do reflash voce pode apagar o `.exe` e manter a pasta `rescuer`, para nao
precisar baixar de novo. Ou apagar tudo e deixar os scripts baixarem outra vez.

```powershell
Remove-Item .\ferramentas\PositivoRescuerInstaller_T2040B_11178165.exe
```
