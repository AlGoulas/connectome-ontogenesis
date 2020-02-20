%The function populates a synthetic brain ("cortical sheet") with neurons
%in a spatially ordered manner and neurons form conenctions with each other 
%in a stochastic manner.
%
%Input: 
%
%sizesheet:     [M N] vector of positive integers descibing the 2D (MxN) 
%               size of the synthetic sheet 
%
%seedpoints:    [K x 2] matrix. Each row is a 2D vector specifiying the 2D
%               coordinates of the roots(seeds) of the gradients
%
%a:             positive float number controlling the width of the
%               timewindows. 
%
%temporal_resolution:
%
%               positive float specifying the temporal "tick" that needs to 
%               be taken at each step. It ranges in [0 1] and thus 
%               specifies the total time points of the simulations
%               E.g. if temporal_resolution = 0.1, then
%               the simulations will unfold in this time frame:
%               0, 0.1, 0.2, ...1 
%
%neuron_rate:   float dictating the increase of the number of neurons
%               to populate the synthetic brain. The increase of neurons
%               is exponential and based on the formula:
%               neurons=neurons_init*power((1+neuron_rate),time); 
%
%neurons:       positive integer specifying the intial number of neurons 
%
%distance_to_connect:
%
%               a positive float specifying the minimum distance 
%               between an axon and a neuron that can lead to an 
%               establishment of a connection  
%
%occupancy_thres:
%
%               positive integer denoting how many 
%               in-connections a neutron can establish
%
%(used from the MakeCorticalSheet_TemporalWindows.m function)
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
%
%Output:
%
%AllConnList:   1 x nr of time points cell containing all the structs 
%               (ConnListreturned from ConnectNeurons.m) specifying the 
%               connections established at each time point of the 
%               simulation
%
%AllCorticalSheet:
%               
%               A 3D matrix (MxNxt) where M N are the 2D dimensions 
%               of the synthetic sheet and t are the timepoints specifying
%               the time frame wherein the simulations took place.
%               Each entry of the 2D matrix AllCorticalSheet(:,:,t) is a 
%               positive integer denoting the number of neurons that occupy
%               each brain patch (in the synthetic brain) at a time point t
%               of the simulations
%
%Occupancy:     A 2D matrix NxM denoting how many in-connections 
%                       can be established per patch
%
%Established:   A 2D matrix NxM denoting how many in-connections 
%               are established per patch	
%
%TimeWindows:   Kxt matrix denoting the unique time windows 
%               for each unique patches of the sheet, where K the number of 
%               unique patches and t the number of time points of the
%               simulation.
%
%Note:  Many inputs concern other functions used by the current one:
%       ConnectNeurons.m 
%       MakeCorticalSheet_TemporalWindows.m
%--------------------------------------------------------------------------

function [AllCorticalSheet, AllConnList, Established, Occupancy, TimeWindows]=pcs_temporalwindows(sizesheet, seedpoints, a, temporal_resolution, neuron_rate, neurons, distance_to_connect, occupancy_thres, time_windows_mode)


neurons_init=neurons;

%Initialize Cortical sheet and assign timewindows
[~, MinDist, TimeWindows]=MakeCorticalSheet_TemporalWindows(sizesheet, seedpoints, a, temporal_resolution, time_windows_mode);

%This is a length(Unique_MinDist)x1 vector with all the unique elements.
Unique_MinDist=unique(MinDist);

Occupancy=zeros(sizesheet);
Established=zeros(sizesheet);

AllConnList={};
AllCorticalSheet=zeros(sizesheet(1), sizesheet(2), size(TimeWindows,2));

for time=1:size(TimeWindows,2)

    fprintf('\nTimepoint:%d/%d\n',time,size(TimeWindows,2));   
    
    %Get the probabilities for the current time point
    CurrentProbabilities=TimeWindows(:,time);
    
    %Get the entries that should be populated at the current time point
    to_populate_idx=find(CurrentProbabilities > rand);
    
    entries_to_be_populated=Unique_MinDist(to_populate_idx);
    
    %If there are positions to be populated then populate them and 
    %connect the cortical sheet.
    if (~isempty(entries_to_be_populated))
        
        %Make current cortical sheet
        CurrentCorticalSheet=zeros(sizesheet);
        
        %Fill-in the cortical sheet (to be vectorized!)
        for n=1:neurons
           
            pos=floor(length(entries_to_be_populated)*rand(1))+1;
            ind=find(entries_to_be_populated(pos)==MinDist);
            
            CurrentCorticalSheet(ind)=CurrentCorticalSheet(ind)+1;
            
        end        
        
        %Keep the cortical sheet status for this developmental timewindow
        AllCorticalSheet(:,:,time)=CurrentCorticalSheet;  

        %Now grow uniformly and at random connections from every neuron that
        %has populated the cortical sheet until this step.
        [ConnList, Occupancy, Established]=ConnectNeurons(sum(AllCorticalSheet,3), Occupancy, Established, occupancy_thres, distance_to_connect);
        AllConnList{time}=ConnList;  
    
    end
    
    %Increase the number of neurons for the next time point in an
    %exponential manner (it will be parametrized to accomodate many types of growth).
    neurons=neurons_init*power((1+neuron_rate),time);
    
     
end

return

