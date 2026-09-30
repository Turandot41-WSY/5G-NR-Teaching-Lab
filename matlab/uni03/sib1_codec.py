"""Actual BCCH-DL-SCH UPER encode/decode using pycrate 0.8.1.

The fixture is a local teaching cell; no captured network identity is used.
The pycrate schema revision is recorded separately from the frozen 3GPP
normative edition. Only base SIB1 IEs are used; no Release 18 extension claim.
"""
import argparse
import importlib.metadata
import json
from pathlib import Path
from pycrate_asn1dir import RRCNR


def fixture():
    generic = {'locationAndBandwidth': 275 * 23, 'subcarrierSpacing': 'kHz30'}
    rach = {'rach-ConfigGeneric': {'prach-ConfigurationIndex': 0, 'msg1-FDM': 'one',
            'msg1-FrequencyStart': 0, 'zeroCorrelationZoneConfig': 0,
            'preambleReceivedTargetPower': -100, 'preambleTransMax': 'n10',
            'powerRampingStep': 'dB2', 'ra-ResponseWindow': 'sl20'},
            'ra-ContentionResolutionTimer': 'sf64',
            'prach-RootSequenceIndex': ('l839', 22),
            'restrictedSetConfig': 'unrestrictedSet'}
    common = {
        'downlinkConfigCommon': {
            'frequencyInfoDL': {'frequencyBandList': [{'freqBandIndicatorNR': 78}],
                'offsetToPointA': 8, 'scs-SpecificCarrierList': [
                    {'offsetToCarrier': 0, 'subcarrierSpacing': 'kHz30', 'carrierBandwidth': 51}]},
            'initialDownlinkBWP': {'genericParameters': {**generic, 'locationAndBandwidth': 275*23+4}},
            'bcch-Config': {'modificationPeriodCoeff': 'n2'},
            'pcch-Config': {'defaultPagingCycle': 'rf128', 'nAndPagingFrameOffset': ('oneT', 0), 'ns': 'one'}},
        'uplinkConfigCommon': {
            'frequencyInfoUL': {'scs-SpecificCarrierList': [
                {'offsetToCarrier': 0, 'subcarrierSpacing': 'kHz30', 'carrierBandwidth': 51}]},
            'initialUplinkBWP': {'genericParameters': generic, 'rach-ConfigCommon': ('setup', rach)},
            'timeAlignmentTimerCommon': 'ms10240'},
        'ssb-PositionsInBurst': {'inOneGroup': (128, 8)},
        'ssb-PeriodicityServingCell': 'ms20',
        'tdd-UL-DL-ConfigurationCommon': {'referenceSubcarrierSpacing': 'kHz30',
            'pattern1': {'dl-UL-TransmissionPeriodicity': 'ms5', 'nrofDownlinkSlots': 4,
            'nrofDownlinkSymbols': 0, 'nrofUplinkSlots': 5, 'nrofUplinkSymbols': 0}},
        'ss-PBCH-BlockPower': -10}
    return {'message': ('c1', ('systemInformationBlockType1', {
        'cellSelectionInfo': {'q-RxLevMin': -65},
        'cellAccessRelatedInfo': {'plmn-IdentityInfoList': [{
            'plmn-IdentityList': [{'mcc': [0,0,1], 'mnc': [0,1]}],
            'trackingAreaCode': (1,24), 'cellIdentity': (321,36),
            'cellReservedForOperatorUse': 'notReserved'}]},
        'servingCellConfigCommon': common}))}


def decode(data):
    obj = RRCNR.NR_RRC_Definitions.BCCH_DL_SCH_Message
    obj.from_uper(data)
    val = obj.get_val()
    assert val['message'][0] == 'c1'
    assert val['message'][1][0] == 'systemInformationBlockType1'
    sib = val['message'][1][1]
    common = sib['servingCellConfigCommon']
    ra = common['uplinkConfigCommon']['initialUplinkBWP']['rach-ConfigCommon'][1]
    return {'codec': 'pycrate', 'version': importlib.metadata.version('pycrate'),
            'message': val, 'randomAccess': ra, 'common': common,
            'canonicalHex': obj.to_uper().hex()}


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('mode', choices=['fixture', 'decode'])
    ap.add_argument('output')
    ap.add_argument('--input')
    args = ap.parse_args()
    if args.mode == 'fixture':
        obj = RRCNR.NR_RRC_Definitions.BCCH_DL_SCH_Message
        obj.set_val(fixture())
        data = obj.to_uper()
        result = decode(data)
        assert result['message'] == fixture()
        result['hex'] = data.hex()
        result['bits'] = [int(b) for byte in data for b in f'{byte:08b}']
    else:
        bits = json.loads(Path(args.input).read_text())
        data = bytes(int(''.join(str(int(b)) for b in bits[i:i+8]),2)
                     for i in range(0, len(bits)//8*8, 8))
        result = decode(data)
    Path(args.output).write_text(json.dumps(result, indent=2)+'\n')
    print(f'UPER {args.mode} passed; {len(data)} bytes; pycrate {result["version"]}')
