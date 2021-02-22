AssertOpenGL;
ListenChar(2);
KbName('UnifyKeyNames');
screenNumber = max(Screen('Screens'));

load('../../mat/ccmat.mat');
load('../../mat/upvplWhitePoints.mat');
lum = 2;
bgUpvpl = upvplWhitePoints(knnsearch(upvplWhitePoints(:,3), lum),:);
bgColor = conv_upvpl2rgb(bgUpvpl,ccmat);
clear ccmat;
clear upvplWhitePoints;

try
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    [winPtr, winRect] = PsychImaging('Openwindow', screenNumber, bgColor);
    Priority(MaxPriority(winPtr));
    [offwin1,offwinrect]=Screen('OpenOffscreenWindow',winPtr, 0);
    
    FlipInterval = Screen('GetFlipInterval', winPtr); % monitor 1 flame time
    RefleshRate = 1./FlipInterval; 
    %HideCursor(screenNumber);
    [mx,my] = RectCenter(winRect);
    [winWidth, winHeight]=Screen('WindowSize', winPtr);
    
    startText = 'Click to start';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, startText, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    
    SetMouse(winWidth/2,winHeight/2,winPtr);
    changeRGB = 0;
    wheelValBefore = 0;
    rgbGray = [50 50 50];
    while 1
        [x,y,buttons,focus,val] = GetMouse(winPtr,0);
        val;
        buttons
        
        if size(val,2) == 4
            changeRGB = -(val(4)-wheelValBefore) / 15;
            if abs(changeRGB) == 1
                rgbGray = rgbGray + changeRGB;
                %if rgbGray
            end
            wheelValBefore = val(4);
        end
        
        Screen('FillRect',winPtr,rgbGray, [mx-200,my-200,mx+200,my+200]);      
        Screen('Flip', winPtr);
        
        if buttons(1) == 1
            break;
        end
    end
        
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