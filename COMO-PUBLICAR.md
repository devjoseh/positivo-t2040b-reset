# Como publicar no GitHub

O repositorio ja esta com Git inicializado, branch `main` e commits feitos.
Falta apenas criar o repositorio remoto e enviar.

---

## 1. Criar o repositorio vazio no GitHub

1. Abra `https://github.com/new`
2. Nome sugerido: `reset-t2040`
3. Descricao sugerida:

```
Recuperacao completa do tablet Positivo T2040B: reflash da ROM oficial, remocao do provisionamento Android Enterprise e debloat.
```

4. Marque **Public** ou **Private**, como preferir
5. **Nao** marque "Add a README", "Add .gitignore" nem "Choose a license". O
   repositorio ja tem tudo isso
6. Clique em **Create repository**

---

## 2. Enviar

No terminal, dentro da pasta do repositorio:

```powershell
cd C:\Users\matap\Documents\Github\pessoal\reset-t2040
git remote add origin https://github.com/SEU_USUARIO/reset-t2040.git
git push -u origin main
```

Se pedir autenticacao, use um Personal Access Token como senha, ou configure o
GitHub CLI:

```powershell
gh auth login
gh repo create reset-t2040 --public --source . --push
```

---

## 3. Depois de publicar

Sugestoes que deixam o repositorio mais util:

- Em **About**, adicione os topicos: `positivo`, `t2040b`, `unisoc`,
  `sc9863a`, `android-11`, `reflash`, `debloat`, `android-enterprise`
- Fixe o repositorio no perfil, se quiser
- Em **Settings**, **Pages**, nao e necessario: este conteudo e para leitura no
  proprio GitHub

---

## 4. O que NAO vai subir

O `.gitignore` ja bloqueia:

| Item | Motivo |
|---|---|
| `ferramentas/*.exe` e `*.pac` | 5 GB, e nao redistribuivel |
| `ferramentas/platform-tools/` | binario de terceiro |
| `logs/*.log` | saida de execucao local |
| `dados/pessoal/` | qualquer dado pessoal seu |

Confira antes de publicar:

```powershell
git status --short
git ls-files | Measure-Object -Line
```

Esperado: nada em `git status` e 44 arquivos rastreados.

---

## 5. Cuidados com dados pessoais

O material foi revisado e nao contem numero de serie nem IMEI reais. Se um dia
voce adicionar logs seus, mascare antes:

- Numero de serie: troque por `<NUMERO_DE_SERIE>`
- IMEI: troque por `<IMEI>`
- Endereco IP local: troque por `<IP_LOCAL>`

Busca rapida:

```powershell
Get-ChildItem -Recurse -File | Select-String -Pattern "4AD85GK0Z|355105"
```

---

## 6. Atualizacoes futuras

```powershell
git add -A
git commit -m "docs: ajuste no capitulo de troubleshooting"
git push
```

Se quiser manter o padrao do historico:

| Prefixo | Uso |
|---|---|
| `feat:` | conteudo novo |
| `fix:` | correcao de erro em script ou documento |
| `docs:` | texto, exemplos, explicacoes |
| `chore:` | configuracao, gitignore, gitattributes |
