set shell := ["bash", "-euo", "pipefail", "-c"]

repo := justfile_directory()
stow_dir := repo + "/.agents"
home := env_var("HOME")
target := env_var_or_default("SKILLS_TARGET", home + "/.agents/skills")

# Show available commands.
default:
    @just --list

# Verify that GNU Stow and the skills package are present.
check:
    @command -v stow >/dev/null || { echo "error: GNU Stow is required; run 'nix develop'" >&2; exit 1; }
    @test -d "{{stow_dir}}/skills" || { echo "error: {{stow_dir}}/skills does not exist" >&2; exit 1; }
    @echo "Stow and the skills package are ready."

# Install skills into SKILLS_TARGET (default: ~/.agents/skills).
install: check
    @mkdir -p "{{target}}"
    stow --dir "{{stow_dir}}" --target "{{target}}" --stow skills

# Preview the links Stow would install.
dry-run: check
    @mkdir -p "{{target}}"
    stow --dir "{{stow_dir}}" --target "{{target}}" --simulate --verbose=2 --stow skills

# Re-link skills after files or directories change.
restow: check
    @mkdir -p "{{target}}"
    stow --dir "{{stow_dir}}" --target "{{target}}" --restow skills

# Remove links installed by Stow, leaving source skills untouched.
uninstall:
    @command -v stow >/dev/null || { echo "error: GNU Stow is required; run 'nix develop'" >&2; exit 1; }
    @if test -d "{{target}}"; then stow --dir "{{stow_dir}}" --target "{{target}}" --delete skills; else echo "Nothing to uninstall: {{target}} does not exist."; fi
