%The function computed the euclidean distance from a point 
%in 2D space from a line defined by two points
%
%Input:
%	linepoint1,linepoint2: 	1x2 vectors of integers defining 
%                           2D coords for a straight line 
%
%	point:                  1x2 vector of integers defining 
%                           2D coords for point
%
%Output:
%	
%	d:                      euclidean distance of the point 
%                           and the line
%

function d=DistFromLine(linepoint1,linepoint2, point)

d = abs(det([linepoint2-linepoint1;point-linepoint1]))/norm(linepoint2-linepoint1); 

return;