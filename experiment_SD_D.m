% SD彩色の刺激とD彩色の刺激の光沢感比較を行うプログラム（同色のみの比較）
clear all

% date, subject, output filename
date = datetime;
sn = input('Subject Name?: ', 's');
sessionNum = input('Session Number?: ');

% filename
dataFilename = sprintf('../data/experiment_SDvsD/%s/data_%s', sn, sn);
dataListFilename = sprintf('../data/experiment_SDvsD/%s/list_%s.mat', sn, sn);
dataTableName = sprintf('../data/experiment_SDvsD/%s/table_%s', sn,sn);
orderFile = sprintf('../data/experiment_SDvsD/%s/order_%s.mat', sn,sn);
sessionFile = sprintf('../data/experiment_SDvsD/%s/session%s/session%s_table_%s', sn,num2str(sessionNum),num2str(sessionNum),sn);
recordFile = sprintf('../data/experiment_SDvsD/%s/record_%s.txt', sn,sn);

% make directory
mkdir(strcat('../data/experiment_SDvsD/',sn));
mkdir(strcat('../data/experiment_SDvsD/',sn,'/session',num2str(sessionNum)));

AssertOpenGL;
ListenChar(2);
KbName('UnifyKeyNames');
screenNumber = max(Screen('Screens'));
%InitializeMatlabOpenGL;

% stimuli parameter
shape = ["bunny", "dragon", "blob"];
light = ["area", "envmap"];
diffuse = ["D01", "D03", "D05"];
diffuseVar = [0.1,0.3,0.5];
roughness = ["alpha005", "alpha01", "alpha02"];
roughVar = [0.05,0.1,0.2];
colorizeW = ["SD", "D"];
colorName = ["red","orange","yellow","green","blue-green","cyan","blue","magenta"];

% the number of each parameter
shapeNum = size(shape,2); % bunny, dragon, blob
lightNum = size(light,2); % area, envmap
diffuseNum = size(diffuse,2); % 0.1, 0.3, 0.5
roughnessNum = size(roughness,2); % 0.05, 0.1, 0.2
colorizeNum = size(colorizeW,2); % SD, D
color = size(colorName,2);

% set background color
load('../mat/ccmat.mat');
load('../mat/upvplWhitePoints.mat');
lum = 2;
bgUpvpl = upvplWhitePoints(knnsearch(upvplWhitePoints(:,3), lum),:);
bgColor = conv_upvpl2rgb(bgUpvpl,ccmat);
clear ccmat;
clear upvplWhitePoints;

try
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
    %firstKey = KbName('1!');
    %secondKey = KbName('2@');
    leftKey = KbName('4');
    rightKey = KbName('6');   
    
    % ------- load stimili data ------------------------------------------
    % show display
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, 'Please wait', 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    
    % stimuli matrix
    % low, column, rgb, color, light, diffuse, roughness, SDorD
    load('../stimuli/stimuliBunny.mat');
    load('../stimuli/back/bgStimuli.mat');
    % ---------------------------------------------------------------------
    
    
    % parameter setting
    flag = 0;
    [mx,my] = RectCenter(winRect);
    [winWidth, winHeight]=Screen('WindowSize', winPtr);
    [iy,ix,iz] = size(bgStimuli(:,:,:,1));
    showStimuliTime = 1; % [s]
    beforeStimuli = 0.5; % [s]
    intervalTime = 0.5; % [s]
    
    % stimuli size
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
    
    % the number of trial
    allTrialNum = lightNum*diffuseNum*roughnessNum*color;
    sessionTrialNum = 144;
    trashTrialNum = 20;
    
    % make index table for stimuli (pair table)
    index = zeros(allTrialNum, 4);
    a = allTrialNum;
    paramNum = [a/(lightNum), a/(lightNum*diffuseNum), a/(lightNum*diffuseNum*roughnessNum)];
    for i = 1:lightNum
        for j = 1:diffuseNum
            for k = 1:roughnessNum
                for l = 1:color
                    index(sum(paramNum.*[i-1,j-1,k-1]) + l,:) = [i,j,k,l+1];
                end
            end
        end
    end

    % make session table
    varTypes = {'string','double','double','string','string','datetime'};
    varNames = {'light','diffuse','roughness','color','win','responseTime'};
    sessionTable = table('Size',[sessionTrialNum,6],'VariableTypes',varTypes,'VariableNames',varNames);
    
    % make or load subject data
    if sessionNum == 1
        % make data matrix for result
            % 1 dim : area or envmap
            % 2 dim : diffuse parameter  0.1, 0.3, 0.5
            % 3 dim : roughness  0.05, 0.1, 0.2
            % 4 dim : color
            % value : 1:SD win, 2:D win
        data = zeros(lightNum,diffuseNum,roughnessNum,color);
        dataList = zeros(allTrialNum, 5);
        dataList(:,1:4) = index;
        
        % make data table
        dataTable = table('Size',[allTrialNum,6],'VariableTypes',varTypes,'VariableNames',varNames);
        
        % generate random order
        order = randperm(allTrialNum);
        %order = randperm(sessionTrialNum*2);
    else
        % load subject data
        load(dataFilename);
        load(dataListFilename);
        load(strcat(dataTableName,'.mat'));
        load(orderFile);
    end
    
    % generate random order for trash trial
    orderTrash = randi([1,allTrialNum], 1,trashTrialNum);
    
    % display initial text
    startText = 'Press any key to start';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, startText, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    KbWait([], 2);
    WaitSecs(2);
    
    % Main Experiment
    for i = 1:sessionTrialNum + trashTrialNum
        if i <= trashTrialNum
            % trash trial
            stiNum = orderTrash(i);
        else
            % main trial
            n = i + sessionTrialNum*(sessionNum-1) - trashTrialNum; % trial number
            stiNum = order(n);
        end
        
        % stimuli position (random)
        rx = randi(fix(winWidth-(2*sx+distance))-1);
        ry = randi(fix(winHeight-sy)-1);
        leftPosition = [rx, ry, rx+sx, ry+sy];
        rightPosition = [rx+sx+distance, ry, rx+2*sx+distance, ry+sy];

        % before showing stimluli
        leftStimulus = Screen('MakeTexture', winPtr,bgStimuli(:,:,:,index(stiNum,1)));
        rightStimulus = Screen('MakeTexture',winPtr,bgStimuli(:,:,:,index(stiNum,1)));
        Screen('DrawTexture', winPtr, leftStimulus, [], leftPosition);
        Screen('DrawTexture', winPtr, rightStimulus, [], rightPosition);
        flipTime = Screen('Flip', winPtr);

        
        % -------- decide stimuli ----------------------------------------
        oneOrTwo = randi([1 2]);
        
        % already loaded
        rgbLeft = stimuliBunny(:,:,:,index(stiNum,4),index(stiNum,1),index(stiNum,2),index(stiNum,3),oneOrTwo);
        rgbRight = stimuliBunny(:,:,:,index(stiNum,4),index(stiNum,1),index(stiNum,2),index(stiNum,3),3-oneOrTwo); 
        
        %{ 
        ------ stimuli data ----------
        light : light(index(stiNum,1)
        diffuse : diffuseVar(index(stiNum,2))
        roughness : roughVar(index(stiNum,3))
        color : index(stiNum, 4)
        %}
        
        %{
        % load each time
        % mat/shape/light/diffuse/roughness/colorize
        load(strcat('../mat/bunny/',light(index(stiNum,1)),'/',diffuse(index(stiNum,2)),'/',roughness(index(stiNum,3)),'/coloredSD.mat'));
        load(strcat('../mat/bunny/',light(index(stiNum,1)),'/',diffuse(index(stiNum,2)),'/',roughness(index(stiNum,3)),'/coloredD.mat'));
        if oneOrTwo == 1
            rgbLeft = coloredSD(:,:,:,index(stiNum,4));
            rgbRight = coloredD(:,:,:,index(stiNum,4));
        if oneOrTwo == 2
            rgbLeft = coloredD(:,:,:,index(stiNum,4));
            rgbRight = coloredSD(:,:,:,index(stiNum,4));
        end
        
        rgbLeft = wImageXYZ2rgb_wtm(rgbLeft,ccmat);
        rgbRight = wImageXYZ2rgb_wtm(rgbRight,ccmat);
        %}
        
        % ----------------------------------------------------------------
        
        leftStimulus = Screen('MakeTexture', winPtr,rgbLeft);
        rightStimulus = Screen('MakeTexture', winPtr, rgbRight);

        % show stimuli
        Screen('DrawTexture', winPtr, leftStimulus, [], leftPosition);
        Screen('DrawTexture', winPtr, rightStimulus, [], rightPosition);
        flipTime = Screen('Flip', winPtr, flipTime+beforeStimuli);

        % capture
        %imageArray = Screen('GetImage',winPtr);

        % after showing stimluli for 1 second
        Screen('FillRect', winPtr, bgColor);
        flipTime = Screen('Flip', winPtr, flipTime+showStimuliTime);
        
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
                respones = 0;
                flag = 3;
                break;
            end
        end
        resTime = datetime;
        
        % if push escape key, experiment is interrupted
        if flag == 3
            DrawFormattedText(winPtr, 'Experiment is interrupted', 'center', 'center',[255 255 255]);
            Screen('Flip', winPtr);
            WaitSecs(1);
            break
        end
        
        if i <= trashTrialNum
            fprintf('trash\n');
        else
            fprintf('main\n');
        end
        fprintf('trial number in this session : %d\n', i);
        fprintf('stimuli number : %d\n', stiNum);
        fprintf('left : %s, right : %s\n', colorizeW(oneOrTwo), colorizeW(3-oneOrTwo));
        fprintf('pressed key : %d\n', flag);
        fprintf('subject response : %s\n\n', colorizeW(response));
        
        % record data
        if i > trashTrialNum
            data(index(stiNum,1), index(stiNum,2), index(stiNum,3), index(stiNum,4)) = response;
            dataList(stiNum, 5) = response;
            
            %{
            ------ data table ----------
            light : light(index(stiNum,2))
            diffuse : diffuseVar(index(stiNum,3))
            roughness : roughVar(index(stiNum,4))
            color : colorName(index(stiNum,4)-1)
            win : colorizeW(response)
            responseTime : resTime
            %}
            % table data
            sessionTable(i-trashTrialNum,:) = {light(index(stiNum,1)),diffuseVar(index(stiNum,2)),roughVar(index(stiNum,3)),colorName(index(stiNum,4)-1),colorizeW(response),resTime};
            dataTable(stiNum,:) = {light(index(stiNum,1)),diffuseVar(index(stiNum,2)),roughVar(index(stiNum,3)),colorName(index(stiNum,4)-1),colorizeW(response),resTime};
        end

        if i == round((sessionTrialNum+trashTrialNum)/2)
            DrawFormattedText(winPtr, 'Half. Press any key to continue.', 'center', 'center',[255 255 255]);
            Screen('Flip', winPtr);
            KbWait([], 2);
        end
        
        WaitSecs(intervalTime);
    end
    
    clear stimuliBunny
    
    % save data
    save(dataFilename, 'data');
    save(dataListFilename, 'dataList');
    save(strcat(dataTableName,'.mat'), 'dataTable');
    save(orderFile, 'order');
    save(strcat(sessionFile,'.mat'), 'sessionTable');
    writetable(dataTable, strcat(dataTableName,'.txt'));
    writetable(sessionTable, strcat(sessionFile,'.txt'));
    
    % experiment finish
    finTime = datetime;
    finishText = 'The experiment is over. Press any key.';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, finishText, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    KbWait([], 2);

    % write session data
    expTime = finTime - date;
    fp = fopen(recordFile, 'a');
    fprintf(fp, '%dセッション目\n', sessionNum);
    fprintf(fp, '実験実施日　%s\n', char(date));
    fprintf(fp, '試行回数　%d回\n', i);
    fprintf(fp, '実験時間　%s\n\n', char(expTime));
    fclose(fp);    
    
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