function stateIndex = ComputeTerminalStateIndex(stateSpace, map)
%ComputeTerminalStateIndex Compute the index of the terminal state in the
%stateSpace matrix
%
%   stateIndex = ComputeTerminalStateIndex(stateSpace, map) 
%   Computes the index of the terminal state in the stateSpace matrix
%   Input arguments:
%       stateSpace:
%           A (K x 3)-matrix, where the i-th row represents the i-th
%           element of the state space.
%
%       map:
%           A (M x N)-matrix describing the terrain of the estate map. With
%           values: FREE TREE SHOOTER PICK_UP DROP_OFF BASE
%
%   Output arguments:
%       stateIndex:
%           An integer that is the index of the terminal state in the
%           stateSpace matrix

global DROP_OFF

% Find the location of deliver staion.
[Dropoff_m, Dropoff_n] = find(map == DROP_OFF); 

% Find the state where the drone is at the deliver station and is carring a
% package [Dropoff_m, Dropoff_n, 1]. Using ismember to find the true or
% false value of the terminate state.
Dropoff_id = ismember(stateSpace,[Dropoff_m, Dropoff_n, 1], 'rows');

% Find the index of the terminate state.
stateIndex = find(Dropoff_id == 1);
                  
end
