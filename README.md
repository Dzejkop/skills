# Agent skills

A single repository for agent skills, installed as one symbolic link.

## Install

```sh
nix develop
just dry-run
just install
```

Keep each skill in its own directory under `.agents/skills/`, with its manifest at `.agents/skills/<name>/SKILL.md`. Installation creates one directory link:

```text
~/.agents/skills  ->  <repository>/.agents/skills
```

Use a different destination by setting `SKILLS_TARGET`:

```sh
SKILLS_TARGET="$HOME/.config/my-agent/skills" just install
```

## Commands

- `just check` — verify the source skills directory
- `just dry-run` — preview the link without changing it
- `just install` — create the directory link
- `just relink` — replace the directory link
- `just uninstall` — remove the link without deleting source files

The commands refuse to overwrite real directories or symlinks owned by something else.
