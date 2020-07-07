% SD彩色の刺激とD彩色の刺激の光沢感比較を行うプログラム（同色のみの比較）
clear all

% date, subject, output filename
%date = char(datetime('now','Format','yyyy-MM-dd''T''HHmmss'));
subjectName = input('Subject Name?: ', 's');
dataFilename = sprintf('../data/experiment_SD_D/%s_SD_D.mat', subjectName);
dataListFilename = sprintf('../data/experiment_SD_D/list_%s_SD_D.mat', subjectName);
orderFile = sprintf('../data/experiment_SD_D/order_%s_SD_D.mat', subjectName);
sessionNum = input('Session Number?: ');

AssertOpenGL;
ListenChar(2);
bgColor = [0 0 0];
KbName('UnifyKeyNames');
screenNumber = max(Screen('Screens'));
%InitializeMatlabOpenGL;

% the number of each parameter
%shape = 1; % bunny, dragon, blob
light = 2; % area, envmap
diffuse = 3; % 0.1, 0.3, 0.5
roughness = 3; % 0.05, 0.1, 0.2
colorize = 2; % SD, D
color = 8;
%colorPair = nchoosek(color,2);


try
    % set window
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    [winPtr, winRect] = PsychImaging('Openwindow', screenNumber, 0);
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
    
    % show display
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, 'Please wait', 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    
    % stimuli matrix
    % low, column, rgb, color, light, diffuse, roughness, SDorD
    stimuliBunny = zeros(720, 960, 3, color, light, diffuse, roughness, colorize);
    
    % load stimulus data : Bunny
    load('../stimuli/bunny/area/D01/alpha01/bunnySD.mat');
    %load('../stimuli/bunny/area/D01/alpha01/bunnyD.mat');
    %stimuliBunny(:,:,:,:,1,1,1,1) = bunnySD;
    %stimuliBunny(:,:,:,:,1,1,1,2) = bunnyD;
    load('../stimuli/stimuliBunny.mat');
    
    % parameter setting
    flag = 0;
    [mx,my] = RectCenter(winRect);
    [iy,ix,iz] = size(bunnySD(:,:,:,1));
    distance = mx/1.75;
    scale = 2.5/9;
    showStimuliTime = 1; % [s]
    intervalTime = 1; % [s]
    leftPosition = [mx-ix*scale-distance/2, my-iy*scale, mx+ix*scale-distance/2, my+iy*scale]; 
    rightPosition = [mx-ix*scale+distance/2, my-iy*scale, mx+ix*scale+distance/2, my+iy*scale];
    
    % the number of trial
    allTrialNum = light*diffuse*roughness*color;
    sessionTrialNum = allTrialNum;
    
    % make index table for stimuli (pair table)
    index = zeros(allTrialNum, 4);
    a = allTrialNum;
    paramNum = [a/(light), a/(light*diffuse), a/(light*diffuse*roughness)];
    for i = 1:light
        for j = 1:diffuse
            for k = 1:roughness
                for l = 1:color
                    index(sum(paramNum.*[i-1,j-1,k-1]) + l,:) = [i,j,k,l+1];
                end
            end
        end
    end
    
    % make or load subject data
    if sessionNum == 1
        % make data matrix for result
            % 1 dim : area or envmap
            % 2 dim : diffuse parameter  0.1, 0.3, 0.5
            % 3 dim : roughness  0.05, 0.1, 0.2
            % 4 dim : color
            % value : 1:SD win, 2:D win
        data = zeros(light,diffuse,roughness,color);
        dataList = zeros(allTrialNum, 5);
        dataList(:,1:4) = index;
        
        % generate random order
        order = randperm(allTrialNum);
        %order = randperm(sessionTrialNum*2);
    else
        load(dataFilename);
        load(dataListFilename);
        load(orderFile);
    end
    
    % display initial text
    startText = 'Press any key to start';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, startText, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    KbWait([], 2);
    WaitSecs(2);
    
    % Main Experiment
    for i = 1:sessionTrialNum
        n = i + sessionTrialNum*(sessionNum-1); % trial number
        
        oneOrTwo = randi([1 2]);
        rgbLeft = stimuliBunny(:,:,:,index(order(n),4),index(order(n),1),index(order(n),2),index(order(n),3),oneOrTwo);
        rgbRight = stimuliBunny(:,:,:,index(order(n),4),index(order(n),1),index(order(n),2),index(order(n),3),3-oneOrTwo); 
        
        leftStimulus = Screen('MakeTexture', winPtr,rgbLeft);
        rightStimulus = Screen('MakeTexture', winPtr, rgbRight);

        % show stimuli
        Screen('DrawTexture', winPtr, leftStimulus, [], leftPosition);
        Screen('DrawTexture', winPtr, rightStimulus, [], rightPosition);
        flipTime = Screen('Flip', winPtr);

        % capture
        %imageArray = Screen('GetImage',winPtr);

        % after showing stimluli for 1 second
        %Screen('FillRect', winPtr, [0 0 0]);
        %flipTime = Screen('Flip', winPtr, flipTime+showStimuliTime);
        
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
                respones = 0;
                flag = 3;
                break;
            end
        end
        
        Screen('FillRect', winPtr, [0 0 0]);
        Screen('Flip', winPtr);
        
        % if push escape key, experiment is interrupted
        if flag == 3
            DrawFormattedText(winPtr, 'Experiment is interrupted', 'center', 'center',[255 255 255]);
            Screen('Flip', winPtr);
            WaitSecs(1);
            break
        end
        
        fprintf('pressed key : %d\n', flag);
        if response == 1
            fprintf('subject response : SD\n\n');
        elseif response == 2
            fprintf('subgject response : D\n\n');
        end
        
        % record data
        data(index(order(n),1), index(order(n),2), index(order(n),3), index(order(n),4)) = response;
        dataList(order(n), 5) = response;
        
        WaitSecs(intervalTime);
    end
    
    clear stimuliBunny
    
    % save data
    save(dataFilename, 'data');
    save(dataListFilename, 'dataList');
    save(orderFile, 'order');
    
    % experiment finish
    finishText = 'The experiment is over. Press any key.';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, finishText, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    KbWait([], 2);
    
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