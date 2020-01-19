function costactual = costsum(schxij,info,data)

costactual = 0;
for i=1:info.n
    taskID=info.rank(i);
    costactual = costactual + data.w(taskID,schxij(taskID))*data.gama(schxij(taskID));
    tempid = data.pre(taskID,:)>0;
    id = data.pre(taskID,tempid);
    if ~isempty(id)
        for k = 1:length(id)
            serverPreTask = schxij(id(k));
            if serverPreTask ~= schxij(taskID)
                costactual = costactual + data.rcomn(1)*data.c(id(k), taskID);
            end
        end
    end
end

