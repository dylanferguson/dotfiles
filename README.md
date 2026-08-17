# .dotfiles

macOS configuration: bash, git, Ghostty, editors, and shared AI agent
instructions. Homebrew is the source of truth for packages and apps.

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
$HOME/.dotfiles/install.sh
```

The script installs the Brewfile, makes the Homebrew bash your login shell,
symlinks every config, then applies `system_defaults.sh`. It is safe to re-run.

Finally:
```shell
sudo reboot
```

A few apps have no cask and need installing by hand. They are listed at the
bottom of the [Brewfile](Brewfile).

## Layout

| Path | Goes to |
| --- | --- |
| `.bash_profile`, `.bashrc` | `~/` |
| `.gitconfig`, `.gitignore_global` | `~/` |
| `starship.toml` | `~/.config/` |
| `ghostty.config` | `~/Library/Application Support/com.mitchellh.ghostty/` |
| `cursor/settings.json` | `~/Library/Application Support/Cursor/User/` |
| `vscode/settings.json` | `~/Library/Application Support/Code/User/` |
| `AGENTS.md` | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` |
| `agents/skills` | `~/.claude/skills`, `~/.agents/skills` |
| `agents/extensions` | `~/.pi/agent/extensions` |
| `agents/claude/settings.json` | `~/.claude/settings.json` |

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
./adopt.sh
```
Hands apps you installed by hand over to Homebrew, so `brew bundle` stops
trying to reinstall them. Needed once on a machine that predates the Brewfile.

```shell
./update.sh
```
Upgrades Homebrew, App Store, and npm packages, then reports drift between the
machine and the Brewfile. It does not commit anything — review and commit
Brewfile changes by hand.
