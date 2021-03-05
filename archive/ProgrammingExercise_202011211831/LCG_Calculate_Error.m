%% Calculuating Error

P_1 = eval("load('example_P.mat')");
error_P = zeros(K,K,5);
count_P = 0;
Threshold_P = 0.00000001;
diff_P = 0;

for i = 1:476
    for j = 1:476
        for u = 1:5
            error_P(i,j,u) = abs(P(i,j,u)-P_1.P(i,j,u)) <= Threshold_P;
            % error_P(i,j,u) = isequal(P(i,j,u), P_1.P(i,j,u));
            diff_P = diff_P + abs(P(i,j,u)-P_1.P(i,j,u));
            if error_P(i,j,u) == 0
                count_P = count_P + 1;
                fprintf('Count_P: %f, From state: %f, To state: %f, input: %f, P_self = %f, P_example = %f \n',count_P,i,j,u, P(i,j,u), P_1.P(i,j,u));
            end
        end
    end
end

G_1 = eval("load('example_G.mat')");
error_G = zeros(K,5);
count_G = 0;
Threshold_G = 0.00000001;
Upperbound_G = 100000;
diff_G = 0;

for i = 1:476
    for u = 1:5
        error_G(i,u) = (abs(G(i,u)-G_1.G(i,u)) <= Threshold_G)|((G(i,u)==Inf)&(G_1.G(i,u)==Inf));
        % error_G(i,u) = isequal(G(i,u), G_1.G(i,u))|((G(i,u)==Inf)&(G_1.G(i,u)==Inf));
        
        if G_1.G(i,u) < Upperbound_G
            diff_G = diff_G + abs(G(i,u)-G_1.G(i,u));
        end
        
        if error_G(i,u) == 0
            count_G = count_G + 1;
            fprintf('Count_G: %f, From state: %f, input: %f, G_self = %f, G_example = %f \n',count_G,i,u, G(i,u), G_1.G(i,u));
        end
    end
end


% There is numerical error.
% When we evaluate isequal(G(476,5),G_1.G(476,5)), the anwser is 0.
% But G(476,5) = G_1.G(476,5) = 1.450000000000000.
% So you will see that the error_G is 1 instead of 0.