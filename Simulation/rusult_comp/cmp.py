def read_matrix_from_file(filename):
  
    with open(filename, 'r') as file:
        return [[float(num) for num in line.split()] for line in file]

def calculate_exact_similarity(matrix1, matrix2):
   
    same_count = 0
    total_count = 0

    
    if len(matrix1) != len(matrix2) or any(len(row1) != len(row2) for row1, row2 in zip(matrix1, matrix2)):
        print("erro with diff matrix size")
        return 0

    for row1, row2 in zip(matrix1, matrix2):
        for num1, num2 in zip(row1, row2):
            if num1 == num2:
                same_count += 1
            total_count += 1

    
    similarity = same_count / total_count if total_count > 0 else 0
    return similarity


matrix1 = read_matrix_from_file('../../stdp_python/Parameter/delta_weights_py.txt')
matrix2 = read_matrix_from_file('../../stdp_vhdl/stdp/updated_weightD.txt')


similarity = calculate_exact_similarity(matrix1, matrix2)
print(f"same rate: {similarity * 100:.8f}%")

