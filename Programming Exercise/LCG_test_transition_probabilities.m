function [] = LCG_test_transition_probabilities(stateSpace, map, P)

plot_mode = 0; % 0: interest points to base; 1:interest points to test point

global FREE TREE SHOOTER PICK_UP DROP_OFF BASE

[Base_m, Base_n] = find(map == BASE);
base_index_0 = find(ismember(stateSpace,[Base_m, Base_n, 0], 'rows'));
base_index_1 = find(ismember(stateSpace,[Base_m, Base_n, 1], 'rows'));

[Pickup_m, Pickup_n] = find(map == PICK_UP);
pickup_index_0 = find(ismember(stateSpace,[Pickup_m, Pickup_n, 0], 'rows'));
pickup_index_1 = find(ismember(stateSpace,[Pickup_m, Pickup_n, 1], 'rows'));

[Dropoff_m, Dropoff_n] = find(map == DROP_OFF);
dropoff_index_0 = find(ismember(stateSpace,[Dropoff_m, Dropoff_n, 0], 'rows'));
dropoff_index_1 = find(ismember(stateSpace,[Dropoff_m, Dropoff_n, 1], 'rows'));

[Shooter_m, Shooter_n] = find(map == SHOOTER);
for ind = 1:length(Shooter_m)
    shooter_index_0(ind) = find(ismember(stateSpace,[Shooter_m(ind), Shooter_n(ind), 0], 'rows'));
    shooter_index_1(ind) = find(ismember(stateSpace,[Shooter_m(ind), Shooter_n(ind), 1], 'rows'));
end

[m, n] = size(map);
corner_index_0(1) = find(ismember(stateSpace,[1, 1, 0], 'rows'));
corner_index_0(2) = find(ismember(stateSpace,[m, 1, 0], 'rows'));
corner_index_0(3) = find(ismember(stateSpace,[m, n, 0], 'rows'));
corner_index_0(4) = find(ismember(stateSpace,[1, n, 0], 'rows'));

[Free_m, Free_n] = find(map == FREE);
rand_ind = floor(rand(1,3)* length(Free_m));
Free_m = Free_m(rand_ind);
Free_n = Free_n(rand_ind);
for ind = 1:length(Shooter_m)
    free_index_0(ind) = find(ismember(stateSpace,[Free_m(ind), Free_n(ind), 0], 'rows'));
    free_index_1(ind) = find(ismember(stateSpace,[Free_m(ind), Free_n(ind), 1], 'rows'));
end

for u = 1:5
    figure(u);
    LCG_plot_map(map);
end

test_state = [base_index_0, pickup_index_0, dropoff_index_0, shooter_index_0, corner_index_0, free_index_0];
test_state_name = ["Base", "Pickup", "Dropoff", repmat(["Shooter"],1,length(shooter_index_0)), repmat(["Corner"],1,length(corner_index_0)), repmat(["Free"],1,length(free_index_0))];
for ind = 1:length(test_state)
    state_index_0 = test_state(ind);
    fprintf("---------------------------------%s--------------------------------------------\n", test_state_name(ind));
    test_state_co = stateSpace(state_index_0, :);
    test_m = test_state_co(1);
    test_n = test_state_co(2);
    test_point = [test_m, test_n];
    aoi = LCG_generate_area_of_interest(test_point, stateSpace);
    for each = 1:size(aoi, 1)
        interest_point = aoi(each, :);
        interest_point_index_0 = find(ismember(stateSpace,[interest_point(1), interest_point(2), 0], 'rows'));
        if plot_mode == 1
            for u = 1:5
                figure(u);
                hold on
                test_prob = P(interest_point_index_0, state_index_0, u);
                fprintf("Transition Probability from position [%d, %d] to position [%d, %d] applying %d is %f\n", interest_point, test_point, u, test_prob);
                plot(interest_point(1), interest_point(2), '.', 'MarkerSize',20);
                plot([interest_point(1) test_point(1)], [interest_point(2) test_point(2)], '-');
                text(interest_point(1), interest_point(2),num2str(test_prob));
            end
        else
            for u = 1:5
                figure(u);
                hold on
                test_prob = P(interest_point_index_0, base_index_0, u);
                fprintf("Transition Probability from position [%d, %d] to position [%d, %d] applying %d is %f\n", interest_point, Base_m, Base_n, u, test_prob);
                plot(interest_point(1), interest_point(2), '.', 'MarkerSize',20);
                plot([interest_point(1) Base_m], [interest_point(2) Base_n], '-');
                text(interest_point(1), interest_point(2),num2str(test_prob));  
            end
        end
    end
end




end