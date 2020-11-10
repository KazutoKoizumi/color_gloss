% 白色点をD65の色度として色域を調べる

cx2u = makecform('xyz2upvpl');
cu2x = makecform('upvpl2xyz');
cx2X = makecform('xyl2xyz');
load('../mat/ccmat.mat');

% D65の色度
XYZWhitePoint = whitepoint('D65');
uvlWhitePoint = applycform(XYZWhitePoint,cx2u);

% モニターの最小と最大
minXYZ = TNT_rgb2XYZ([0;0;0],ccmat);
maxXYZ = TNT_rgb2XYZ([1;1;1],ccmat);
minLum = minXYZ(2);
maxLum = maxXYZ(2);

lumDiv = 200;
lumLogScale = logspace(log10(minLum),log10(maxLum), lumDiv);

upvplWhitePointsD65 = zeros(lumDiv,3);
upvplWhitePointsD65(:,1:2) = ones(lumDiv,2) .* uvlWhitePoint(1:2);
upvplWhitePointsD65(:,3) = ones(lumDiv,1) .* lumLogScale';

monitorColorMaxD65 = zeros(lumDiv,3,8);
r2 = sqrt(2);
uUnitCircle = [1 1/r2 0 -1/r2 -1 -1/r2 0 1/r2];
vUnitCircle = [0 1/r2 1 1/r2 0 -1/r2 -1 -1/r2];
colorDistanceDiff = 0.001;

for i = 1:lumDiv
    for j = 1:8
        monitorColorMaxD65(i,:,j) = upvplWhitePointsD65(i,:);
        while 1
            monitorColorMaxD65(i,1,j) = monitorColorMaxD65(i,1,j) + uUnitCircle(j)*colorDistanceDiff;
            monitorColorMaxD65(i,2,j) = monitorColorMaxD65(i,2,j) + vUnitCircle(j)*colorDistanceDiff;
            if (max(TNT_XYZ2rgb(applycform(monitorColorMaxD65(i,:,j),cu2x)',ccmat)) > 1) || (min(TNT_XYZ2rgb(applycform(monitorColorMaxD65(i,:,j),cu2x)',ccmat)) < 0)
                monitorColorMaxD65(i,1,j) = monitorColorMaxD65(i,1,j) - uUnitCircle(j)*colorDistanceDiff;
                monitorColorMaxD65(i,2,j) = monitorColorMaxD65(i,2,j) - vUnitCircle(j)*colorDistanceDiff;
                break;
            end
        end
    end
    disp(num2str(i)+"/200"+blanks(4)+num2str(round(i/200*100))+"%...");
end
    
fixedColorMaxD65 = monitorColorMaxD65 - upvplWhitePointsD65;
fixedColorMaxD65(:,3,:) = monitorColorMaxD65(:,3,:);

uvColor = fixedColorMaxD65(:,1:2,:);

saturationMaxD65 = sqrt(sum(uvColor.^2, 2));
saturationMaxD65 = reshape(saturationMaxD65,[lumDiv, 8]);
saturationMaxD65 = min(saturationMaxD65,[],2);

saturateColorD65 = zeros(lumDiv,3,8);
saturateColorD65(:,3,:) = monitorColorMaxD65(:,3,:);
for i = 1:8
    saturateColorD65(:,1,i) = saturationMaxD65*cos((i-1)*pi/4);
    saturateColorD65(:,2,i) = saturationMaxD65*sin((i-1)*pi/4);
end

save('../mat/D65/lumLogScale','lumLogScale');
save('../mat/D65/monitorColorMaxD65','monitorColorMaxD65');
save('../mat/D65/upvplWhitePointsD65','upvplWhitePointsD65');
save('../mat/D65/fixedColorMaxD65', 'fixedColorMaxD65');
save('../mat/D65/saturationMaxD65', 'saturationMaxD65');
save('../mat/D65/saturateColorD65', 'saturateColorD65');