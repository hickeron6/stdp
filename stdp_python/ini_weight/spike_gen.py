from Parameter import *
import numpy as np

def generate_spikes(pre_neuron, pre_time_length, post_neuron, post_time_length):
    input_spike = np.random.randint(2, size=(pre_time_length, pre_neuron))
    output_spike = np.random.randint(2, size=(post_time_length, post_neuron))
    return input_spike, output_spike


input_spike, output_spike = generate_spikes(pre_neuron, pre_time_length, post_neuron, post_time_length)


with open('../Parameter/input_spike.txt', 'w') as input_file:
    for row in input_spike:
        input_file.write(''.join(map(str, row)) + '\n')


with open('../Parameter/output_spike.txt', 'w') as output_file:
    for row in output_spike:
        output_file.write(''.join(map(str, row)) + '\n')

print("Spike files generated and saved.")

