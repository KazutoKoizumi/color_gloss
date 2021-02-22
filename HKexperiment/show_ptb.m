%% 実験画面に刺激画像を表示する
clear all

%% 初期準備
AssertOpenGL;
ListenChar(2);
KbName('UnifyKeyNames');
screenNumber = max(Screen('Screens'));
%InitializeMatlabOpenGL;

%% 刺激のパラメータ
colorName = ["red","orange","yellow","green","blue-green","cyan","blue","magenta"];
lumNum = 3;
satNum = 3;
colorNum = 8;
stimuliN = lumNum * satNum * colorNum;

%% 背景色の設定
load('../../mat/ccmat.mat');
load('../../mat/upvplWhitePoints.mat');
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
    %HideCursor(screenNumber);
    
    % Key
    escapeKey = KbName('ESCAPE');
    
    
    %% データ読み込み
    % show display
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, 'Please wait', 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    
    % stimuli matrix
    load('../../stimuli/patch/stimuliPatch.mat');
    load('../../stimuli/back/bgStimuli.mat');
    
    %% パラメータ設定
    flag = 0;
    [mx,my] = RectCenter(winRect);
    [winWidth, winHeight]=Screen('WindowSize', winPtr);
    [iy,ix,iz] = size(bgStimuli(:,:,:,1));
    showStimuliTime = 1; % [s]
    beforeStimuli = 0.5; % [s]
    intervalTime = 0.5; % [s]
    
    % 刺激サイズ
    %viewingDistance = 80; % Viewing distance (cm)
    %screenWidthCM = 54.3; % screen width （cm）
    %visualAngle = 11; % visual angle（degree）
    %sx = 2 * viewingDistance * tan(deg2rad(visualAngle/2)) * winWidth / screenWidthCM; % stimuli x size (pixel)
    sx = 400;
    sy = sx * iy / ix; % stimuli y size (pixel)
    d = 14; % stimulus distance  (pixel)
    
    % 刺激呈示位置
    sp = [mx-(2*sx+3*d/2), my-(sy+d/2), mx-(sx+3*d/2), my-(d/2);
            mx-(sx+d/2), my-(sy+d/2), mx-(d/2), my-(d/2);
            mx+(d/2), my-(sy+d/2), mx+(sx+d/2), my-(d/2);
            mx+(sx+3*d/2), my-(sy+d/2), mx+(2*sx+3*d/2), my-(d/2);
            mx-(2*sx+3*d/2), my+(d/2), mx-(sx+3*d/2), my+(sy+d/2);
            mx-(sx+d/2), my+(d/2), mx-(d/2), my+(sy+d/2);
            mx+(d/2), my+(d/2), mx+(sx+d/2), my+(sy+d/2);
            mx+(sx+3*d/2), my+(d/2), mx+(2*sx+3*d/2), my+(sy+d/2)];
    
    
    %% 実験開始直前
    % display initial text
    SetMouse(winWidth/2,winHeight/2-150,winPtr);
    startText = 'Click to start';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, startText, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    while 1
        [x,y,buttons] = GetMouse;
        if any(buttons)
            break;
        end
    end
    WaitSecs(2);
    
    %% メインループ
    for i = 1:3 % lum
        for j = 1:3 % sat
            stimTexture = zeros(1,8);
            for k = 1:8
                stimTexture(k) = Screen('Maketexture',winPtr,stimuliPatch(:,:,:,k,i,j));
                Screen('DrawTexture', winPtr, stimTexture(k), [], sp(k,:));
            end
            Screen('Flip', winPtr);
            
            % capture
            %imageArray = Screen('GetImage',winPtr);  
            
            fprintf('luminance:%d, saturation:%d\n\n', i,j);
            
            while 1
                % 被験者応答
                [x,y,buttons,focus,val] = GetMouse(winPtr,0);
            
                % 左クリックで次の刺激
                if buttons(1) == 1
                    flag = 1;
                    break;
                end
                
                % escキーを押したら実験中断
                keyIsDown = 0;
                [keyIsDown, seconds, keyCode] = KbCheck(-1);
                if keyIsDown && keyCode(escapeKey)
                    flag = 2;
                    break;
                end
            end
            
            % 刺激を消す
            Screen('FillRect', winPtr, bgColor);
            Screen('Flip', winPtr);
            Screen('Close', stimTexture);
            
            % 中断処理
            if flag == 2
                DrawFormattedText(winPtr, 'Experiment is interrupted', 'center', 'center',[255 255 255]);
                Screen('Flip', winPtr);
                WaitSecs(1);
                break
            end
            
            WaitSecs(1);
            
        end
        
        if flag == 2
            DrawFormattedText(winPtr, 'Experiment is interrupted', 'center', 'center',[255 255 255]);
            Screen('Flip', winPtr);
            WaitSecs(1);
            break
        end
        
    end
        
    % experiment finish
    finishText = 'The experiment is over. Click to finish.';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, finishText, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    while 1
        [x,y,buttons] = GetMouse;
        if any(buttons)
            break;
        end
    end
    
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