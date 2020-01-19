function sch1=schedulstart(data,info)
R=zeros(info.n,info.m);
cost=1./zeros(info.n,info.m);
schxij1=zeros(1,info.n);
Rset=ones(1,info.n);
matrix = zeros(info.n, 4);
for i=1:info.n
    taskID=info.rank(i);
    for j=1:info.m
        R(taskID,j)=exp(-data.lambda(j)*data.w(taskID,j));
    end
    Rmin(taskID)=min(R(taskID,:));
    Rmax(taskID)=max(R(taskID,:));
end
RminG=prod(Rmin);
RmaxG=prod(Rmax);

%³õÊ¼»¯sch
for i=1:info.n
    if data.RgoalG>RmaxG
        sch1.costG=inf;
        sch1.R=0;
        break;
    end
    taskID=info.rank(i);
    for j=1:info.m
        cost(taskID,j)=data.w(taskID,j)*data.gama(j);
        tempid=data.pre(taskID,:)>0;
        id=data.pre(taskID,tempid);
        if ~isempty(id)
            premID=zeros(1,length(id));
            for k=1:length(id)
                premID(k)=schxij1(id(k));
            end
            for k=1:length(premID)
                if j~= premID(k)
                    cost(taskID,j)=cost(taskID,j)+data.c(id(k),taskID)*data.rcomn(1);
                end
            end
            
        end
    end
    [~,coreIndex]=min(cost(taskID,:));
    schxij1(taskID)=coreIndex;
    Rset(taskID)=R(taskID,coreIndex);
end
schxij2=schxij1;

for i=1:info.n
    taskID=info.rank(i);
    if data.RgoalG>RmaxG
        sch1.costG=inf;
        sch1.R=0;
        break;
    end
    RcostCoeff=-1./zeros(1,info.m);
    for k=1:info.m
        if ~eq(schxij2(taskID),k)
            schxij3=schxij2;
            schxij3(taskID)=k;
            
            costPreTaskID = costTaskID(schxij2, data, taskID);
            costAftTaskID = costTaskID(schxij3, data, taskID);
            
            costIncrease = costAftTaskID-costPreTaskID;
            if R(taskID,k)<=R(taskID,schxij2(taskID))
                RcostCoeff(k)=-inf;
            elseif costIncrease<=0
                RcostCoeff(k)=1000+abs((R(taskID,k)/R(taskID,schxij2(taskID)))/costIncrease);
            else
                RcostCoeff(k)=(R(taskID,k)/R(taskID,schxij2(taskID)))/costIncrease;
            end
        end
    end
    [RcostCoeffvalue,newindexS]=max(RcostCoeff());
    serverMigrationFrom = schxij2(taskID);
    serverMigrationTo = newindexS;
    matrix(taskID,:) = [taskID, serverMigrationFrom, serverMigrationTo, RcostCoeffvalue];
end
while prod(Rset)<data.RgoalG
    if data.RgoalG>=RmaxG
        sch1.costG=inf;
        sch1.R=0;
        break;
    end
    [~,index]=max(matrix(:,end));
    B=matrix(index(1),:);
    taskID=B(1);
    schxij2(taskID)=B(3);
    Rset(taskID)=R(taskID,schxij2(taskID));
    %update matrix
    for s=1:info.m
        if ~eq(schxij2(taskID),s)
            
            schxij3=schxij2;
            schxij3(taskID)=s;
            
            costPreTaskID = costTaskID(schxij2, data, taskID);
            costAftTaskID = costTaskID(schxij3, data, taskID);
            costIncrease = costAftTaskID-costPreTaskID;
            
            if R(taskID,s)<=R(taskID,schxij2(taskID))
                RcostCoeff(s)=-inf;
            elseif costIncrease<=0
                RcostCoeff(s)=1000+abs((R(taskID,s)/R(taskID,schxij2(taskID)))/costIncrease);
            else
                RcostCoeff(s)=(R(taskID,s)/R(taskID,schxij2(taskID)))/costIncrease;
            end
        else
            RcostCoeff(s) = -inf;
        end
    end
    [RcostCoeffvalue,newindexS]=max(RcostCoeff());
    serverMigrationFrom = schxij2(taskID);
    serverMigrationTo = newindexS;
    matrix(taskID,:) = [taskID, serverMigrationFrom, serverMigrationTo, RcostCoeffvalue];
    
    tempid=data.pre(taskID,:)>0;
    id1=data.pre(taskID,tempid);
    if ~isempty(id1)
        for k=1:length(id1)
            taskiD=id1(k);
            RcostCoeff=-1./zeros(1,info.m);
            for s=1:info.m
                if ~eq(schxij2(taskiD),s)
                    costold=costsum(schxij2,info,data);
                    schxij3=schxij2;
                    schxij3(taskiD)=s;
                    
                    costPreTaskID = costTaskID(schxij2, data, taskiD);
                    costAftTaskID = costTaskID(schxij3, data, taskiD);
                    costIncrease = costAftTaskID-costPreTaskID;
                    
                    
                    if R(taskiD,s)<=R(taskiD,schxij2(taskiD))
                        RcostCoeff(s)=-inf;
                    elseif costIncrease<=0
                        RcostCoeff(s)=1000+abs((R(taskiD,s)/R(taskiD,schxij2(taskiD)))/costIncrease);
                    else
                        RcostCoeff(s)=(R(taskiD,s)/R(taskiD,schxij2(taskiD)))/costIncrease;
                    end
                end
            end
            [RcostCoeffvalue,newindexS]=max(RcostCoeff());
            serverMigrationFrom = schxij2(taskiD);
            serverMigrationTo = newindexS;
            matrix(taskiD,:) = [taskiD, serverMigrationFrom, serverMigrationTo, RcostCoeffvalue];
            
        end
        
    end
    tempid2=data.aft(taskID,:)>0;
    id2=data.aft(taskID,tempid2);
    if ~isempty(id2)
        for k=1:length(id2)
            taskID2=id2(k);
            RcostCoeff=-1./zeros(1,info.m);
            for s=1:info.m
                if ~eq(schxij2(taskID2),s)
                    costold=costsum(schxij2,info,data);
                    schxij3=schxij2;
                    schxij3(taskID2)=s;
                    costnew=costsum(schxij3,info,data);
                    costIncrease = costnew-costold;
                    if R(taskID2,s)<=R(taskID2,schxij2(taskID2))
                        RcostCoeff(s)=-inf;
                    elseif costIncrease<=0
                        RcostCoeff(s)=1000+abs((R(taskID2,s)/R(taskID2,schxij2(taskID2)))/costIncrease);
                    else
                        RcostCoeff(s)=(R(taskID2,s)/R(taskID2,schxij2(taskID2)))/costIncrease;
                    end
                end
            end
            [RcostCoeffvalue,newindexS]=max(RcostCoeff());
            serverMigrationFrom = schxij2(taskID2);
            serverMigrationTo = newindexS;
            matrix(taskID2,:) = [taskID2, serverMigrationFrom, serverMigrationTo, RcostCoeffvalue];
            
        end
        
    end   
end

if data.RgoalG<=RmaxG
    sch1.xij=schxij2;
    sch1.costG=costsum(schxij2,info,data);
    sch1.R=prod(Rset);
    
    
    %%
    sch1.mkTtemp = zeros(1,info.m);
    sch1.st = zeros(1, info.n);
    sch1.et = zeros(1,info.n);
    
    
    for i=1:info.n
        taskID=info.rank(i);
        temp= data.pre(taskID,:)>0;
        curpre=data.pre(taskID,temp);
        if ~isempty(curpre)
            abst=zeros(1,length(curpre));
            for j=1:length(curpre)
                abst(j)=sch1.st(curpre(j))+sch1.et(curpre(j));
                if sch1.xij(curpre(j))~=sch1.xij(taskID)
                    abst(j)=abst(j)+data.c(curpre(j),taskID);
                end
            end
            abstmax=max(abst);
            sch1.st(taskID)=max(sch1.mkTtemp(sch1.xij(taskID)),abstmax);
            sch1.et(taskID)=data.w(taskID,sch1.xij(taskID));
            sch1.mkTtemp(sch1.xij(taskID))=sch1.st(taskID)+sch1.et(taskID);
        else
            sch1.st(taskID)=0;
            sch1.et(taskID)=data.w(taskID,sch1.xij(taskID));
            sch1.mkTtemp(sch1.xij(taskID))=sch1.st(taskID)+sch1.et(taskID);
        end
    end
end





