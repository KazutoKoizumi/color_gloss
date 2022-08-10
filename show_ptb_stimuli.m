%% 実験画面キャプチャ用のプログラム

clear all;

AssertOpenGL;
ListenChar(2);
KbName('UnifyKeyNames');
screenNumber = max(Screen('Screens'));

%% 実験画面の背景色設定
load('../mat/ccmat.mat');
load('../mat/upvplWhitePoints.mat');
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
    % low, column, rgb, color, light, diffuse, roughness, SDorD
    load('../stimuli/stimuliBunny.mat');
    load('../stimuli/back/bgStimuli.mat');
    
    %% 実験パラメータ設定
    flag = 0;
    [mx,my] = RectCenter(winRect);
    [winWidth, winHeight]=Screen('WindowSize', winPtr);
    [iy,ix,iz] = size(bgStimuli(:,:,:,1));
    showStimuliTime = 0.5; % [s]
    beforeStimuli = 0.1; % [s]
    intervalTime = 0.1; % [s]
    
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
    %}
    
    
    %% 実験開始直前
    % display initial text
    startText = 'Press any key to start';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, startText, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    KbWait([], 2);
    WaitSecs(2);
    
    %% 呈示部分
    % 呈示する刺激を決定
    i = 1;
    j = 1;
    k = 2;
    l = 1;
    m = 1;
    hue1 = 5;
    hue2 = 2;
    
    %rgbLeft = stimuliBunny(:,:,:,hue1,j,k,l,m);
    %rgbRight = stimuliBunny(:,:,:,hue2,j,k,l,m);
    
    % 背景の場合
    rgbLeft = bgStimuli(:,:,:,1);
    rgbRight = bgStimuli(:,:,:,1);
    
    % 刺激呈示
    leftStimulus = Screen('MakeTexture', winPtr,rgbLeft);
    rightStimulus = Screen('MakeTexture', winPtr, rgbRight);

    % show stimuli
    Screen('DrawTexture', winPtr, leftStimulus, [], leftPosition);
    Screen('DrawTexture', winPtr, rightStimulus, [], rightPosition);
    flipTime = Screen('Flip', winPtr);

    % capture
    %imageArray = Screen('GetImage',winPtr);

    % 1秒後に刺激を消す
    
    Screen('FillRect', winPtr, bgColor);
    flipTime = Screen('Flip', winPtr, flipTime+showStimuliTime);
    Screen('Close', [leftStimulus, rightStimulus]);
    %}
    imageArray = Screen('GetImage',winPtr);

    %% 被験者応答
    % Wait for subject's response
    keyIsDown = 0;
    while 1
        [keyIsDown, seconds, keyCode] = KbCheck(-1);
        if keyIsDown && keyCode(leftKey)
            flag = 1;
            %response = oneOrTwo;
            break;
        elseif keyIsDown && keyCode(rightKey)
            flag = 2;
            %response = 3-oneOrTwo;
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
    end

    WaitSecs(intervalTime);
    
    %% 実験終了後
    clear stimuliBunny;
    %clear stimuliDragon;
    %clear stimuliBlob;
    finTime = datetime;
    
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
    
    
