%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%step 2: preprocessing the data,including:
% epoch extraction
% blink interpolation
% smoothing
% baseline correction
% reject bad trials
% update: 2026.05.27
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


close all;
clearvars;


root_dir = 'D:\0eye_tracking\1data_formal_exp1\1_Diameter';
out_dir  = 'D:\0eye_tracking\1data_formal_exp1\2_Preprocessed';
cd(root_dir);

file_mat = dir('*_sampleTable.mat');
fs = 1000;% sampling rate

% epoch window
epoch_pre  = 500;% ms
epoch_post = 780;% ms

% baseline window
baseline_start = -200;
baseline_end   = 0;

% smoothing
smooth_window = 20;

% blink interpolation
max_gap_ms = 200;

% bad trial rejection
nan_threshold = 0.50;


for m = 1:length(file_mat)
    tic
    disp(file_mat(m).name)

    loadedData = load(file_mat(m).name);
    sampleTable = loadedData.sampleTable;
    subName = erase(file_mat(m).name, '_sampleTable.mat');
    disp(['Processing ', subName])
   
    % output
    trial_outdir = fullfile(out_dir, [subName '_step2']);
    if ~exist(trial_outdir,'dir')
        mkdir(trial_outdir);
    end

    % trial list
    trialList = unique(sampleTable.trialID);
    trialList(trialList == 0) = [];

   
    % loop trials
    for tr = 1:length(trialList)

        currentTrial = trialList(tr);

        % select trial
        idxTrial = sampleTable.trialID == currentTrial;
        trialData = sampleTable(idxTrial,:);
        if isempty(trialData)
            continue
        end

        %exclude ACC=0
        accVal = unique(trialData.ACC);

        if any(accVal == 0)
            continue
        end

        %exclude condition 3(control condition)
        accVal = string(unique(trialData.condition));

        if any(accVal == '3')
            continue
        end

      
        % find target onset 
        idxTarget = contains( ...
            trialData.event, ...
            'hellotarget');

        if ~any(idxTarget)
            continue
        end

        targetTime = ...
            trialData.time(find(idxTarget,1));

       
        % epoch extraction
        epochStart = targetTime - epoch_pre;
        epochEnd   = targetTime + epoch_post;

        idxEpoch = ...
            trialData.time >= epochStart & ...
            trialData.time <= epochEnd;

        epochData = trialData(idxEpoch,:);

        if isempty(epochData)
            continue
        end

       
        % relative time
        t_ms = epochData.time - targetTime;

       
        % pupil signal 
        R = double(epochData.R);

        
        % remove impossible values 
        R(R <= 0) = NaN;
       
        % blink interpolation
        
        nanIdx = isnan(R);
        if any(nanIdx)
            x = 1:length(R);
            validIdx = ~nanIdx;
            if sum(validIdx) > 2
                R_interp = interp1( ...
                    x(validIdx), ...
                    R(validIdx), ...
                    x, ...
                    'linear');

                % detect NaN gaps
                d = diff([0 nanIdx' 0]);
                gapStart = find(d == 1);
                gapEnd   = find(d == -1) - 1;
                gapLength = gapEnd - gapStart + 1;

                % preserve large gaps
                for g = 1:length(gapLength)

                    if gapLength(g) > max_gap_ms

                        R_interp( ...
                            gapStart(g):gapEnd(g)) = NaN;
                    end
                end

                R = R_interp;

            end
        end

       
        % smoothing 
        R_smooth = smoothdata( ...
            R, ...
            'sgolay', ...
            smooth_window);

       
        % baseline correction
        baselineIdx = ...
            t_ms >= baseline_start & ...
            t_ms <= baseline_end;

        baseline = mean( ...
            R_smooth(baselineIdx), ...
            'omitnan');

        R_baseline = R_smooth - baseline;

       
        %bad trial rejection 
        rejectTrial = false;

        % too many NaNs
        nanRatio = sum(isnan(R_baseline)) / length(R_baseline);
        if nanRatio > nan_threshold
            rejectTrial = true;
        end

        % flat signal
        signalSTD = std(R_baseline,'omitnan');
        if signalSTD < 0.01
            rejectTrial = true;
        end

        % too few valid samples
        validRatio = ...
            sum(~isnan(R_baseline)) / length(R_baseline);
        if validRatio < 0.5
            rejectTrial = true;
        end
       
        % create output structure
        
        pupilEpoch = struct();
        pupilEpoch.t_ms = t_ms;
        pupilEpoch.R = R_baseline;

        % duplicate right eye
        pupilEpoch.L = R_baseline;

        pupilEpoch.trialID = currentTrial;

        pupilEpoch.condition = ...
            unique(epochData.target_cong);

        pupilEpoch.target = ...
            unique(epochData.target);

        pupilEpoch.ACC = ...
            unique(epochData.ACC);

        pupilEpoch.rejectTrial = rejectTrial;

        pupilEpoch.nanRatio = nanRatio;

        pupilEpoch.signalSTD = signalSTD;

        % save
        saveName = fullfile( ...
            trial_outdir, ...
            ['pupil_epoch_' ...
            subName ...
            '_trial_' ...
            num2str(currentTrial) ...
            '.mat']);

        save(saveName,'pupilEpoch');
    end

    elapsedTime = toc;

    fprintf('one_loop_running_time: %.4f s\n', elapsedTime);

end
