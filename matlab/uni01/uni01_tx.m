function t=uni01_tx(c)
% Generate a formatted BCCH-BCH-Message and one SS/PBCH block.
% Normative maps: TS38.211 7.3.3,7.4.1.4,7.4.2,7.4.3;
% BCH: TS38.212 7.1; MIB fields: TS38.331 6.2.1/6.2.2.
assert(c.ssbIndex==0 && c.Lmax==8 && c.firstSsbSymbol==2 && c.halfFrame==0 && c.subcarrierSpacing==30, ...
    'uni01:UnsupportedFixture','This pilot transmitter implements Case C index 0, Lmax 8, first half-frame only.');
bits=@(v,n) int8(dec2bin(v,n)'-'0');
t.mibBits=[int8(0);bits(floor(c.systemFrameNumber/16),6); ...
    int8(c.mibSubcarrierSpacingCommon==30);bits(mod(c.kSsb,16),4); ...
    int8(c.dmrsTypeAPosition==3);bits(c.pdcchConfigSib1,8); ...
    int8([1;0;0])]; % notBarred, intra-frequency allowed, spare
assert(numel(t.mibBits)==24);
t.codedBits=nrBCH(t.mibBits,c.systemFrameNumber,c.halfFrame, ...
    c.Lmax,c.kSsb,c.cellID);
t.ssb=zeros(240,4);
t.labels=zeros(240,4);
t.pssIndices=nrPSSIndices;
t.sssIndices=nrSSSIndices;
t.dmrsIndices=nrPBCHDMRSIndices(c.cellID);
t.pbchIndices=nrPBCHIndices(c.cellID);
t.ssb(t.pssIndices)=nrPSS(mod(c.cellID,3)); t.labels(t.pssIndices)=1;
t.ssb(t.sssIndices)=nrSSS(c.cellID); t.labels(t.sssIndices)=2;
t.ssb(t.dmrsIndices)=nrPBCHDMRS(c.cellID,c.ssbIndex); t.labels(t.dmrsIndices)=3;
t.pbchSymbols=nrPBCH(t.codedBits,c.cellID,mod(c.ssbIndex,8)); % three LSBs for Lmax=8
t.ssb(t.pbchIndices)=t.pbchSymbols; t.labels(t.pbchIndices)=4;
carrier=nrCarrierConfig('NSizeGrid',c.captureResourceBlocks, ...
    'SubcarrierSpacing',c.subcarrierSpacing,'NCellID',c.cellID);
t.grid=nrResourceGrid(carrier);
first=(size(t.grid,1)-240)/2+1;
t.grid(first:first+239,c.firstSsbSymbol+(1:4))=t.ssb;
[t.waveform,info]=nrOFDMModulate(carrier,t.grid,'Windowing',0);
t.sampleRate=info.SampleRate;
t.nfft=info.Nfft;
t.ofdmInfo=info;
t.ssbStartSample=sum(info.SymbolLengths(1:c.firstSsbSymbol)); % zero-based CP start
t.config=c;
end
