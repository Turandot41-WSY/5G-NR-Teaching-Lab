function run_uni09
root=fileparts(mfilename('fullpath'));out=fullfile(root,'results');if ~isfolder(out),mkdir(out);end
figdir=fullfile(root,'..','..','notes','99 Attachments','5G','Uni Labs','Uni-09');if ~isfolder(figdir),mkdir(figdir);end
diary(fullfile(out,'run.log'));cleanup=onCleanup(@()diary('off'));disp(version);ver;
cfg=struct('seed',9007,'replicates',3,'duration',0.2,'step',0.01,'frequency',3.5e9,'bandwidth',5e6,'scs',30e3,'txPower',10,'UEPower',23);
policies=["RoundRobin" "ProportionalFair" "BestCQI"];names=["Light" "Heavy" "Far users" "More uplink"];
positions=[30 0 1.5;100 100 1.5;300 -100 1.5;700 0 1.5];farpositions=positions;farpositions(:,1:2)=positions(:,1:2)*4;
patterns=[2 2;2 2;2 2;1 3];loads=[500 500;6000 3000;6000 3000;6000 3000];
rows=[];times=[];raw={};events={};
for scenario=1:4
 for policy=1:3
  for replicate=1:cfg.replicates
   rng(cfg.seed+100*scenario+replicate,'twister');sim=wirelessNetworkSimulator.init;
   pat=struct('DLULPeriodicity',2.5,'NumDLSlots',patterns(scenario,1),'NumDLSymbols',12,'NumULSymbols',1,'NumULSlots',patterns(scenario,2));
   g=nrGNB(Name='Cell',Position=[0 0 10],DuplexMode='TDD',ChannelBandwidth=cfg.bandwidth,SubcarrierSpacing=cfg.scs,CarrierFrequency=cfg.frequency,TransmitPower=cfg.txPower,DLULConfigTDD=pat,PHYModel='abstract-phy');
   configureScheduler(g,Scheduler=policies(policy),MaxNumUsersPerTTI=2,ResourceAllocationType=1);
   pos=positions;if scenario==3,pos=farpositions;end
   u=nrUE(Position=pos,Name=["UE1" "UE2" "UE3" "UE4"],TransmitPower=cfg.UEPower,PHYModel='abstract-phy');
   connectUE(g,u);addNodes(sim,g);addNodes(sim,u);
   runevents=[];registerEventCallback(g,["AppPacketGenerated" "AppPacketReceived"],@capture);
   registerEventCallback(u,["AppPacketGenerated" "AppPacketReceived"],@capture);
   for k=1:4
    addTrafficSource(g,networkTrafficOnOff(DataRate=loads(scenario,1),PacketSize=1000,OnTime=1,OffTime=0),DestinationNode=u(k));
    addTrafficSource(u(k),networkTrafficOnOff(DataRate=loads(scenario,2),PacketSize=1000,OnTime=1,OffTime=0),DestinationNode=g);
   end
   for step=1:round(cfg.duration/cfg.step)
    run(sim,cfg.step,IsLastStep=step==round(cfg.duration/cfg.step));gs=statistics(g,'all');us=statistics(u);t=step*cfg.step;
    for k=1:4
     dl=us(k).App.ReceivedBytes;ul=sum(runevents(runevents(:,2)==g.ID & runevents(:,3)==1 & runevents(:,5)==u(k).ID,4));
     times(end+1,:)=[scenario policy replicate k t dl ul gs.App.Destinations(k).TransmittedBytes us(k).App.TransmittedBytes gs.MAC.Destinations(k).Retransmissions us(k).MAC.Retransmissions];
    end
   end
   dlLatency=kpi(g,u,'latency',Layer='APP');ulLatency=kpi(u,g,'latency',Layer='APP');
   dlrate=[us.App];dlrate=[dlrate.ReceivedBytes]*8/cfg.duration/1e6;
   ulbytes=zeros(1,4);for k=1:4,ulbytes(k)=sum(runevents(runevents(:,2)==g.ID & runevents(:,3)==1 & runevents(:,5)==u(k).ID,4));end
   ulrate=ulbytes*8/cfg.duration/1e6;
   dlLatency(dlrate==0)=NaN;ulLatency(ulbytes==0)=NaN;
   jdl=sum(dlrate)^2/(4*sum(dlrate.^2));jul=sum(ulrate)^2/(4*sum(ulrate.^2));
   for k=1:4
    rows(end+1,:)=[scenario policy replicate k norm(pos(k,:)-[0 0 10]) dlrate(k) ulrate(k) dlLatency(k)*1e3 ulLatency(k)*1e3 gs.MAC.Destinations(k).Retransmissions us(k).MAC.Retransmissions gs.App.Destinations(k).TransmittedBytes us(k).App.TransmittedBytes us(k).App.ReceivedBytes ulbytes(k) jdl jul us(k).PHY.DecodeFailures gs.PHY.Destinations(k).DecodeFailures];
   end
   raw{end+1}=struct('scenario',scenario,'policy',policy,'replicate',replicate,'gNB',gs,'UE',us,'DLlatency',dlLatency,'ULlatency',ulLatency,'gNBConfig',struct('TDD',pat,'Position',[0 0 10],'PowerdBm',cfg.txPower),'UEPositions',pos);
   events{end+1}=runevents;
   fprintf('Scenario=%s policy=%s repeat=%d DL=%.3f UL=%.3f Mbps J=%.3f\n',names(scenario),policies(policy),replicate,sum(dlrate),sum(ulrate),jdl);
  end
 end
end
results=array2table(rows,VariableNames={'Scenario','Policy','Replicate','UE','DistanceM','DLGoodputMbps','ULGoodputMbps','DLDelayMs','ULDelayMs','DLRetransmissions','ULRetransmissions','DLGeneratedBytes','ULGeneratedBytes','DLDeliveredBytes','ULDeliveredBytes','DLJain','ULJain','DLDecodeFailures','ULDecodeFailures'});
timeline=array2table(times,VariableNames={'Scenario','Policy','Replicate','UE','TimeS','DLDeliveredBytes','ULDeliveredBytes','DLGeneratedBytes','ULGeneratedBytes','DLRetransmissions','ULRetransmissions'});
matlabVersion=version;toolboxes=ver;save(fullfile(out,'run.mat'),'cfg','policies','names','positions','farpositions','patterns','loads','results','timeline','raw','events','matlabVersion','toolboxes');
writetable(results,fullfile(out,'per_ue.csv'));writetable(timeline,fullfile(out,'timeline.csv'));
summary=[];for sc=1:4,for po=1:3
 t=results(results.Scenario==sc & results.Policy==po,:);r=[];for rep=1:3,q=t(t.Replicate==rep,:);r(rep,:)=[sum(q.DLGoodputMbps) sum(q.ULGoodputMbps) q.DLJain(1) q.ULJain(1) sum(q.DLDeliveredBytes)/sum(q.DLGeneratedBytes) sum(q.ULDeliveredBytes)/sum(q.ULGeneratedBytes)];end
 summary(end+1,:)=[sc po mean(r) 4.3026527299*std(r)/sqrt(3)];
end;end
summary=array2table(summary,VariableNames={'Scenario','Policy','DLGoodputMbps','ULGoodputMbps','DLJain','ULJain','DLDeliveryFraction','ULDeliveryFraction','DLHalfCI','ULHalfCI','DLJainHalfCI','ULJainHalfCI','DLDeliveryHalfCI','ULDeliveryHalfCI'});writetable(summary,fullfile(out,'summary.csv'));save(fullfile(out,'summary.mat'),'summary');
figures={};set(groot,'defaultFigureVisible','off','defaultAxesFontSize',20,'defaultTextFontSize',20);
fields={'DLGoodputMbps','ULGoodputMbps','DLDelayMs','ULDelayMs','DLRetransmissions','ULRetransmissions'};
labels={'Downlink payload (Mbit/s)','Uplink payload (Mbit/s)','Mean delivered packet delay (ms)','Mean delivered packet delay (ms)','Downlink MAC retransmissions','Uplink MAC retransmissions'};
for sc=1:4
 for j=1:numel(fields)
  f=newfig;hold on;for po=1:3,t=results(results.Scenario==sc & results.Policy==po,:);a=zeros(4,1);e=a;for k=1:4,v=t.(fields{j})(t.UE==k);a(k)=mean(v);e(k)=4.3026527299*std(v)/sqrt(3);end;errorbar((1:4)+(po-2)*.06,a,e,'-o',LineWidth=2);end
  xlabel('User equipment index');ylabel(labels{j});xticks(1:4);legend(policies,Location='best',FontSize=17);grid on;title(names(sc)+' : '+fields{j});keep(f,char(names(sc)+' '+fields{j}));
 end
end
fields={'DLGoodputMbps','ULGoodputMbps','DLJain','ULJain','DLDeliveryFraction','ULDeliveryFraction'};
ci={'DLHalfCI','ULHalfCI','DLJainHalfCI','ULJainHalfCI','DLDeliveryHalfCI','ULDeliveryHalfCI'};
for j=1:6,f=newfig;hold on;for po=1:3,t=summary(summary.Policy==po,:);errorbar(t.Scenario+(po-2)*.08,t.(fields{j}),t.(ci{j}),'-o',LineWidth=2);end;xticks(1:4);xticklabels(names);xlabel('Experiment scenario');ylabel(fields{j});title('Cell '+string(fields{j}));legend(policies,Location='best',FontSize=17);grid on;keep(f,['Cell ' fields{j}]);end
f=newfig;scatter(positions(:,1),positions(:,2),100,'filled');hold on;scatter(farpositions(:,1),farpositions(:,2),100,'s','filled');scatter(0,0,150,'^','filled');text(positions(:,1)+20,positions(:,2),string(1:4));text(farpositions(:,1)+20,farpositions(:,2),string(1:4));axis equal;grid on;xlabel('East x (m)');ylabel('North y (m)');legend('Baseline UE','Far UE','gNB');title('Plan view; right handed ENU, camera above');keep(f,'UE positions');
f=newfig;a=zeros(2,70);for k=1:2,p=patterns(1,:);if k==2,p=patterns(4,:);end;a(k,1:p(1)*14+12)=1;a(k,end-p(2)*14:end)=2;end;imagesc((0:69)/14*.5,1:2,a);yticks(1:2);yticklabels({'2 DL / 2 UL','1 DL / 3 UL'});xlabel('Time in 2.5 ms period (ms)');title('TDD symbols: 0 guard, 1 downlink, 2 uplink');colorbar;keep(f,'TDD symbol allocations');
for field={'DLDeliveredBytes','DLUndeliveredBytes'},f=newfig;hold on;for po=1:3,t=timeline(timeline.Scenario==2 & timeline.Policy==po & timeline.Replicate==1,:);v=t.DLDeliveredBytes;if strcmp(field{1},'DLUndeliveredBytes'),v=t.DLGeneratedBytes-v;end;[ts,~,ix]=unique(t.TimeS);plot(ts*1e3,accumarray(ix,v)/1000,'-o',LineWidth=2);end;xlabel('Elapsed simulation time (ms)');ylabel('Application bytes (kB)');legend(policies,Location='best');title(strrep(field{1},'DL','Heavy downlink '));grid on;keep(f,field{1});end
writetable(cell2table(figures,VariableNames={'File','Title'}),fullfile(out,'figures.csv'));test_uni09;test_uni09_outputs;
assert(height(results)==144 && height(timeline)==2880);assert(all(results.DLDeliveredBytes<=results.DLGeneratedBytes));assert(all(results.ULDeliveredBytes<=results.ULGeneratedBytes));assert(all(results.DLJain>=.25 & results.DLJain<=1+1e-12));assert(numel(figures(:,1))>=32);fprintf('PASS connected simulator, delivered byte conservation, fairness, replicate intervals.\n');
 function capture(e)
  received=strcmp(e.EventName,'AppPacketReceived');if received,peer=e.EventData.SourceNodeID;else,peer=e.EventData.DestinationNodeID;end
  runevents(end+1,:)=[e.Timestamp e.NodeID received e.EventData.PacketLength peer];
 end
 function f=newfig,f=figure(Position=[100 100 1440 900]);end
 function keep(f,ttl),file=['Uni-09 - ' ttl ' v2.png'];exportgraphics(f,fullfile(figdir,file),Resolution=150);close(f);figures(end+1,:)={file,ttl};end
end
