%% 実験画面に刺激画像を表示する
clear all

%% 初期準備
AssertOpenGL;
ListenChar(2);
KbName('UnifyKeyNames');
screenNumber = max(Screen('Screens'));
%InitializeMatlabOpenGL;

%% オブジェクトのパラメータ
shape = ["bunny", "dragon", "blob"];
light = ["area", "envmap"];
diffuse = ["D01", "D03", "D05"];
diffuseVar = [0.1,0.3,0.5];
roughness = ["alpha005", "alpha01", "alpha02"];
roughVar = [0.05,0.1,0.2];
colorizeW = ["SD", "D"];
colorName = ["gray","red","orange","yellow","green","blue-green","cyan","blue","magenta"];

% 各パラメータの数
shapeNum = size(shape,2); % bunny, dragon, blob
lightNum = size(light,2); % area, envmap
diffuseNum = size(diffuse,2); % 0.1, 0.3, 0.5
roughnessNum = size(roughness,2); % 0.05, 0.1, 0.2
colorizeNum = size(colorizeW,2); % SD, D
color = 9;
colorPair = nchoosek(color,2);

%% 背景色の設定
load('../mat/ccmat.mat');
load('../mat/upvplWhitePoints.mat');
lum = 0.1526;
bgUpvpl = upvplWhitePoints(knnsearch(upvplWhitePoints(:,3), lum),:);
bgColor = conv_upvpl2rgb(bgUpvpl,ccmat);
clear ccmat upvplWhitePoints;

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
    %firstKey = KbName('1!');
    %secondKey = KbName('2@');
    leftKey = KbName('4');
    rightKey = KbName('6');
    
    
    %% データ読み込み
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
    
    %% パラメータ設定
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
    
    
    % stimuli position (center) 
    leftPosition = [mx-sx-distance/2, my-sy/2, mx-distance/2, my+sy/2];
    rightPosition = [mx+distance/2, my-sy/2, mx+sx+distance/2, my+sy/2];
    
    
    % the number of trial
    allTrialNum = shapeNum*lightNum*diffuseNum*roughnessNum*colorizeNum*color;
    sessionTrialNum = 162*3;
    
    % make index matrix for stimuli (pair table)
    index = zeros(allTrialNum, 6);
    a = allTrialNum;
    paramNum = [a/shapeNum, a/(shapeNum*lightNum), a/(shapeNum*lightNum*diffuseNum), a/(shapeNum*lightNum*diffuseNum*roughnessNum), a/(shapeNum*lightNum*diffuseNum*roughnessNum*colorizeNum)];
    for i = 1:shapeNum
        for j = 1:lightNum
            for k = 1:diffuseNum
                for l = 1:roughnessNum
                    for m = 1:colorizeNum
                        for n = 1:color
                            index(sum(paramNum.*[i-1,j-1,k-1,l-1,m-1]) + n,:) = [i,j,k,l,m,n];
                        end
                    end
                end
            end
        end
    end    
    
    % make order
    order = 1:sessionTrialNum;
    
    % display initial text
    startText = 'Press any key to start';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, startText, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    KbWait([], 2);
    WaitSecs(2);
    
    % Main Experiment
    for i = 1:sessionTrialNum
        stiNum = order(i);
        
        % before showing stimluli
        leftStimulus = Screen('MakeTexture', winPtr,bgStimuli(:,:,:,index(stiNum,2)));
        rightStimulus = Screen('MakeTexture',winPtr,bgStimuli(:,:,:,index(stiNum,2)));
        Screen('DrawTexture', winPtr, leftStimulus, [], leftPosition);
        Screen('DrawTexture', winPtr, rightStimulus, [], rightPosition);
        flipTime = Screen('Flip', winPtr);
        
        
        % ---------- decide stimuli -------------------------------------
        oneOrTwo = randi([1 2]);
              
        % already loaded
        flagShape = index(stiNum,1);
        if flagShape == 1
            % bunny
            rgbLeft = stimuliBunny(:,:,:,index(stiNum,6),1,index(stiNum,3),index(stiNum,4),index(stiNum,5));
            rgbRight = stimuliBunny(:,:,:,index(stiNum,6),2,index(stiNum,3),index(stiNum,4),index(stiNum,5));             
        elseif flagShape == 2
            % dragon
            rgbLeft = stimuliDragon(:,:,:,index(stiNum,6),1,index(stiNum,3),index(stiNum,4),index(stiNum,5));
            rgbRight = stimuliDragon(:,:,:,index(stiNum,6),2,index(stiNum,3),index(stiNum,4),index(stiNum,5)); 
        elseif flagShape == 3
            % blob
            rgbLeft = stimuliBlob(:,:,:,index(stiNum,6),1,index(stiNum,3),index(stiNum,4),index(stiNum,5));
            rgbRight = stimuliBlob(:,:,:,index(stiNum,6),2,index(stiNum,3),index(stiNum,4),index(stiNum,5)); 
        end
        
        % ---------------------------------------------------------------
            
        leftStimulus = Screen('MakeTexture', winPtr,rgbLeft);
        rightStimulus = Screen('MakeTexture', winPtr, rgbRight);

        % show stimuli
        Screen('DrawTexture', winPtr, leftStimulus, [], leftPosition);
        Screen('DrawTexture', winPtr, rightStimulus, [], rightPosition);
        flipTime = Screen('Flip', winPtr, flipTime+beforeStimuli);

        % capture
        %imageArray = Screen('GetImage',winPtr);  
        
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
        
        % if push escape key, experiment is interrupted
        if flag == 3
            DrawFormattedText(winPtr, 'Experiment is interrupted', 'center', 'center',[255 255 255]);
            Screen('Flip', winPtr);
            WaitSecs(1);
            break
        end
        
        WaitSecs(intervalTime);
    end
    
    clear stimuliBunny;
    clear stimuliDragon;
    clear stimuliBlob;
   
    % experiment finish
    finTime = datetime;
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