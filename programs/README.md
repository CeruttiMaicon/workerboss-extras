# Scripts de instalação de programas (Worker Boss)

O Worker Boss usa os `.sh` desta pasta **quando** no **`~/.workerboss.yml`** existir uma entrada na **lista** `install.programs_dir` com o path deste `programs` (absoluto ou com `~`). O mesmo formato serve para apontar para outras pastas noutros repositórios.

```yaml
install:
  programs_dir:
    - "~/Projects/substitui-pelo-caminho-do-clone/programs"
    - "~/Projects/outro-repo/outros-programs"
```

## Estrutura

- Um **subdiretório por SO** (ex.: `ubuntu/`), como no menu «Selecionar Sistema Operacional».
- Dentro de cada SO, ficheiros **`*.sh`** numerados se quiseres ordenação (ex.: `01-curl.sh`); o prefixo numérico é removido só no texto do menu.

Os scripts costumam correr com **`sudo sh …`** (o Worker Boss pede a password quando necessário).

É preciso **yq** no PATH. Se houver **várias** pastas da lista com scripts `.sh`, o Worker Boss pergunta qual queres usar antes de listar SO/scripts.

Para a opção aparecer no menu, pelo menos uma pasta da lista tem de existir e conter **pelo menos um** `.sh` (em qualquer subpasta de SO).
