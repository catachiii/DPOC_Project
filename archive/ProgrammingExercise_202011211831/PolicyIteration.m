function [ J_opt, u_opt_ind ] = PolicyIteration(P, G)
%POLICYITERATION Policy iteration
%   Solve a stochastic shortest path problem by Policy Iteration.
%
%   [J_opt, u_opt_ind] = PolicyIteration(P, G) computes the optimal cost and
%   the optimal control input for each state of the state space.
%
%   Input arguments:
%       P:
%           A (k x k x L)-matrix containing the transition probabilities
%           between all states in the state space for all control inputs.
%           The entry P(i, j, l) represents the transition probability
%           from state i to state j if control input l is applied.
%
%       G:
%           A (k x L)-matrix containing the stage costs of all states in
%           the state space for all control inputs. The entry G(i, l)
%           represents the cost if we are in state i and apply control
%           input l.
%
%   Output arguments:
%       J_opt:
%       	A (k x 1)-matrix containing the optimal cost-to-go for each
%       	element of the state space.
%
%       u_opt_ind:
%       	A (k x 1)-matrix containing the index of the optimal control
%       	input for each element of the state space. Mapping of the
%       	terminal state is arbitrary (for example: HOVER).

global K HOVER

%% Handle terminal state
% Do yo need to do something with the teminal state before starting policy
% iteration?
global TERMINAL_STATE_INDEX
% IMPORTANT: You can use the global variable TERMINAL_STATE_INDEX computed
% in the ComputeTerminalStateIndex.m file (see main.m)

%% Policy Iteration
iter_num = 1000;

% Initialize a proper policy
policy = zeros(K,1); 

for i = 1:K
    policy(i) = find(~isinf(G(i,:)), 1);
end

iter = 0;
J_now = zeros(K,1);

while iter <= iter_num
    iter = iter + 1;
    
    % Stage 1 Policy Evaluation
    J_now = zeros(K,1);
    P_now = zeros(K,K);
    G_now = zeros(K,1);
    
    for i = 1:K
        for j = 1:K
            P_now(i,j) = P(i,j,policy(i));
        end
        G_now(i) = G(i,policy(i));
    end
    
    J_cor = inv(eye(K)-P_now)*G_now; % singular??
    
    
    % Check if converged
    if J_cor == J_now
        continue
    else
        J_now = J_cor;
    end
    
    
    % Stage 2 Policy Improvement
    for i = 1:K
        
        summation = zeros(1,5);
        for j = 1:K
            for u = 1:5
                summation(u) = summation(u) + P(i,j,u) * J_cor(j); 
            end
        end
        
        [~, policy(i)] = min(G(i,:)+summation);
    end

end

J_opt = J_now;
u_opt_ind = policy;


