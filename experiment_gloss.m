%サーストンの一対比較法で光沢感を測定する実験
clear all

% date, subject, output filename
%date = char(datetime('now','Format','yyyy-MM-dd''T''HHmmss'));
subjectName = input('Subject Name?: ', 's');
dataFilename = sprintf('../data/experiment_gloss/%s.mat', subjectName);
dataListFilename = sprintf('../data/experiment_gloss/list_%s.mat', subjectName);
orderFile = sprintf('../data/experiment_gloss/order_%s.mat', subjectName);
sessionNum = input('Session Number?: ');

AssertOpenGL;
ListenChar(2);
bgColor = [0 0 0];
KbName('UnifyKeyNames');
screenNumber = max(Screen('Screens'));
%InitializeMatlabOpenGL;

% the number of each parameter
shape = 1; % bunny, dragon, blob
light = 2; % area, envmap
diffuse = 3; % 0.1, 0.3, 0.5
roughness = 3; % 0.05, 0.1, 0.2
colorize = 2; % SD, D
color = 9;
colorPair = nchoosek(color,2);


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
    allTrialNum = shape*light*diffuse*roughness*colorize*colorPair;
    sessionTrialNum = 36;
    
    % make index table for stimuli (pair table)
    index = zeros(allTrialNum, 6);
    a = allTrialNum;
    paramNum = [a/shape, a/(shape*light), a/(shape*light*diffuse), a/(shape*light*diffuse*roughness), a/(shape*light*diffuse*roughness*colorize)];
    for i = 1:shape
        for j = 1:light
            for k = 1:diffuse
                for l = 1:roughness
                    for m = 1:colorize
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
        % make data matrix for result
            % 1 dim : Bunny or Dragon or Blob
            % 2 dim : area or envmap
            % 3 dim : diffuse parameter  0.1, 0.3, 0.5
            % 4 dim : roughness  0.05, 0.1, 0.2
            % 5 dim : SD or D
            % 6 dim : pair number
            % value : 1:the first of the pair win, 2:the second of the pair win
        data = zeros(shape,light,diffuse,roughness,colorize,colorPair);
        dataList = zeros(allTrialNum, 7);
        dataList(:,1:6) = index;
        
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
        n = i + sessionTrialNum*(sessionNum-1) % trial number
        
        flagShape = index(order(n),1);
        oneOrTwo = randi([1 2]);
        if flagShape == 1
            % bunny
            rgbLeft = stimuliBunny(:,:,:,pair2color(index(order(n),6),oneOrTwo),index(order(n),2),index(order(n),3),index(order(n),4),index(order(n),5));
            rgbRight = stimuliBunny(:,:,:,pair2color(index(order(n),6),3-oneOrTwo),index(order(n),2),index(order(n),3),index(order(n),4),index(order(n),5)); 
        elseif flagShape == 2
            % dragon
        elseif flagShape == 3
            % blob
        end
        leftStimulus = Screen('MakeTexture', winPtr,rgbLeft);
        rightStimulus = Screen('MakeTexture', winPtr, rgbRight);
        
        % show stimuli
        Screen('DrawTexture', winPtr, leftStimulus, [], leftPosition);
        Screen('DrawTexture', winPtr, rightStimulus, [], rightPosition);
        flipTime = Screen('Flip', winPtr);
        
        % capture
        %imageArray = Screen('GetImage',winPtr);
        
        % after showing stimluli for 1 second
        Screen('FillRect', winPtr, [0 0 0]);
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
                respones = 0;
                flag = 3;
                break;
            end
        end       
        
        % if push escape key, experiment is interrupted
        if flag == 3
            DrawFormattedText(winPtr, 'Experiment is interrupted', 'center', 'center',[255 255 255]);
            Screen('Flip', winPtr);
            WaitSecs(1);
            break
        end
        
        
        disp([flag, response])
        
        % record data
        data(index(order(n),1), index(order(n),2), index(order(n),3), index(order(n),4), index(order(n),5), index(order(n),6)) = response;
        dataList(order(n), 7) = response;
        
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