clear;close all;clc;FS=20;

load dataWine

%% Simple linear fit

EPR=T.TEAC_EPR_Trolox;
UV=T.TEAC_U_VIS_Trolox;
p=polyfit(EPR,UV,1);

Nred=find(strcmp('red',T.color));
Nrose=find(strcmp('rose',T.color));
Nwhite=find(strcmp('white',T.color));

figure(1)

plot(EPR(Nred),UV(Nred),'o','color','red','LineWidth',1.5)
hold on
plot(EPR(Nrose),UV(Nrose),'o','color','magenta','LineWidth',1.5)
plot(EPR(Nwhite),UV(Nwhite),'o','color','green','LineWidth',1.5)
EPRfit=linspace(min(EPR),1.05*max(EPR),20);
plot(EPRfit,polyval(p,EPRfit),'--','color','black','LineWidth',1)
ylim([0 1.05*max(EPR)])
xlim([0 1.05*max(EPR)])
xlabel('TEAC_{EPR}')
ylabel('TEAC_{UV-vis}')
set(gca,'FontSize',FS)
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 12 8],'PaperSize',[12 8])

print -dpng Fig1simple_corr

corrcoef(UV,EPR)

RMSE=sqrt(sum((EPR-UV).^2)/length(EPR))
maxAE=max(abs(EPR-UV))

%% CatBoost

% Prepare the columns description for CatBoost
TCB=T(:,[8,7,5:6,9:10,11:12]);
Param={'TEACUV','TEACEPR','Tint','CI','TPC','AlcContent','Sugar','Origin'}';
Type={'Label','Num','Num','Num','Num','Num','Categ','Categ'}';
No=[0:length(Param)-1]';
CD=table(No,Type,Param);
bsl=table(polyval(p,EPR),'VariableNames',{'RawFormulaVal'});
writetable(bsl,'bsline.txt','Delimiter','\t','WriteVariableNames',1);
writetable(CD,'TabDescrCateg.txt','Delimiter','\t','WriteVariableNames',0);
writetable(TCB,'trainDataNumCateg.txt','Delimiter','\t','WriteVariableNames',0);
command = 'catboost-0.26.exe fit --learn-set trainDataNumCateg.txt --column-description TabDescrCateg.txt --learn-baseline bsline.txt --loss-function RMSE --logging-level Silent --depth 2';
status = system(command)
command = 'catboost-0.26.exe fstr -m model.bin --input-path trainDataNumCateg.txt --column-description TabDescrCateg.txt -o feature_importancesCateg.tsv'
status = system(command)

command = 'catboost-0.26.exe calc -m model.bin --input-path trainDataNumCateg.txt --column-description TabDescrCateg.txt  --prediction-type RawFormulaVal,Probability  -o OutNum.tsv'
status = system(command)



A=tdfread('OutNum.tsv');
Pred=A.RawFormulaVal;
Pred=polyval(p,EPR)+Pred;

maxAE1=max(abs(Pred-UV))
RMSE=sqrt(sum((Pred-UV).^2)/length(EPR))
close all;

figure;
stem(abs(Pred-UV)./UV,'color','blue')
hold on
stem(abs(polyval(p,EPR)-UV)./UV,'*','color','black')

w=1:44;
wname=table2cell(T(:,1));
set(gca,'FontSize',FS)


wname=table2cell(T(:,1));
for j = 1:length(Nred)
    wname{Nred(j)} = ['\color{red} ' wname{Nred(j)}];
end
for j = 1:length(Nrose)
    wname{Nrose(j)} = ['\color{magenta} ' wname{Nrose(j)}];
end
for j = 1:length(Nwhite)
    wname{Nwhite(j)} = ['\color{green} ' wname{Nwhite(j)}];
end

set(gca,'XTick',w,'XTickLabel',wname,'FontSize',FS-7,'XTickLabelRotation',90)
print -dpng Fig2deviations


% %% Reduced set
% 
% % Prepare the columns description for CatBoost
% TCB=T(:,[8,7,9,6]);
% Param={'TEACUV','TEACEPR','TPC','CI'}';
% Type={'Label','Num','Num','Num'}';
% No=[0:length(Param)-1]';
% CD=table(No,Type,Param);
% writetable(CD,'TabDescrCategR.txt','Delimiter','\t','WriteVariableNames',0);
% writetable(TCB,'trainDataNumCategR.txt','Delimiter','\t','WriteVariableNames',0);
% command = 'catboost-0.26.exe fit --learn-set trainDataNumCategR.txt --column-description TabDescrCategR.txt --loss-function RMSE --logging-level Silent --depth 8 --iterations 3000';
% status = system(command)
% 
% command = 'catboost-0.26.exe calc -m model.bin --input-path trainDataNumCategR.txt --column-description TabDescrCategR.txt --prediction-type RawFormulaVal,Probability  -o OutNumR.tsv'
% status = system(command)
% 
% AR=tdfread('OutNumR.tsv');
% PredR=AR.RawFormulaVal;
% 
% maxAE1R=max(abs(PredR-UV))
% RMSER=sqrt(sum((PredR-UV).^2)/length(EPR))
% 
% 
% stem(abs(PredR-UV)./UV,'s')