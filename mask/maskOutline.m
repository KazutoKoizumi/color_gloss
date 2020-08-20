% マスクイメージから輪郭部を切り落として新たなマスクを生成する

load('maskBunny.mat');

maskNoOutline = zeros(size(mask));
count = 0;

for i = 2:size(mask, 1)-1
    for j = 2:size(mask, 2)-1
        count = 0;
        if mask(i,j) == 1
            if mask(i-1,j) == 0
                count = count + 1;
            end
            if mask(i+1,j) == 0
                count = count + 1;
            end
            if mask(i,j-1) == 0
                count = count + 1;
            end
            if mask(i,j+1) == 0
                count = count + 1;
            end
            
            if count == 0
                maskNoOutline(i,j) = mask(i,j);
            end
        end
    end
end

maskNoOutline2 = zeros(size(mask));
count = 0;

for i = 2:size(mask, 1)-1
    for j = 2:size(mask, 2)-1
        count = 0;
        if maskNoOutline(i,j) == 1
            if maskNoOutline(i-1,j) == 0
                count = count + 1;
            end
            if maskNoOutline(i+1,j) == 0
                count = count + 1;
            end
            if maskNoOutline(i,j-1) == 0
                count = count + 1;
            end
            if maskNoOutline(i,j+1) == 0
                count = count + 1;
            end
            
            if count == 0
                maskNoOutline2(i,j) = maskNoOutline(i,j);
            end
        end
    end
end

save('maskBunnyOutline', 'maskNoOutline2');
                
            
                
