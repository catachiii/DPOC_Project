function [] = LCG_plot_map(map)
    [m, n] = size(map);
    hold on
    color = {'w', '#77AC30', '#D95319', '#7E2F8E', '#4DBEEE', 'y'};
    for i = 1:m
        for j = 1:n
            plot(i,j,'--gs',...
            'LineWidth',1,...
            'MarkerSize',20,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor',color{map(i,j) + 1})
        end
    end
    axis equal
end