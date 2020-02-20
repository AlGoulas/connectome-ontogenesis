%The function computes timewindows of each patch of the synthetic cortical
%sheet, as well as the distances from the root(s) of the gradients.
%The are different possibilities to construct the time windows and assign
%them to patches
%
%Input: 
% 
%size_sheet:        a 1x2 vector of integers [n m] specifying the 2D size of 
%       		    the synthetic sheet 
%
%xy_coords_roots:   nx2 matrix specifying the 2D coords of n root(s) of the
%                   gradients
%
%a:                 positive float controlling the overlap of the 
%                   time windows
%                   
%
%temporal_resolution:
%
%                   parameter specifying the temporal "tick" that needs to 
%                   be taken at each step. It ranges in [0 1] and thus 
%                   specifies the total time points of the simulations
%                   E.g. if temporal_resolution = 0.1, then
%                   the simulations will unfold in this time frame:
%                   0, 0.1, 0.2, ...1 
%	
%time_windows_mode: String parameter:
%                   'gradients'
%                       Timewindows are assigned based on the physical 
%                       distance from the root(s)
%
%                   'random_timewindows'
%                       Timewindows are assigned randomly at patches of 
%                       the synthetic sheet (BETA!!! NOT TESTED) 
%
%                   'random_assignments_timewindows'
%                       Timewindows are generated as in 'gradients', but 
%                       afterwards they are reassigned at random to patches 
%                       irrespective of their distance for the root(s)
%
%Output:    
%
%Sheet:       Initialized synthetic sheet with dimensions size_sheet (input)
%
%MinDist:     Minimum distances of each patch from the root(s). Can
%             be structured or random depending on the 'time_windows_mode'
% 
%TimeWindows: Kxt matrix denoting the unique time windows 
%             for each unique patches of the sheet, where K the number of 
%             unique patches and t the number of time points of the
%             simulation.
%
%Note:      For very small values of the parameter 'a' and depending on how
%           many unique time windows we have, the time windows 
%           for some patches might not be defined (the function will return 
%           some rows of the variable TimeWindows with NaNs). This needs to
%           be checked systematically for avoiding problems when working
%           with a specific range of values for the parameters. For the time
%           being, this range is selected without involving 
%           very small values of 'a' and checking the time windows.
%--------------------------------------------------------------------------

function [Sheet, MinDist, TimeWindows]=MakeCorticalSheet_TemporalWindows(size_sheet, xy_coords_roots, a, temporal_resolution, time_windows_mode)

%Initiate cortical sheet
Sheet=zeros(size_sheet);

%Get coordinates of the cortical sheet
[x, y]=find(Sheet==0);

if(strcmp(time_windows_mode,'gradients'))
    
    %Compute for every "cortical patch" the distance from the root(s) of the 
    %gradients
    for i=1:size(xy_coords_roots,1)

        dist=bsxfun(@minus, xy_coords_roots(i,:), horzcat(x,y));
        dist=power(dist,2);
        dist=sqrt(sum(dist,2));

        temp=zeros(size_sheet);

        idx = sub2ind(size_sheet,x,y);

        temp(idx)=dist;
        AllDistances(:,:,i)=temp;

    end

    %Compute for every patch the nearest distance to a root of a gradient.
    MinDist=min(AllDistances,[],3);
    MinDist=MinDist+1;%Avoid 0s
    MinDist=round(MinDist);


end

if(strcmp(time_windows_mode,'random_timewindows'))

    idx=sub2ind(size_sheet,x,y);
    values=idx(randperm(length(idx)));
    MinDist=zeros(size_sheet);
    MinDist(idx)=values;
    
end


if(strcmp(time_windows_mode,'random_assignments_timewindows'))
    
    %Compute for every "cortical patch" the distance from the root(s) of the 
    %gradients
    for i=1:size(xy_coords_roots,1)

        dist=bsxfun(@minus, xy_coords_roots(i,:), horzcat(x,y));
        dist=power(dist,2);
        dist=sqrt(sum(dist,2));

        temp=zeros(size_sheet);

        idx = sub2ind(size_sheet,x,y);

        temp(idx)=dist;
        AllDistances(:,:,i)=temp;

    end

    %Compute for every patch the nearest distance to a root of a gradient.
    MinDist=min(AllDistances,[],3);
    MinDist=MinDist+1;%Avoid 0s
    MinDist=round(MinDist);

    %This is the only difference with the 'gradients' mode: The time
    %windows are now randomly assigned to patches, irrespective of the
    %distance of each patch from the root(s) of the gradients.
    idx=sub2ind(size_sheet,x,y);
    values=MinDist(:);
    values=values(randperm(length(values)));
    MinDist(idx)=values;

end

%We have to construct as many temporal windows as unique minimum 
%distances from the roots of gradients (or unique patches if we build random time windows).
%Unique min distances
unique_dist=unique(MinDist);

%Temporal scale
total_t=0:temporal_resolution:1;

%Use the unique min distances and the temporal resolution to construct the 
%timewindow for each cortical patch.

for patch=2:length(unique_dist)+1 %The indexes are shifted since for patch==1 NaNs appear 
    
    for time=1:length(total_t)

            TimeWindows(patch,time)=Ptime(patch, length(unique_dist)+1, total_t(time), a);

    end 
    
    %Normalize to [0 1]
    TimeWindows(patch,:)=TimeWindows(patch,:)./max(TimeWindows(patch,:));

end

%Rearrange TimeWindows to account for the +1 shift
tmp=TimeWindows;
clear TimeWindows;
TimeWindows=tmp(2:end,:);


return;


