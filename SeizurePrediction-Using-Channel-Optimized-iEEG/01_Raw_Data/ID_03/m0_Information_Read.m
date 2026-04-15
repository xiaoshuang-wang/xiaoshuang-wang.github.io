clc
clear
close all
tic

%%
load('ID03_info.mat');
FileSelect(:,1) = ceil(seizure_begin/3600);
FileSelect(:,2) = ceil(seizure_end/3600);

SeizureStartEnd = FileSelect;
SeizureStartEnd(:,3) = seizure_begin-(FileSelect(:,1)-1)*3600;
SeizureStartEnd(:,4) = seizure_end-(FileSelect(:,2)-1)*3600;
SeizureStartEnd(:,5) = seizure_end-seizure_begin;
clear FileSelect

%%
toc