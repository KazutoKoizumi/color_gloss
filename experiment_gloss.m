%サーストンの一対比較法で光沢感を測定する実験
clear all

% date, subject, output filename
date = char(datetime('now','Format','yyyy-MM-dd''T''HHmmss'));
subjectName = input('Subject Name?: ', 's');
dataFilename = sprintf('../data/experiment_gloss/%s_%s.mat', subjectName, date);

AssertOpenGL;
ListenChar(2);
bgColor = [0 0 0];
KbName('UnifyKeyNames');
screenNumber = max(Screen('Screens'));
%InitializeMatlabOpenGL;

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
    leftKey = KbName('LeftArrow');
    rightKey = KbName('RightArrow');
    
    % stimuli matrix
    % low, column, rgb, color, light, diffuse, roughness, SDorD
    stimuliBunny = zeros(720, 960, 3, 9, 2, 3, 3, 2);
    
    % load stimulus data : Bunny
    load('../stimuli/bunny/area/D01/alpha01/bunnySD');
    load('../stimuli/bunny/area/D01/alpha01/bunnyD');
    stimuliBunny(:,:,:,:,1,1,1,1) = bunnySD;
    stimuliBunny(:,:,:,:,1,1,1,2) = bunnyD;
    
    % display initial text
    startText = 'Press any key to start';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, startText, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    KbWait([], 2);
    WaitSecs(2);
    
    % parameter setting
    
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