% Select a folder containing all the aquired QP series (Rest and Stress)

% version 1.0.1

function ViewAcqTime()

% path to main folder
path = GetPath;

% find folders with the AcqTime tag
% (one for rest and one for stress)
Files = GetSpecificFile(path,'*AcqTime*','');

% give some info
disp(['Found ' num2str(length(Files)) ' folders at the designated path with AcquisitionTime attribute in Dicom header'])
disp('Extracting AcquisitionTime attribute from detected files ...')

% for the content of each of the two folders do:
for k1 = 1:length(Files)

    % detect files with the .dcm extension
    extension = '.dcm';
    dirData = dir([Files{k1} '/*' extension]); % look for files with ext

    % for each dicom file load Dicom header and get AcquisitionTime
    % This has been improved by removing dicominfo and using an object
    % instead where the desired attribute can be extracted
    for k2 = 1:length(dirData)
        file_string = [Files{k1} '/' dirData(k2).name];
        obj = images.internal.dicom.DICOMFile(file_string);
        time_data.AcquisitionTime(k2) = ...
            str2num(obj.getAttributeByName('AcquisitionTime'));
    end

    % also get the number of dynamic phases
    time_data.NumberOfTemporalPositions = ...
        obj.getAttributeByName('NumberOfTemporalPositions');
    NumPhases = time_data.NumberOfTemporalPositions;

    % calculate the number of acquired slices
    NumSlice = length(dirData)./NumPhases;

    % absolute time for slice acquisitions
    % (first column is AIF, the following are MYO stack)
    slice_time = reshape(time_data.AcquisitionTime,[],NumSlice);

    % relative time for slice acquisitions
    % (first column is AIF, the following are MYO stack)
    rel_slice_trig = padarray(diff(slice_time),[1,0],'pre');

    % fix the random '40 second error'
    error = 40;
    rel_slice_trig(rel_slice_trig > error) = ...
        rel_slice_trig(rel_slice_trig > error) - error;

    % calculate cumulative Acquisition Times
    % (first column is AIF, the following are MYO stack)
    slice_trig = cumsum(rel_slice_trig);

    % approximate 1RR interval
    oneRR = min(rel_slice_trig(rel_slice_trig>0));

    % approximate 2RR percentage
    % find number of 2RR intervals as a multiplication of 1RR length
    mean_timings = mean(rel_slice_trig, 2);
    twoRR = sum(mean_timings>(oneRR.*1.5));
    percentage = round(twoRR./length(mean_timings).*100);
    twoRR_sixty = sum(mean_timings(1:60)>(oneRR.*1.5));
    percentage_sixty = round(twoRR_sixty./length(mean_timings(1:60)).*100);

    % plots
    subplot(2,1,k1)

        % plot the start of dynamic phase acquisition as a stick

        % AIF
        stem(slice_trig(:,1),0.65 .* ones(size(slice_trig(:,2))),':diamondr','filled');

        hold on;

        % Slice stack
        stem(slice_trig(:,2),0.75 .* ones(size(slice_trig(:,2))),'b','filled');

        % plot the duration of one RR interval as a colored box
        hline = line(NaN,NaN,'LineWidth',6,'Color',[0 .5 .5]);
        x = slice_trig(:,2); y = 0; h = 0.6; w = oneRR;
        for k = 1:length(x)
            rectangle('Position',[x(k),y,w,h],'FaceColor',[0 .5 .5]);
        end

        % plot percentage 2RR intervals
        string1 = sprintf("%d%% 2RR",percentage);
        text(10,1,string1,'FontSize',10)
        string2 = sprintf("First 60 phases: %d%% 2RR",percentage_sixty);
        text(10,0.9,string2,'FontSize',10)

        % set the plot dimensions
        xlabel('Acquisition Time [sec.]')

        if contains(Files{k1},'Stress') | contains(Files{k1},'STRESS')
            ylabel('Stress Scan')
        elseif contains(Files{k1},'Rest') | contains(Files{k1},'REST')
            ylabel('Rest Scan')
        else % terminate and throw error
            disp('Error - check if main folder contains Rest and Stress dataset')
        end

        xlim([-2 slice_trig(end,2) + 5])
        ylim([0 1.2])

        legend('AIF Acquisition Time','Slice Acquisition Time','~1RR interval')

end % end main loop

% give some info
disp('Done')
disp('Exporting report .pdf')

% export a pdf
string = [path.full '/AcquisitionTimeDiagram'];
export_fig(string, '-pdf');

end % end function
