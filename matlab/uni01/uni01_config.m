function c=uni01_config
% Configuration for one unpunctured FR1 Case C SS/PBCH block.
% This is a capture grid, not a complete commercial NR carrier allocation.
c.cellID=321;
c.ssbIndex=0;
c.Lmax=8;
c.subcarrierSpacing=30; % kHz
c.captureResourceBlocks=24;
c.firstSsbSymbol=2; % zero-based: TS38.213 4.1, Case C
c.systemFrameNumber=426;
c.halfFrame=0;
c.kSsb=0;
c.mibSubcarrierSpacingCommon=30;
c.dmrsTypeAPosition=2;
c.pdcchConfigSib1=0;
c.seed=61001;
info=nrOFDMInfo(c.captureResourceBlocks,c.subcarrierSpacing);
c.receiver=struct('subcarrierSpacing',c.subcarrierSpacing, ...
    'sampleRate',info.SampleRate,'Lmax',c.Lmax, ...
    'searchOffsetsHz',(-60:15:60)*1000,'correctFrequency',true);
end
