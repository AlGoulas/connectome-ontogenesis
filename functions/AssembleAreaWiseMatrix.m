%Given a list of connections and a 2D cortical sheet parcellation, the
%function returns the connectivity matrix and the distances between centers
%of mass of the areas. 
%
%Input: AllConnList: As structure with the connectivity list in the form 
%                    of a 'from to' list of coordinates 
%                    (returned from the pcs_temporalwindows.m function).     
%
%       Areas:       2D parcellation of the cortical sheet. These are the
%                    areas upon which the connectivity matrix will be
%                    estimated.
%                    The function TasselatePoints2Areas.m can be used to
%                    produce a parcellation.
%
%Output:C:           The directed and weighted area-based connectivity    
%                    matrix.
%       Dist:        The area-to-area distance matrix based on the
%                    barycenters of the areas.
%--------------------------------------------------------------------------

function [C, Dist]=AssembleAreaWiseMatrix(AllConnList, Areas)

if(iscell(AllConnList))
    
    tmp(1).from=[];
    tmp(1).to=[];

    for i=1:length(AllConnList)

        tmp=[tmp AllConnList{i}];

    end

    %clear AllConnList

    AllConnList=tmp;
    clear tmp;

end

C=zeros(length(unique(Areas)),length(unique(Areas)));

for i=1:length(AllConnList)

    %Get source target area ids
    current_from=AllConnList(i).from;
    current_to=AllConnList(i).to;
    
    if((~isempty(current_from)) & (~isempty(current_to)))
        
        area_from=Areas(current_from(1),current_from(2));
        area_to=Areas(current_to(1),current_to(2));

        C(area_from,area_to)=C(area_from,area_to)+1;    
        
    end
    
end

%get rid of self-self connections
C=C-diag(diag(C));

%Get the distances between areas
area_ids=unique(Areas);
Dist=zeros(length(unique(Areas)),length(unique(Areas)));

for i=1:length(area_ids)

    [x1, y1]=find(Areas==area_ids(i));
    
    x1=mean(x1,1);
    y1=mean(y1,1);
    
    for j=1:length(area_ids)
        
        if(i~=j)
           
            [x2, y2]=find(Areas==area_ids(j));
              
            x2=mean(x2,1);
            y2=mean(y2,1);
            
            Dist(i,j)=sqrt(((x1-x2).^2) + ((y1-y2).^2));
            
        end        
        
    end

end


return
