function a=uni02_coded(wrongIdentity)
fixture=uni02_link(25,0,2,42001,false); c=fixture.carrier; p=fixture.pdsch;
[di,diInfo]=nrPDSCHIndices(c,p); R=.5; A=nrTBS('QPSK',1,24,diInfo.NREPerPRB,R);
rng(42002,'twister'); info=nrDLSCHInfo(A,R); tb=randi([0 1],A,1);
crc=nrCRCEncode(tb,info.CRC); cb=nrCodeBlockSegmentLDPC(crc,info.BGN); enc=nrLDPCEncode(cb,info.BGN);
rm=nrRateMatchLDPC(enc,diInfo.G,0,'QPSK',1); sym=nrPDSCH(c,p,rm);
tx=fixture.tx; tx(di)=sym; nv=fixture.noiseVariance;
rx=fixture.H.*tx+sqrt(nv/2)*(randn(size(tx))+1i*randn(size(tx)));
pr=p; if wrongIdentity,pr.DMRS.NIDNSCID=43;end
ref=nrPDSCHDMRS(c,pr); [h,nest]=nrChannelEstimate(c,rx,fixture.dmrsIndices,ref,'CDMLengths',[1 1]);
[eq,csi]=nrEqualizeMMSE(rx(di),h(di),nest); [llr,~]=nrPDSCHDecode(c,p,eq,nest);
% Apply equalizer CSI to both QPSK bits before LDPC rate recovery.
scaled=llr{1}.*reshape(repmat(csi.',2,1),[],1);
rr=nrRateRecoverLDPC(scaled,A,R,0,'QPSK',1); [dec,it]=nrLDPCDecode(rr,info.BGN,12,'Algorithm','Normalized min-sum');
[joined,cbErr]=nrCodeBlockDesegmentLDPC(dec,info.BGN,A+info.L); [out,err]=nrCRCDecode(joined,info.CRC);
a=struct('A',A,'G',diInfo.G,'R',R,'seed',42002,'wrongIdentity',wrongIdentity,'info',info,'tb',tb,'encoded',enc,'rateMatched',rm,'tx',tx,'rx',rx,'Hhat',h,'eq',eq,'llr',scaled,'decoded',out,'crcFailure',logical(err)||any(cbErr),'bitErrors',sum(tb~=out),'iterations',it);
end
