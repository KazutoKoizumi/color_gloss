function tonemappedXYZ = tonemaping(xyz,lw)

load('../mat/upvplWhitePoints.mat');
[iy,ix,iz] = size(xyz);

cx2u = makecform('xyz2upvpl');
cu2x = makecform('upvpl2xyz');
monitorMaxLum = max(upvplWhitePoints(:,3))/2-1;
%monitorMaxLum = max(upvplWhitePoints(:,3))-2;
%monitorMinLum = min(upvplWhitePoints(:,3));
monitorMinLum = upvplWhitePoints(2,3);
upvpl = applycform(xyz,cx2u);

%lw = 3.5;

%lw = max(max(upvpl(:,:,3)))
for i = 1:iy
    for j = 1:ix
        
        x = upvpl(i,j,3);
        %f = (x/(1+x)) * (1+x/lw^2);
        k = log(1/255) / lw;
        f = 1 - exp(k*x);
        upvpl(i,j,3) = f * monitorMaxLum;
        if upvpl(i,j,3) > monitorMaxLum
            upvpl(i,j,3) = monitorMaxLum;
        elseif upvpl(i,j,3) < monitorMinLum
            upvpl(i,j,3) = monitorMinLum;
        end
    end
end

tonemappedXYZ = applycform(upvpl,cu2x);

end
