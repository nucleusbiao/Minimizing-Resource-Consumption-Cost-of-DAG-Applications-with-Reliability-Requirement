function costactual = costTaskID(schxij, data, taskID)

costactual = 0;

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

tempid = data.aft(taskID,:)>0;
id = data.aft(taskID,tempid);
if ~isempty(id)
    for k = 1:length(id)
        serverAftTask = schxij(id(k));
        if serverAftTask ~= schxij(taskID)
            costactual = costactual + data.rcomn(1)*data.c(taskID, id(k));
        end
    end
end


