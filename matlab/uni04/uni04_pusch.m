function r=uni04_pusch(carrier,delaySamples,advanceSamples,snrREdB)
% Real UL-SCH and CP-OFDM PUSCH. Compare UE timing advance with no advance.
% Practical receiver: fixed scheduled origin, DM-RS channel/noise estimates.
% delaySamples is used only by the channel; it never selects an FFT window.
pusch=nrPUSCHConfig(PRBSet=0:5,Modulation='QPSK',NumLayers=1, ...
    MappingType='A',SymbolAllocation=[0 14],RNTI=1);
pusch.DMRS.DMRSAdditionalPosition=2;
[dataInd,pinfo]=nrPUSCHIndices(carrier,pusch);
dmrsInd=nrPUSCHDMRSIndices(carrier,pusch);
dmrs=nrPUSCHDMRS(carrier,pusch);
rate=0.48;
tbs=nrTBS(pusch.Modulation,pusch.NumLayers,numel(pusch.PRBSet),pinfo.NREPerPRB,rate);
bits=randi([0 1],tbs,1,'int8');
encoder=nrULSCH(TargetCodeRate=rate);
setTransportBlock(encoder,bits);
codeword=encoder(pusch.Modulation,pusch.NumLayers,pinfo.G,0);
symbols=nrPUSCH(carrier,pusch,codeword);
grid=nrResourceGrid(carrier,1);
grid(dataInd)=symbols; grid(dmrsInd)=dmrs;
[tx,ofdm]=nrOFDMModulate(carrier,grid,Windowing=0);
guard=1024; L=numel(tx);
noiseVariance=1/(ofdm.Nfft*10^(snrREdB/10));
noise=sqrt(noiseVariance/2)*complex(randn(L,1),randn(L,1));
residuals=[delaySamples delaySamples-advanceSamples];
names={'uncorrected','corrected'};
for j=1:2
    residual=residuals(j);
    assert(abs(residual)<guard,'Channel buffer guard exceeded.');
    buffer=[zeros(guard+residual,1);tx;zeros(guard-residual,1)];
    % This crop is constant for every trial, regardless of true delay.
    rx=buffer(guard+(1:L))+noise;
    rxGrid=nrOFDMDemodulate(carrier,rx,CyclicPrefixFraction=0.5);
    [hest,nvest]=nrChannelEstimate(carrier,rxGrid,dmrsInd,dmrs, ...
        CDMLengths=pusch.DMRS.CDMLengths);
    nvest=max(nvest,1e-9);
    [rxData,hData]=nrExtractResources(dataInd,rxGrid,hest);
    [eq,csi]=nrEqualizeMMSE(rxData,hData,nvest);
    llr=nrPUSCHDecode(carrier,pusch,eq,nvest);
    if iscell(llr), llr=llr{1}; end
    llr=llr.*repelem(csi,2);
    decoder=nrULSCHDecoder(TargetCodeRate=rate,TransportBlockLength=tbs, ...
        LDPCDecodingAlgorithm='Normalized min-sum',MaximumLDPCIterationCount=12);
    [decoded,crc]=decoder(llr,pusch.Modulation,pusch.NumLayers,0);
    if iscell(decoded), decoded=decoded{1}; end
    r.([names{j} 'CRC'])=double(crc);
    r.([names{j} 'BitErrors'])=sum(decoded~=bits);
    r.([names{j} 'EVMPercent'])=100*sqrt(mean(abs(eq-symbols).^2)/mean(abs(symbols).^2));
    r.([names{j} 'Symbols'])=eq;
    r.([names{j} 'Waveform'])=rx;
end
r.correctedResidual=residuals(2); r.uncorrectedResidual=residuals(1);
r.transmitSymbols=symbols; r.transmitWaveform=tx;
r.sampleRate=ofdm.SampleRate; r.Nfft=ofdm.Nfft;
r.cyclicPrefixLengths=ofdm.CyclicPrefixLengths(1:14);
r.fftStartSamples=[0 cumsum(ofdm.SymbolLengths(1:13))]+fix(0.5*r.cyclicPrefixLengths);
r.tbs=tbs; r.targetCodeRate=rate; r.snrREdB=snrREdB;
end
