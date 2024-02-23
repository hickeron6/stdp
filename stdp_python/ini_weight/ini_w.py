import numpy as np

from Parameter import *

def generate_weight_file(pre_neuron, post_neuron, scale_factor, filename):
    weights = np.random.rand(pre_neuron, post_neuron) * scale_factor
    print("Generated Weights:")
    print(weights)
    np.savetxt(filename, weights, fmt='%.6f')


filename = "../Parameter/weights.txt"

generate_weight_file(pre_neuron, post_neuron, scale_factor, filename)

