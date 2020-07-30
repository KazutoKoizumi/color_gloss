%サーストンの一対比較法で光沢感を測定する実験
clear all

% date, subject, output filename
date = datetime;
sn = input('Subject Name?: ', 's');
dataFilename = sprintf('../data/experiment_gloss/%s/data_%s.mat', sn,sn);
dataListFilename = sprintf('../data/experiment_gloss/%s/list_%s.mat', sn,sn);
dataTableName = sprintf('../data/experiment_gloss/%s/table_%s.mat', sn,sn);
orderFile = sprintf('../data/experiment_gloss/%s/order_%s.mat', sn,sn);
sessionNum = input('Session Number?: ');
sessionFile = sprintf('../data/experiment_gloss/%s/session_%s.mat', sn,sn);
recordFile = sprintf('../data/experiment_gloss/%s/record_%s.txt', sn,sn);

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
colorName = ["gray","red","orange","yellow","green","blue-green","cyan","blue","magenta"];

% the number of each parameter
shapeNum = size(shape,2); % bunny, dragon, blob
lightNum = size(light,2); % area, envmap
diffuseNum = size(diffuse,2); % 0.1, 0.3, 0.5
roughnessNum = size(roughness,2); % 0.05, 0.1, 0.2
colorizeNum = size(colorizeW,2); % SD, D
color = 9;
colorPair = nchoosek(color,2);

% set background color
load('../mat/ccmat.mat');
load('../mat/upvplWhitePoints.mat');
lum = 1;
bgUpvpl = upvplWhitePoints(knnsearch(upvplWhitePoints(:,3), lum),:);
bgColor = conv_upvpl2rgb(bgUpvpl,ccmat);

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
    firstKey = KbName('1!');
    secondKey = KbName('2@');
    %leftKey = KbName('LeftArrow');
    %rightKey = KbName('RightArrow');
    
    
    % ------- load stimili data ------------------------------------------
    % show display
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, 'Please wait', 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    
    % stimuli matrix
    % low, column, rgb, color, light, diffuse, roughness, SDorD
    load('../stimuli/stimuliBunny.mat');
    load('../stimuli/stimuliDragon.mat');
    load('../stimuli/stimuliBlob.mat');
    load('../stimuli/back/bgStimuli.mat');
    % ---------------------------------------------------------------------
    
    
    % parameter setting
    flag = 0;
    [mx,my] = RectCenter(winRect);
    [winWidth, winHeight]=Screen('WindowSize', winPtr);
    [iy,ix,iz] = size(bgStimuli(:,:,:,1));
    showStimuliTime = 1; % [s]
    beforeStimuli = 1; % [s]
    intervalTime = 0.5; % [s]
    
    % stimuli size
    viewingDistance = 80; % Viewing distance (cm)
    screenWidthCM = 49; % screen width （cm）
    visualAngle = 10; % visual angle（degree）
    sx = 2 * viewingDistance * tan(visualAngle/360 * pi) * winWidth / screenWidthCM; % stimuli x size (pixel)
    sy = sx * iy / ix; % stimuli y size (pixel)
    distance = 14; % stimulus distance  (pixel)
    
    %{
    % stimuli position (center) 
    leftPosition = [mx-sx-distance/2, my-sy/2, mx-distance/2, my+sy/2];
    rightPosition = [mx+distance/2, my-sy/2, mx+sx+distance/2, my+sy/2];
    %}
    
    % the number of trial
    allTrialNum = shapeNum*lightNum*diffuseNum*roughnessNum*colorizeNum*colorPair;
    sessionTrialNum = 324;
    trashTrialNum = 20;
    
    % make index table for stimuli (pair table)
    index = zeros(allTrialNum, 6);
    a = allTrialNum;
    paramNum = [a/shapeNum, a/(shapeNum*lightNum), a/(shapeNum*lightNum*diffuseNum), a/(shapeNum*lightNum*diffuseNum*roughnessNum), a/(shapeNum*lightNum*diffuseNum*roughnessNum*colorizeNum)];
    for i = 1:shapeNum
        for j = 1:lightNum
            for k = 1:diffuseNum
                for l = 1:roughnessNum
                    for m = 1:colorizeNum
                        for n = 1:colorPair
                            index(sum(paramNum.*[i-1,j-1,k-1,l-1,m-1]) + n,:) = [i,j,k,l,m,n];
                        end
                    end
                end
            end
        end
    end
    pair2color = nchoosek(1:color,2); % pair number to color number
    
    % make or load subject data
    if sessionNum == 1
        %{
        % make data matrix for result
            % 1 dim : Bunny or Dragon or Blob
            % 2 dim : area or envmap
            % 3 dim : diffuse parameter  0.1, 0.3, 0.5
            % 4 dim : roughness  0.05, 0.1, 0.2
            % 5 dim : SD or D
            % 6 dim : pair number
            % value : 1:the first of the pair win, 2:the second of the pair win
        %}
        data = zeros(shapeNum,lightNum,diffuseNum,roughnessNum,colorizeNum,colorPair);
        dataList = zeros(allTrialNum, 7);
        dataList(:,1:6) = index;
        
        % make data table
        varTypes = {'string','string','double','double','string','string','string','uint8','datetime'};
        varNames = {'shape','light','diffuse','roughness','colorize','color1','color2','win','responseTime'};
        dataTable = table('Size',[allTrialNum,9],'VariableTypes',varTypes,'VariableNames',varNames);
        
        % generate random order
        order = randperm(allTrialNum);
        %order = randperm(sessionTrialNum);
    else
        % load subject data
        load(dataFilename);
        load(dataListFilename);
        load(dataTableName);
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
            stiNum = order(n); % stimuli number
        end
        
        
        % stimuli position (random)
        rx = randi(fix(winWidth-(2*sx+distance))-1);
        ry = randi(fix(winHeight-sy)-1);
        leftPosition = [rx, ry, rx+sx, ry+sy];
        rightPosition = [rx+sx+distance, ry, rx+2*sx+distance, ry+sy];
        %}
        
        % before showing stimluli
        leftStimulus = Screen('MakeTexture', winPtr,bgStimuli(:,:,:,index(stiNum,2)));
        rightStimulus = Screen('MakeTexture',winPtr,bgStimuli(:,:,:,index(stiNum,2)));
        Screen('DrawTexture', winPtr, leftStimulus, [], leftPosition);
        Screen('DrawTexture', winPtr, rightStimulus, [], rightPosition);
        %Screen('FillRect', winPtr, stimuliBgColor, leftPosition);
        %Screen('FillRect', winPtr, stimuliBgColor, rightPosition);
        flipTime = Screen('Flip', winPtr);
        
        
        % ---------- decide stimuli -------------------------------------
        oneOrTwo = randi([1 2]);
              
        % already loaded
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
        
        %{
        % load each time
        % mat/shape/light/diffuse/roughness/colorize
        load(strcat('../mat/',shape(index(stiNum,1)),'/',light(index(stiNum,2)),'/',diffuse(index(stiNum,3)),'/',roughness(index(stiNum,4)),'/colored',colorizeW(index(stiNum,5)),'.mat'));
        if index(stiNum,5) == 1
            % SD
            rgbLeft = coloredSD(:,:,:,pair2color(index(stiNum,6),oneOrTwo));
            rgbRight = coloredSD(:,:,:,pair2color(index(stiNum,6),3-oneOrTwo));
        elseif index(stiNum,5) == 2
            % D
            rgbLeft = coloredD(:,:,:,pair2color(index(stiNum,6),oneOrTwo));
            rgbRight = coloredD(:,:,:,pair2color(index(stiNum,6),3-oneOrTwo));
        end
        
        rgbLeft = wImageXYZ2rgb_wtm(rgbLeft,ccmat);
        rgbRight = wImageXYZ2rgb_wtm(rgbRight,ccmat);
        %}
        
        % ---------------------------------------------------------------
            
        leftStimulus = Screen('MakeTexture', winPtr,rgbLeft);
        rightStimulus = Screen('MakeTexture', winPtr, rgbRight);

        % show stimuli
        Screen('DrawTexture', winPtr, leftStimulus, [], leftPosition);
        Screen('DrawTexture', winPtr, rightStimulus, [], rightPosition);
        flipTime = Screen('Flip', winPtr, flipTime+beforeStimuli);

        % capture
        %imageArray2 = Screen('GetImage',winPtr);  

        % after showing stimluli for 1 second
        Screen('FillRect', winPtr, bgColor);
        flipTime = Screen('Flip', winPtr, flipTime+showStimuliTime);
        
        % Wait for subject's response
        keyIsDown = 0;
        while 1
            [keyIsDown, seconds, keyCode] = KbCheck(-1);
            if keyIsDown && keyCode(firstKey)
                flag = 1;
                response = oneOrTwo;
                break;
            elseif keyIsDown && keyCode(secondKey)
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
        fprintf('pressed key : %d\n', flag);
        %fprintf('color pair : %d\n', index(stiNum,6));
        %fprintf('subject response : %d\n\n', response);
        fprintf('color pair : %s vs %s\n', colorName(pair2color(index(stiNum,6),oneOrTwo)), colorName(pair2color(index(stiNum,6),3-oneOrTwo)));
        fprintf('subject response : %s\n\n', colorName(pair2color(index(stiNum,6),response)));
        
        % record data
        if i > trashTrialNum
            data(index(stiNum,1), index(stiNum,2), index(stiNum,3), index(stiNum,4), index(stiNum,5), index(stiNum,6)) = response;
            dataList(stiNum, 7) = response;
            
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
            dataTable(stiNum,:) = {shape(flagShape),light(index(stiNum,2)),diffuseVar(index(stiNum,3)),roughVar(index(stiNum,4)),colorizeW(index(stiNum,5)),colorName(pair2color(index(stiNum,6),1)),colorName(pair2color(index(stiNum,6),2)),response,resTime};
        end
        
        WaitSecs(intervalTime);
    end
    
    clear stimuliBunny;
    clear stimuliDragon;
    clear stimuliBlob;
    
    % save data
    save(dataFilename, 'data');
    save(dataListFilename, 'dataList');
    save(dataTableName, 'dataTable');
    save(orderFile, 'order');
    save(sessionFile, 'sessionNum');
    
    % experiment finish
    finTime = datetime;
    finishText = 'The experiment is over. Press any key.';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, finishText, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    KbWait([], 2);
    
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