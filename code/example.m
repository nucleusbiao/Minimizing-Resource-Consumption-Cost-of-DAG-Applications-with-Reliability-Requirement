% Author: Biao Hu
% 2020-01-19

clear
clc
close all

numProcessor=3;
data=setupDataExample(numProcessor);
info.n = size(data.w,1); % task count
info.m = numProcessor; % processor count
info.rank=rankqueue(data,info); % upward rank value
data.RgoalG=0.95;
sch=schedulstart(data,info);
gantt(sch,info)