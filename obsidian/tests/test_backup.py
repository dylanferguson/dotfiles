import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1]


class BackupTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='obsidian-test-')
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.cloud = self.root / 'icloud'
        self.base = self.root / 'backup'
        self.repo = self.base / 'repo'
        self.dropbox = self.root / 'dropbox'
        self.env = os.environ | {
            'OBSIDIAN_BACKUP_ICLOUD': str(self.cloud),
            'OBSIDIAN_BACKUP_BASE': str(self.base),
            'OBSIDIAN_BACKUP_DROPBOX': str(self.dropbox),
            'GIT_CONFIG_GLOBAL': '/dev/null',
            'GIT_CONFIG_NOSYSTEM': '1',
        }
        for path in (self.cloud, self.repo, self.dropbox):
            path.mkdir(parents=True)
        self.run_command('git', 'init', '-q', '-b', 'main', str(self.repo))
        self.git('config', 'user.name', 'Backup test')
        self.git('config', 'user.email', 'backup-test@example.invalid')
        self.remote = self.root / 'remote.git'
        self.run_command('git', 'init', '-q', '--bare', str(self.remote))
        self.git('remote', 'add', 'origin', str(self.remote))
        self.put(self.repo / 'README.md', 'Fixture repository\n')
        self.git('add', '-A')
        self.git('commit', '-qm', 'chore: prepare fixture')

    def run_command(self, *args, check=True):
        return subprocess.run(args, env=self.env, capture_output=True, text=True, check=check)

    def git(self, *args):
        return self.run_command('git', '-C', str(self.repo), *args).stdout.strip()

    @staticmethod
    def put(path, text='example\n'):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def vault(self, name='Vault', notes=2, parent=None):
        vault = (parent or self.cloud) / name
        self.put(vault / '.obsidian/app.json', '{}\n')
        for i in range(notes):
            self.put(vault / f'note-{i:03}.md', f'original note {i}\n')
        return vault

    def backup(self):
        return self.run_command('/bin/bash', str(SOURCE / 'backup.sh'), check=False)

    def test_partial_sync_does_not_publish_failed_vault(self):
        broken = self.vault('Broken')
        healthy = self.vault('Healthy')
        self.assertEqual(self.backup().returncode, 0)
        self.put(broken / 'note-000.md', 'new content copied before a later transfer error\n')
        blocked = broken / 'note-001.md'
        self.put(blocked, 'new content that cannot be read\n')
        self.put(healthy / 'note-000.md', 'healthy vault update\n')
        blocked.chmod(0)
        try:
            result = self.backup()
        finally:
            blocked.chmod(0o644)
        self.assertEqual(self.git('show', 'HEAD:Broken/note-000.md'), 'original note 0')
        self.assertEqual((self.repo / 'Broken/note-000.md').read_text(), 'original note 0\n')
        self.assertEqual(self.git('show', 'HEAD:Healthy/note-000.md'), 'healthy vault update')
        self.assertNotEqual(result.returncode, 0)

    def test_push_failure_reports_failure_and_still_mirrors(self):
        self.vault()
        self.git('remote', 'set-url', 'origin', str(self.root / 'missing.git'))
        result = self.backup()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.dropbox / 'Backups/Obsidian/Vault/note-000.md').read_text(), 'original note 0\n')

    def test_evicted_files_are_not_deleted_when_trash_masks_the_count(self):
        vault = self.vault(notes=100)
        self.assertEqual(self.backup().returncode, 0)
        before = self.git('rev-parse', 'HEAD')
        for note in list(vault.glob('*.md'))[:50]:
            note.rename(note.with_name('.' + note.name + '.icloud'))
        for i in range(50):
            self.put(vault / '.trash' / f'deleted-{i}.md')
        result = self.backup()
        self.assertEqual(self.git('rev-parse', 'HEAD'), before)
        self.assertNotEqual(result.returncode, 0)

    def test_duplicate_vault_names_are_rejected_before_any_copy(self):
        self.vault('Notes')
        external = self.vault('Notes', parent=self.root / 'external')
        self.put(external / 'note-000.md', 'different vault\n')
        self.put(self.base / 'vaults.conf', str(external) + '\n')
        before = self.git('rev-parse', 'HEAD')
        result = self.backup()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.git('rev-parse', 'HEAD'), before)
        self.assertFalse((self.repo / 'Notes').exists())

    def test_attic_retains_multiple_replacements_on_the_same_day(self):
        vault = self.vault()
        self.assertEqual(self.backup().returncode, 0)
        self.put(vault / 'note-000.md', 'second version with different size\n')
        self.assertEqual(self.backup().returncode, 0)
        self.put(vault / 'note-000.md', 'third version with another size again\n')
        self.assertEqual(self.backup().returncode, 0)
        attic = self.dropbox / 'Backups/Obsidian-attic'
        versions = {p.read_text() for p in attic.rglob('note-000.md')}
        self.assertEqual(versions, {'original note 0\n', 'second version with different size\n'})

    def test_commit_failure_is_reported_while_dropbox_still_updates(self):
        self.vault()
        hook = self.repo / '.git/hooks/pre-commit'
        self.put(hook, '#!/bin/sh\nexit 1\n')
        hook.chmod(0o755)
        result = self.backup()
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue((self.dropbox / 'Backups/Obsidian/Vault/note-000.md').is_file())

    def test_lfs_backup_works_with_launchd_path(self):
        vault = self.vault()
        self.put(self.repo / '.gitattributes', '*.png filter=lfs diff=lfs merge=lfs -text\n')
        self.git('lfs', 'install', '--local')
        self.put(vault / 'image.png', 'fixture image bytes\n')
        self.env['PATH'] = '/usr/bin:/bin:/usr/sbin:/sbin'
        result = self.backup()
        self.assertEqual(result.returncode, 0, result.stderr)
        pointer = self.git('show', 'HEAD:Vault/image.png')
        self.assertTrue(pointer.startswith('version https://git-lfs.github.com/spec/v1'))
        self.assertEqual(self.run_command('git', '--git-dir', str(self.remote), 'rev-parse', 'main').stdout.strip(), self.git('rev-parse', 'HEAD'))

    def test_dropbox_failure_is_reported_after_git_push(self):
        self.vault()
        self.put(self.dropbox / 'Backups', 'not a directory\n')
        result = self.backup()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.run_command('git', '--git-dir', str(self.remote), 'rev-parse', 'main').stdout.strip(), self.git('rev-parse', 'HEAD'))

    def test_setup_preserves_live_vault_git_configuration(self):
        vault = self.vault()
        names = ('.git', '.gitignore', '.gitattributes')
        for name in names:
            self.put(vault / name, 'existing user configuration\n')
        self.run_command('/bin/bash', str(SOURCE / 'enable.sh'), '--prepare-only')
        for name in names:
            self.assertEqual((vault / name).read_text(), 'existing user configuration\n')

    def test_setup_does_not_snapshot_evicted_files(self):
        vault = self.vault(notes=100)
        self.assertEqual(self.backup().returncode, 0)
        before = self.git('rev-parse', 'HEAD:Vault')
        for note in list(vault.glob('*.md'))[:50]:
            note.rename(note.with_name('.' + note.name + '.icloud'))
        self.run_command('/bin/bash', str(SOURCE / 'enable.sh'), '--prepare-only')
        self.assertEqual(self.git('rev-parse', 'HEAD:Vault'), before)
        self.assertEqual(len(list((self.repo / 'Vault').glob('*.md'))), 100)

    def test_interrupted_replacement_requires_recovery_before_committing(self):
        self.vault()
        self.assertEqual(self.backup().returncode, 0)
        previous = self.base / '.snapshot.interrupted/previous'
        previous.parent.mkdir()
        (self.repo / 'Vault').rename(previous)
        before = self.git('rev-parse', 'HEAD')
        result = self.backup()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.git('rev-parse', 'HEAD'), before)
        self.assertEqual((previous / 'note-000.md').read_text(), 'original note 0\n')


if __name__ == '__main__':
    unittest.main()
