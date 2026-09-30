"""Encode the base NR RRC establishment subset with actual ASN.1 UPER.

NAS is an opaque teaching payload; core registration is not executed.
"""
import argparse
import importlib.metadata
import json
from pathlib import Path
from pycrate_asn1dir import RRCNR

M = RRCNR.NR_RRC_Definitions

def fixtures():
    cg = M.CellGroupConfig
    cg.set_val({'cellGroupId': 0, 'rlc-BearerToAddModList': [
        {'logicalChannelIdentity': 1, 'servedRadioBearer': ('srb-Identity', 1)}]})
    cell = cg.to_uper()
    return {
        'request': ('UL_CCCH_Message', {'message': ('c1', ('rrcSetupRequest', {
            'rrcSetupRequest': {'ue-Identity': ('randomValue', (0x123456789, 39)),
                                'establishmentCause': 'mo-Signalling', 'spare': (0, 1)}}))}),
        'setup': ('DL_CCCH_Message', {'message': ('c1', ('rrcSetup', {
            'rrc-TransactionIdentifier': 1, 'criticalExtensions': ('rrcSetup', {
                'radioBearerConfig': {'srb-ToAddModList': [{'srb-Identity': 1}]},
                'masterCellGroup': cell})}))}),
        'complete': ('UL_DCCH_Message', {'message': ('c1', ('rrcSetupComplete', {
            'rrc-TransactionIdentifier': 1, 'criticalExtensions': ('rrcSetupComplete', {
                'selectedPLMN-Identity': 1, 'dedicatedNAS-Message': b'UNI08-OPAQUE-NAS'})}))})}

def encode_all():
    result = {'codec': 'pycrate', 'version': importlib.metadata.version('pycrate'),
              'nasBoundary': 'Opaque bytes carried only; no NAS parser, authentication or session',
              'messages': {}}
    for name, (schema, val) in fixtures().items():
        obj = getattr(M, schema); obj.set_val(val); raw = obj.to_uper()
        obj.from_uper(raw); assert obj.to_uper() == raw
        result['messages'][name] = {'schema': schema, 'hex': raw.hex(),
             'bits': [int(b) for v in raw for b in f'{v:08b}'],
             'decoded': repr(obj.get_val()), 'roundTrip': True}
    assert len(result['messages']['request']['bits']) == 48
    return result

if __name__ == '__main__':
    p = argparse.ArgumentParser(); p.add_argument('mode', choices=['fixture','verify']);
    p.add_argument('output'); p.add_argument('--input'); args = p.parse_args()
    if args.mode == 'fixture':
        result = encode_all()
    else:
        recovered = json.loads(Path(args.input).read_text())
        result = {'verified': {}}
        expected = encode_all()['messages']
        for name, values in recovered.items():
            bits = ''.join(str(int(v)) for v in values)
            raw = bytes(int(bits[k:k+8],2) for k in range(0,len(bits),8))
            obj = getattr(M, expected[name]['schema']); obj.from_uper(raw)
            assert obj.to_uper().hex() == expected[name]['hex']
            result['verified'][name] = {'bitEquality': True, 'decoded': repr(obj.get_val())}
    Path(args.output).write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({'mode':args.mode,'passed':True}))
