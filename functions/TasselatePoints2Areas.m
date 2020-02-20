%The function creates a 2D cortical sheet of x and y dimensions with the
%corresponding size and a specified number of areas.
%
%Input:    sheetxy: A 1d vector with 2 entries specifying the
%                   X and Y dimensions of the cortical sheet 
%                   e.g., [20 20]     
%          n_points:An integer specifying the number of areas that the
%                   cortical sheet will be composed of.
%Output:   Areas:   A 2D matrix with unique integers denoting each area.
%          XY:      The 2D coordinates of the centers of mass of the areas. 
%--------------------------------------------------------------------------


function [Areas, XY]=TasselatePoints2Areas(sheetxy,n_points)

Areas=zeros(sheetxy(1),sheetxy(2));

while 1

x=floor(sheetxy(1).*rand(n_points,1))+1;
y=floor(sheetxy(2).*rand(n_points,1))+1;

XY=[x y];

%So x y are the center of the areas. Assign now all the points to one of
%these areas.

indexes=1:size(XY,1);

[x_sheet, y_sheet]=find(~isnan(Areas));

for i=1:size(XY,1)
    
    distances(:,i)=sqrt(((XY(i,1)-x_sheet).^2)+((XY(i,2)-y_sheet).^2));

end

for i=1:size(distances,1)
    
    tmp=find(distances(i,:)==min(distances(i,:)));
    ids(i)=tmp(1);
    
end

Areas(sub2ind(size(Areas),x_sheet,y_sheet))=ids;

if(length(unique(Areas))==n_points)
    break;
end

end

return