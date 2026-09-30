function [lo,hi]=uni01_interval(k,n)
% Two-sided Wilson 95% interval for an iid Bernoulli count.
assert(all(k>=0 & k<=n,'all'));
z=1.95996398454005; p=k./n; d=1+z^2./n;
centre=(p+z^2./(2*n))./d;
half=z*sqrt(p.*(1-p)./n+z^2./(4*n.^2))./d;
lo=max(0,centre-half); hi=min(1,centre+half);
lo(n==0)=NaN; hi(n==0)=NaN;
end
