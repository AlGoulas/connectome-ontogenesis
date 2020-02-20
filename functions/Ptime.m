%The function computes the probability of event x at timepoint t.
%It is based on Nisbach and Kaiser Eur. Phys. J. B 58, 185-191 (2007)
%
%Input: i:  positive integer specifying for which timewindow 
%           we are computing Pt, satisfying i<=k.
%       k:  positive integer specifying the total timewindows.
%       t:  timepoint expressed as a value between [0 1].
%       a:  parameter controlling the overlap of 
%           timewindows (a > 0). Values close to 0 indicate low overlap and
%           higher values more overlap between the time windows.
%Output:Pt: probability of event x at timepoint t for timewindow i.    
%--------------------------------------------------------------------------

function Pt=Ptime(i,k,t,a)

m=i/(k+1);
l=-(log(2)/log(m));

Pt=power((power(t,2*l))*(power((power(t,l)-1),2)), 1/(m*a));


return;