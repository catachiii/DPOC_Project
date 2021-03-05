function P = ComputeTransitionProbabilities(stateSpace, map)
%COMPUTETRANSITIONPROBABILITIES Compute transition probabilities.
% 	Compute the transition probabilities between all states in the state
%   space for all control inputs.
%
%   P = ComputeTransitionProbabilities(stateSpace, map) 
%   computes the transition probabilities between all states in the state 
%   space for all control inputs.
%
%   Input arguments:
%       stateSpace:
%           A (K x 3)-matrix, where the i-th row represents the i-th
%           element of the state space.
%
%       map:
%           A (M x N)-matrix describing the world. With
%           values: FREE TREE SHOOTER PICK_UP DROP_OFF BASE
%
%   Output arguments:
%       P:
%           A (K x K x L)-matrix containing the transition probabilities
%           between all states in the state space for all control inputs.
%           The entry P(i, j, l) represents the transition probability
%           from state i to state j if control input l is applied.

global GAMMA R P_WIND
global FREE TREE SHOOTER PICK_UP DROP_OFF BASE
global NORTH SOUTH EAST WEST HOVER
global K TERMINAL_STATE_INDEX

% Initialize P m n
P = zeros(K, K, 5);
[m, n] = size(map);

% Increment w.r.t. different inputs
Increment = [0,  1;  % NORTH
             0, -1;  % SOUTH
             1,  0;  % EAST
            -1,  0;  % WEST
             0,  0]; % HOVER
         
[Base_m, Base_n] = find(map == BASE);
Aftercrash_state = find(ismember(stateSpace,[Base_m, Base_n, 0], 'rows'));

[Pickup_m, Pickup_n] = find(map == PICK_UP);
Pickup_state = find(ismember(stateSpace,[Pickup_m, Pickup_n, 0], 'rows'));
Pickedup_state = find(ismember(stateSpace,[Pickup_m, Pickup_n, 1], 'rows'));

[Shooter_m, Shooter_n] = find(map == SHOOTER);
Shooter_number = length(Shooter_m);

for From_state = 1:K
    for Control_input = [NORTH, SOUTH, EAST, WEST, HOVER]
        % Without doing anything, is the From_state already Terminate?
        if From_state == TERMINAL_STATE_INDEX
            To_state = TERMINAL_STATE_INDEX;
            P(From_state, To_state, Control_input) = 1;
            continue
        end
        
        % Extract position and carrying state
        From_m = stateSpace(From_state,1);
        From_n = stateSpace(From_state,2);
        From_c = stateSpace(From_state,3);
        
        To_m = From_m + Increment(Control_input, 1);
        To_n = From_n + Increment(Control_input, 2);
        To_c = From_c;
        
        % 1. Allowable control input
        Allowability = (To_m >= 1) && (To_m <= m) && (To_n >= 1) &&(To_n <= n);
        if Allowability == 1
            Allowability = Allowability && (map(To_m, To_n) ~= TREE);
        end
        
        if Allowability == 0 % If not allowable input, then do nothing. 
            continue % P remains 0.
        end
        
        % if the input is allowable
        To_stateindex = ismember(stateSpace,[To_m, To_n, To_c],'rows');
        To_state = find(To_stateindex == 1);
        
        % 2. Gust
        for If_gust = [0,1] 
            if If_gust == 0 % If gust doesn't occur, Gustto_state = To_state.  
                Gustto_m = To_m;
                Gustto_n = To_n;
                Gustto_c = To_c;
                Gustto_state = To_state;
                Nogust_prob = 1 - P_WIND;
                
                % 4. Angry residents
                % Calculate probability of getting shot down
                Shot_prob = [];
                for i = 1:Shooter_number
                    d = abs(Gustto_m - Shooter_m(i)) + abs(Gustto_n - Shooter_n(i));
                    if d <= R
                        Shot_prob(i) = GAMMA / (1 + d);
                    else
                        Shot_prob(i) = 0;
                    end
                end
                Shot_prob = 1 - prod((ones(1, Shooter_number) - Shot_prob));

                for whether_shot = [0,1]
                    if whether_shot == 0 % not got shot
                        Shotto_state = Gustto_state;
                        P(From_state, Shotto_state, Control_input) = ...
                            Nogust_prob * (1 - Shot_prob);
                        
                        % 5. Whether to pick up?
                        if Shotto_state == Pickup_state
                            Prob = P(From_state, Shotto_state, Control_input);
                            P(From_state, Shotto_state, Control_input) = 0;
                            P(From_state, Pickedup_state, Control_input) = Prob;
                        end
                        
                    else % got shot
                        Shotto_state = Aftercrash_state;
                        P(From_state, Shotto_state, Control_input) = ...
                            P(From_state, Shotto_state, Control_input) + ...
                            Nogust_prob * Shot_prob;
                    end
                end


                
            else % Gust occurs.
                for Gust = [NORTH, SOUTH, EAST, WEST]  
                    Gustto_m = To_m + Increment(Gust, 1);
                    Gustto_n = To_n + Increment(Gust, 2);
                    Gustto_c = To_c;
                    Gust_prob = 0.25 * P_WIND;
                    
                    Notcrashed = (Gustto_m >= 1) && (Gustto_m <= m) && (Gustto_n >= 1) && (Gustto_n <= n);
                    if Notcrashed == 1
                        Notcrashed = Notcrashed && (map(Gustto_m, Gustto_n) ~= TREE);
                    end

                    if Notcrashed == 0 % 3. Crashed after gust
                        Gustto_state = Aftercrash_state;
                        P(From_state, Gustto_state, Control_input) = ...
                            P(From_state, Gustto_state, Control_input) + Gust_prob;
                        continue
                    end

                    % Not crashed after gust
                    Gustto_stateindex = ismember(stateSpace,[Gustto_m, Gustto_n, Gustto_c],'rows');
                    Gustto_state = find(Gustto_stateindex == 1);
                    
                    % 4. Angry residents
                    % Calculate probability of getting shot down
                    Shot_prob = [];
                    for i = 1:Shooter_number
                        d = abs(Gustto_m - Shooter_m(i)) + abs(Gustto_n - Shooter_n(i));
                        if d <= R
                            Shot_prob(i) = GAMMA / (1 + d);
                        else
                            Shot_prob(i) = 0;
                        end
                    end
                    Shot_prob = 1 - prod((ones(1, Shooter_number) - Shot_prob));

                    for whether_shot = [0,1]
                        if whether_shot == 0 % not got shot
                            Shotto_state = Gustto_state;
                            P(From_state, Shotto_state, Control_input) = ...
                                P(From_state, Shotto_state, Control_input) + Gust_prob * (1 - Shot_prob);
                            
                            % 5. Whether to pick up?
                            if Shotto_state == Pickup_state
                                Prob = P(From_state, Shotto_state, Control_input);
                                P(From_state, Shotto_state, Control_input) = 0;
                                P(From_state, Pickedup_state, Control_input) = Prob;
                            end
                            
                        else % got shot
                            Shotto_state = Aftercrash_state;
                            P(From_state, Shotto_state, Control_input) = ...
                                P(From_state, Shotto_state, Control_input) + Gust_prob * Shot_prob;
                        end
                    end
                end
            end
        end
    end  
end