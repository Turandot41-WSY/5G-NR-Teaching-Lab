function r=uni09_network_experiment(cfg,scenario,policy)
% One connected-cell run extracted from run_uni09.
% The simulator default propagation is free-space path loss. No access chain.
assert(ismember(scenario,1:4),'Uni09:Scenario','Select a scenario from 1 to 4.');
assert(ismember(policy,1:3),'Uni09:Policy','Select a policy from 1 to 3.');
assert(ismember(cfg.duration,[0.1 0.2]),'Uni09:Duration','Use 0.1 or 0.2 seconds for this teaching run.');
assert(isscalar(cfg.step) && isfinite(cfg.step) && cfg.step>0,'Uni09:Step','Set a positive finite scalar simulation step.');
stepCount=round(cfg.duration/cfg.step);
assert(stepCount>=1 && abs(cfg.duration-stepCount*cfg.step)<=1e-12,'Uni09:Step','The simulation step must divide the duration into a positive integer number of intervals.');
assert(isfield(cfg,'positions') && isequal(size(cfg.positions),[4 3]) && all(isfinite(cfg.positions),'all'), ...
    'Uni09:Positions','Set four finite [east north height] positions in the geometry cell.');
policies=["RoundRobin" "ProportionalFair" "BestCQI"];names=["Light" "Heavy" "Far users" "More uplink"];
patterns=[2 2;2 2;2 2;1 3];loads=[500 500;6000 3000;6000 3000;6000 3000];
rows=[];times=[];raw={};events={};replicate=1;
   rng(cfg.seed+100*scenario+replicate,'twister');sim=wirelessNetworkSimulator.init;
   pat=struct('DLULPeriodicity',2.5,'NumDLSlots',patterns(scenario,1),'NumDLSymbols',12,'NumULSymbols',1,'NumULSlots',patterns(scenario,2));
   g=nrGNB(Name='Cell',Position=[0 0 10],DuplexMode='TDD',ChannelBandwidth=cfg.bandwidth,SubcarrierSpacing=cfg.scs,CarrierFrequency=cfg.frequency,TransmitPower=cfg.txPower,DLULConfigTDD=pat,PHYModel='abstract-phy');
   configureScheduler(g,Scheduler=policies(policy),MaxNumUsersPerTTI=2,ResourceAllocationType=1);
   pos=cfg.positions;
   u=nrUE(Position=pos,Name=["UE1" "UE2" "UE3" "UE4"],TransmitPower=cfg.UEPower,PHYModel='abstract-phy');
   connectUE(g,u);addNodes(sim,g);addNodes(sim,u);
   runevents=zeros(0,5);registerEventCallback(g,["AppPacketGenerated" "AppPacketReceived"],@capture);
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
results=array2table(rows,VariableNames={'Scenario','Policy','Replicate','UE','DistanceM','DLGoodputMbps','ULGoodputMbps','DLDelayMs','ULDelayMs','DLRetransmissions','ULRetransmissions','DLGeneratedBytes','ULGeneratedBytes','DLDeliveredBytes','ULDeliveredBytes','DLJain','ULJain','DLDecodeFailures','ULDecodeFailures'});
timeline=array2table(times,VariableNames={'Scenario','Policy','Replicate','UE','TimeS','DLDeliveredBytes','ULDeliveredBytes','DLGeneratedBytes','ULGeneratedBytes','DLRetransmissions','ULRetransmissions'});
r=struct('cfg',cfg,'scenario',scenario,'policy',policy,'policyName',policies(policy), ...
 'scenarioName',names(scenario),'results',results,'timeline',timeline,'raw',{raw},'events',{events}, ...
 'positions',pos,'pattern',pat,'loadKbps',loads(scenario,:));
assert(all(results.DLDeliveredBytes<=results.DLGeneratedBytes));
assert(all(results.ULDeliveredBytes<=results.ULGeneratedBytes));
assert(all(isnan(results.DLDelayMs(results.DLDeliveredBytes==0))));
assert(all(isnan(results.ULDelayMs(results.ULDeliveredBytes==0))));
 function capture(e)
  received=strcmp(e.EventName,'AppPacketReceived');if received,peer=e.EventData.SourceNodeID;else,peer=e.EventData.DestinationNodeID;end
  runevents(end+1,:)=[e.Timestamp e.NodeID received e.EventData.PacketLength peer];
 end
end
