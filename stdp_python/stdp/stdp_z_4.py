import numpy as np

from Parameter import *


class STDPModel:
    def __init__(self, num_neurons_pre, num_neurons_post, learning_rate, time_window, weight_file):
        self.num_neurons_pre = num_neurons_pre
        self.num_neurons_post = num_neurons_post
        self.learning_rate = learning_rate
        self.time_window = time_window
        self.weights = self.load_weights(weight_file)
        self.delta_weights = np.zeros((num_neurons_pre, num_neurons_post))  # 初始化delta_weights
        print("Initial Weights:")
        print(self.weights)
        self.time = 0

    def load_weights(self, weight_file):
        try:
            
            return np.loadtxt(weight_file)
        except IOError:
            
            raise FileNotFoundError(f"Weight file not found: {weight_file}")

    def calculate_weight_change(self, pre_spike, post_spike, pre_time, post_time):
        weight_change = np.zeros((self.num_neurons_pre, self.num_neurons_post))

        last_pre_neuron = None
        last_post_neuron = None

        for pre_neuron in range(self.num_neurons_pre):
            for post_neuron in range(self.num_neurons_post):
                if pre_neuron == last_pre_neuron and post_neuron == last_post_neuron:
                    continue
                last_pre_neuron = pre_neuron
                last_post_neuron = post_neuron

                if pre_time[pre_neuron] <= post_time[post_neuron]:
                    if pre_spike[pre_neuron] != 0 and post_spike[post_neuron] != 0: 
                        delta_t = post_time[post_neuron] - pre_time[pre_neuron]
                        if delta_t <= time_window:
                            weight_change[num_neurons_pre-pre_neuron-1, num_neurons_post-post_neuron-1] = 1

                            print(f"Pre-time: {pre_time[pre_neuron]}, Post-time: {post_time[post_neuron]},weight 1")
                        
                elif pre_time[pre_neuron] > post_time[post_neuron]:
                    if pre_spike[pre_neuron] != 0 and post_spike[post_neuron] != 0:
                        delta_t = pre_time[pre_neuron] - post_time[post_neuron]
                        if delta_t <= time_window:
                            weight_change[num_neurons_pre-pre_neuron-1, num_neurons_post-post_neuron-1] = -1

                            print(f"Pre-time: {pre_time[pre_neuron]}, Post-time: {post_time[post_neuron]},weight -1")
                        
        return weight_change


    def update_weights(self, pre_spike, post_spike, pre_time, post_time):
        weight_change = self.calculate_weight_change(pre_spike, post_spike, pre_time, post_time)
        self.weights += weight_change
        self.delta_weights += weight_change

    def spike(self, neuron, time):
        self.last_spikes[neuron] = time

    def run_simulation(self, pre_spikes, post_spikes, pre_times, post_times):
        num_inputs = len(pre_spikes)
        num_outputs = len(post_spikes)

        last_pre_spike = [None for _ in range(self.num_neurons_pre)]
        last_post_spike = [None for _ in range(self.num_neurons_post)]

        for i in range(num_inputs):
            pre_spike = pre_spikes[i]
            pre_time = pre_times[i]
            for j in range(num_outputs):
                post_spike = post_spikes[j]
                post_time = post_times[j]

                # 检查当前脉冲是否与上一次的脉冲相同，如果是，则忽略
                if pre_spike == last_pre_spike and post_spike == last_post_spike:
                    continue

                # 更新上一次的脉冲记录
                last_pre_spike = pre_spike
                last_post_spike = post_spike

                # 如果脉冲不同，则更新权重
                self.update_weights(pre_spike, post_spike, pre_time, post_time)


    def print_weights(self):
        print("Synap Weights:")
        print(self.weights)

    def load_data_from_file(self, filename):
        data = []
        with open(filename, 'r') as file:
            for line in file:
                line = line.strip()
                if line:
                    data.append(list(line))
        return data


    def save_weights(self, filename):
        np.savetxt(filename, self.weights, fmt='%.6f')

    def save_delta_weights(self, filename):
        np.savetxt(filename, self.delta_weights, fmt='%.6f')



if __name__ == "__main__":
    

    weight_file = '../Parameter/weights.txt'

    stdp_model = STDPModel(num_neurons_pre, num_neurons_post, learning_rate, time_window, weight_file)

    
    input_spike_data = stdp_model.load_data_from_file('../Parameter/input_spike.txt')
    pre_spikes = []
    for row in input_spike_data:
        spikes = [int(val) for val in row]
        pre_spikes.append(spikes)


    
    output_spike_data = stdp_model.load_data_from_file('../Parameter/output_spike.txt')
    post_spikes = []
    for row in output_spike_data:
        spikes = [int(val) for val in row]
        post_spikes.append(spikes)

    
    pre_times = []
    post_times = []

    for i, pre_spike_row in enumerate(pre_spikes):
        pre_time_row = []
        for pre_spike_val in pre_spike_row:
            if pre_spike_val == 1:
                pre_time_row.append(i*2 + 1)  
            else:
                pre_time_row.append(0)
        pre_times.append(pre_time_row)


    for i, post_spike_row in enumerate(post_spikes):
        post_time_row = []
        for post_spike_val in post_spike_row:
            if post_spike_val == 1:
                post_time_row.append(i*2 + 2)  
            else:
                post_time_row.append(0)
        post_times.append(post_time_row)
    

    stdp_model.run_simulation(pre_spikes, post_spikes, pre_times, post_times)
    stdp_model.print_weights()

    delta_weights_file = '../Parameter/delta_weights_py.txt'
    stdp_model.save_delta_weights(delta_weights_file)

    final_weights_file = '../Parameter/final_weights_py.txt'
    stdp_model.save_weights(final_weights_file)

