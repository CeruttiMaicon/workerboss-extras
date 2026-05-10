# Scripts de instalação de programas (ZshMap)

O ZshMap usa os `.sh` desta pasta **quando** no **`~/.zshmap.yml`** existir uma entrada na **lista** `install.programs_dir` com o path deste `programs` (absoluto ou com `~`). O mesmo formato serve para outras pastas noutros repositórios.

```yaml
install:
  programs_dir:
    - "~/Projects/substitui-pelo-caminho-do-clone/programs"
    - "~/Projects/outro-repo/outros-programs"
```

## Estrutura

- Um **subdiretório por SO** (ex.: `ubuntu/`).
- Ficheiros **`*.sh`** por SO; prefixo numérico opcional para ordenação no menu.

Os scripts costumam correr com **`sudo sh …`** (o ZshMap pede a password quando necessário).

É preciso **yq** no PATH. Se houver **várias** pastas da lista com `.sh`, o ZshMap pergunta qual usar antes de listar SO/scripts.

Para a opção aparecer no menu, pelo menos uma pasta da lista tem de existir e conter **pelo menos um** `.sh`.
