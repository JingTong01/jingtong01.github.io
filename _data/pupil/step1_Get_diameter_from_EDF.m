%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%step 1 get diameter value from EDF data
% update: 2026.05.27
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all; clearvars;
addpath('D:\0eye_tracking\pupil-size-master\pupil-size-master\code\helperFunctions\importEDF');
root_dir='D:\0eye_tracking\1data_formal_exp1\0_rawData';
out_dir='D:\0eye_tracking\1data_formal_exp1\1_Diameter';
cd(root_dir);
trial_setting=readtable('trial_setting.xlsx');
edfFilename=dir('*.EDF');
sampleTable_allSub = table();

for s=1:length(edfFilename)
    tic
    hMex   = @edfmex; %#ok<NASGU>
    [~,rawEDF] = evalc(['edfmex(''' edfFilename(s).name ''');']);
    disp(edfFilename(s).name)

    %% from rawEDF.FEVENT.message to create resultTable,in which it includes time, all events, click_pic, trial ID

    % prepare message
    message_raw = {rawEDF.FEVENT.message}';
    message_cell = strings(length(message_raw),1);
    for i = 1:length(message_raw)
        if ischar(message_raw{i}) || isstring(message_raw{i})
            message_cell(i) = string(message_raw{i});
        elseif isnumeric(message_raw{i})
            message_cell(i) = string(num2str(message_raw{i}));
        else
            message_cell(i) = "";
        end
    end
    % get time
    eventTime_ms= double([rawEDF.FEVENT.sttime])';
    % all events
    targetEvents = {
        'helloclassifier'
        'hellotarget'
        '!V TRIAL_VAR Click_pic'
        'blank_screen'
        'TRIAL_RESULT 0'
        };
    allEvent = strings(0,1);
    allTime  = [];
    
    % look for the corresponding time for each event
    for k = 1:length(targetEvents)
        idx = contains(message_cell, targetEvents{k});
        allEvent = [allEvent; message_cell(idx)];
        allTime  = [allTime; eventTime_ms(idx)];
    end
    
    % create table and sort by time
    resultTable = table(allTime, allEvent);
    resultTable = sortrows(resultTable, 'allTime');
    
    % add trialID
    trialID = zeros(height(resultTable),1);
    currentTrial = 0;
    for i = 1:height(resultTable)
        if contains(resultTable.allEvent{i}, 'helloclassifier')
            currentTrial = currentTrial + 1;
        end
        trialID(i) = currentTrial;
    end
    resultTable.trialID = trialID;

    % add click_pic and ACC
    click_pic = strings(height(resultTable),1);
    for tr = unique(resultTable.trialID)'
        idxTrial = resultTable.trialID == tr;
        trialEvents = resultTable.allEvent(idxTrial);
        idxClick = contains(trialEvents, '!V TRIAL_VAR Click_pic');
        if any(idxClick)
            clickMsg = trialEvents{find(idxClick,1)};
            parts = split(string(clickMsg));
            picName = parts(end);
            click_pic(idxTrial) = picName;
    
        end

    end
    resultTable.click_pic = click_pic;
    %% add ACC and other information

    resultTable = outerjoin( ...
        resultTable, ...
        trial_setting(:,{'trialID','target','condition','target_cong'}), ...
        'Keys','trialID', ...
        'MergeKeys',true);

    resultTable.ACC = double( ...
        resultTable.click_pic == string(resultTable.target));
    
    %% create sample table and combine result and sample table

    %sample data
    t_ms= double(rawEDF.FSAMPLE.time)';
    R = double(rawEDF.FSAMPLE.pa(2,:)');
    RIGHT_GAZE_X = rawEDF.FSAMPLE.gx(2,:);
    RIGHT_GAZE_Y = rawEDF.FSAMPLE.gy(2,:);

    sampleTable = table();
    sampleTable.time = t_ms;
    sampleTable.R = R;
    sampleTable.gx = RIGHT_GAZE_X';
    sampleTable.gy = RIGHT_GAZE_Y';
    
    sampleTable.trialID = zeros(height(sampleTable),1);
    sampleTable.click_pic = strings(height(sampleTable),1);
    sampleTable.event = strings(height(sampleTable),1);
    
    % add trialID and click_pic (between helloclassifier and TRIAL_RESULT 0; TRIAL_RESULT 0 means the end of trial)
    trialStart = resultTable( ...
        contains(resultTable.allEvent, 'helloclassifier'), ...
        {'trialID','allTime','click_pic','target','condition','target_cong','ACC'});%trial start
    trialEnd = resultTable( ...
        contains(resultTable.allEvent, 'TRIAL_RESULT 0'), ...
        {'trialID','allTime','click_pic','target','condition','target_cong','ACC'});%trial end
    nTrial = min(height(trialStart), height(trialEnd));
    for tr = 1:nTrial
        startTime = trialStart.allTime(tr);
        endTime   = trialEnd.allTime(tr);
        idx = sampleTable.time >= startTime & ...
            sampleTable.time <= endTime;
        sampleTable.trialID(idx) = trialStart.trialID(tr);
        sampleTable.click_pic(idx) = trialStart.click_pic(tr);
        sampleTable.target(idx) = trialStart.target(tr);
        sampleTable.condition(idx) = trialStart.condition(tr);
        sampleTable.target_cong(idx) = trialStart.target_cong(tr);
        sampleTable.ACC(idx) = trialStart.ACC(tr);
    end

    % add events
    sampleTable.event = strings(height(sampleTable),1);
    for i = 1:height(resultTable)
        eventTime = resultTable.allTime(i);
        idx = find(sampleTable.time >= eventTime, 1, 'first');
        if ~isempty(idx)
            sampleTable.event(idx) = string(resultTable.allEvent{i});
        end
    end
   
  
    subName = erase(edfFilename(s).name, '.EDF');
    sampleTable.subID = repmat(string(subName), height(sampleTable), 1);
    % sampleTable_allSub = [sampleTable_allSub; sampleTable];
    file_sampleTable=fullfile(out_dir,[subName,'_sampleTable.mat']);
    % save(file_sampleTable, ...
    %     'sampleTable_allSub', ...
    %     '-v7.3');
    save(file_sampleTable, ...
        'sampleTable', ...
        '-v7.3');
    elapsedTime = toc;   % 结束计时
    fprintf('one_loop_runing_time: %.4f s\n', elapsedTime);
end








































