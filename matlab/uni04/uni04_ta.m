function a=uni04_ta(measuredSamples,Fs,mu,NTAoffset)
% Quantize residual PRACH arrival delay relative to the gNB UL reference.
% TS 38.213 V18.8.0 4.2: absolute RAR TA, not the 6-bit relative MAC CE.
Tc=1/(480e3*4096);
a.stepSeconds=16*64*Tc/2^mu;
% Algebraically combine exact constants before division to preserve half ties.
stepSamples=Fs/(1.92e6*2^mu);
a.command=min(3846,max(0,round(measuredSamples/stepSamples)));
a.NTA=a.command*16*64/2^mu;
a.advanceSamples=round(a.NTA*Tc*Fs);
a.residualSamples=measuredSamples-a.advanceSamples;
a.totalAdvanceSeconds=(a.NTA+NTAoffset)*Tc;
% The gNB UL reference is -NTAoffset*Tc relative to its DL frame origin.
a.arrivalRelativeDLSeconds=measuredSamples/Fs-a.totalAdvanceSeconds;
end
