% 選考尺度値に有意差があるかをチェックする

exp = 'experiment_gloss';
sn = 'all_N3';

load(strcat('../../analysis_result/',exp,'/',sn,'/sv.mat'));
load(strcat('../../analysis_result/',exp,'/',sn,'/selectionScale.mat'));

colorNum = 1:9;
conbination = nchoosek(colorNum, 2);

se = 1.96;
sValueDifference = zeros(size(conbination,1),3,3,2,3,3,2);

for i =1:size(conbination,1)
    sValueDifference(i,:,:,:,:,:,:) = selectionScale(conbination(i,1),:,:,:,:,:,:) - selectionScale(conbination(i,2),:,:,:,:,:,:);
end

%errorbar(a, sValueDifference(:,3,1,1,1,1,1), -se*sValueDifference(:,1,1,1,1,1,1), se*sValueDifference(:,2,1,1,1,1,1), 'o');