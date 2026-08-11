set shell := ["bash", "-euo", "pipefail", "-c"]

repo := justfile_directory()
source := repo + "/.agents/skills"
target := env_var_or_default("SKILLS_TARGET", env_var("HOME") + "/.agents/skills")

# Show available commands.
default:
    @just --list

# Verify that the source skills directory is present.
check:
    @test -d "{{source}}" || { echo "error: {{source}} does not exist" >&2; exit 1; }
    @echo "Skills directory is ready."

# Link the skills directory into SKILLS_TARGET (default: ~/.agents/skills).
install: check
    @mkdir -p "$(dirname "{{target}}")"
    @if test -L "{{target}}"; then link=$(readlink "{{target}}"); if test "$link" = "{{source}}"; then echo "Already installed: {{target}}"; exit 0; fi; echo "error: {{target}} links to $link" >&2; exit 1; elif test -e "{{target}}"; then echo "error: {{target}} already exists and is not a symlink" >&2; exit 1; fi; ln -s "{{source}}" "{{target}}"; echo "Linked {{target}} -> {{source}}"

# Preview the link without changing it.
dry-run: check
    @echo "LINK: {{target}} -> {{source}}"

# Replace this repository's current skills link.
relink: check
    @if test -L "{{target}}"; then link=$(readlink "{{target}}"); if test "$link" = "{{source}}"; then rm "{{target}}"; else echo "error: refusing to replace {{target}} -> $link" >&2; exit 1; fi; elif test -e "{{target}}"; then echo "error: {{target}} exists and is not a symlink" >&2; exit 1; fi
    @mkdir -p "$(dirname "{{target}}")"
    @ln -s "{{source}}" "{{target}}"
    @echo "Linked {{target}} -> {{source}}"

# Remove this repository's skills link.
uninstall:
    @if test -L "{{target}}"; then link=$(readlink "{{target}}"); if test "$link" = "{{source}}"; then rm "{{target}}"; echo "Removed {{target}}"; else echo "error: refusing to remove {{target}} -> $link" >&2; exit 1; fi; elif test -e "{{target}}"; then echo "error: {{target}} exists and is not a symlink" >&2; exit 1; else echo "Nothing to uninstall."; fi
