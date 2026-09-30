function r=uni01_rx(w,a)
% Practical acquisition: receiver is not given PCI, CFO, delay or MIB bits.
% Correlation and CP CFO estimation are engineering algorithms, not mandated
% by 3GPP. Reference method: MathWorks NR Cell Search and MIB/SIB1 Recovery.
w=w(:); fs=a.sampleRate; scs=a.subcarrierSpacing;
oi=nrOFDMInfo(20,scs,'SampleRate',fs);
refs=cell(3,1);
for n2=0:2
    g=zeros(240,2); g(nrPSSIndices)=nrPSS(n2);
    % nrPSSIndices refers to column 1; move reference to column 2.
    g(:,2)=g(:,1); g(:,1)=0; refs{n2+1}=g;
end
freqs=a.searchOffsetsHz;
if ~a.correctFrequency, freqs=0; end
scores=zeros(numel(freqs),3); offsets=scores;
n=(0:numel(w)-1)';
for f=1:numel(freqs)
    z=w.*exp(-1i*2*pi*freqs(f)*n/fs);
    for n2=0:2
        [offset,mag]=nrTimingEstimate(z,20,scs,0,refs{n2+1},'SampleRate',fs);
        scores(f,n2+1)=max(mag,[],'all'); offsets(f,n2+1)=offset;
    end
end
[~,best]=max(scores(:)); [fi,pssCandidateIndex]=ind2sub(size(scores),best);
coarse=freqs(fi); n2=pssCandidateIndex-1; offset=offsets(fi,pssCandidateIndex);
z=w.*exp(-1i*2*pi*coarse*n/fs);
ssbStart=offset+oi.SymbolLengths(1);
cp=oi.CyclicPrefixLengths(2); sl=oi.Nfft+cp;
acc=0;
for l=0:3
    idx=ssbStart+l*sl+(5:cp-4); % interior of each normal CP, one-based below
    idx=idx(idx>=0 & idx+oi.Nfft<numel(z))+1;
    acc=acc+sum(conj(z(idx)).*z(idx+oi.Nfft));
end
fine=angle(acc)*fs/(2*pi*oi.Nfft);
if ~a.correctFrequency, fine=0; end
total=coarse+fine;
z=w.*exp(-1i*2*pi*total*n/fs);
[offset,mag]=nrTimingEstimate(z,20,scs,0,refs{pssCandidateIndex},'SampleRate',fs);
grid=nrOFDMDemodulate(z(offset+1:end),20,scs,0,'SampleRate',fs);
if size(grid,2)<5, error('uni01:CaptureShort','Acquired SSB extends beyond capture.'); end
g=grid(:,2:5);
sssRx=g(nrSSSIndices); sssScores=zeros(336,1);
for n1=0:335
    sssScores(n1+1)=abs(sum(sssRx.*conj(nrSSS(3*n1+n2))))^2;
end
[~,i1]=max(sssScores); nid=3*(i1-1)+n2;
di=nrPBCHDMRSIndices(nid); ds=zeros(a.Lmax,1);
for ib=0:a.Lmax-1
    ref=zeros(240,4); ref(di)=nrPBCHDMRS(nid,ib);
    [h,nv]=nrChannelEstimate(g,ref,'AveragingWindow',[0 1]);
    ds(ib+1)=mean(abs(h).^2,'all')/max(nv,1e-12);
end
[~,besti]=max(ds); ib=besti-1;
ref=zeros(240,4); ref(di)=nrPBCHDMRS(nid,ib);
[h,nv]=nrChannelEstimate(g,ref,'AveragingWindow',[0 1]);
bi=nrPBCHIndices(nid); sy=g(bi); he=h(bi);
[eq,csi]=nrEqualizeMMSE(sy,he,max(nv,1e-12));
v=mod(ib,4); if a.Lmax==8, v=ib; end
soft=nrPBCHDecode(eq,nid,v,max(nv,1e-12));
soft=soft.*repelem(csi,2);
[~,crc,mib,sfn4,hrf,kmsb]=nrBCHDecode(soft,8,a.Lmax,nid);
r=struct('cellID',nid,'ssbIndex',ib,'crcError',logical(crc), ...
    'mibBits',int8(mib),'frequencyOffset',total,'coarseOffset',coarse, ...
    'fineOffset',fine,'timingOffset',offset, ...
    'ssbStartSample',offset+oi.SymbolLengths(1),'noiseVariance',nv, ...
    'pssScores',scores,'frequencyCandidates',freqs,'timingCorrelation',mag, ...
    'sssScores',sssScores,'dmrsScores',ds,'grid',g,'channelEstimate',h, ...
    'pbchReceived',sy,'pbchEqualized',eq,'softBits',soft, ...
    'correctedWaveform',z,'systemFrameNumber',NaN,'halfFrame',double(hrf), ...
    'kSsb',NaN);
if ~crc
    u=@(b) double(b(:)')*2.^(numel(b)-1:-1:0)';
    r.systemFrameNumber=16*u(mib(2:7))+u(sfn4);
    r.kSsb=u(mib(9:12))+16*u(kmsb);
    r.subcarrierSpacingCommon=15*(1+double(mib(8)));
    r.dmrsTypeAPosition=2+double(mib(13));
    r.pdcchConfigSib1=u(mib(14:21));
    r.cellBarred=~logical(mib(22));
    r.intraFrequencyReselectionAllowed=~logical(mib(23));
end
end
