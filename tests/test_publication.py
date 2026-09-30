"""Publication checks use temporary Git repositories and synthetic data."""
import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PublicationTests(unittest.TestCase):
    def setUp(self):
        path = ROOT / 'site/check_publication.py'
        self.assertTrue(path.is_file(), 'Publication checker has not been implemented')
        spec = importlib.util.spec_from_file_location('publication', path)
        self.check = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.check)
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.git('init', '-b', 'main')
        self.git('config', 'user.name', 'Test Author')
        self.git('config', 'user.email', '123+example@users.noreply.github.com')
        (self.root / 'LICENSE').write_text('Example test licence')
        (self.root / '.gitignore').write_text('.env\n')

    def git(self, *args):
        return subprocess.run(['git', *args], cwd=self.root, check=True,
                              capture_output=True, text=True).stdout

    def test_clean_initial_snapshot_and_ignored_files(self):
        (self.root / '.env').write_text('local only')
        (self.root / 'lesson.md').write_text('Public contact: author@example.org')
        self.assertEqual(self.check.audit(self.root), [])

    def test_untracked_private_file_is_blocked(self):
        (self.root / 'scratch.log').write_text('trace')
        self.assertTrue(any('scratch.log' in row for row in self.check.audit(self.root)))

    def test_staged_secret_is_checked_even_after_worktree_cleanup(self):
        secret = 'ghp' + '_' + 'A' * 36
        (self.root / 'settings.py').write_text(secret)
        self.git('add', '.')
        (self.root / 'settings.py').write_text('safe')
        issues = self.check.audit(self.root)
        self.assertTrue(any('index' in row for row in issues))
        self.assertFalse(any(secret in row for row in issues))

    def test_deleted_secret_in_history_is_blocked(self):
        path = self.root / 'old.txt'
        path.write_text('http://localhost:8891/?token=' + 'a' * 30)
        self.git('add', '.')
        self.git('commit', '-m', 'Initial')
        self.git('rm', 'old.txt')
        self.git('commit', '-m', 'Remove')
        self.assertTrue(any('history' in row for row in self.check.audit(self.root)))

    def test_personal_commit_email_is_blocked(self):
        self.git('config', 'user.email', 'private@example.org')
        self.git('add', '.')
        self.git('commit', '-m', 'Initial')
        self.git('config', 'user.email', '123+example@users.noreply.github.com')
        self.assertTrue(any('commit email' in row for row in self.check.audit(self.root)))

    def test_private_current_identity_is_blocked(self):
        self.git('config', 'user.email', 'private@example.org')
        self.assertTrue(any('identity' in row for row in self.check.audit(self.root)))

    def test_local_paths_and_notebook_outputs_are_blocked(self):
        (self.root / 'paths.json').write_text('/' + 'Users' + '/example/private')
        (self.root / 'lab.ipynb').write_text('{"cells":[{"cell_type":"code",'
            '"execution_count":1,"outputs":[{"text":"result"}]}]}')
        issues = self.check.audit(self.root)
        self.assertTrue(any('local path' in row for row in issues))
        self.assertTrue(any('notebook output' in row for row in issues))

    def test_force_added_ignored_pdf_is_blocked(self):
        (self.root / '.gitignore').write_text('*.pdf\n')
        (self.root / 'standard.pdf').write_bytes(b'%PDF-1.7')
        self.git('add', '-f', 'standard.pdf')
        self.assertTrue(any('standard.pdf' in row for row in self.check.audit(self.root)))

    def test_missing_license_is_blocked(self):
        (self.root / 'LICENSE').unlink()
        self.assertTrue(any('LICENSE' in row for row in self.check.audit(self.root)))

    def test_external_symlink_is_blocked(self):
        (self.root / 'linked.txt').symlink_to('/etc/hosts')
        self.assertTrue(any('symlink' in row for row in self.check.audit(self.root)))

    def test_credentials_in_commit_messages_are_blocked(self):
        self.git('add', '.')
        self.git('commit', '-m', 'accidental ' + 'ghp' + '_' + 'B' * 36)
        self.assertTrue(any('commit message' in row for row in self.check.audit(self.root)))

    def test_renamed_excluded_history_path_is_blocked(self):
        (self.root / 'draft.log').write_text('otherwise harmless')
        self.git('add', '.')
        self.git('commit', '-m', 'Initial')
        self.git('mv', 'draft.log', 'safe.txt')
        self.git('commit', '-m', 'Rename')
        self.assertTrue(any('draft.log' in row for row in self.check.audit(self.root)))


if __name__ == '__main__':
    unittest.main()
