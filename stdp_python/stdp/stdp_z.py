import numpy as np

class STDPModel:
    def __init__(self, num_neurons, learning_rate, time_window):
        self.num_neurons = num_neurons
        self.learning_rate = learning_rate
        self.time_window = time_window
        self.weights = np.random.rand(num_neurons, num_neurons)  # 初始化随机权重
        print(self.weights)
        self.last_spikes = np.zeros(num_neurons)
        self.time = 0

    def calculate_weight_change(self, pre_spike, post_spike):
        delta_t = post_spike - pre_spike
        if delta_t > 0:
            weight_change = self.learning_rate * np.exp(-delta_t / self.time_window)
        else:
            weight_change = -self.learning_rate * np.exp(delta_t / self.time_window)
        
        return weight_change

    def update_weights(self, pre_neuron, post_neuron):
        weight_change = self.calculate_weight_change(self.last_spikes[pre_neuron], self.last_spikes[post_neuron])
        print("self.last_spikes[pre_neuron]:",self.last_spikes[pre_neuron])
        print("self.last_spikes[post_neuron]:",self.last_spikes[post_neuron])
        self.weights[pre_neuron, post_neuron] += weight_change
        

    def spike(self, neuron):
        self.last_spikes[neuron] = self.time
        print("last_spikes:",self.last_spikes)
        self.time += 1

    def run_simulation(self, num_iterations):
        for _ in range(num_iterations):
            #pre_neuron = np.random.randint(self.num_neurons)
            #print(pre_neuron)
            #post_neuron = np.random.randint(self.num_neurons)
            #print(post_neuron)
            pre_neuron = 2
            post_neuron = 1
            self.spike(pre_neuron)                              #self.last_spikes[pre_neuron] = self.time =0
            self.spike(post_neuron)                             #self.last_spikes[post_neuron] = self.time =1
                                                                # last_spikes = [0. 0. 1.]
            self.update_weights(pre_neuron, post_neuron)

    def print_weights(self):
        print("Synaptic Weights:")
        print(self.weights)
        

if __name__ == "__main__":
    num_neurons = 3
    learning_rate = 0.01
    time_window = 10

    stdp_model = STDPModel(num_neurons, learning_rate, time_window)
    num_iterations = 1

    stdp_model.run_simulation(num_iterations)
    stdp_model.print_weights()
