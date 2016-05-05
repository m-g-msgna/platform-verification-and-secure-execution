% [state_sequence] = viterbi_sequence(initial_probability,
%                                     transition_probability,
%                                     emission_probability)
% initial_probability = initial probability (\pi_{i})
% transition_probability = transition probatility (T)
% emission_probability = emission probability (E)
% state_sequence = most probable state sequence that would have resulted to the emission of (O) 
% Author: Mehari G. Msgna
% Date: 16 April, 2013

function [state_sequence] = viterbi_sequence(initial_probability, transition_probability, emission_probability)
    number_of_states = length(initial_probability(1,:));
    number_of_observations = length(emission_probability(1,:));
    state_sequence = zeros(1,number_of_observations);
    sequence_probability = zeros(number_of_observations, number_of_states);
    
    for c = 1:number_of_states
        sequence_probability(1,c) = emission_probability(c,1) * initial_probability(1,c);
    end
    for r = 2:number_of_observations
        temp = zeros(1,number_of_states);
        for c = 1:number_of_states
            for c1 = 1:number_of_states
                temp(1,c1) = transition_probability(c1,c) * sequence_probability(r-1,c1);            
            end
            mx = max(temp(1,:));
            sequence_probability(r,c) = emission_probability(c,r) * mx;
        end
    end
    for j = 1:number_of_observations
        [value, index] = max(sequence_probability(j,:));
        state_sequence(1,j) = index;
    end
end