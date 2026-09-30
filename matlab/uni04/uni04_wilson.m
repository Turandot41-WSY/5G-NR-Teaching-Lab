function [lo,hi]=uni04_wilson(k,n)
% Wilson score interval with two-sided 95 percent nominal coverage.
assert(n>0 && k>=0 && k<=n);
z=1.959963984540054; p=k/n; den=1+z^2/n;
mid=(p+z^2/(2*n))/den;
half=z*sqrt(p*(1-p)/n+z^2/(4*n^2))/den;
lo=max(0,mid-half); hi=min(1,mid+half);
if k==0, lo=0; end
if k==n, hi=1; end
end
