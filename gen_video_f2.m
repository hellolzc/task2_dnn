function  gen_video_f2(uuid)
%gen_eideo_f  view effect of recovery by producing a video
%   2017/6/26
lib_path = './tools';
addpath(lib_path);
%warning off;

%uuid = 'S0011_0020';
docname1 = strcat('data/output_csv/', uuid,'_rotated');%output_csv/
docname2 = strcat('test_output/', uuid,'_out');

viewangle = 0;%30

fpsfactor = 4;
% Fetch data from CSV file
numericData = csvread([docname1,'.csv']);

[ x, y, z, numframes, ~] = reshape_row(numericData, fpsfactor);
[ x, y, z ] = check_points_f(x, y, z, numframes);

% Fetch data from CSV out file
numericData2 = csvread([docname2,'.csv']);
[ x2, y2, z2, numframes, ~] = reshape_row(numericData2, fpsfactor);
[ x2, y2, z2 ] = check_points_f(x2, y2, z2, numframes);

%output_temp_docname = strcat('/tmp/',uuid)
output_name = '/dev/shm/temp';
prepare_video_compare( output_name, viewangle, x, y, z, numframes, x2, y2, z2);%uuid
rmpath(lib_path);

%cmd = strcat('ffmpeg -i /tmp/temp_0.avi',' -i ../NewDataArranged/aligened_netural/output_wav/', ...
 %            uuid,'_mono.wav -c:v copy -c:a copy -map 0:v:0 -map 1:a:0 ',uuid,'_0_output.avi');
%disp(cmd)
%unix(cmd)
end

function [ x, y, z, numframes, numsensors] = reshape_row(numericData, fpsfactor)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
A = numericData(1:fpsfactor:end,2:end);%10
numframes = size(A,1);
numsensors = size(A,2)/3;

i = 1:1:numsensors;
k = 1:1:numframes;

j = 1:3:size(A,2); x(k,i) = A(k,j);
j = 2:3:size(A,2); y(k,i) = A(k,j);
j = 3:3:size(A,2); z(k,i) = A(k,j);

end
