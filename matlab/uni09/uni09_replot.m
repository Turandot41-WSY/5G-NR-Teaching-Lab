function uni09_replot
% Re-render the Uni-09 teaching figures in the light theme from the saved run.mat and summary.mat.
% No simulation runs here; every curve is read from results, timeline and summary written by run_uni09.
root=fileparts(mfilename('fullpath'));out=fullfile(root,'results');
figdir=fullfile(root,'..','..','notes','99 Attachments','5G','Uni Labs','Uni-09');
d=load(fullfile(out,'run.mat'),'policies','names','positions','farpositions','patterns','results','timeline');
policies=d.policies;names=d.names;positions=d.positions;farpositions=d.farpositions;patterns=d.patterns;results=d.results;timeline=d.timeline;
s=load(fullfile(out,'summary.mat'),'summary');summary=s.summary;
figures={};
fields={'DLGoodputMbps','ULGoodputMbps','DLDelayMs','ULDelayMs','DLRetransmissions','ULRetransmissions'};
labels={'Downlink payload (Mbit/s)','Uplink payload (Mbit/s)','Mean delivered packet delay (ms)','Mean delivered packet delay (ms)','Downlink MAC retransmissions','Uplink MAC retransmissions'};
for sc=1:4
 for j=1:numel(fields)
  f=newfig;hold on;for po=1:3,t=results(results.Scenario==sc & results.Policy==po,:);a=zeros(4,1);e=a;for k=1:4,v=t.(fields{j})(t.UE==k);a(k)=mean(v);e(k)=4.3026527299*std(v)/sqrt(3);end;errorbar((1:4)+(po-2)*.06,a,e,'-o',LineWidth=2);end
  xlabel('User equipment index');ylabel(labels{j});xticks(1:4);legend(policies,Location='best');grid on;title(names(sc)+': '+fields{j});
  yl=ylim; ylim([0 max(yl(2),1)]); allv=results.(fields{j})(results.Scenario==sc); if all(allv==0|isnan(allv)), text(0.5,0.55,'No MAC retransmissions observed','Units','normalized','HorizontalAlignment','center'); end
  keep(f,char(names(sc)+' '+fields{j}));
 end
end
fields={'DLGoodputMbps','ULGoodputMbps','DLJain','ULJain','DLDeliveryFraction','ULDeliveryFraction'};
ci={'DLHalfCI','ULHalfCI','DLJainHalfCI','ULJainHalfCI','DLDeliveryHalfCI','ULDeliveryHalfCI'};
for j=1:6,f=newfig;hold on;for po=1:3,t=summary(summary.Policy==po,:);errorbar(t.Scenario+(po-2)*.08,t.(fields{j}),t.(ci{j}),'-o',LineWidth=2);end;xticks(1:4);xticklabels(names);xlabel('Experiment scenario');ylabel(fields{j});title('Cell '+string(fields{j}));legend(policies,Location='best');grid on;keep(f,['Cell ' fields{j}]);end
f=newfig;scatter(positions(:,1),positions(:,2),100,'filled');hold on;scatter(farpositions(:,1),farpositions(:,2),100,'s','filled');scatter(0,0,150,'^','filled');text(farpositions(:,1)+70,farpositions(:,2)-150,'UE '+string(1:4));axis equal;grid on;xlim([-250 3350]);xlabel('East x (m)');ylabel('North y (m)');legend('Baseline UE','Far UE','gNB',Location='northeast');title('Plan view; right handed ENU, camera above');keep(f,'UE positions');
f=newfig;a=zeros(2,70);for k=1:2,p=patterns(1,:);if k==2,p=patterns(4,:);end;a(k,1:p(1)*14+12)=1;a(k,end-p(2)*14:end)=2;end;imagesc((0:69)/14*.5,1:2,a);yticks(1:2);yticklabels({'2 DL / 2 UL','1 DL / 3 UL'});xlabel('Time in 2.5 ms period (ms)');title('TDD symbol directions in one period');colormap(gca,[0.25 0.25 0.25;0.60 0.71 0.78;0.90 0.57 0.36]);clim([0 2]);cb=colorbar;cb.Ticks=[0 1 2];cb.TickLabels={'Guard','Downlink','Uplink'};keep(f,'TDD symbol allocations');
for field={'DLDeliveredBytes','DLUndeliveredBytes'},f=newfig;hold on;for po=1:3,t=timeline(timeline.Scenario==2 & timeline.Policy==po & timeline.Replicate==1,:);v=t.DLDeliveredBytes;if strcmp(field{1},'DLUndeliveredBytes'),v=t.DLGeneratedBytes-v;end;[ts,~,ix]=unique(t.TimeS);plot(ts*1e3,accumarray(ix,v)/1000,'-o',LineWidth=2);end;xlabel('Elapsed simulation time (ms)');ylabel('Application bytes (kB)');legend(policies,Location='best');title(strrep(field{1},'DL','Heavy downlink '));grid on;keep(f,field{1});end
expected=readtable(fullfile(out,'figures.csv'));assert(isequal(sort(expected.File),sort(figures(:,1))),'Figure inventory differs from figures.csv');
fprintf('Re-rendered %d Uni-09 figures in the light theme.\n',size(figures,1));
 function f=newfig
  f=pubfig.new('wide');
 end
 function keep(f,ttl),file=['Uni-09 - ' ttl ' v2.png'];pubfig.export(f,fullfile(figdir,file));close(f);figures(end+1,:)={file,ttl};end
end
