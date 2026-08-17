# .dotfiles

macOS configuration: bash, git, Ghostty, editors, and shared AI agent
instructions. The [Brewfile](Brewfile) is a checklist for setting up the next
machine — what to reinstall, not a manifest this machine is held to.

## Install

First, do a [clean install](https://www.imore.com/how-do-clean-install-macos)

After that:
```shell
sudo softwareupdate -i -a
xcode-select --install
```

Then clone and run. `install.sh` installs Homebrew if it is missing, so this
works on a machine with nothing on it:
```shell
git clone https://github.com/dylanferguson/dotfiles.git $HOME/.dotfiles
$HOME/.dotfiles/bin/install.sh
```

`bin/install.sh` installs the Brewfile, makes the Homebrew bash your login shell,
symlinks every config, then applies `system_defaults.sh`. It is safe to re-run.

Finally:
```shell
sudo reboot
```

A few apps have no cask and need installing by hand. They are listed at the
bottom of the [Brewfile](Brewfile).

## Layout

```
bash/       .bash_profile, .bashrc
git/        .gitconfig, .gitignore_global
macos/      system_defaults.sh
terminal/   ghostty.config, starship.toml
editors/    cursor/, vscode/
agents/     AGENTS.md, skills/, extensions/, claude/
mise/       config.toml
bin/        install.sh, update.sh
```

Every destination:

| Path | Goes to |
| --- | --- |
| `bash/.bash_profile`, `bash/.bashrc` | `~/` |
| `git/.gitconfig`, `git/.gitignore_global` | `~/` |
| `terminal/starship.toml` | `~/.config/` |
| `mise/config.toml` | `~/.config/mise/` |
| `terminal/ghostty.config` | `~/Library/Application Support/com.mitchellh.ghostty/` |
| `editors/cursor/settings.json` | `~/Library/Application Support/Cursor/User/` |
| `editors/vscode/settings.json` | `~/Library/Application Support/Code/User/` |
| `agents/AGENTS.md` | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` |
| `agents/skills` | `~/.claude/skills`, `~/.agents/skills` |
| `agents/extensions` | `~/.pi/agent/extensions` |
| `agents/claude/settings.json` | `~/.claude/settings.json` |

`macos/system_defaults.sh` applies system preferences and is run by
`bin/install.sh`, not symlinked.

## Runtimes

[mise](https://mise.jdx.dev) owns every host-managed runtime — node, bun, go,
rust, hugo — plus the global CLIs that ship on npm, in
[mise/config.toml](mise/config.toml). Projects override it with their own
`mise.toml`, `.tool-versions`, or `.nvmrc`.

Nothing else manages runtimes: Volta and the Homebrew go formula were removed,
and `~/.local/bin` now sits behind the mise shims so a bundled node cannot
shadow the managed one. Check what is in use with `mise ls` and `which node`.

`AGENTS.md` is the single set of agent instructions, shared by every tool.
Cursor has no global path for it — use the `agents-here` alias to link it into
a project.

## Maintenance

```shell
make lint
```
Runs shellcheck over every shell file, using Docker if shellcheck is not
installed. CI runs the same target.

```shell
bin/update.sh
```
Upgrades Homebrew packages and the mise runtimes, then lists anything
installed here that the Brewfile does not mention yet — including apps
installed outside Homebrew. Add what you want on the next machine; ignore the
rest. It does not commit anything.

GUI apps update themselves, and Homebrew leaves their versions alone on
purpose, so `brew upgrade` never fights an app's own updater.
