from pathlib import Path
import subprocess
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1]


class AppTests(unittest.TestCase):
    def test_launcher_rejects_modified_bundled_script(self):
        with tempfile.TemporaryDirectory(prefix='obsidian-app-test-') as directory:
            app = Path(directory) / 'Obsidian Backup.app'
            subprocess.run(['/bin/bash', str(SOURCE / 'build.sh'), str(app), '-'], check=True, capture_output=True)
            launcher = app / 'Contents/MacOS/ObsidianBackup'
            valid = subprocess.run([str(launcher), '--verify'], capture_output=True)
            self.assertEqual(valid.returncode, 0, valid.stderr)
            script = app / 'Contents/Resources/backup.sh'
            script.write_text(script.read_text() + '\n# Modified after signing\n')
            invalid = subprocess.run([str(launcher), '--verify'], capture_output=True)
            self.assertNotEqual(invalid.returncode, 0)


if __name__ == '__main__':
    unittest.main()
