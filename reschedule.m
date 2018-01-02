function []=reschedule(ac,i,actime)
global strings1 intervalTime
if size(strings1{ac},1)<i
    return
end
strings1{ac}(:,7)=ac;
strings1{ac}(i,8)=actime;
strings1{ac}(i,9)=strings1{ac}(i,8)-strings1{ac}(i,5)+strings1{ac}(i,6);
for i1=i+1:size(strings1{ac},1)
    if strings1{ac}(i1,5)<strings1{ac}(i1-1,9)+intervalTime;
        strings1{ac}(i1,8)=strings1{ac}(i1-1,9)+intervalTime;
        strings1{ac}(i1,9)=strings1{ac}(i1,8)-strings1{ac}(i1,5)+strings1{ac}(i1,6);
        
    else
        strings1{ac}(i1,8)=strings1{ac}(i1,5);
        strings1{ac}(i1,9)=strings1{ac}(i1,6);
    end
end
strings1{ac}(:,11)=strings1{ac}(:,8)-strings1{ac}(:,5);

end