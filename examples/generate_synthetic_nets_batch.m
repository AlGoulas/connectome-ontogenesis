

generate_synthetic_nets_batch(nr_of_sheets, size_of_sheets, nr_of_gradients, range_of_a, temporal_resolution, neuron_rate, neurons, distance_to_connect, occupancy_thres, time_windows_mode, name)

for alpha=1:length(range_of_a)
    
    current_a=range_of_a(alpha);
    
    %Seed for the roots of the gradients
    for s=1:length(nr_of_gradients)

        mkdir(strcat('alpha_',num2str(current_a),'nr_of_gradients',num2str(nr_of_gradients(s))));
        cd(strcat('alpha_',num2str(current_a),'nr_of_gradients',num2str(nr_of_gradients(s))));

        for sheets=1:nr_of_sheets

            
            %Create the seeds for the roots of the gradients
            %based on the number of gradients and the size of the sheet
            
            for i=1:nr_of_gradients(s)
               
                seedpoints(i,1)=floor(size_of_sheets(1)*rand(1))+1;
                seedpoints(i,2)=floor(size_of_sheets(2)*rand(1))+1;
                
            end

            %Make the cortical sheet with the current settings
            [AllCorticalSheet, AllConnList, Established, Occupancy, TimeWindows]=pcs_temporalwindows(size_of_sheets, seedpoints, current_a, temporal_resolution, neuron_rate, neurons, distance_to_connect, occupancy_thres, time_windows_mode);

            TotalData(sheets).AllCorticalSheet=AllCorticalSheet;
            TotalData(sheets).AllConnList=AllConnList;
            TotalData(sheets).Established=Established;
            TotalData(sheets).Occupancy=Occupancy;
            TotalData(sheets).TimeWindows=TimeWindows;
            TotalData(sheets).current_a=current_a;
            TotalData(sheets).seedpoints=seedpoints;
            TotalData(sheets).temporal_resolution=temporal_resolution;
            TotalData(sheets).neuron_rate=neuron_rate;
            TotalData(sheets).neurons=neurons;
            TotalData(sheets).distance_to_connect=distance_to_connect;
            TotalData(sheets).occupancy_thres=occupancy_thres;

            
        end

        save(name,'TotalData');

        cd('..');
        
    end

end

