function out=uni08_rar(mode,in)
% TS38.3216.2.2/6.2.3: E=0,T=1,RAPID; R=0,TA12,grant27,TC-RNTI16.
% Grant TS38.2138.2: hopping1,freq14,time4,MCS4,TPC3,CSI1.
b=@(v,n) int8(dec2bin(v,n)'-'0');
if strcmp(mode,'encode')
    assert(in.ta>=0 && in.ta<=3846 && in.rapid<64);
    out=[int8([0;1]);b(in.rapid,6);int8(0);b(in.ta,12);int8(0); ...
         b(in.riv,14);b(in.td,4);b(in.mcs,4);b(in.tpc,3);int8(0);b(in.rnti,16)];
else
    v=@(x) bin2dec(char(double(x(:)')+'0'));
    assert(numel(in)>=64 && in(1)==0 && in(2)==1 && in(9)==0);
    out=struct('rapid',v(in(3:8)),'ta',v(in(10:21)), 'hop',in(22), ...
        'riv',v(in(23:36)),'td',v(in(37:40)),'mcs',v(in(41:44)), ...
        'tpc',v(in(45:47)),'csi',in(48),'rnti',v(in(49:64)));
    assert(out.ta<=3846);
end
end
