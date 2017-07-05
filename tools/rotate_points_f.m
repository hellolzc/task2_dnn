function [ x, y, z ] = rotate_points_f( x, y ,z ,numframes)
%ROTATE_POINTS_F 此处显示有关此函数的摘要
%   此处显示详细说明
p = 1;
while p <= numframes      
    
      
 % Define anchor point
    d = x(p,48);%18
    e = y(p,48);
    f = z(p,48);
    
    x(p,:) = x(p,:)-d;
    y(p,:) = y(p,:)-e;
    z(p,:) = z(p,:)-f;
    
    

    
    % p1, p2
%     p1x = x(p,8);
%     p1y = y(p,8);
%     p1z = z(p,8);
%     
%     p2x = x(p,10);
%     p2y = y(p,10);
%     p2z = z(p,10);

    %Define anchor point2
    d2 = x(p,18);%(p1x+p2x)/2;%48
    e2 = y(p,18);%(p1y+p2y)/2;%
    f2 = z(p,18);%(p1z+p2z)/2;%
    
    
    % calculate angers
    %alpha = atan(d2/abs(f2));
    %beta = atan(sqrt(d2^2+f2^2)/abs(e2));
    gamma = atan(-f2/(-e2));
    delta = atan(d2/sqrt(e2^2+f2^2));
    RotatedM = R_x(pi/12)*R_z(-delta)*R_x(-gamma)*[x(p,:);y(p,:);z(p,:)];%R_x(pi/6)*R_x(-beta)*R_y(-alpha)*
    x(p,:) = RotatedM(1,:);
    y(p,:) = RotatedM(2,:);
    z(p,:) = RotatedM(3,:);
    % increment p
    p = p+1;
end

end

function Rx = R_x(alpha)
    Rx = [1 0 0 ; 0 cos(alpha) -sin(alpha) ;0 sin(alpha) cos(alpha)];
end

function Ry = R_y(alpha)
    Ry = [cos(alpha)  0  sin(alpha) ; 0 1 0 ;-sin(alpha) 0 cos(alpha)];
end

function Rz = R_z(alpha)
    Rz = [cos(alpha)  -sin(alpha)  0 ; sin(alpha) cos(alpha) 0 ;0 0 1];
end
