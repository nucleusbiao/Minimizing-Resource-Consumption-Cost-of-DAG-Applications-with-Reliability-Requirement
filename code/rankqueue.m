function  indexS = rankqueue(data,info)
DAG_Matrix = zeros(info.n, info.n);
for iRow = 1:size(data.aft, 1)
    for iColumn = 1:size(data.aft, 2)
        if ~eq(data.aft(iRow, iColumn), 0)
            DAG_Matrix(iRow, data.aft(iRow, iColumn)) = 100;
        end
    end
end
rank=zeros(1,info.n);
for i=info.n:-1:1
    w=0;
    for j=1:info.m
        w=w+data.w(i,j)*data.gama(j);
    end
    if i==info.n
        rank(i)=w/info.m;
    else 
        temp=0;
        for k=1:info.n
             if data.c(i,k)~=0 
                 temp=max(temp,rank(k)+data.c(i,k));%后继任务中的最大rank值
             end
        end
        rank(i)=w/info.m+temp;
    end
end
[rank, indexS]=sort(rank,'descend');


