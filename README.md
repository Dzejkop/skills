# Agent skills

A single repository for agent skills, installed with [GNU Stow](https://www.gnu.org/software/stow/).

## Install

```sh
nix develop
just dry-run
just install
```

Keep each skill in its own directory under `.agents/skills/`, with its manifest at `.agents/skills/<name>/SKILL.md`. Stow links those directories into `~/.agents/skills` by default:

```text
.agents/skills/example/SKILL.md  ->  ~/.agents/skills/example/SKILL.md
```

Use a different destination by setting `SKILLS_TARGET`:

```sh
SKILLS_TARGET="$HOME/.config/my-agent/skills" just install
```

## Commands

- `just check` — verify Stow and the skills directory
- `just dry-run` — preview links without changing them
- `just install` — create skill links
- `just restow` — refresh links after repository changes
- `just uninstall` — remove installed links without deleting source files
