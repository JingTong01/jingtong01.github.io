%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%step 3 cluster preparation + plotting
% update: 2026.05.27
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear; clc;

data_dir = 'D:\0eye_tracking\1data_formal_exp1\2_Preprocessed';
out_dir = 'D:\0eye_tracking\1data_formal_exp1\3_Prepara_for_cluster';
files_sub = dir(fullfile(data_dir, '*_step2'));

% initialize empty table
 T_all_trial_sub = table();
for s = 1:length(files_sub)
    disp(files_sub(s).name)
    trial_dir = fullfile(data_dir, files_sub(s).name);
    file_trial = dir(fullfile(trial_dir, '*.mat'));

    % extract subject ID
    subID = erase(files_sub(s).name, '_step2');
    T_all_trial = table();
    for i = 1:length(file_trial)
       
        file_path = fullfile(trial_dir, file_trial(i).name);
        S_trial = load(file_path);

        ep = S_trial.pupilEpoch;

        % skip rejected trials
        if ep.rejectTrial
            continue
        end

        time = ep.t_ms(:);      % column vector
        pupil = ep.R(:);        % column vector

        condition = string(ep.condition{1});

        nTime = length(time);

        % repeat values for all time points
        subID_col = repmat(s, nTime, 1);
        trialID_col = repmat(i, nTime, 1);
        condition_col = repmat(condition, nTime, 1);

        % create table
        T = table( ...
            subID_col, ...
            trialID_col, ...
            time, ...
            pupil, ...
            condition_col, ...
            'VariableNames', ...
            {'subID','trialID','time','pupil','condition'} );
        % concatenate
        T_all_trial = [T_all_trial; T];

    end
    T_all_trial_sub=[T_all_trial_sub; T_all_trial];

    
   
end
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

writetable(T_all_trial_sub, fullfile(out_dir, 'stp3_allsub.txt'), ...
    'Delimiter', '\t');



figure; hold on;

subs = unique(T_all_trial_sub.subID);
conds = unique(T_all_trial_sub.condition);

common_time = 0:10:780;  

colors = lines(length(conds)); % clean color palette

for c = 1:length(conds)

    cond = conds(c);

    subj_mean_all = [];

    for s = 1:length(subs)

        idx = T_all_trial_sub.subID == subs(s) & ...
              T_all_trial_sub.condition == cond;

        Tsub = T_all_trial_sub(idx, :);

        % event window
        Tsub = Tsub(Tsub.time >= 0 & Tsub.time <= 780, :);

        if isempty(Tsub)
            continue
        end

        % subject mean
        [t_unique, ~, ic] = unique(Tsub.time);
        mean_pupil = accumarray(ic, Tsub.pupil, [], @mean);

        % interpolate to common time axis
        pupil_interp = interp1(t_unique, mean_pupil, common_time);

        subj_mean_all = [subj_mean_all, pupil_interp(:)];

    end

    % grand average
    grand_mean = mean(subj_mean_all, 2, 'omitnan');
    grand_sem  = std(subj_mean_all, 0, 2, 'omitnan') / sqrt(size(subj_mean_all,2));

    % shading (clean)
    hFill = fill([common_time fliplr(common_time)], ...
        [grand_mean'-grand_sem' fliplr(grand_mean'+grand_sem')], ...
        colors(c,:), ...
        'FaceAlpha', 0.25, ...
        'EdgeColor', 'none');

    % remove fill from legend
    hFill.HandleVisibility = 'off';

    % line
    plot(common_time, grand_mean, ...
        'Color', colors(c,:), ...
        'LineWidth', 2.5, ...
        'DisplayName', char(cond));
end


xlabel('Time (ms)', 'FontSize', 14, 'FontName', 'Arial');
ylabel('Pupil size (a.u.)', 'FontSize', 14, 'FontName', 'Arial');

title('Pupil response (0–780 ms)', ...
    'FontSize', 15, 'FontName', 'Arial');

set(gca, ...
    'FontSize', 12, ...
    'FontName', 'Arial', ...
    'LineWidth', 1.2, ...
    'Box', 'off');

legend('Location','best','Box','off','Interpreter','none');

xlim([0 780]);
exportgraphics(gcf, fullfile(out_dir, 'pupil_grand_average_exp1.png'), 'Resolution', 300);