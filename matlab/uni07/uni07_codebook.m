function W=uni07_codebook
% TS 38.214 V18.10.0 Table 5.2.2.2.1-1, two ports, one layer.
W=[ones(1,4);exp(1i*pi/2*(0:3))]/sqrt(2);
end
