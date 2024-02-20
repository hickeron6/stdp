from Parameter import num_neurons_pre, num_neurons_post
import numpy as np

matrix = np.zeros((num_neurons_pre, num_neurons_post))


with open('weight_delta.txt', 'r') as file:
    for line in file:
        
        
        delta, row, column = map(int, line.strip().split(','))
       
        matrix[row, column] += delta


print(matrix)


np.savetxt('updated_weightD.txt', matrix, fmt='%.6f')

