%% Show descriptor result
function [] = TYY_showResults()
% 1 - SIFT
% 2 - DSP
% 3 - ASV with interpolation
% 4 - 1M2M
% 5 - ASV w/same threshold for all pairs of scale samples
% 6 - ASV w/same threshold for all thresholds for given pairs of scales
% 7 - ASV w/two interpolated samples in 1/3 and 2/3 of distance in between 
% those samples
% 8 - ASV with no interpolation

desType1 = 8;
desType2 = 6;

allmAP(desType1)
headTohead(desType1,desType2)



function [] = allmAP(desType)

detectType = 1;
if detectType == 1
    nameR = ['./mAPdes/DoG/'];
elseif detectType == 2
    nameR = ['./mAPdes/MSER/'];
end
if size(dir(nameR),1) ==0
    fprintf('-----------------------------------------------\n');
    fprintf('No result is evaluated yet.\nYou need to extract the descriptors \nand run the TYY_evaluation_des.m. \nCheck the readme.txt again !!!\n')
    fprintf('-----------------------------------------------\n');
    stop
end

if desType == 1
    load([nameR,'allResults_sift.mat'])
elseif desType ==2
    load([nameR,'allResults_dsp.mat'])
elseif desType ==3
    load([nameR,'allResults_asv.mat'])
elseif desType ==4
    load([nameR,'allResults_1m2m.mat'])
elseif desType ==5
    load([nameR,'allResults_asv_y1.mat']) 
elseif desType ==6
    load([nameR,'allResults_asv_y2.mat']) 
elseif desType ==7
    load([nameR,'allResults_asv_y3.mat']) 
elseif desType ==8
    load([nameR,'allResults_asv_no_inter.mat'])
else
    stop
end


mAP = sum(AP)/(8*5);
fprintf('mAP: %.4f\n',mAP);



figure(1)
data = [AP'];
hbar = bar(data);
set(hbar(1),'facecolor',[1 0 0]);
xlabel('image pair ID','FontSize',20)
ylabel('AP','FontSize',20)


%% Comparing different methods
function [] = headTohead(desType1,desType2)

desType =[desType1,desType2];
detectType = [1,1];
pairAP = zeros(2,8*5);

for i = 1:2
    
    if detectType(i) == 1
        nameR = ['./mAPdes/DoG/'];
    end
    if size(dir(nameR),1) ==0
        mkdir(nameR)
    end

    if desType(i) == 1
        load([nameR,'allResults_sift.mat'])
        pairAP(i,:) = AP;
    elseif desType(i) ==2
        load([nameR,'allResults_dsp.mat'])
        pairAP(i,:) = AP;
    elseif desType(i) ==3
        load([nameR,'allResults_asv.mat'])
        pairAP(i,:) = AP;
    elseif desType(i) ==4
        load([nameR,'allResults_1m2m.mat'])
        pairAP(i,:) = AP;
    elseif desType(i) ==5
        load([nameR,'allResults_asv_y1.mat'])
        pairAP(i,:) = AP;
    elseif desType(i) ==6
        load([nameR,'allResults_asv_y2.mat'])
        pairAP(i,:) = AP;
    elseif desType(i) ==7
        load([nameR,'allResults_asv_y3.mat'])
        pairAP(i,:) = AP;
    elseif desType(i) ==8
        load([nameR,'allResults_asv_no_inter.mat'])
        pairAP(i,:) = AP;
    end
end

figure(2)
x = 0:0.1:1;
y = 0:0.1:1;
plot(pairAP(1,:),pairAP(2,:),'ro',x,y,'k--','linewidth',3)
xlabel(['desType:',num2str(desType(1)),', detectType: ',num2str(detectType(1))],'fontsize',20);
ylabel(['desType:',num2str(desType(2)),', detectType: ',num2str(detectType(2))],'fontsize',20);
title('Oxford','fontsize',20)