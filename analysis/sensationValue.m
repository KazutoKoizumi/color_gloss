%% 選考尺度値を求め、プロットする

%% Initialization
clear all

% name
exp = 'experiment_gloss';
sn = 'preexp_koizumi';

% result
sv = zeros(1,9,3,2,3,3,2);
errorRange = zeros(9,3,3,2,3,3,2);

% choose ML method
% choose ML method
fprintf('What ML method are you using?\n')
fprintf('   [1] Customized fminsearch in MLDS method\n');
fprintf('   [2] Normal fminsearch\n');
fprintf('   [3] fmincon for constrained parameter range (MATLAB only)\n');
method = input('Please enter 1, 2, or 3 (default: 3):   ');

% parameters
B = 10000; % Repetition number in Bootstrap
tnum = 1; % trial number in each stimulus pair in conventional experiment
stimnum = 9; % number of stimuli

% make ground truth: psychological sensation magnitude such as 'glossiness'
GroundTruth = rand(1,stimnum).*6-3; % range of Ground Truth of sensation magnitude

% make stimulus pairs
stimnum = length(GroundTruth);
cmbs = zeros((stimnum*(stimnum-1)./2), 2);
combinum = size(cmbs,1);
count = 1;
for a = 1:stimnum-1
    for b = a+1:stimnum
        cmbs(count,1) = a;
        cmbs(count,2) = b;
        count = count + 1;
    end
end

% show some info
fprintf('Ground truths of sensation values were created.\n');
fprintf('   Number of stimuli: %d\n', stimnum);
fprintf('   Number of stimulus combinations: %d\n\n', combinum);
if IsOctave, fflush(1); end

WaitSecs(0.2);

fprintf('Trial number per stimulus pair: %d\n\n\n', tnum);
fprintf('-> Total trial number: %d\n', tnum.*combinum)

snum = (length(cmbs).*tnum)./floor(stimnum/2); % make the trialnum equal between conventional and swiss-draw experiment
fprintf('Session number: %d\n', snum);
if IsOctave, fflush(1); end

%% preparation for different algorithms
startstring = {'Simulation of conventional paired comparison experiment..\n',...
               'Simulation of swiss-draw experiment..\n',...
               'Simulation of random stim-pair experiment..\n',...
               'Simulation of half swiss-draw and random experiment..\n'};
algostr = {'Conventional method', 'Swiss-draw', 'Pure-random', 'half swiss-random'};

% variable to store standard errors of each method
mean_se = zeros(1,4);

algo = 1;

%% load experiment result
load(strcat('../..//data/',exp,'/',sn,'/winTable/mtx'));
load(strcat('../..//data/',exp,'/',sn,'/winTable/OutOfNum'));
load(strcat('../..//data/',exp,'/',sn,'/winTable/NumGreater'));

sd = 1; % SD of sensation ('1' is the assumption of case V)


mtx = 1;
OutOfNum = 1;
%% analysis

for i = 1:3 % shape
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                for m = 1:2 % colorize(method)
                    
                    %% step1. Analysis to estimate sensation magnitude
                    % Analysis 1: Thurston's case V model based on z-score�itypically the results are slightly distorted�j
                    estimated_sv = TNT_FCN_PCanalysis_Thurston(mtx(:,:,i,j,k,l,m), 0.005);
                    estimated_sv = estimated_sv - mean(estimated_sv);

                    % Analysis 2: Maximum likelihood method�itypically better with enough trials�j
                    InitValues = estimated_sv - estimated_sv(1); % Thurston's estimated value is the initial value. But the leftmost value was set to be 0 to reduce DOF.
                    [estimated_sv2,NumGreater_v,OutOfNum_v] = TNT_FCN_PCanalysis_ML(OutOfNum(:,:,i,j,k,l,m), NumGreater(:,:,i,j,k,l,m), cmbs, InitValues, method);
                    estimated_sv2 = estimated_sv2 - mean(estimated_sv2);

                    fprintf('....Done!!\n\n\n');    if IsOctave, fflush(1); end
                    WaitSecs(0.8);


                    %% step2. Bootstrap analysis
                    str = ['Bootstrap analysis of ', algostr{algo}, '\n'];
                    fprintf(str);
                    fprintf('  Bootstrap repetition number: %d\n\n\n', B);
                    if IsOctave, fflush(1); end

                    % variables to store bootstrap samples
                    sv_th = zeros(B, stimnum); % Bootstrap samples for Thurston method.
                    sv_ml = zeros(B, stimnum); % Bootstrap samples for ML. -> typically this is better

                    pg = 1;
                    for b=1:B % makes bootstrap samples (requires a lot of processing time)
                    % show progress
                    if b/B>pg*0.05
                    fprintf('   progress...%2.0f%%\n', pg*0.05*100);if IsOctave, fflush(1); end
                    pg = pg+1;
                    end

                    % Simulation of observer responses 1: from results of Thurston's method (z-score)
                    if algo==1 % conventional method
                    [mtx_s, OutOfNum_s, NumGreater_s] = TNT_FCN_ObsResSimulation(estimated_sv, cmbs, tnum, sd);
                    else % swiss-draw method, random method, or half of swiss-draw and random method(2,3, or 4)
                    [mtx_s, OutOfNum_s, NumGreater_s] = TNT_FCN_ObsResSimulation_swiss(estimated_sv, cmbs, snum, sd, method, 0, algo-1);
                    end

                    % Analysis�Fz-score
                    sv_th(b,:) = TNT_FCN_PCanalysis_Thurston(mtx_s, 0.005);
                    sv_th(b,:) = sv_th(b,:) - mean(sv_th(b,:));


                    % Simulation of observer responses 2: from results of ML
                    if algo==1 % conventional method
                    [mtx_s, OutOfNum_s, NumGreater_s] = TNT_FCN_ObsResSimulation(estimated_sv2, cmbs, tnum, sd);
                    else % swiss-draw method, random method, or half of swiss-draw and random method(2,3, or 4)
                    [mtx_s, OutOfNum_s, NumGreater_s] = TNT_FCN_ObsResSimulation_swiss(estimated_sv2, cmbs, snum, sd, method, 0, algo-1);
                    end

                    % pre-analysis based on Thurston's case V (using z-score)
                    prediction = TNT_FCN_PCanalysis_Thurston(mtx_s, 0.005);

                    % Analysis: Maximum likelihood
                    InitValues = prediction - prediction(1); % from pre-analysis: the leftmost value was set to be 0 to reduce DOF
                    [sv_ml(b,:), dummy1, dummy2] = TNT_FCN_PCanalysis_ML(OutOfNum_s, NumGreater_s, cmbs, InitValues, method);
                    sv_ml(b,:) = sv_ml(b,:) - mean(sv_ml(b,:));
                    end

                    % simple SE: not used (�����o�C�A�X���l�����ƕs�K�؂�)
                    ses_th = std(sv_th); % by Thurston
                    ses_ml = std(sv_ml); % by ML
                    fprintf('....Done!!\n\n\n');   if IsOctave, fflush(1); end

                    % 68% confidence interval (~=SE) based on Bootstrap samples
                    ranges68_th = zeros(stimnum, 3); % 68%CI�@by Thurston
                    ranges68_ml = zeros(stimnum, 3); % 68%CI�@by ML
                    ubi = round(B*84/100);
                    lbi = round(B*16/100);
                    mi = round(B./2);
                    for s=1:stimnum
                    % for Thurston data
                    sdata = sort(sv_th(:,s));
                    ranges68_th(s,1) = sdata(lbi)-sdata(mi); % lower bound
                    ranges68_th(s,2) = sdata(ubi)-sdata(mi); % upper bound
                    ranges68_th(s,3) = sdata(mi);

                    % for ML data
                    sdata = sort(sv_ml(:,s));
                    ranges68_ml(s,1) = sdata(lbi)-sdata(mi); % lower bound
                    ranges68_ml(s,2) = sdata(ubi)-sdata(mi); % upper bound
                    ranges68_ml(s,3) = sdata(mi);
                    end
                    
                    % record data
                    sv(:,:,i,j,k,l,m) = estimated_v2;
                    errorRange(:,:,i,j,k,l,m) = range68_ml;

                    %{
                    %% just to compare the experiment procedures: plot the simulation results
                    % Comparison of Thurston and ML: estimated sensation values with error bars.
                    str = ['Ground truth vs Estimated: ', algostr{algo}];
                    figure('Position',[1 1 800 300], 'Name', str);
                    subplot(1,2,1); hold on;
                    plot(GroundTruth, estimated_sv, 'ok');
                    errorbar(GroundTruth, ranges68_th(:,3), -ranges68_th(:,1), ranges68_th(:,2), '.k'); % 68%CI
                    plot([-4 4], [-4 4],'--k')
                    title('Estimated by Thurston method')
                    xlabel('Ground truth');
                    ylabel('Estimated sensation value');
                    subplot(1,2,2); hold on;
                    plot(GroundTruth, estimated_sv2, 'ok');
                    errorbar(GroundTruth, ranges68_ml(:,3), -ranges68_ml(:,1), ranges68_ml(:,2), '.k'); % 68%CI
                    plot([-4 4], [-4 4],'--k')
                    title('Estimated by maximum likelihood method')
                    xlabel('Ground truth');
                    ylabel('Estimated sensation value');


                    % Histograms of bootstrap samples of the minimum sensation value
                    [dummy, index] = min(GroundTruth);
                    str = ['Histogram of estimated values', algostr{algo}];
                    figure('Position',[1 1 800 300], 'Name', str);
                    subplot(1,2,1); hold on;
                    hist(sv_th(:,index), 20);
                    title('Thurston method');

                    subplot(1,2,2); hold on;
                    hist(sv_ml(:,index), 20);
                    title('Maximum likelihood');


                    % shows psychometric function in the analysis
                    if algo==2
                    params = estimated_sv2 - estimated_sv2(1);
                    dummy = TNT_FCN_MLDS_negLL(params(2:end), cmbs, NumGreater_v, OutOfNum_v, 1);
                    end


                    %% save standard errors of each method
                    mean_se(algo) = mean(ses_ml);

                    fprintf('Mean standard error of each experimental algorithm (analyzed by maximum likelihood method)\n');
                    fprintf('   conventional method: %f\n', mean_se(1));
                    %}
                end
            end
        end
    end
end

%% save data
save(strcat('../../analysis_result/',exp,'/',sn,'/sv', 'sv'));
save(strcat('../../analysis_result/',exp,'/',sn,'/errorRange', 'errorRange'));
