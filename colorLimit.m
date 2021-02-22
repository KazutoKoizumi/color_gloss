% モニターの色域を調べるプログラム
% mat/に
%   logScale.mat : ?
%   upvplWhitePoints.mat : 各輝度での白色点のuv座標
%   monitorColorMax.mat : 各輝度での色域の限界のuv座標、8色
%   fixedColorMax.mat : 各輝度、各色相の白色点から最大彩度までのu,v座標の変位
%   saturationMax.mat : 各輝度での、彩度一定で彩色できる距離（白色点を中心とした円の半径）
%   saturateColor.mat : saturationMaxに対応する、各色相の白色点からのuv座標の変位
% を生成する
% 

cx2u = makecform('xyz2upvpl');
cu2x = makecform('upvpl2xyz');

lumDivNumber = 200;
r2 = sqrt(2);
uUnitCircle = [1 1/r2 0 -1/r2 -1 -1/r2 0 1/r2];
vUnitCircle = [0 1/r2 1 1/r2 0 -1/r2 -1 -1/r2];
colorDistanceDiff = 0.001;

logScale = logspace(-3, 0, lumDivNumber);
rgbDiv = zeros(1,lumDivNumber+10);
rgbDiv(1:11) = 0:0.0001:0.001;
rgbDiv(11:lumDivNumber+10) = logScale;
lumDivNumber = lumDivNumber+10;

monitorColorMax = zeros(lumDivNumber,3,8);
%logScale = 0:1/lumDivNumber:1;
load('../mat/ccmat.mat');
upvplWhitePoints = zeros(lumDivNumber,3);

for i = 1:lumDivNumber
    xyzLogScale = TNT_rgb2XYZ([rgbDiv(i);rgbDiv(i);rgbDiv(i)],ccmat);
    upvplLogScaledWhitePoint = applycform(xyzLogScale',cx2u);
    upvplWhitePoints(i,:) = upvplLogScaledWhitePoint;
    for j = 1:8
        monitorColorMax(i,:,j) = upvplLogScaledWhitePoint;
        while 1
            monitorColorMax(i,1,j) = monitorColorMax(i,1,j) + uUnitCircle(j)*colorDistanceDiff;
            monitorColorMax(i,2,j) = monitorColorMax(i,2,j) + vUnitCircle(j)*colorDistanceDiff;
            % disp(monitorColorMax(i,:,j));
            if (max(TNT_XYZ2rgb(applycform(monitorColorMax(i,:,j),cu2x)',ccmat)) > 1) || (min(TNT_XYZ2rgb(applycform(monitorColorMax(i,:,j),cu2x)',ccmat)) < 0)
                monitorColorMax(i,1,j) = monitorColorMax(i,1,j) - uUnitCircle(j)*colorDistanceDiff;
                monitorColorMax(i,2,j) = monitorColorMax(i,2,j) - vUnitCircle(j)*colorDistanceDiff;
                break;
            end
        end
    end
    disp(num2str(i)+"/200"+blanks(4)+num2str(round(i/200*100))+"%...");
end

fixedColorMax = monitorColorMax - upvplWhitePoints;
fixedColorMax(:,3,:) = monitorColorMax(:,3,:);

uvColor = zeros(lumDivNumber,2,8);
uvColor = fixedColorMax(:,1:2,:);

saturationMax = sqrt(sum(uvColor.^2, 2));
saturationMax = reshape(saturationMax,[lumDivNumber, 8]);
saturationMax = min(saturationMax,[],2);

saturateColor = zeros(lumDivNumber,3,8);
saturateColor(:,3,:) = monitorColorMax(:,3,:);
for i = 1:8
    saturateColor(:,1,i) = saturationMax*cos((i-1)*pi/4);
    saturateColor(:,2,i) = saturationMax*sin((i-1)*pi/4);
end


save('../mat/logScale','logScale');
save('../mat/monitorColorMax','monitorColorMax');
save('../mat/upvplWhitePoints','upvplWhitePoints');
save('../mat/fixedColorMax', 'fixedColorMax');
save('../mat/saturationMax', 'saturationMax');
save('../mat/saturateColor', 'saturateColor');
