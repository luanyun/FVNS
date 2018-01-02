function cost=delaycost(string,i,actime,intervalTime)
if size(string,1)<i
    cost=0;
    return
end
string(i,8)=actime;
string(i,9)=string(i,8)-string(i,5)+string(i,6);
for i1=i+1:size(string,1)
    if string(i1,5)<string(i1-1,9)+intervalTime;
        string(i1,8)=string(i1-1,9)+intervalTime;
        string(i1,9)=string(i1,8)-string(i1,5)+string(i1,6);
        
    else
        string(i1,8)=string(i1,5);
        string(i1,9)=string(i1,6);
    end
end
string(:,11)=string(:,8)-string(:,5);
cost=sum(string(:,11));
end