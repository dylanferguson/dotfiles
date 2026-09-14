# Obsidian vault backups

Hourly snapshots, one directory per vault. Settings and plugins are included;
workspace files, cache, trash, `.git` directories and iCloud placeholders are
excluded. [Setup and operation](https://github.com/dylanferguson/dotfiles/tree/main/obsidian).

## Restore

Clone outside iCloud and the backup working directory. Verify recovered notes
and attachments before copying them into a live vault.

```sh
brew install git-lfs
git lfs install
git clone git@github.com:dylanferguson/obsidian-vaults.git obsidian-restore
cd obsidian-restore
git lfs pull
```

Recover a deleted note (replace the example path and commit):

```sh
git log --oneline --diff-filter=D -- 'Obsidian/notes/Some Note.md'
git restore --source='<deletion-commit>^' -- 'Obsidian/notes/Some Note.md'
```

Or open a past snapshot:

```sh
git log --oneline
git switch --detach <commit>
git lfs pull
```
