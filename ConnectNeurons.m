%The function connects the neutrons that populate the synthetic brain
%at a given time point
%
%It is used from the pcs_temporalwindows.m main function
%
%Input: 
%
%CorticalSheet:         The 2D sheet NxM containing the neurons at t 
%                       time points. The matrix is a 3D with 
%                       dimensions: NxMxt
%                       It must be passed as a 2D matrix NxM summing
%                       across timepjoint t
%			 
%Occupancy:             A 2D matrix NxM denoting how many in-connections 
%                       can be established per patch
%
%Established:           A 2D matrix NxM denoting how many in-connections 
%                       are established per patch	
%	
%
%occupancy_thres:       positive integer denoting how many 
%                       in-connections a neutron can establish
%			 
%
%distance_thres:        a float denoting the distance of a 
%
%Output:
%	
%ConnList:              A struct with field .from and .to
%                       Each field is a 1x2 vector of integers
%                       which correspond to the x,y coord 
%                       of the connected neurons 
%
%Occupancy:             A 2D matrix NxM denoting how many in-connections 
%                       can be established per patch after the new 
%                       connections are formed
%
%Established:           A 2D matrix NxM denoting how many in-connections 
%                       are established per patch after the new connections
%                       are formed
%
%--------------------------------------------------------------------------

function [ConnList, Established, Occupancy]=ConnectNeurons(CorticalSheet, Occupancy, Established, occupancy_thres, distance_thres)


%Ok here is what needs to be done. Get all the locations from places of the
%cortical sheet that are populated by at least one neuron. 

ConnList=[];

conn_ind=1;

neurons_ind=find(CorticalSheet ~= 0);
occupancy_ind=find((Occupancy.*CorticalSheet) < (CorticalSheet.*occupancy_thres));
established_ind=find((Established == 0) | (Established < CorticalSheet));

%How many neurons can establish connections?
neurons_can_sendconn=intersect(neurons_ind,established_ind);
neurons_can_receiveconn=intersect(neurons_ind,occupancy_ind);

[sendneurons_x,sendneurons_y] = ind2sub(size(CorticalSheet),neurons_can_sendconn);
[receiveneurons_x,receiveneurons_y] = ind2sub(size(CorticalSheet),neurons_can_receiveconn);

%Establish an upper ceiling nr of attempts to connect neurons
upper_limit=length(sendneurons_x);

%With random order see if a neuron can establish a connection with another
%neuron
counter_upper_limit=1;

ind_rand=randperm(length(sendneurons_x));

sendneurons_x=sendneurons_x(ind_rand);
sendneurons_y=sendneurons_y(ind_rand);

for attempt=1:length(sendneurons_x)
    

    x_current=sendneurons_x(attempt);
    y_current=sendneurons_y(attempt);
    
    %nr_neurons_in_position=CorticalSheet(x_current,y_current);
    
    %for n=1:length(nr_neurons_in_position)      
     
        %Pick a random point in a unit circle. 
        
        r=1; 
        w = r * sqrt(rand); 
        t = 2 * pi * rand;
        x = w * cos(t); 
        y = w * sin(t);
        
        new_point_x=x_current+x;
        new_point_y=y_current+y;
        
        %Calculate distances to the line defined by the current point and
        %the new point
        d=zeros(1,length(receiveneurons_x));
        
        for dist_ind=1:length(receiveneurons_x)%Vectorize this!!!!!!!!!!!!!!!!!!
        
            d(dist_ind)=DistFromLine([x_current y_current],[new_point_x new_point_y],horzcat(receiveneurons_x(dist_ind),receiveneurons_y(dist_ind)));
        
        end
        
        %Which distances are smaller than the distance_thres?
        potential_connections=find(d <= distance_thres);
        
%         potential_connections(positions)=0;
%         potential_connections=potential_connections(potential_connections~=0);
        
        %If more than a neuron can be a target then
        if(length(potential_connections) > 1)
            
            while 1
                
                choice_ind=1:length(potential_connections);
                choice_ind=choice_ind(randperm(length(potential_connections)));
                choice=potential_connections(choice_ind(1));
                
                 if((receiveneurons_x(choice) ~= x_current) | (receiveneurons_y(choice)) ~= y_current)
                    break; 
                 end
                
            end
            
            ConnList(conn_ind).from=[x_current y_current];
            ConnList(conn_ind).to=[receiveneurons_x(choice) receiveneurons_y(choice)];
              
            conn_ind=conn_ind+1; 
              
            %Update the Occupied and Established indexes
            Occupancy(receiveneurons_x(choice),receiveneurons_y(choice))=Occupancy(receiveneurons_x(choice),receiveneurons_y(choice))+1;
            Established(x_current,y_current)=Established(x_current,y_current)+1;
                       
        
        end
        
        if((length(potential_connections)==1))
        
            if((sub2ind(size(CorticalSheet),x_current,y_current) ~= sub2ind(size(CorticalSheet),receiveneurons_x(potential_connections),receiveneurons_y(potential_connections))))
                
              ConnList(conn_ind).from=[x_current y_current];
              ConnList(conn_ind).to=[receiveneurons_x(potential_connections) receiveneurons_y(potential_connections)];
              
              conn_ind=conn_ind+1; 
              
              %Update the Occupied and Established indexes
              Occupancy(receiveneurons_x(potential_connections),receiveneurons_y(potential_connections))=Occupancy(receiveneurons_x(potential_connections),receiveneurons_y(potential_connections))+1;
              Established(x_current,y_current)=Established(x_current,y_current)+1;
              
            end
            
            
        end
        
        
        %The occupancy and establishment positions have been updated so
        %grab the neurons corresponding to the new status
        occupancy_ind=find((Occupancy.*CorticalSheet) < (CorticalSheet.*occupancy_thres));
        %established_ind=find((Established == 0) | (Established < CorticalSheet));

        %How many neurons can establish connections?
        %neurons_can_sendconn=intersect(neurons_ind,established_ind);
        neurons_can_receiveconn=intersect(neurons_ind,occupancy_ind);

        %[sendneurons_x,sendneurons_y] = ind2sub(size(CorticalSheet),neurons_can_sendconn);
        [receiveneurons_x,receiveneurons_y] = ind2sub(size(CorticalSheet),neurons_can_receiveconn);
        
        
    %end
    
    %This means that the neurons have only ONE opportunity to establish
    %connections
    %Established(x_current,y_current)=Established(x_current,y_current)+1;
       
    if(upper_limit==counter_upper_limit)
       break; 
    else
        counter_upper_limit=counter_upper_limit+1; 
    end
    
    
    
end    
    

return