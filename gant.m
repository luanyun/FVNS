function []=gant(newschedule,Scenario)
global citys
switch Scenario
    case 1
        axis([6,23,0.5,7.5]);
        n_task_nb = 70;
    case 2
        axis([6,23,7.5,19.5]);
        n_task_nb = 140;
    otherwise
        return
end

set(gca,'xtick',0:1:24) ;
set(gca,'ytick',0.5:1:20) ;
n_start_time=newschedule(:,8)/60;
n_duration_time =newschedule(:,10)/60;
n_bay_start=newschedule(:,7);
rec=[0,0,0,0];
for i =1:n_task_nb  
  rec(1) = n_start_time(i);%矩形的横坐标
  rec(2) = n_bay_start(i)-0.45;  %矩形的纵坐标
  rec(3) = n_duration_time(i);  %矩形的x轴方向的长度
  rec(4) = 0.9; 
  txt1=sprintf('%d',newschedule(i,1));
   rectangle('Position',rec,'LineWidth',0.5,'LineStyle','-','FaceColor','w');%draw every rectangle  
   text(n_start_time(i)+n_duration_time(i)/2,(n_bay_start(i))-0.3,txt1,'FontWeight','Bold','FontSize',8,'HorizontalAlignment','center');
   text(n_start_time(i)+n_duration_time(i)/2,(n_bay_start(i)),citys(newschedule(i,2)),'FontWeight','Bold','FontSize',8,'HorizontalAlignment','center');
   text(n_start_time(i)+n_duration_time(i)/2,(n_bay_start(i))+0.3,citys(newschedule(i,3)),'FontWeight','Bold','FontSize',8,'HorizontalAlignment','center');%label the id of every task  
end  
switch Scenario
    case 1
        for i=1:7
            text(5.4,i,sprintf('C%d',i),'FontWeight','Bold','FontSize',12);
        end
    case 2
        for i=8:19
            text(5.4,i,sprintf('C%d',i),'FontWeight','Bold','FontSize',12);
        end
end
set(gca,'ydir','reverse')
set(gca,'XGrid','on'); 
set(gca,'YGrid','on'); 
set(gca,'XMinorGrid','on')
set(gca,'GridAlpha',0.8);
set(gca,'MinorGridAlpha',0.8);
set(gca,'YTickLabel',[]);
set(gca,'XAxisLocation','top');
set(gca,'FontWeight','bold');
xpatch=[14,14,15,15];
ypatch=[0.5,19.5,19.5,0.5];
patch(xpatch,ypatch,'k','LineWidth',1,'facealpha',0.2);