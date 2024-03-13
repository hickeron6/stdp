from Parameter import *
import numpy as np

def generate_spikes(pre_neuron, pre_time_length, post_neuron, post_time_length):
    # Set the probability of generating 1 and the probability of generating 0
    p = [0.6, 0.4]  
    input_spike = np.random.choice([0, 1], size=(pre_time_length, pre_neuron), p=p)
    output_spike = np.random.choice([0, 1], size=(post_time_length, post_neuron), p=p)
    return input_spike, output_spike

input_spike, output_spike = generate_spikes(pre_neuron, pre_time_length, post_neuron, post_time_length)

with open('../Parameter/input_spike.txt', 'w') as input_file:
    for row in input_spike:
        input_file.write(''.join(map(str, row)) + '\n')

with open('../Parameter/output_spike.txt', 'w') as output_file:
    for row in output_spike:
        output_file.write(''.join(map(str, row)) + '\n')

print("Spike files generated and saved.")

