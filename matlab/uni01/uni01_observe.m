function [w,m]=uni01_observe(t,snrDb,cfoHz,delaySamples,seed)
% Unit-energy active-RE SNR, not average capture-power SNR.
% MATLAB OFDM IFFT normalization gives FFT noise variance = Nfft*sigma2.
assert(delaySamples>=0 && fix(delaySamples)==delaySamples);
rng(seed,'twister');
w=[zeros(delaySamples,1);t.waveform;zeros(1024,1)];
n=(0:numel(w)-1)';
w=w.*exp(1i*2*pi*cfoHz*n/t.sampleRate);
sigma2=1/(t.nfft*10^(snrDb/10));
w=w+sqrt(sigma2/2)*(randn(size(w))+1i*randn(size(w)));
m=struct('snrDb',snrDb,'frequencyOffsetHz',cfoHz, ...
    'delaySamples',delaySamples,'seed',seed,'noiseVarianceTime',sigma2, ...
    'expectedSsbStartSample',t.ssbStartSample+delaySamples);
end
