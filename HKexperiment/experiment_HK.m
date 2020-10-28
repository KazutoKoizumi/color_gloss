%% サーストンの一対比較法で光沢感を測定する実験
clear all

%% 初期準備
% input date, subject name, session number
date = datetime;
sn = input('Subject Name?: ', 's');
sessionNum = input('Session Number?: ');

% filename
dataTableName = sprintf('../../data/experiment_HK/%s/table_%s', sn,sn);
orderFile = sprintf('../../data/experiment_HK/%s/order_%s.mat', sn,sn);
sessionFile = sprintf('../../data/experiment_HK/%s/session%s/session%s_table_%s', sn,num2str(sessionNum),num2str(sessionNum),sn);
recordFile = sprintf('../../data/experiment_HK/%s/record_%s.txt', sn,sn);

% make directory
mkdir(strcat('../../data/experiment_HK/',sn));
mkdir(strcat('../../data/experiment_gloss/',sn,'/session',num2str(sessionNum)));

AssertOpenGL;
ListenChar(2);
KbName('UnifyKeyNames');
screenNumber = max(Screen('Screens'));
%InitializeMatlabOpenGL;

%% 刺激のパラメータ数
lumNum = 3;
satNum = 3;
colorNum = 8;
stiNum = lumNum * satNum * colorNum;


%% 実験画面の背景色設定
load('../../mat/ccmat.mat');
load('../../mat/upvplWhitePoints.mat');
lum = 2;
bgUpvpl = upvplWhitePoints(knnsearch(upvplWhitePoints(:,3), lum),:);
bgColor = conv_upvpl2rgb(bgUpvpl,ccmat);
clear ccmat;
clear upvplWhitePoints;

%% Main
try
    %% PTB準備
    % set window
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    [winPtr, winRect] = PsychImaging('Openwindow', screenNumber, bgColor);
    Priority(MaxPriority(winPtr));
    [offwin1,offwinrect]=Screen('OpenOffscreenWindow',winPtr, 0);
    
    FlipInterval = Screen('GetFlipInterval', winPtr); % monitor 1 flame time
    RefleshRate = 1./FlipInterval; 
    HideCursor(screenNumber);
    
    % Key
    escapeKey = KbName('ESCAPE');
    %leftKey = KbName('1!');
    %rightKey = KbName('2@');
    leftKey = KbName('4');
    rightKey = KbName('6');
    
    %% データ読み込み
    % show display
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, 'Please wait', 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    
    % 刺激データ
    % low, column, rgb, color, luminance, saturation
    load('../stimuli/stimuliPatch.mat');
    load('../stimuli/back/bgStimuli.mat');
    
    %% 実験パラメータ設定
    flag = 0;
    [mx,my] = RectCenter(winRect);
    [winWidth, winHeight]=Screen('WindowSize', winPtr);
    [iy,ix,iz] = size(bgStimuli(:,:,:,1));
    showStimuliTime = 1; % [s]
    beforeStimuli = 0.5; % [s]
    intervalTime = 0.5; % [s]
    
    % 刺激サイズ
    viewingDistance = 80; % Viewing distance (cm)
    screenWidthCM = 54.3; % screen width （cm）
    visualAngle = 11; % visual angle（degree）
    sx = 2 * viewingDistance * tan(deg2rad(visualAngle/2)) * winWidth / screenWidthCM; % stimuli x size (pixel)
    sy = sx * iy / ix; % stimuli y size (pixel)
    distance = 14; % stimulus distance  (pixel)
    
    %{
    % stimuli position (center) 
    leftPosition = [mx-sx-distance/2, my-sy/2, mx-distance/2, my+sy/2];
    rightPosition = [mx+distance/2, my-sy/2, mx+sx+distance/2, my+sy/2];
    %}
    
    % 全セッション数
    allSessionNum = 5;
    % 試行数
    sessionTrialNum = stiNum;
    trashTrialNum = 20;
    
    
    %% 刺激のインデックス・呈示順・結果保存用の配列
    % make index matrix for stimuli (pair table)
    index = zeros(allSessionNum, 3);
    a = stiNum;
    paramNum = [a/lumNum, a/(lumNum*satNum), a/(lumNum*satNum*colorNum)];
    for i = 1:lumNum
        for j = 1:satNum
            for k = 1:colorNum
                index(sum(paramNum.*[i-1,j-1]) + k,:) = [i,j,k];
            end
        end
    end
    
    % セッションごとの記録をするテーブル
    varTypes = {'string','string','stirng','uint8','datetime'};
    varNames = {'luminance','saturation','color','gray_lum','responseTime'};
    sessionTable = table('Size',[sessionTrialNum,5],'VariableTypes',varTypes,'VariableNames',varNames);
    
    % 応答データを記録するテーブル・刺激呈示順を作るまたは読み込む
    varTypes = {'string','string','stirng','uint8','uint8','uint8','uint8','uint8'};
    varNames = {'luminance','saturation','color','gray_lum1','gray_lum2','gray_lum3','gray_lum4','gray_lum5'};
    if sessionNum == 1  
        % make data table
        dataTable = table('Size',[stiNum,8],'VariableTypes',varTypes,'VariableNames',varNames);
    else
        % load subject data
        load(strcat(dataTableName,'.mat'));
        load(orderFile);
    end
    
    % セッションごとに刺激の呈示順をランダムに決定
    order = randperm(stiNum);
    
    % 捨て試行の呈示順
    orderTrash = randi([1,stiNum], 1,trashTrialNum);
    
    %% 実験開始直前
    % display initial text
    startText = 'Press any key to start';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, startText, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    KbWait([], 2);
    WaitSecs(2);
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    %% 実験のメインループ
    for i = 1:sessionTrialNum + trashTrialNum
        %% 呈示する刺激・位置を決定
        % 刺激番号
        if i <= trashTrialNum
            % trash trial
            stiNum = orderTrash(i);
        else
            % main trial
            n = i + sessionTrialNum*(sessionNum-1) - trashTrialNum; % trial number
            stiNum = order(n); % stimuli number
        end
              
        % 刺激呈示位置 (random)
        rx = randi(fix(winWidth-(2*sx+distance))-1);
        ry = randi(fix(winHeight-sy)-1);
        leftPosition = [rx, ry, rx+sx, ry+sy];
        rightPosition = [rx+sx+distance, ry, rx+2*sx+distance, ry+sy];
        %}
        
        %% 刺激呈示前に背景のみ表示
        leftStimulus = Screen('MakeTexture', winPtr,bgStimuli(:,:,:,index(stiNum,2)));
        rightStimulus = Screen('MakeTexture',winPtr,bgStimuli(:,:,:,index(stiNum,2)));
        Screen('DrawTexture', winPtr, leftStimulus, [], leftPosition);
        Screen('DrawTexture', winPtr, rightStimulus, [], rightPosition);
        flipTime = Screen('Flip', winPtr);
        
        %% 呈示する刺激を決定
        oneOrTwo = randi([1 2]);
              
        flagShape = index(stiNum,1);
        if flagShape == 1
            % bunny
            rgbLeft = stimuliBunny(:,:,:,pair2color(index(stiNum,6),oneOrTwo),index(stiNum,2),index(stiNum,3),index(stiNum,4),index(stiNum,5));
            rgbRight = stimuliBunny(:,:,:,pair2color(index(stiNum,6),3-oneOrTwo),index(stiNum,2),index(stiNum,3),index(stiNum,4),index(stiNum,5));             
        elseif flagShape == 2
            % dragon
            rgbLeft = stimuliDragon(:,:,:,pair2color(index(stiNum,6),oneOrTwo),index(stiNum,2),index(stiNum,3),index(stiNum,4),index(stiNum,5));
            rgbRight = stimuliDragon(:,:,:,pair2color(index(stiNum,6),3-oneOrTwo),index(stiNum,2),index(stiNum,3),index(stiNum,4),index(stiNum,5)); 
        elseif flagShape == 3
            % blob
            rgbLeft = stimuliBlob(:,:,:,pair2color(index(stiNum,6),oneOrTwo),index(stiNum,2),index(stiNum,3),index(stiNum,4),index(stiNum,5));
            rgbRight = stimuliBlob(:,:,:,pair2color(index(stiNum,6),3-oneOrTwo),index(stiNum,2),index(stiNum,3),index(stiNum,4),index(stiNum,5)); 
        end
        
        %{ 
        ------ stimuli data ----------
        shape : shape(flagShape)
        light : light(index(stiNum,2)
        diffuse : diffuseVar(index(stiNum,3))
        roughness : roughVar(index(stiNum,4))
        colorize : colorizeW(index(stiNum,5))
        color1 : colorName(pair2color(index(stiNum,6),1))
        color2 : colorName(pair2color(index(stiNum,6),2))
        %}
        
        % 試行番号と呈示する刺激のパラメータ表示
        if i <= trashTrialNum
            fprintf('trash\n');
        else
            fprintf('main\n');
        end
        fprintf('trial number in this session : %d\n', i);
        fprintf('stimuli number : %d\n', stiNum);
        fprintf('%s, %s, diffuse:%f, roughness:%s, %s\n', shape(flagShape), light(index(stiNum,2)), diffuseVar(index(stiNum,3)), roughVar(index(stiNum,4)), colorizeW(index(stiNum,5)));
        fprintf('color pair : %s vs %s\n', colorName(pair2color(index(stiNum,6),oneOrTwo)), colorName(pair2color(index(stiNum,6),3-oneOrTwo)));
        
        %% 刺激呈示
        leftStimulus = Screen('MakeTexture', winPtr,rgbLeft);
        rightStimulus = Screen('MakeTexture', winPtr, rgbRight);

        % show stimuli
        Screen('DrawTexture', winPtr, leftStimulus, [], leftPosition);
        Screen('DrawTexture', winPtr, rightStimulus, [], rightPosition);
        flipTime = Screen('Flip', winPtr, flipTime+beforeStimuli);

        % capture
        %imageArray = Screen('GetImage',winPtr);

        % 1秒後に刺激を消す
        Screen('FillRect', winPtr, bgColor);
        flipTime = Screen('Flip', winPtr, flipTime+showStimuliTime);
        Screen('Close', [leftStimulus, rightStimulus]);
        
        
        %% 被験者応答
        % Wait for subject's response
        keyIsDown = 0;
        while 1
            [keyIsDown, seconds, keyCode] = KbCheck(-1);
            if keyIsDown && keyCode(leftKey)
                flag = 1;
                response = oneOrTwo;
                break;
            elseif keyIsDown && keyCode(rightKey)
                flag = 2;
                response = 3-oneOrTwo;
                break;
            elseif keyIsDown && keyCode(escapeKey)
                response = 0;
                flag = 3;
                break;
            end
        end
        resTime = datetime;
        
        %% 中断処理
        % if push escape key, experiment is interrupted
        if flag == 3
            DrawFormattedText(winPtr, 'Experiment is interrupted', 'center', 'center',[255 255 255]);
            Screen('Flip', winPtr);
            WaitSecs(1);
            break
        end
        
        %% 応答データを記録
        if i > trashTrialNum
            
            %{
            ------ data table ----------
            shape : shape(flagShape)
            light : light(index(stiNum,2))
            diffuse : diffuseVar(index(stiNum,3))
            roughness : roughVar(index(stiNum,4))
            colorize : colorizeW(index(stiNum,5))
            color1 : colorName(pair2color(index(stiNum,6),1))
            color2 : colorName(pair2color(index(stiNum,6),2))
            win : response
            responseTime : resTime
            %}
            % table data
            sessionTable(i-trashTrialNum,:) = {shape(flagShape),light(index(stiNum,2)),diffuseVar(index(stiNum,3)),roughVar(index(stiNum,4)),colorizeW(index(stiNum,5)),colorName(pair2color(index(stiNum,6),1)),colorName(pair2color(index(stiNum,6),2)),colorName(pair2color(index(stiNum,6),response)),resTime};
            dataTable(stiNum,:) = {shape(flagShape),light(index(stiNum,2)),diffuseVar(index(stiNum,3)),roughVar(index(stiNum,4)),colorizeW(index(stiNum,5)),colorName(pair2color(index(stiNum,6),1)),colorName(pair2color(index(stiNum,6),2)),colorName(pair2color(index(stiNum,6),response)),resTime};
        end
        
        % 応答表示
        fprintf('pressed key : %d\n', flag);
        fprintf('subject response : %s\n\n', colorName(pair2color(index(stiNum,6),response)));
        
        %% 実験が半分経過
        if i == round((sessionTrialNum+trashTrialNum)/2)
            DrawFormattedText(winPtr, 'Half. Press any key to continue.', 'center', 'center',[255 255 255]);
            Screen('Flip', winPtr);
            KbWait([], 2);
        end
        
        WaitSecs(intervalTime);
    end
    
    %% 実験終了後
    clear stimuliBunny;
    clear stimuliDragon;
    clear stimuliBlob;
    finTime = datetime;
    
    % データを保存
    save(strcat(dataTableName,'.mat'), 'dataTable');
    save(orderFile, 'order');
    save(strcat(sessionFile,'.mat'), 'sessionTable');
    writetable(dataTable, strcat(dataTableName,'.txt'));
    writetable(sessionTable, strcat(sessionFile,'.txt'));
    
    % セッションごとのログ
    expTime = finTime - date;
    fp = fopen(recordFile, 'a');
    fprintf(fp, '%dセッション目\n', sessionNum);
    fprintf(fp, '実験実施日　%s\n', char(date));
    fprintf(fp, '試行回数　%d回\n', i);
    fprintf(fp, '実験時間　%s\n\n', char(expTime));
    fclose(fp);    
    
    % 終了の表示
    finishText = 'The experiment is over. Press any key.';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, finishText, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    KbWait([], 2);
    
    % 終了処理
    Priority(0);
    Screen('CloseAll');
    ShowCursor;
    ListenChar(0);
catch
    Screen('CloseAll');
    ShowCursor;
    a = "dame";
    ListenChar(0);
    psychrethrow(psychlasterror);
end