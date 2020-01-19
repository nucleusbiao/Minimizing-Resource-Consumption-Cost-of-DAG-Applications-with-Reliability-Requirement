function data = setupDataExample(numProessor)
level=4;
preAftTaskMax=6;
taskLevelArray = [0 1; 1 5; 6 3; 9 1];
numTask = taskLevelArray(end,1) + 1;
DAG_Matrix = zeros(numTask, numTask) ;

% Task communication overhead
DAG_Matrix(1,2) = 18;
DAG_Matrix(1,3) = 12;
DAG_Matrix(1,4) = 9;
DAG_Matrix(1,5) = 11;
DAG_Matrix(1,6) =14;
DAG_Matrix(2,8) = 19;
DAG_Matrix(2,9) = 16;
DAG_Matrix(3,7) = 23;
DAG_Matrix(4,8) = 27;
DAG_Matrix(4,9) = 23;
DAG_Matrix(5,9) = 13;
DAG_Matrix(6,8) = 15;
DAG_Matrix(7,10) = 17;
DAG_Matrix(8,10) = 11;
DAG_Matrix(9,10) = 13;


aftArray = zeros(numTask,preAftTaskMax); % successors
preArray = zeros(numTask,preAftTaskMax); % predecessors
for i = 1:size(DAG_Matrix, 1)
    count = 1;
    for j = 1:size(DAG_Matrix, 1)
        if DAG_Matrix(i,j) > 0
            aftArray(i,count) = j;
            count = count + 1;
        end
    end
end

for i = 1:size(DAG_Matrix, 2)
    count = 1;
    for j = 1:size(DAG_Matrix, 1)
        if DAG_Matrix(j,i) > 0
            preArray(i,count) = j;
            count = count + 1;
        end
    end
end

% Execution cost on different processors
W=zeros(numTask,numProessor); 
W(1,:)=[14,16,9];
W(2,:)=[13,19,18];
W(3,:)=[11,13,19];
W(4,:)=[13,8,17];
W(5,:)=[12,13,10];
W(6,:)=[13,16,9];
W(7,:)=[7,15,11];
W(8,:)=[5,11,14];
W(9,:)=[18,12,20];
W(10,:)=[21,7,16];

data.pre = preArray;
data.aft = aftArray;
data.w=W;
data.c=DAG_Matrix;
data.lambda=[0.0005,0.0002,0.0009];
data.gama=[5,9,2];
 data.rcomn(1)=1;

for i=1:level
    data.level(i,:)=[taskLevelArray(i,1)+1 taskLevelArray(i,1)+taskLevelArray(i,2)];
end
end





