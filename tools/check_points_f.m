function [ x, y, z ] = check_points_f(x, y, z, numframes)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
p = 1;
while p <= numframes      
    
      
 % Define anchor point
    d = x(p,18);
    e = y(p,18);
    f = z(p,18);
    
    x(p,:) = x(p,:)-d;
    y(p,:) = y(p,:)-e;
    z(p,:) = z(p,:)-f;
    
    w = 1;
    warray=[];
    while w <= 103
        if isnan(x(p,w))
            if ismember([w],warray) == 0
                warray = horzcat(warray, [w]);
            end
        end 
        w = w + 1;
    end
        
    if isnan(x(p,85))
        x(p,85) = 0;
        y(p,85) = (y(p,55) + y(p,70))/2 + 4 ;
        z(p,85) = (z(p,55) + z(p,70))/2; 
    end
    
    if isnan(x(p,82))
        x(p,82) = 21;
        y(p,82) = 79;
        z(p,82) = -50;
    end
    
    if isnan(x(p,88))
        x(p,88) = 90;
        y(p,88) = -50;
        z(p,88) = -30;
    end
    
    
    if isnan(x(p,83))
        x(p,83) = (x(p,82) + x(p,85))/2;
        y(p,83) = (y(p,82) + y(p,85))/2;
        z(p,83) = (z(p,82) + z(p,85))/2;
    end
    
    if isnan(x(p,87))
        x(p,87) = (x(p,88) + x(p,85))/2;
        y(p,87) = (y(p,88) + y(p,85))/2;
        z(p,87) = (z(p,88) + z(p,85))/2;
    end
    
    if isnan(x(p,71))
        x(p,71) = (x(p,70) + x(p,100))/2;
        y(p,71) = (y(p,70) + y(p,100))/2;
        z(p,71) = (z(p,70) + z(p,100))/2;
    end
    
    % select neighbor points for missing data recovery
    sensors = [82 89 90 91 92 93 88];
    xx = x(p,sensors); xx(find(isnan(xx))) = [];
    yy = y(p,sensors); yy(find(isnan(yy))) = [];
    zz = z(p,sensors); zz(find(isnan(zz))) = [];
    
    polynomialy = polyfit(xx,yy,2);
    polynomialz = polyfit(xx,zz,2);
    
    
    % if sensor m89 is occasionally missing
    if isnan(x(p,89))
            x(p,89) = x(p,82) - 6;
            y(p,89) = y(p,82) + 6;
            z(p,89) = z(p,82);
    end
    
    %update approximation function
    xx = x(p,sensors); xx(find(isnan(xx))) = [];
    yy = y(p,sensors); yy(find(isnan(yy))) = [];
    zz = z(p,sensors); zz(find(isnan(zz))) = [];
    
    polynomialy = polyfit(xx,yy,2);
    polynomialz = polyfit(xx,zz,2);
    
    % if sensor m90 is occasionally missing
    if isnan(x(p,90))
        %if the value is missing from the beginning
            x(p,90) = x(p,84) - 1;
            y(p,90) = polyval(polynomialy,x(p,90));
            z(p,90) = polyval(polynomialz,x(p,90));
    end
    
%     if isnan(x(p,94))
%         x(p,94) = 2*x(p,59) - x(p,64);
%         y(p,94) = 2*y(p,59) - y(p,64);
%         z(p,94) = 2*z(p,59) - z(p,64);
%     end

    
    sensors2 = [66 65 63 60 94 95 96 98 99 100 75 78 80 81];
    xx = x(p,sensors2); xx(find(isnan(xx))) = [];
    yy = y(p,sensors2); yy(find(isnan(yy))) = [];
    zz = z(p,sensors2); zz(find(isnan(zz))) = [];
    
    polynomialy2 = polyfit(xx,yy,2);
    polynomialz2 = polyfit(xx,zz,2);

    if isnan(x(p,94))
        x(p,94) = (x(p,37)+x(p,38))/2;
        y(p,94) = polyval(polynomialy2,x(p,94));
        z(p,94) = polyval(polynomialz2,x(p,94));
    end
    

            

    if isnan(x(p,92))
        x(p,92) = 2*x(p,85) - x(p,90);
        y(p,92) = polyval(polynomialy,x(p,92));
        z(p,92) = polyval(polynomialz,x(p,92));
    end
    
    % if sensor m91 is missing or unstable
    if isnan(x(p,91))
        x(p,91) = x(p,85);
        y(p,91) = polyval(polynomialy,x(p,91));
        z(p,91) = polyval(polynomialz,x(p,91));
    end
    
    if isnan(x(p,93))
        x(p,93) = 2*x(p,85) - x(p,89);
        y(p,93) = y(p,89);
        z(p,93) = z(p,89);
    end
    
    if isnan(x(p,86))
        x(p,86) = 2*x(p,85) - x(p,84);
        y(p,86) = y(p,84);
        z(p,86) = z(p,84);
    end
    
    
    sensors2 = [66 65 63 60 94 95 96 98 99 100 75 78 80 81];
    xx = x(p,sensors2); xx(find(isnan(xx))) = [];
    yy = y(p,sensors2); yy(find(isnan(yy))) = [];
    zz = z(p,sensors2); zz(find(isnan(zz))) = [];
    
    polynomialy2 = polyfit(xx,yy,2);
    polynomialz2 = polyfit(xx,zz,2);

    if isnan(x(p,65))
       x(p,65) = 2*x(p,35)-x(p,25);
       y(p,65) = 2*y(p,35)-y(p,25);
       z(p,65) = z(p,80);
    end    
    
    if isnan(x(p,65))
        x(p,65) = x(p,24);
        y(p,65) = polyval(polynomialy,x(p,65));
        z(p,65) = polyval(polynomialz,x(p,65));
    end
        

    if isnan(x(p,66))
       x(p,66) = (x(p,65)+x(p,34))/2;
       y(p,66) = (y(p,65)+y(p,34))/2;
       z(p,66) = z(p,81);
    end   
        

    if isnan(x(p,66))
       x(p,66) = 2*x(p,24) - x(p,14);
       y(p,66) = 2*y(p,24) - y(p,14);
       z(p,66) = z(p,81);
    end    

    
    if isnan(x(p,95))
        x(p,95) = x(p,53);
        y(p,95) = polyval(polynomialy2,x(p,95));
        z(p,95) = polyval(polynomialz2,x(p,95));
    end

    
    if isnan(x(p,60)) 
        x(p,60) = (x(p,61)+x(p,57))/2;
        y(p,60) = polyval(polynomialy2,x(p,60));
        z(p,60) = polyval(polynomialz2,x(p,60));
    end   


    
    if isnan(x(p,64))
        x(p,64) = (x(p,66)+x(p,61))/2;
        y(p,64) = (y(p,66)+y(p,61))/2;
        z(p,64) = (z(p,66)+z(p,61))/2;
    end
    

    
     if isnan(x(p,94))
         x(p,94) = (x(p,37) + x(p,38))/2;
         y(p,94) = polyval(polynomialy2,x(p,94));
         z(p,94) = polyval(polynomialz2,x(p,94));
     end    
     
     if isnan(x(p,27))
         x(p,27) = (x(p,8) + x(p,38))/2;
         y(p,27) = (y(p,8) + y(p,38))/2;
         z(p,27) = (z(p,8) + z(p,38))/2;
     end  
     
     if isnan(x(p,24))
         x(p,24) = (x(p,14)+x(p,66))/2;
         y(p,24) = (y(p,14)+y(p,66))/2;
         z(p,24) = (z(p,14)+z(p,66))/2;
     end
     
     if isnan(x(p,39))
        x(p,39) = (x(p,9) + x(p,54))/2;
        y(p,39) = (y(p,9) + y(p,54))/2;
        z(p,39) = (z(p,9) + z(p,54))/2;
     end
     
     if isnan(x(p,39))
         x(p,39)=(x(p,16)+x(p,50))/2;
         y(p,39)=(y(p,16)+y(p,50))/2;
         z(p,39)=z(p,42);
     end
     
      if isnan(x(p,62))
        x(p,62) = (x(p,94) + x(p,64))/2;
        y(p,62) = (y(p,94) + y(p,64))/2;
        z(p,62) = (z(p,94) + z(p,64))/2;
      end
     
     if isnan(x(p,55))
        x(p,55) = (x(p,95) + x(p,57))/2;
        y(p,55) = (y(p,95) + y(p,57))/2;
        z(p,55) = (z(p,95) + z(p,57))/2;
     end
    
     if isnan(x(p,56))
        x(p,56) = (x(p,55) + x(p,94))/2;
        y(p,56) = (y(p,55) + y(p,94))/2;
        z(p,56) = (z(p,55) + z(p,94))/2;
     end
     
     if isnan(x(p,54))
        x(p,54) = (x(p,55) + x(p,53))/2;
        y(p,54) = (y(p,55) + y(p,53))/2;
        z(p,54) = (z(p,55) + z(p,53))/2;
     end
     
     if isnan(x(p,34))
        x(p,34) = (x(p,65) + x(p,1))/2;
        y(p,34) = (y(p,65) + y(p,1))/2;
        z(p,34) = (z(p,65) + z(p,1))/2;
     end
     
     if isnan(x(p,40))
        x(p,40) = (x(p,48) + x(p,11))/2;
        y(p,40) = (y(p,48) + y(p,11))/2;
        z(p,40) = (z(p,48) + z(p,11))/2;
     end
     
    if isnan(x(p,63))
        x(p,63) = x(p,35);
        y(p,63) = polyval(polynomialy2,x(p,63));
        z(p,63) = polyval(polynomialz2,x(p,63));
     end
     
     if isnan(x(p,25))
        x(p,25) = (x(p,34) + x(p,16))/2;
        y(p,25) = (y(p,34) + y(p,16))/2;
        z(p,25) = (z(p,34) + z(p,16))/2;
     end
     
     if isnan(x(p,29))
        x(p,29) = (x(p,41) + x(p,19))/2;
        y(p,29) = (y(p,41) + y(p,19))/2;
        z(p,29) = (z(p,41) + z(p,19))/2;
     end
     
     if isnan(x(p,97))
        x(p,97) = (x(p,95) + x(p,99))/2;
        y(p,97) = (y(p,95) + y(p,99))/2;
        if y(p,97) <= y(p,91)
            y(p,97) = y(p,91) + 2;
        end
        z(p,97) = (z(p,95) + z(p,99))/2;
     end
  
     if isnan(x(p,28))
        x(p,28) = (x(p,40) + x(p,17))/2;
        y(p,28) = (y(p,40) + y(p,17))/2;
        z(p,28) = (z(p,40) + z(p,17))/2;
     end
     
     if isnan(x(p,81))
        x(p,81) = 2*x(p,80) - x(p,78);
        y(p,81) = 2*y(p,80) - y(p,78);
        z(p,81) = 2*z(p,80) - z(p,78);
     end
     
     if isnan(x(p,41))
        x(p,41) = (x(p,48) + x(p,12))/2;
        y(p,41) = (y(p,48) + y(p,12))/2;
        z(p,41) = (z(p,48) + z(p,12))/2;
     end
     
     if isnan(x(p,36))
        x(p,36) = (x(p,35) + x(p,37))/2;
        y(p,36) = (y(p,35) + y(p,37))/2;
        z(p,36) = (z(p,35) + z(p,37))/2;
     end
     
     if isnan(x(p,13))
        x(p,13) = 2*x(p,14) - x(p,15);
        y(p,13) = 2*y(p,14) - y(p,15);
        z(p,13) = 2*z(p,14) - z(p,15);
     end

     if isnan(x(p,30))
        x(p,30) = (x(p,42) + x(p,6))/2;
        y(p,30) = (y(p,42) + y(p,6))/2;
        z(p,30) = z(p,27);
     end
     
    if isnan(x(p,80))
        x(p,80) = 2*x(p,79) - x(p,46);
        y(p,80) = 2*y(p,79) - y(p,46);
        z(p,80) = 2*z(p,79) - z(p,46);
    end 
    
     if isnan(x(p,55))
        x(p,55) = (x(p,54) + x(p,56))/2;
        y(p,55) = (y(p,54) + y(p,56))/2;
        z(p,55) = (z(p,54) + z(p,56))/2;
     end
    
     
     if isnan(x(p,80))
        x(p,80) = (x(p,81) + x(p,78))/2;
        y(p,80) = (y(p,81) + y(p,78))/2;
        z(p,80) = (z(p,81) + z(p,78))/2;
     end
     
     if isnan(x(p,98))
        x(p,98) = 2*x(p,71) - x(p,78);
        y(p,98) = polyval(polynomialy2,x(p,98));
        z(p,98) = polyval(polynomialz2,x(p,98));
    end    
    
    if isnan(x(p,96))
        x(p,96) = -x(p,98);
        y(p,96) = polyval(polynomialy2,x(p,96));
        z(p,96) = polyval(polynomialz2,x(p,96));
    end    
    
    if isnan(x(p,99))
        x(p,99) = (x(p,98) + x(p,100))/2;
        y(p,99) = polyval(polynomialy2,x(p,99));
        z(p,99) = polyval(polynomialz2,x(p,99));
    end
    
    if isnan(x(p,29))
        x(p,29) = (x(p,19) + x(p,41))/2;
        y(p,29) = (y(p,19) + y(p,41))/2;
        z(p,29) = (z(p,19) + z(p,41))/2;
    end
    
     if isnan(x(p,28))
        x(p,28) = (x(p,17) + x(p,40))/2;
        y(p,28) = (y(p,17) + y(p,40))/2;
        z(p,28) = (z(p,17) + z(p,40))/2;
     end
     

     
     if isnan(x(p,26))
        x(p,26) = (x(p,8) + x(p,36))/2;
        y(p,26) = (y(p,8) + y(p,36))/2;
        z(p,26) = (z(p,8) + z(p,36))/2;
     end
     
     
     if isnan(x(p,1))
        x(p,1) = 2*x(p,2) - x(p,3);
        y(p,1) = 2*y(p,2) - y(p,3);
        z(p,1) = z(p,7);
     end
     
     if isnan(x(p,59))
        x(p,59) = (x(p,60) + x(p,58))/2;
        y(p,59) = (y(p,60) + y(p,58))/2;
        z(p,59) = (z(p,60) + z(p,58))/2;
     end
     
     if isnan(x(p,58))
        x(p,58) = (x(p,57) + x(p,59))/2;
        y(p,58) = (y(p,57) + y(p,59))/2;
        z(p,58) = (z(p,57) + z(p,59))/2;
     end
     
     if isnan(x(p,75))
        x(p,75) = (x(p,100) + x(p,78))/2;
        y(p,75) = polyval(polynomialy2,x(p,75));
        z(p,75) = polyval(polynomialz2,x(p,75));
     end
     
      if isnan(x(p,69))
        x(p,69) = (x(p,68) + x(p,70))/2;
        y(p,69) = (y(p,68) + y(p,70))/2;
        z(p,69) = (z(p,68) + z(p,70))/2;
      end
      
      if isnan(x(p,42))
        x(p,42) = (x(p,41) + x(p,43))/2;
        y(p,42) = (y(p,41) + y(p,43))/2;
        z(p,42) = (z(p,41) + z(p,43))/2;
      end
   
      if isnan(x(p,25))
        x(p,25) = (x(p,24) + x(p,26))/2;
        y(p,25) = (y(p,24) + y(p,26))/2;
        z(p,25) = (z(p,24) + z(p,26))/2;
      end
      
      if isnan(x(p,34))
        x(p,34) = (x(p,1) + x(p,65))/2;
        y(p,34) = (y(p,1) + y(p,65))/2;
        z(p,34) = (z(p,1) + z(p,65))/2;
      end
   

    % increment p
    p = p+1;
    disp(warray)
end

end
