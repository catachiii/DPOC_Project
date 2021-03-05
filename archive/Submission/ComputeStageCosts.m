function G = ComputeStageCosts(stateSpace, map)
%COMPUTESTAGECOSTS Compute stage costs.
% 	Compute the stage costs for all states in the state space for all
%   control inputs.
%
%   G = ComputeStageCosts(stateSpace, map) 
%   computes the stage costs for all states in the state space for all
%   control inputs.
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
%       G:
%           A (K x L)-matrix containing the stage costs of all states in
%           the state space for all control inputs. The entry G(i, l)
%           represents the expected stage cost if we are in state i and 
%           apply control input l.

global GAMMA R P_WIND Nc
global FREE TREE SHOOTER PICK_UP DROP_OFF BASE
global NORTH SOUTH EAST WEST HOVER
global K
global TERMINAL_STATE_INDEX

% Initialize G
G = zeros(K,5);
[m, n] = size(map);

% Increment w.r.t. different inputs
Increment = [0,  1;  % NORTH
             0, -1;  % SOUTH
             1,  0;  % EAST
            -1,  0;  % WEST
             0,  0]; % HOVER
         
[Shooter_m, Shooter_n] = find(map == SHOOTER);
Shooter_number = length(Shooter_m);

for From_state = 1:K
    for Control_input = [NORTH, SOUTH, EAST, WEST, HOVER]
        % Without doing anything, is the From_state already Terminate?
        if From_state == TERMINAL_STATE_INDEX
            G(From_state, Control_input) = 0;
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
        
        if Allowability == 0 % If not allowable input. 
            G(From_state, Control_input) = inf;
            continue
        end
        
        % If the input is allowable
        
        % 2. Gust
        for If_gust = [0,1] 
            if If_gust == 0 % If gust doesn't occur.  
                Gustto_m = To_m;
                Gustto_n = To_n;
                Gustto_c = To_c;
                Nogust_prob = 1 - P_WIND;
                
                % 4. Angry residents
                % Calculate probability of getting shot down
                Shot_prob = 0;
                for i = 1:Shooter_number
                    d = abs(Gustto_m - Shooter_m(i)) + abs(Gustto_n - Shooter_n(i));
                    if d <= R
                        Shot_prob = Shot_prob + GAMMA / (1 + d);
                    end
                end

                for whether_shot = [0,1]
                    if whether_shot == 0 % not got shot
                        G(From_state, Control_input) = ...
                            G(From_state, Control_input) ...
                            + 1 * Nogust_prob * (1 - Shot_prob);

                    else % got shot
                        G(From_state, Control_input) = ...
                            G(From_state, Control_input) ...
                            + Nc * Nogust_prob * Shot_prob;
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
                        G(From_state, Control_input) = ...
                            G(From_state, Control_input) ...
                            + Nc * Gust_prob;
                        continue
                    end

                    % Not crashed after gust

                    % 4. Angry residents
                    % Calculate probability of getting shot down
                    Shot_prob = 0;
                    for i = 1:Shooter_number
                        d = abs(Gustto_m - Shooter_m(i)) + abs(Gustto_n - Shooter_n(i));
                        if d <= R
                            Shot_prob = Shot_prob + GAMMA / (1 + d);
                        end
                    end

                    for whether_shot = [0,1]
                        if whether_shot == 0 % not got shot
                            G(From_state, Control_input) = ...
                            G(From_state, Control_input) ...
                            + 1 * Gust_prob * (1 - Shot_prob);
                        else % got shot
                            G(From_state, Control_input) = ...
                            G(From_state, Control_input) ...
                            + Nc * Gust_prob * Shot_prob;
                        end
                    end
                end
            end
        end
    end  
end

