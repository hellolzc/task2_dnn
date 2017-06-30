function  gen_video_f2(docname)
%gen_eideo_f  view effect of recovery by producing a video
%   2017/6/26
lib_path = './tools';
addpath(lib_path);
%warning off;

%docname = 'S0011_0020';
docname2 = strcat('test_output/', docname,'_out');
docname1 = strcat('data/', docname);%output_csv/

viewangle = 0;%30

fpsfactor = 4;
% Fetch data from CSV file
numericData = csvread([docname1,'.csv']);

[ x, y, z, numframes, ~] = reshape_row(numericData, fpsfactor);
[ x, y, z ] = check_points_f(x, y, z, numframes);
[ x, y, z ] = rotate_points_f( x, y ,z ,numframes);

% Fetch data from CSV out file
numericData2 = csvread([docname1,'.csv']);
[ x2, y2, z2, numframes, ~] = reshape_row(numericData2, fpsfactor);
%[ x2, y2, z2 ] = rotate_points_f(x2, y2, z2 ,numframes);

prepare_video_compare( docname, viewangle, x, y, z, numframes, x2, y2, z2);
rmpath(lib_path);

end

function [ x, y, z, numframes, numsensors] = reshape_row(numericData, fpsfactor)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
A = numericData(10:fpsfactor:end,2:end);
numframes = size(A,1);
numsensors = size(A,2)/3;

i = 1:1:numsensors;
k = 1:1:numframes;

j = 1:3:size(A,2); x(k,i) = A(k,j);
j = 2:3:size(A,2); y(k,i) = A(k,j);
j = 3:3:size(A,2); z(k,i) = A(k,j);

end
