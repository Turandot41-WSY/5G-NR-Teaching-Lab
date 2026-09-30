function [carrier,prach,waveform,info]=uni04_prach
% One active FR1 FDD format 0 occasion. Explicit 25 RB, 15 kHz carrier.
carrier=nrCarrierConfig(NSizeGrid=25,SubcarrierSpacing=15,NCellID=1);
prach=nrPRACHConfig(FrequencyRange='FR1',DuplexMode='FDD', ...
    ConfigurationIndex=27,SubcarrierSpacing=1.25,SequenceIndex=0, ...
    PreambleIndex=0,ZeroCorrelationZone=8,NPRACHSlot=0);
grid=nrPRACHGrid(carrier,prach);
grid(nrPRACHIndices(carrier,prach))=nrPRACH(carrier,prach);
[waveform,info]=nrPRACHOFDMModulate(carrier,prach,grid,Windowing=0);
assert(any(waveform),'Configured PRACH occasion is inactive.');
end
