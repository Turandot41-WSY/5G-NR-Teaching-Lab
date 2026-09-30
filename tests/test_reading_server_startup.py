"""Repeated commands use one reading server and one build."""
from contextlib import ExitStack
from pathlib import Path
import socket
import sys
import tempfile
import unittest
from unittest.mock import patch
from urllib.error import HTTPError
from urllib.request import urlopen

from test_reference_startup import load


class ReadingServerStartupTests(unittest.TestCase):
    def environment(self, module, root, port):
        stack = ExitStack()
        stack.enter_context(patch.multiple(module, ROOT=root, SITE=root/'site'))
        stack.enter_context(patch.object(sys, 'argv', ['publish_site.py','serve','--no-browser','--port',str(port)]))
        stack.enter_context(patch.object(module, 'python_executable', return_value=Path(sys.executable)))
        stack.enter_context(patch.object(module, 'prepare_environment'))
        stack.enter_context(patch.object(module, 'ensure_dependencies'))
        return stack

    def test_repeated_start_reuses_same_project_without_build(self):
        module = load('publish_site')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            with self.environment(module, root, 0):
                server = module.serve(0)
                server.ready = True
                try:
                    with patch.object(sys, 'argv', ['publish_site.py','--no-browser','--port',str(server.server_port)]), \
                         patch.object(module, 'build') as build:
                        self.assertEqual(module.main(), 0)
                        build.assert_not_called()
                finally:
                    server.shutdown(); server.server_close()

    def test_different_project_is_not_reused_or_rebuilt(self):
        module = load('publish_site')
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            with self.environment(module, root/'first', 0):
                server=module.serve(0)
                server.ready=True
                try:
                    with self.environment(module, root/'second', server.server_port), \
                         patch.object(module, 'build') as build:
                        self.assertEqual(module.main(), 1)
                        build.assert_not_called()
                finally:
                    server.shutdown(); server.server_close()

    def test_preparing_server_is_reused_without_second_build(self):
        module=load('publish_site')
        with tempfile.TemporaryDirectory() as directory:
            with self.environment(module, Path(directory), 0):
                server=module.serve(0)
                server.ready=False
                try:
                    with patch.object(sys, 'argv', ['publish_site.py','--no-browser','--port',str(server.server_port)]), \
                         patch.object(module, 'build') as build:
                        self.assertEqual(module.main(), 0)
                        build.assert_not_called()
                finally:
                    server.shutdown(); server.server_close()

    def test_port_is_reserved_and_pages_blocked_until_build_succeeds(self):
        module=load('publish_site')
        real_serve=module.serve
        servers=[]
        def serve(port):
            server=real_serve(port); servers.append(server); return server
        def failed_build(validate):
            self.assertEqual(len(servers),1, 'Reserve the port before starting a build')
            url=f'http://127.0.0.1:{servers[0].server_port}'
            with self.assertRaises(HTTPError) as error:
                urlopen(url+'/index.html',timeout=2)
            self.assertEqual(error.exception.code,503)
            return False
        with tempfile.TemporaryDirectory() as directory:
            with self.environment(module, Path(directory), 0), \
                 patch.object(module, 'serve', side_effect=serve), \
                 patch.object(module, 'build', side_effect=failed_build):
                self.assertEqual(module.main(),1)
            self.assertEqual(servers[0].socket.fileno(),-1,'Failed startup must release its socket')

    def test_unrelated_listener_gets_short_error_before_build(self):
        module=load('publish_site')
        with socket.socket() as occupied, tempfile.TemporaryDirectory() as directory:
            occupied.bind(('127.0.0.1',0)); occupied.listen()
            with self.environment(module, Path(directory), occupied.getsockname()[1]), \
                 patch.object(module, 'build') as build:
                self.assertEqual(module.main(),1)
                build.assert_not_called()


if __name__=='__main__':
    unittest.main()
