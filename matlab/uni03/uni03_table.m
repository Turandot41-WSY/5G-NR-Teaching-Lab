function q=uni03_table(m)
% Bounded teaching lookup, verified against TS38.213 V18.8.0 Tables13-4/13-11.
assert(~m.crcError,'uni03:MibCRC','BCH CRC must pass before using MIB.');
assert(m.subcarrierSpacingCommon==30 && m.kSsb==0 && m.ssbIndex==0, ...
 'uni03:UnsupportedProfile','This fixture supports Case C 30/30 kHz, kSSB0, SSB0.');
idx=floor(m.pdcchConfigSib1/16); ss=mod(m.pdcchConfigSib1,16);
tab=[24 2 0;24 2 1;24 2 2;24 2 3;24 2 4;24 3 0;24 3 1;24 3 2;24 3 3;24 3 4;48 1 12;48 1 14;48 1 16;48 2 12;48 2 14;48 2 16];
assert(ss==0,'uni03:UnsupportedSearchSpace','Only SearchSpaceZero0 is implemented.');
q=struct('table','13-4','index',idx,'searchSpaceZero',ss,'nrb',tab(idx+1,1), ...
 'duration',tab(idx+1,2),'offsetRB',tab(idx+1,3),'O',0,'M',1,'firstSymbol',0, ...
 'monitorSlots',[0 1],'frameParity',0,'isMonitoringFrame',mod(m.systemFrameNumber,2)==0);
end
