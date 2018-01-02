clear
global strings1 intervalTime
load data.mat
[citys,i1,j1]=unique(Schedules{:,3:4},'stable');
schedules=zeros(210,9);
schedules(:,[1,4,5,6,7,8,9])=Schedules{:,[2,1,5,6,1,5,6]};
schedules(:,2:3)=reshape(j1,210,2);
schedules(:,[5,6,8,9])=floor(schedules(:,[5,6,8,9])/100)*60+mod(schedules(:,[5,6,8,9]),100);

%config parameter
Scenario = 1;%2


numacs=[7,12];
intervalTimes=[30,20];
schedulesRange={1:70,71:210};
Indexoffset=[0,7];
numac=numacs(Scenario);
intervalTime=intervalTimes(Scenario);
schedules1=schedules(schedulesRange{Scenario},:);

Nflight=size(schedules1,1);
schedules1(:,10)=schedules1(:,9)-schedules1(:,8);
schedules1(:,11)=zeros(Nflight,1);
beginTime=840;
finishTime = 900;

tic
%delay considering airport closure
j1=j1(1:Nflight);
for i=2:Nflight
    if schedules1(i,4)~=schedules1(i-1,4)
        continue;
    end
    if (schedules1(i,2)==1||schedules1(i,2)==8)&&schedules1(i,5)<finishTime&&schedules1(i,5)>=beginTime
        schedules1(i,8)=finishTime;
        schedules1(i,9)=schedules1(i,8)-schedules1(i,5)+schedules1(i,6);
    elseif (schedules1(i,3)==1||schedules1(i,3)==8)
        if schedules1(i,6)<finishTime&&schedules1(i,6)>=beginTime
            schedules1(i,9)=finishTime;
        elseif schedules1(i,5)<finishTime&&schedules1(i,5)>=beginTime
            schedules1(i,8)=finishTime;
            schedules1(i,9)=schedules1(i,8)-schedules1(i,5)+schedules1(i,6);
        end
    end
    if schedules1(i,8)>=finishTime
        if schedules1(i,8)<schedules1(i-1,9)+intervalTime;
            schedules1(i,8)=schedules1(i-1,9)+intervalTime;
            schedules1(i,9)=schedules1(i,8)-schedules1(i,5)+schedules1(i,6);
        end
    end
    schedules1(i,11)=schedules1(i,8)-schedules1(i,5);
end

% flight order sets
strings1=cell(1,numac);
k0=1;
for i=1:numac
    k=k0;
    while k<Nflight&&schedules1(k+1,4)==schedules1(k,4)
        k=k+1;
    end
    strings1(i)=num2cell(schedules1(k0:k,:),[1 2]);
    k0=k+1;
end



while 1
    Numac=length(strings1);
    kStrings=zeros(1,Numac);
    tkStrings=zeros(1,Numac);
    for i=1:Numac
        kStrings(i)=find(strings1{i}(:,8)>=finishTime,1);
        tkStrings(i)=strings1{i}(kStrings(i),8);
    end
    
    
    [t,ac]=min(tkStrings);
    best=0;
    while t~=inf
        [t,ac]=min(tkStrings);
        i=kStrings(ac);
        t2=strings1{ac}(i,8);
        
        for j=1:numac
            if j==ac
                continue
            end
            swapj=find(strings1{j}(:,9)<t2-intervalTime&strings1{j}(:,3)==strings1{ac}(i,2));
            for k=1:length(swapj)
                
                flight=strings1{ac}(i,1);
                kflight=flight==schedules(:,2);
                jTime=max(strings1{ac}(i-1,9)+intervalTime,strings1{j}(swapj(k)+1,5));
                acTime=max(strings1{j}(swapj(k),9)+intervalTime,strings1{ac}(i,5));
                if strings1{ac}(i,2)==1||strings1{ac}(i,2)==8||strings1{ac}(i,3)==1||strings1{ac}(i,3)==8
                    acTime = max(acTime, finishTime);
                    jTime = max(jTime,finishTime);
                end
                if acTime<strings1{ac}(i,8)
                    %calulate delay cost before and after the swap
                    originalcost=sum(strings1{ac}(:,11))+sum(strings1{j}(:,11));
                    newcost=delaycost(strings1{ac},i,acTime,intervalTime)+delaycost(strings1{j},swapj(k)+1,jTime,intervalTime);
                    better=originalcost-newcost;
                    %the best swap will be acted
                    if better>best
                        best=better;
                        acbest=ac;
                        ibest=i;
                        acjbest=j;
                        sjbest=swapj(k)+1;
                        acTimeBest=acTime;
                        jTimeBest=jTime;
                    end
                end
            end
        end
        
        if kStrings(ac)+1>size(strings1{ac},1)
            tkStrings(ac)=inf;
        else
            kStrings(ac)=kStrings(ac)+1;
            tkStrings(ac)=strings1{ac}(kStrings(ac),8);
        end
    end
    if best<=0
        break
    else
        substring=strings1{acbest}(ibest:end,:);
        strings1{acbest}(ibest:end,:)=[];strings1{acbest}(1:ibest-1,8);
        strings1{acbest} =[strings1{acbest};strings1{acjbest}(sjbest:end,:)];
        strings1{acjbest}(sjbest:end,:) = [];
        strings1{acjbest}=[strings1{acjbest};substring];
        reschedule(acbest,ibest,jTimeBest);
        reschedule(acjbest,sjbest,acTimeBest);
    end
end
toc
S=0;
for i=1:numac
    S=S+sum(strings1{i}(:,11));
end
newschedule=[];
for i=1:numac
    strings1{i}(:,7)=i+Indexoffset(Scenario);
    newschedule=[newschedule;strings1{i}];
end
newschedule(:,10)=newschedule(:,9)-newschedule(:,8);
gant(newschedule,Scenario)