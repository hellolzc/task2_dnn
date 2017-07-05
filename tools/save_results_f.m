function  save_results_f(docname, x, y, z, numframes)
%gen_eideo_f  view effect of recovery by producing a video
%   2017/6/26

% Recover missing data
output = NaN(numframes,310);

for p = 1:numframes

    % update the row
    row = reshape([x(p,:);y(p,:);z(p,:)],1,[]);
    output(p,:) = [p row];
end

% Output data
dlmwrite([docname,'_rotated.csv'],output,'precision','%5f');

end
