function run_uni08
% Complete ordered teaching access subset. Actual waveforms and message bytes;
% Explicit control resources; selected PDCCH/PUCCH waveforms and SRB headers.
base=fileparts(mfilename('fullpath'));addpath(base,fullfile(base,'..','uni03'),fullfile(base,'..','uni04'));
uni03_setup; out=fullfile(base,'results');if ~isfolder(out),mkdir(out);end
diary(fullfile(out,'run.log'));clean=onCleanup(@()diary('off')); %#ok<NASGU>
test_uni08; test_uni08_control; seed=2026090801;rng(seed,'twister');started=tic;
py=course_python; codec=fullfile(base,'rrc_codec.py');
[status,msg]=system(sprintf('"%s" "%s" fixture "%s"',py,codec,fullfile(base,'rrc-fixtures.json')));disp(msg);assert(status==0);
rrc=jsondecode(fileread(fullfile(base,'rrc-fixtures.json')));
t=uni03_tx; delay=19;cfo=3400;snrDB=20;
w=[zeros(delay,1);t.waveform;zeros(256,1)]; n=(0:numel(w)-1)';
w=w.*exp(1i*2*pi*cfo*n/t.sampleRate);
w=w+sqrt(1/(2*t.ofdmInfo.Nfft*10^(snrDB/10)))*complex(randn(size(w)),randn(size(w)));
a=t.config.receiver;a.sampleRate=t.sampleRate;m=uni01_rx(w,a);assert(~m.crcError);
frameStart=m.ssbStartSample-sum(t.ofdmInfo.SymbolLengths(1:2));
grid=nrOFDMDemodulate(m.correctedWaveform(frameStart+1:end),28,30,0,'SampleRate',t.sampleRate);
broadcast=uni03_receive(m,grid,struct); assert(~broadcast.transportCRC && ~broadcast.dciCRC);
writeJSON(fullfile(out,'sib1-bits.json'),broadcast.transportBits);
[status,msg]=system(sprintf('"%s" "%s" decode "%s" --input "%s"',py, ...
 fullfile(base,'..','uni03','sib1_codec.py'),fullfile(out,'sib1-decoded.json'),fullfile(out,'sib1-bits.json')));disp(msg);assert(status==0);
sib=jsondecode(fileread(fullfile(out,'sib1-decoded.json')));
ra=sib.randomAccess;g=ra.rach_ConfigGeneric;
assert(g.prach_ConfigurationIndex==0 && g.zeroCorrelationZoneConfig==0);
rootSequence=ra.prach_RootSequenceIndex{2};assert(rootSequence==22);
dlRIV=sib.common.downlinkConfigCommon.initialDownlinkBWP.genericParameters.locationAndBandwidth;
ulRIV=sib.common.uplinkConfigCommon.initialUplinkBWP.genericParameters.locationAndBandwidth;
assert(dlRIV==275*23+4 && ulRIV==275*23);
pattern=sib.common.tdd_UL_DL_ConfigurationCommon.pattern1;
assert(pattern.nrofDownlinkSlots==4 && pattern.nrofUplinkSlots==5 && strcmp(pattern.dl_UL_TransmissionPeriodicity,'ms5'));
carrier=nrCarrierConfig(NSizeGrid=24,SubcarrierSpacing=30,NCellID=m.cellID);
p=nrPRACHConfig(FrequencyRange='FR1',DuplexMode='TDD',ConfigurationIndex=g.prach_ConfigurationIndex, ...
    SubcarrierSpacing=1.25,SequenceIndex=rootSequence,ZeroCorrelationZone=g.zeroCorrelationZoneConfig);
% nrPRACH long-format calendar uses absolute1ms NPRACHSlot. Anchor to recovered SFN.
for absoluteMS=m.systemFrameNumber*10+(1:160)
    p.NPRACHSlot=absoluteMS;
    if ~isempty(nrPRACH(carrier,p)),break;end
end
prachTimeMS=absoluteMS-m.systemFrameNumber*10;
assert(prachTimeMS==79,'Recovered SFN426 must await SFN433/subframe9.');
rarSlot=(prachTimeMS+1)*2+1; % Next allowed DL slot plus one slot margin.
raRNTI=1+p.SymbolLocation+14*mod(absoluteMS,10)+14*80*p.FrequencyIndex;
assert(raRNTI==127);
pg=nrPRACHGrid(carrier,p);pg(nrPRACHIndices(carrier,p))=nrPRACH(carrier,p);
[prach,pinfo]=nrPRACHOFDMModulate(carrier,p,pg,Windowing=0);assert(any(prach));
arrival=321;prx=[zeros(arrival,1);prach];
[index,offset]=nrPRACHDetect(carrier,p,prx);assert(index==0 && abs(offset-arrival)<.51);
ta=uni04_ta(offset,pinfo.SampleRate,1,0);
assert(ta.command==80 && ta.advanceSamples==320 && ta.residualSamples==1);
rarBits=uni08_rar('encode',struct('rapid',index,'ta',ta.command,'rnti',4660,'riv',264,'td',0,'mcs',4,'tpc',3));
controls.rar=uni08_control("RAR",struct('rnti',raRNTI,'slot',rarSlot,'seed',80801));
assert(controls.rar.crc==0 && isequal(controls.rar.prbs,0:11));
assert(controls.rar.fields.mcs==4 && controls.rar.fields.td==0 && controls.rar.fields.scaling==0);
packets=cell(1,6);packets{1}=uni08_packet("DL",rarBits,20,0,raRNTI,controls.rar.prbs,rarSlot);assert(~packets{1}.crc);
rar=uni08_rar('decode',packets{1}.payload);assert(rar.rapid==index);
% 24RB BWP: RIV264 -> start0,length12; default row1 -> k2=1,Delta=3.
assert(rar.hop==0 && rar.riv==264 && rar.td==0 && rar.mcs==4);
msg3slot=rarSlot+1+3;assert(mod(msg3slot,10)>=5);
bits8=@(x) int8(dec2bin(x,8)'-'0');
req=int8(rrc.messages.request.bits(:)); setup=int8(rrc.messages.setup.bits(:));complete=int8(rrc.messages.complete.bits(:));
msg3=[bits8(52);req];
packets{2}=uni08_packet("UL",msg3,20,arrival-ta.advanceSamples,rar.rnti,0:11,msg3slot);
assert(~packets{2}.crc && isequal(packets{2}.payload,msg3)); recovered.request=packets{2}.payload(9:56);
% Contention identity is the first48bits of the decoded CCCH SDU.
identity=recovered.request; msg4=[bits8(62);identity;bits8(0);bits8(numel(setup)/8);setup];
controls.msg4=uni08_control("MSG4",struct('rnti',rar.rnti,'slot',rarSlot+9,'seed',80802));
assert(controls.msg4.crc==0 && controls.msg4.fields.mcs==4 && controls.msg4.fields.td==0);
assert(controls.msg4.fields.rv==0 && controls.msg4.fields.ndi==1);
packets{3}=uni08_packet("DL",msg4,20,0,rar.rnti,controls.msg4.prbs,rarSlot+9);
assert(~packets{3}.crc && isequal(packets{3}.payload(9:56),req));
recovered.setup=packets{3}.payload(73:end);
controls.ack=uni08_control("ACK",struct('slot',controls.msg4.feedbackSlot,'ack',1,'seed',80803));
assert(controls.ack.detected && controls.ack.rxACK==1 && controls.ack.slot==rarSlot+14);
% SRB1 subset: complete RLC AM PDU(SN0), PDCP SRB SN0, unprotected MAC-I zeros.
pdcp=[bits8(0);bits8(0);complete;zeros(32,1,'int8')];rlc=[bits8(128);bits8(0);pdcp];
msg5=[bits8(1);bits8(numel(rlc)/8);rlc];
packets{4}=uni08_packet("UL",msg5,20,1,rar.rnti,0:11,rarSlot+15);
assert(~packets{4}.crc);recovered.complete=packets{4}.payload(49:end-32);
writeJSON(fullfile(out,'rrc-recovered-bits.json'),recovered);
[status,msg]=system(sprintf('"%s" "%s" verify "%s" --input "%s"',py,codec, ...
 fullfile(out,'rrc-decoded.json'),fullfile(out,'rrc-recovered-bits.json')));disp(msg);assert(status==0);
% Transport test payloads after connection, not a user-plane PDU session.
dl=int8(randi([0 1],256,1));ul=int8(randi([0 1],256,1));
packets{5}=uni08_packet("DL",dl,20,0,rar.rnti,0:11,rarSlot+19);
packets{6}=uni08_packet("UL",ul,20,1,rar.rnti,0:11,rarSlot+24);
assert(all(cellfun(@(r)r.crc==0 && r.bitErrors==0,packets)));
names=["RAR" "Msg3 RRCSetupRequest" "Msg4 RRCSetup" "RRCSetupComplete" "First DL test block" "First UL test block"];
slots=rarSlot+[0 4 9 15 19 24];types=["DL" "UL" "DL" "UL" "DL" "UL"];
for k=1:6
    pos=mod(slots(k),10);assert((types(k)=="DL" && pos<4)||(types(k)=="UL" && pos>=5));
end
% Procedural event model checks actual decoder outcomes before each transition.
cases=["success" "missing RAR" "wrong RAPID" "Msg3 CRC failure" "wrong contention identity" "SetupComplete transaction mismatch" "SetupComplete CRC failure"];
terminal=["CONNECTED_AND_BIDIRECTIONAL" "RAR_WINDOW_EXPIRED" "RAR_WINDOW_EXPIRED" "CONTENTION_TIMER_EXPIRED" "CONTENTION_TIMER_EXPIRED" "GNB_AWAITS_MATCHING_COMPLETE" "GNB_AWAITS_COMPLETE"];
atMs=[(slots(6)+1)*.5 slots(1)*.5+10 slots(1)*.5+10 (slots(2)+1)*.5+64 (slots(2)+1)*.5+64 (slots(4)+1)*.5 (slots(4)+1)*.5];
states=uni08_states(packets,rar,req,recovered,slots,'success'); assert(states.connected && states.firstDL && states.firstUL);
failureChecks=false(7,1);failureChecks(1)=true;
for k=2:7
    z=uni08_states(packets,rar,req,recovered,slots,char(cases(k)));failureChecks(k)=~z.connected;
end
assert(all(failureChecks));
failures=table(cases',terminal',atMs',failureChecks,'VariableNames',{'scenario','terminal','observationTimeMs','passed'});
events=table(names',slots',slots'*.5,types',cellfun(@(r)r.tbs,packets)', ...
 cellfun(@(r)r.crc,packets)',cellfun(@(r)r.evm,packets)', ...
 'VariableNames',{'stage','slot','timeMs','direction','tbs','crcFailure','evmPercent'});
% Conditional data transport sweep after successful access; twenty pairs/SNR.
rows=cell(120,1);serial=0;
for sn=[-5 0 5 10 15 20]
 for trial=1:20
  serial=serial+1;rng(seed+10000+serial,'twister');payload=int8(randi([0 1],256,1));
  rd=uni08_packet("DL",payload,sn,0,4660,0:11,slots(5));ru=uni08_packet("UL",payload,sn,1,4660,0:11,slots(6));
  rows{serial}=table(sn,trial,seed+10000+serial,rd.crc,ru.crc,rd.evm,ru.evm, ...
      'VariableNames',{'snrDB','trial','seed','dlCRC','ulCRC','dlEVM','ulEVM'});
 end
end
trials=vertcat(rows{:}); software=ver;elapsed=toc(started);
writetable(events,fullfile(out,'events.csv'));writetable(failures,fullfile(out,'failures.csv'));writetable(trials,fullfile(out,'trials.csv'));
save(fullfile(out,'run.mat'),'t','m','w','grid','broadcast','sib','prach','prx','pinfo','pg','p','ta','rar','rrc', ...
 'packets','controls','raRNTI','names','slots','events','failures','trials','states','seed','software','elapsed','prachTimeMS','-v7.3');
writeJSON(fullfile(out,'summary.json'),struct('seed',seed,'elapsedSeconds',elapsed,'events',table2struct(events), ...
 'failures',table2struct(failures),'software',software,'connectedSubset',states.connected, ...
 'controlBoundary','Actual RAR/Msg4 PDCCH and PUCCH ACK with explicit resource configuration and separate burst captures; later UL/data grants supplied directly', ...
 'rrcBoundary','UPER messages carried and decoded; basic SRB1 header fixture; no general RLC/PDCP engine', ...
 'coreBoundary','Opaque NAS bytes only; test transport blocks not DRB application traffic'));
uni08_plots;uni_lab_provenance(base);disp(events);disp(failures);fprintf('PASS: ordered access subset and120conditional transport pairs;%.2fs\n',elapsed);
end

function writeJSON(file,x)
f=fopen(file,'w');c=onCleanup(@()fclose(f));fwrite(f,jsonencode(x,'PrettyPrint',true));
end
