import numpy as np

class STDPModel:
    def __init__(self, num_neurons_pre, num_neurons_post, learning_rate, time_window):
        self.num_neurons_pre = num_neurons_pre
        self.num_neurons_post = num_neurons_post
        self.learning_rate = learning_rate
        self.time_window = time_window
        self.weights = np.random.rand(num_neurons_pre, num_neurons_post)  
        print("Initial Weights:")
        print(self.weights)
        self.time = 0

    def calculate_weight_change(self, pre_spike, post_spike, pre_time, post_time):
        weight_change = np.zeros((self.num_neurons_pre, self.num_neurons_post))

        for pre_neuron in range(self.num_neurons_pre):
            for post_neuron in range(self.num_neurons_post):
                if pre_time[pre_neuron] <= post_time[post_neuron]:
                  if (pre_spike[pre_neuron] != 0 and post_spike[post_neuron] != 0): 
                    delta_t = post_time[post_neuron] - pre_time[pre_neuron]
                    weight_change[pre_neuron, post_neuron] = 1
                elif pre_time[pre_neuron] >= post_time[post_neuron]:
                  if (pre_spike[pre_neuron] != 0 and post_spike[post_neuron] != 0):
                    delta_t = post_time[post_neuron] - pre_time[pre_neuron]
                    weight_change[pre_neuron, post_neuron] = -1
        return weight_change

    def update_weights(self, pre_spike, post_spike, pre_time, post_time):
        weight_change = self.calculate_weight_change(pre_spike, post_spike, pre_time, post_time)
        self.weights += weight_change

    def spike(self, neuron, time):
        self.last_spikes[neuron] = time

    def run_simulation(self, pre_spikes, post_spikes, pre_times, post_times):
        num_inputs = len(pre_spikes)
        num_outputs = len(post_spikes)

        for i in range(num_inputs):
            pre_spike = pre_spikes[i]
            pre_time = pre_times[i]
            for j in range(num_inputs):
                post_spike = post_spikes[j]
                post_time = post_times[j]
                self.update_weights(pre_spike, post_spike, pre_time, post_time)

    def print_weights(self):
        print("Synap Weights:")
        print(self.weights)

if __name__ == "__main__":
    num_neurons_pre = 4
    num_neurons_post = 2
    learning_rate = 0.01
    time_window = 10

    stdp_model = STDPModel(num_neurons_pre, num_neurons_post, learning_rate, time_window)

    # 从外部文件读取输入数据
    with open('input.txt', 'r') as file:
        lines = file.readlines()
    
    pre_spikes = []
    post_spikes = []
    pre_times = []
    post_times = []
    
    for line in lines:
        data = line.strip().split(',')
        pre_spikes.append([int(x) for x in data[0].split()])
        post_spikes.append([int(x) for x in data[1].split()])
        pre_times.append([int(x) for x in data[2].split()])
        post_times.append([int(x) for x in data[3].split()])

    stdp_model.run_simulation(pre_spikes, post_spikes, pre_times, post_times)
    stdp_model.print_weights()
