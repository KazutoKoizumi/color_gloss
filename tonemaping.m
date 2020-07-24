function tonemappedXYZ = tonemaping(xyz,sameXyz,lw,scale,ccmatrix)

[iy,ix,iz] = size(xyz);

cx2u = makecform('xyz2upvpl');
cu2x = makecform('upvpl2xyz');
monitorMaxUpvpl = applycform(transpose(TNT_rgb2XYZ([1 1 1]',ccmatrix)),cx2u);
monitorMaxLum = monitorMaxUpvpl(3);
monitorMinUpvpl = applycform(transpose(TNT_rgb2XYZ([0 0 0]',ccmatrix)),cx2u);
monitorMinLum = monitorMinUpvpl(3);
upvpl = applycform(xyz,cx2u);
%disp(strcat('max luminance: ',num2str(monitorMaxLum)));
a = max(max(applycform(sameXyz,cx2u)));
sh = 8;

% bunny,area,D01 : 4,  D03 : 6,  D05 : 8
% bunny,envmap,D01 : 2, D03 : 2, D05 : 3
% dragon,area,D01 : 4, D03 : 6, D05 : 8
% dragon,envmap,D01 : 2, D03 : 2, D05 : 3
% blob,area,D01 : 4, D03 : 6, D05 : 8
% blob,envmap,D01 : 2, D03 : 2, D05 : 3
%lw = 3;

% Reinhard function
for i = 1:iy
    for j = 1:ix
        %x = upvpl(i,j,3)/a(3);
        %upvpl(i,j,3) = monitorMaxLum * x*sh/(1+x*sh)*(1+x*sh/lw^2);
        %upvpl(i,j,3) = monitorMaxLum * x.^(1/lw);
        %upvpl(i,j,3) = monitorMmaxLum * log(1+lw*x);
        %upvpl(i,j,3) = monitorMaxLum * x;
        
        x = upvpl(i,j,3);
        %f = (x/(1+x)) * (1+x/lw^2);
        k = log(1/255) / lw;
        f = 1 - exp(k*x);
        upvpl(i,j,3) = f * monitorMaxLum;
        if upvpl(i,j,3) > monitorMaxLum
            upvpl(i,j,3) = monitorMaxLum;
        elseif upvpl(i,j,3) < 0
            upvpl(i,j,3) = 0;
        end
        if upvpl(i,j,3) < 10^(-20)
            upvpl(i,j,:) = upvpl(i,j-1,:);
        end
    end
end

minUpvpl = min(min(applycform(sameXyz,cx2u)));
upvpl(:,:,3) = upvpl(:,:,3) * scale;
upvpl(:,:,3) = upvpl(:,:,3)*(monitorMaxLum-monitorMinLum)/monitorMaxLum;
upvpl(:,:,3) = upvpl(:,:,3) + monitorMinLum/2;

tonemappedXYZ = applycform(upvpl,cu2x);
max(max(upvpl));

end
