function [p,raw]=uni06_power(pl,alpha,M,mu,p0,pmax,deltaTF,f)
% TS 38.213 V18.8.0 7.1.1, single carrier and one power-control state.
raw=p0+10*log10(2^mu*M)+alpha*pl+deltaTF+f;
p=min(pmax,raw);
end
