"""Submit a real code cell to the local Jupyter MATLAB kernel and save its output."""
import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import time
import uuid
import requests
import websocket


class MatlabSession:
    def __init__(self, state):
        self.state = state
        self.http = requests.Session()
        self.http.headers['Authorization'] = 'token ' + state['token']
        r = self.http.post(state['url'] + '/api/kernels', json={'name':'jupyter_matlab_kernel'}, timeout=30)
        r.raise_for_status()
        self.kernel = r.json()['id']
        self.session = str(uuid.uuid4())
        self.ws = websocket.create_connection(state['url'].replace('http:', 'ws:') + '/api/kernels/' + self.kernel + '/channels',
            header={'Authorization':'token ' + state['token']}, origin=state['url'], timeout=180)

    def execute(self, code, timeout=180):
        message_id = str(uuid.uuid4())
        self.ws.send(json.dumps({'header':{'msg_id':message_id,'username':'student','session':self.session,
            'date':datetime.now(timezone.utc).isoformat(),'msg_type':'execute_request','version':'5.3'},
            'parent_header':{},'metadata':{},'channel':'shell',
            'content':{'code':code,'silent':False,'store_history':True,'user_expressions':{},'allow_stdin':False,'stop_on_error':True}}))
        messages = []
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            self.ws.settimeout(max(1, deadline-time.monotonic()))
            m = json.loads(self.ws.recv())
            if m.get('parent_header', {}).get('msg_id') != message_id:
                continue
            messages.append(m)
            if m['header']['msg_type'] == 'status' and m['content']['execution_state'] == 'idle':
                return messages
        raise TimeoutError('MATLAB cell timed out')

    def close(self):
        self.ws.close()
        self.http.delete(self.state['url'] + '/api/kernels/' + self.kernel, timeout=30).raise_for_status()


def main():
    p = argparse.ArgumentParser()
    p.add_argument('state', type=Path)
    p.add_argument('--code', default="disp(version); disp(2+2);")
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    session = MatlabSession(json.loads(args.state.read_text()))
    try:
        messages = session.execute(args.code)
        args.output.write_text(json.dumps(messages, indent=2))
        for m in messages:
            c = m['content']
            print(m['header']['msg_type'], c.get('text', c.get('evalue', list(c.get('data', {})))))
    finally:
        session.close()


if __name__ == '__main__':
    main()
