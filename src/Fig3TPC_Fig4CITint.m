clear;close all;clc;FS=20;

load dataWine

EPR=T.TEAC_EPR_Trolox;
UV=T.TEAC_U_VIS_Trolox;


Nred=find(strcmp('red',T.color));
Nrose=find(strcmp('rose',T.color));
Nwhite=find(strcmp('white',T.color));

TPC=T.TPC;
Tint=T.tint;
CI=T.color_density;

%% Total phenolic content


figure(1)
plot(log(TPC),log(EPR),'o');
pTPC=polyfit(log(TPC),log(EPR),1);
hold on
plot(log(TPC),polyval(pTPC,log(TPC),'--'))


figure(2)

loglog(TPC(Nred),EPR(Nred),'o','color','red','LineWidth',1.5)
hold on
loglog(TPC(Nrose),EPR(Nrose),'o','color','magenta','LineWidth',1.5)
loglog(TPC(Nwhite),EPR(Nwhite),'o','color','green','LineWidth',1.5)
TPCfit=linspace(min(TPC),1.05*max(TPC),20);
loglog(TPCfit,0.0432*TPCfit.^(1.32),'--','color','black','LineWidth',1)
ylim([9 2100])
xlim([60 2600])
xlabel('TPC')
ylabel('TEAC_{EPR}')
set(gca,'FontSize',FS)
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 12 8],'PaperSize',[12 8])

print -dpng Fig3TPC

%% Color intensity

figure(3)
loglog(CI(Nred),EPR(Nred),'o','color','red','LineWidth',1.5)
hold on
loglog(CI(Nrose),EPR(Nrose),'o','color','magenta','LineWidth',1.5)
loglog(CI(Nwhite),EPR(Nwhite),'o','color','green','LineWidth',1.5)
pCI=polyfit(log(CI),log(EPR),1);
hold on
loglog(CI,exp(polyval(pCI,log(CI))),'--')

%% Tint

figure(4)
loglog(Tint(Nred),EPR(Nred),'o','color','red','LineWidth',1.5)
hold on
loglog(Tint(Nrose),EPR(Nrose),'o','color','magenta','LineWidth',1.5)
loglog(Tint(Nwhite),EPR(Nwhite),'o','color','green','LineWidth',1.5)
pTint=polyfit(log(Tint),log(EPR),1);
hold on
loglog(Tint,exp(polyval(pTint,log(Tint))),'--')


figure(5)


h1=axes('Position',[0.1 0.15 0.8 0.75]);
loglog(CI(Nred),EPR(Nred),'o','color','red','LineWidth',1.5,'MarkerSize',8)
hold on
loglog(CI(Nrose),EPR(Nrose),'o','color','magenta','LineWidth',1.5,'MarkerSize',8)
loglog(CI(Nwhite),EPR(Nwhite),'o','color','green','LineWidth',1.5,'MarkerSize',8)
xCI=exp(linspace(log(0.07),log(11),30));
loglog(xCI,146.1*xCI.^0.65,'-','color','black')
xlim([0.05 21])
ylim([9 2100])
xlabel('CI')
ylabel('TEAC_{EPR}')
set(h1,'FontSize',FS);

h2=axes('Position',[0.1 0.15 0.8 0.75]);
loglog(Tint(Nred),EPR(Nred),'*','color','red','LineWidth',1.5,'MarkerSize',8)
hold on
loglog(Tint(Nrose),EPR(Nrose),'*','color','magenta','LineWidth',1.5,'MarkerSize',8)
loglog(Tint(Nwhite),EPR(Nwhite),'*','color','green','LineWidth',1.5,'MarkerSize',8)
xTint=exp(linspace(log(0.8),log(4.6),30));
loglog(xTint,312.1*xTint.^(-1.44),'--','color','blue')
xlim([0.6 5.1])
ylim([9 2100])
xlabel('Tint')
ylabel('TEAC_{EPR}')
set(h2,'color','none','XAxisLocation','top','FontSize',FS)

set(gcf,'PaperUnits','inches','PaperPosition',[0 0 12 8],'PaperSize',[12 8])

print -dpng 'Fig4CITint'
