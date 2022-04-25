clear;close all;clc;FS=20;

load dataWine

EPR=T.TEAC_EPR_Trolox;
UV=T.TEAC_U_VIS_Trolox;
p=polyfit(EPR,UV,1);

%% Reduced set


Param={'TEACUV','TEACEPR','TPC','CI','Tint'}';
Type={'Label','Num','Num','Num','Num'}';
No=[0:length(Param)-1]';
CD=table(No,Type,Param);
writetable(CD,'TabDescrCategR.txt','Delimiter','\t','WriteVariableNames',0);
% First row
TCB=T(2:end,[8,7,9,6,5]);
writetable(TCB,'trainDataNum.txt','Delimiter','\t','WriteVariableNames',0);

bsl=table(polyval(p,EPR(2:end)),'VariableNames',{'RawFormulaVal'});
writetable(bsl,'bsline.txt','Delimiter','\t','WriteVariableNames',1);

command = 'catboost-0.26.exe fit --learn-set trainDataNum.txt --column-description TabDescrCategR.txt --loss-function RMSE --logging-level Silent --depth 5 --learn-baseline bsline.txt';
status = system(command)
TCBtest=T(1,[8,7,9,6,5]);
bsltest=table(polyval(p,EPR(1)),'VariableNames',{'RawFormulaVal'});
writetable(bsltest,'bslinetest.txt','Delimiter','\t','WriteVariableNames',1);
writetable(TCBtest,'testDataNum.txt','Delimiter','\t','WriteVariableNames',0);
command = 'catboost-0.26.exe calc -m model.bin --input-path testDataNum.txt --column-description TabDescrCategR.txt --prediction-type RawFormulaVal,Probability  -o OutNumR.tsv'
status = system(command)
AR=tdfread('OutNumR.tsv');
Pred(1)=AR.RawFormulaVal;

% Intermediate rows
for j=2:43
    TCB=T([1:j-1,j+1:end],[8,7,9,6,5]);
    writetable(TCB,'trainDataNum.txt','Delimiter','\t','WriteVariableNames',0);

bsl=table(polyval(p,EPR(1:j-1,j+1:end)),'VariableNames',{'RawFormulaVal'});
writetable(bsl,'bsline.txt','Delimiter','\t','WriteVariableNames',1);

    command = 'catboost-0.26.exe fit --learn-set trainDataNum.txt --column-description TabDescrCategR.txt --loss-function RMSE --logging-level Silent --depth 5 --learn-baseline bsline.txt';
    status = system(command)
    TCBtest=T(j,[8,7,9,6,5]);
    writetable(TCBtest,'testDataNum.txt','Delimiter','\t','WriteVariableNames',0);
    command = 'catboost-0.26.exe calc -m model.bin --input-path testDataNum.txt --column-description TabDescrCategR.txt --prediction-type RawFormulaVal,Probability  -o OutNumR.tsv'
    status = system(command)
    AR=tdfread('OutNumR.tsv');
    Pred(j)=AR.RawFormulaVal;
end
% Last row
TCB=T(1:end-1,[8,7,9,6,5]);
writetable(TCB,'trainDataNum.txt','Delimiter','\t','WriteVariableNames',0);
bsl=table(polyval(p,EPR(2:end)),'VariableNames',{'RawFormulaVal'});
writetable(bsl,'bsline.txt','Delimiter','\t','WriteVariableNames',1);
command = 'catboost-0.26.exe fit --learn-set trainDataNum.txt --column-description TabDescrCategR.txt --loss-function RMSE --logging-level Silent --depth 5 --learn-baseline bsline.txt';
status = system(command);
TCBtest=T(end,[8,7,9,6,5]);
writetable(TCBtest,'testDataNum.txt','Delimiter','\t','WriteVariableNames',0);
command = 'catboost-0.26.exe calc -m model.bin --input-path testDataNum.txt --column-description TabDescrCategR.txt --prediction-type RawFormulaVal,Probability  -o OutNumR.tsv'
status = system(command)
AR=tdfread('OutNumR.tsv');
Pred(44)=AR.RawFormulaVal;

command = 'catboost-0.26.exe fstr -m model.bin --input-path trainDataNum.txt --column-description TabDescrCategR.txt -o feature_importancesNum.tsv'
status = system(command)

Pred=Pred';
Pred=polyval(p,EPR)+Pred;

RMSE=sqrt(sum((Pred-UV).^2)/length(UV))
maxAE=max(abs(Pred-UV))


figure;
stem(abs(polyval(p,EPR)-UV)./UV,'*','color','black')
hold on
stem(abs(Pred-UV)./UV,'color','blue')

%%% Comparision with naive ML
load BadPred
stem(BadPred,'x','color','red')


ylabel('Relative AD')

w=1:44;
wname=table2cell(T(:,1));
set(gca,'FontSize',FS)

Nred=find(strcmp('red',T.color));
Nrose=find(strcmp('rose',T.color));
Nwhite=find(strcmp('white',T.color));

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

set(gca,'XTick',w,'XTickLabel',wname,'FontSize',FS-3.5,'XTickLabelRotation',90)
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 12 8],'PaperSize',[12 8])

print -dpng Fig2deviations


