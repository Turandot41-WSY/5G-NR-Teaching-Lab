function a=uni05_link(snrDb,rvs,seed,A,R,G,maxIter,combine)
if nargin<8, combine=true; end
rng(seed,'twister'); info=nrDLSCHInfo(A,R);
tb=randi([0 1],A,1); withCRC=nrCRCEncode(tb,info.CRC);
cbs=nrCodeBlockSegmentLDPC(withCRC,info.BGN); enc=nrLDPCEncode(cbs,info.BGN);
soft=zeros(size(enc)); nv=10^(-snrDb/10);
a=struct('snrDb',snrDb,'rvs',rvs,'seed',seed,'A',A,'R',R,'G',G,'maxIter',maxIter,'info',info,'tb',tb,'withCRC',withCRC,'cbs',cbs,'encoded',enc);
a.fail=false(1,numel(rvs)); a.bitErrors=zeros(size(rvs)); a.iterations=zeros(size(rvs));
for j=1:numel(rvs)
 rm=nrRateMatchLDPC(enc,G,rvs(j),'QPSK',1); x=nrSymbolModulate(rm,'QPSK');
 y=x+sqrt(nv/2)*(randn(size(x))+1i*randn(size(x)));
 llr=nrSymbolDemodulate(y,'QPSK',nv);
 rr=nrRateRecoverLDPC(llr,A,R,rvs(j),'QPSK',1);
 if combine, soft=soft+rr; else, soft=rr; end
 [dec,it]=nrLDPCDecode(soft,info.BGN,maxIter,'Algorithm','Normalized min-sum');
 [joined,cbErr]=nrCodeBlockDesegmentLDPC(dec,info.BGN,A+info.L);
 [out,crcErr]=nrCRCDecode(joined,info.CRC);
 a.fail(j)=logical(crcErr)||any(cbErr); a.bitErrors(j)=sum(out~=tb); a.iterations(j)=max(it); a.iterationsPerCB{j}=it;
 a.rateMatched{j}=rm; a.x{j}=x; a.y{j}=y; a.llr{j}=llr;
 a.recovered{j}=rr; a.combined{j}=soft; a.decoded{j}=out;
end
first=find(~a.fail,1); if isempty(first), a.used=numel(rvs); a.delivered=false; else, a.used=first; a.delivered=true; end
end
