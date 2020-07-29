%% モニターの色域を調べるプログラム
% mat/にlogScale.mat,monitorColorMax.mat,upvplWhitePoints.matを生成する

cx2u = makecform('xyz2upvpl');
cu2x = makecform('upvpl2xyz');

lumDivNumber = 200;
r2 = sqrt(2);
uUnitCircle = [1 1/r2 0 -1/r2 -1 -1/r2 0 1/r2];
vUnitCircle = [0 1/r2 1 1/r2 0 -1/r2 -1 -1/r2];
colorDistanceDiff = 0.001;

monitorColorMax = zeros(lumDivNumber,3,8);
logScale = logspace(-3, 0, lumDivNumber);
load('../mat/ccmat.mat');

for i = 1:lumDivNumber
    xyzLogScale = TNT_rgb2XYZ([logScale(i);logScale(i);logScale(i)],ccmat);
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

save('../mat/logScale','logScale');
save('../mat/monitorColorMax','monitorColorMax');
save('../mat/upvplWhitePoints','upvplWhitePoints');
