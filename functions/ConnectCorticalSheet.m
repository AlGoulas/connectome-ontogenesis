%The function receives as input a 2D sheet and Areas and reconnects
%the neurons conained in the Sheet unti the desity of the area-to-area
%matrix reaches the network_density_threshold value. 
%
%This is a static mode of connectivity formation since neurons are
%simultaneously present in the sheet and not added in a spatial or temporal
%fashion.
%
%Input:
%
%Sheet:         A 2D MxN matrix
%               Each entry of the 2D matrix Sheet is a 
%               positive integer denoting the number of neurons that occupy
%               each brain patch (in the synthetic brain).
%
%Areas:         A 2D matrix with unique integers denoting each area.
%
%network_density_threshold:
%
%               The connection denity of the matrix functioning as a
%               stopping criterion for the connectivity formation between
%               the neurons of the Sheet.
%
%distance_to_connect:
%
%               Positive float specifying the minimum distance 
%               between an axon and a neuron that can lead to an 
%               establishment of a connection  
%
%occupancy_thres:
%
%               Positive integer denoting how many 
%               in-connections a neuron can establish
%
%Output:
%
%AllConnList:   1 x nr of time points cell containing all the structs 
%               (ConnList returned from ConnectNeurons.m) specifying the 
%               connections established at each time point of the 
%               simulation
%
%Occupancy:     A 2D matrix NxM denoting how many in-connections 
%               can be established per patch
%
%Established:   A 2D matrix NxM denoting how many in-connections 
%               are established per patch
%
%--------------------------------------------------------------------------

function [AllConnList, Occupancy, Established]=ConnectCorticalSheet(Sheet, Areas, network_density_threshold, occupancy_thres, distance_to_connect)

Occupancy=zeros(size(Sheet));
Established=zeros(size(Sheet));

iter=1;
AllConnList={};


while 1

    fprintf('\nIter:%d\n',iter);
     
    [ConnList, Established, Occupancy]=ConnectNeurons(Sheet, Occupancy, Established, occupancy_thres, distance_to_connect);%Careful with how the arguments are passed!
    AllConnList{iter}=ConnList;
    
    %[C]=RunStatsOnAreaConnection(AllConnList, Sheet, Areas, length(unique(Areas)), [], 0);
    [C,~]=AssembleAreaWiseMatrix(AllConnList, Areas);
    kden=density_dir(C);

    if(kden >= network_density_threshold)
       break; 
    end

    iter=iter+1;


end


end
