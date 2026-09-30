function uni08_plots
base=fileparts(mfilename('fullpath'));s=load(fullfile(base,'results','run.mat'));
out=fullfile(base,'..','..','notes','99 Attachments','5G','Uni Labs','Uni-08');if ~isfolder(out),mkdir(out);end
set(groot,'defaultAxesFontSize',18,'defaultTextFontSize',18,'defaultAxesFontName','Helvetica');
files={};blue=[.12 .32 .52];red=[.7 .19 .19];
for k=1:6
 r=s.packets{k}; tag=sprintf('Stage %02d',k);
 f=newfig; labels=zeros(size(r.grid));labels(r.dataIndices)=1;labels(r.dmrsIndices)=2;
 imagesc(0:13,0:size(labels,1)-1,labels);axis xy;colormap([1 1 1;.65 .76 .86;.24 .36 .52]);
 colorbar('Ticks',[0 1 2],'TickLabels',{'Unused','Data','DM-RS'});xlabel('OFDM symbol');ylabel('Subcarrier in 24 RB BWP');
 title(s.names(k)+': actual resource mapping');saveplot([tag ' Resource Grid']);
 f=newfig; ii=1:min(1200,numel(r.rx));plot((ii-1)/r.sampleRate*1e6,movmean(abs(r.rx(ii)),16),'Color',blue,'LineWidth',1.8);
 xlabel('Time from scheduled receiver origin (microseconds)');ylabel('Smoothed magnitude (16-sample window)');
 title(s.names(k)+sprintf(': received waveform, residual %+d samples',r.residual));saveplot([tag ' Received Waveform']);
 f=newfig;plot(real(r.equalized),imag(r.equalized),'.','Color',blue);hold on;
 plot(real(r.symbols),imag(r.symbols),'kx','MarkerSize',9);axis equal;grid on;
 xlabel('In phase');ylabel('Quadrature');title(s.names(k)+sprintf(': EVM %.2f%%, CRC failure %d',r.evm,r.crc));saveplot([tag ' Equalized Symbols']);
 f=newfig;nn=1:min(160,numel(r.llr));stem(nn-1,r.llr(nn),'.','Color',blue);grid on;
 xlabel('First 160 coded bit positions');ylabel('LLR');title(s.names(k)+': reliability before LDPC decoding');saveplot([tag ' Decoder Reliability']);
end
f=newfig;imagesc(0:size(s.t.grid,2)-1,0:size(s.t.grid,1)-1,abs(s.t.grid));axis xy;colorbar;
xlabel('OFDM symbol in first two slots');ylabel('Capture subcarrier');title('Received cell fixture: SSB and scheduled SIB1 regions');saveplot('Broadcast Resource Capture');
f=newfig;tr=s.broadcast.candidateTrace;bar(tr(:,4)~=0,'FaceColor',blue);xlabel('Blind decode attempt');ylabel('DCI CRC rejected');
title('Actual SIB1 control search before random access');ylim([-.1 1.1]);saveplot('Broadcast Candidate Acceptance');
f=newfig;bits=s.broadcast.transportBits(1:400);bytes=reshape(bits,8,[])';values=double(bytes)*2.^(7:-1:0)';
stem(0:numel(values)-1,values,'.','Color',blue);xlabel('Recovered SIB1 UPER byte index');ylabel('Byte value');title('Fifty decoded SIB1 bytes, canonical encoding verified');saveplot('Decoded SIB1 Byte Values');
f=newfig;plot((0:numel(s.prx)-1)/s.pinfo.SampleRate*1e6,abs(s.prx),'Color',blue);
xlabel('Time from uplink occasion origin (microseconds)');ylabel('Waveform magnitude');title('Actual TDD PRACH format 0, arrival 321 samples');saveplot('PRACH Arrival Waveform');
f=newfig;bar([321 s.ta.advanceSamples s.ta.residualSamples],'FaceColor',blue);
xticks(1:3);xticklabels({'Measured','Advance','Residual'});ylabel('Samples at 15.36 MHz');title('30 kHz PUSCH timing: command 80, residual +1 sample');saveplot('Timing Advance Sample Accounting');
f=newfig;scatter(s.events.timeMs,1:6,130,blue,'filled');yticks(1:6);yticklabels(s.names);set(gca,'YDir','reverse');
xlabel('Nominal scheduled time from broadcast frame origin (ms)');title('Executed message and transport stages in the TDD schedule');grid on;saveplot('Scheduled Access Event Times');
f=newfig;bar(s.events.tbs,'FaceColor',blue);hold on;plot(1:6,cellfun(@(r)r.payloadBits,s.packets),'-or','LineWidth',1.5);
xticks(1:6);xticklabels({'RAR','Msg3','Msg4','Complete','DLtest','ULtest'});ylabel('Bits');legend('Transport capacity','Meaningful fixture payload','Location','northwest');title('Message payload length and selected transport block size');saveplot('Message and Transport Sizes');
f=newfig;sn=unique(s.trials.snrDB);v=zeros(size(sn));lo=v;hi=v;
for k=1:numel(sn),z=s.trials(s.trials.snrDB==sn(k),:);count=sum(z.dlCRC==0&z.ulCRC==0);v(k)=count/height(z);[lo(k),hi(k)]=uni04_wilson(count,height(z));end
errorbar(sn,v,v-lo,hi-v,'-o','Color',blue,'LineWidth',1.7);ylim([-.05 1.05]);xlabel('SNR per resource element (dB)');ylabel('Both transport blocks decode');
title('Conditional on access: 20 fresh DL/UL pairs per SNR, 95% Wilson intervals');saveplot('Bidirectional Transport Probability');
for key=["rar" "msg4"]
 r=s.controls.(key);f=newfig;
 subplot(1,2,1);imagesc(0:13,0:size(r.grid,1)-1,abs(r.grid));axis xy;
 xlabel('OFDM symbol');ylabel('Subcarrier from DL CRB4');title(upper(key)+' PDCCH resources');
 subplot(1,2,2);plot(real(r.equalized),imag(r.equalized),'.','Color',blue);grid on;
 xlabel('In phase');ylabel('Quadrature');title(sprintf('DCI: CRC %d, RNTI %d',r.crc,r.crcRNTI));
 saveplot(char(upper(key)+' Control Decode'));
end
r=s.controls.ack;f=newfig;imagesc(0:13,0:size(r.grid,1)-1,abs(r.grid));axis xy;
xlabel('OFDM symbol');ylabel('Subcarrier from UL CRB0');
title(sprintf('Actual PUCCH ACK %d, slot %d, PRB 0 to PRB 23 hopping',r.rxACK,r.slot));saveplot('Msg4 Feedback Resource Grid');
assert(numel(files)==35); fid=fopen(fullfile(base,'results','figure-list.json'),'w');fprintf(fid,'%s',jsonencode(files,'PrettyPrint',true));fclose(fid);
 function f=newfig
  f=pubfig.new('wide');box on;
 end
 function saveplot(name)
  file=['UNI-08 - ' name ' v1.png'];pubfig.export(f,fullfile(out,file));close(f);files{end+1}=file;
 end
end
