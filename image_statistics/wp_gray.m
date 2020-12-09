shape = ["bunny", "dragon", "blob"]; % i
light = ["area", "envmap"]; % j
diffuse = ["D01", "D03", "D05"]; % k
roughness = ["alpha005", "alpha01", "alpha02"]; %l
method = ["SD", "D"];

wp = zeros(54,2);
count = 0;
for i = 1:3 % shape
    load(strcat('../../mat/',shape(i),'Mask/mask.mat'));
    num = nnz(mask);
    for j = 1:2 % light
        for k = 1:3 % diffuse
            for l = 1:3 % roughness
                count = count + 1;
                load(strcat('../../mat_analysis/',shape(i),'/',light(j),'/',diffuse(k),'/',roughness(l),'/coloredD.mat'));
                
                cx2u = makecform('xyz2upvpl');
                cu2x = makecform('upvpl2xyz');
                
                upvpl = applycform(coloredD(:,:,:,1),cx2u);
                
                wp_u = upvpl(:,:,1);
                wp_v = upvpl(:,:,2);
                wp_u_mask = wp_u .* mask;
                wp_v_mask = wp_v .* mask;
                
                wp_u_mean = sum(wp_u_mask, 'all') / num;
                wp_v_mean = sum(wp_v_mask, 'all') / num;
                
                wp(count,:) = [wp_u_mean, wp_v_mean];
                
            end
        end
    end
end