
function prepare_video_compare( video_name, viewangle, x, y, z, numframes, x2, y2, z2)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
% Prepare video
fig1 = figure(1);
set(fig1,'Color',[1 1 1]);
set(fig1,'Position',[0 0 880 644])
set(fig1,'NextPlot','replacechildren') 

vid = VideoWriter([video_name,'_',num2str(viewangle),'.avi']);
vid.Quality = 100;
vid.FrameRate = 25;
open(vid);

% Plot points into video frames
for i = 1:numframes
    plot3(x(i,:),z(i,:),-y(i,:),'g+',x2(i,:),z2(i,:),-y2(i,:),'r.');
    %plot3(x(i,:),z(i,:),-y(i,:));
    view([viewangle+180 0]);
    xlim([-125,125]);
    ylim([-175,75]);
    zlim([-150,100]);
    axis square;
    %axis off;
    writeVideo(vid, getframe(gca,[92 13 500 500]));
end

close(vid);
%winopen([docname,'_',num2str(viewangle),'.avi']);
beep

end

