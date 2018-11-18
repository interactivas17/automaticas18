import argparse
import numpy as np

from pythonosc import osc_message_builder
from pythonosc import udp_client

import time, queue
from bitalino import BITalino

class Datos:
    # numpy array de dos dimensiones: cada fila representa los datos de un sensor
    # el primer elemento de cada fila será el valor directo del sensor
    def __init__(self, s, f):
        # self data contendrá el numpy
        self.s = s # numero de sensores
        self.num_features = f # numero de datos (features) por sensor
        self.data = np.zeros([s,f])

    def update(self,sensor,index,value):
        # funcion para actualizar 
        # input - dos indices para indicar donde se escribe el dato (sensor,data_index)  + dato
        self.data[sensor,index] = value
    def get_data(self,sensor,index):
        return self.data[sensor,index]
    def get_all_data(self):
        return self.data

# define a generator to read the serial data
def serial_data(macadd, batthr, samp_rate, acqCh, num_s ):
    # Connect to BITalino
    device = BITalino(macadd)
    # Set battery threshold
    device.battery(batthr)
    # Start Acquisition
    device.start(samp_rate, acqCh)

    while True:
        yield device.read(num_s)

    # Stop acquisition
    device.stop()        
    # Close connection
    device.close()

# set MAC address
macAddress = "/dev/tty.bitalino-DevB"
    
batteryThreshold = 30
acqChannels = [4]
num_sen = len(acqChannels)
samplingRate = 100
nSamples = 1

# initialize queues for each sensor and set the epoch size
epoch_size = 10
queue_list = []
for s in range(num_sen):
    queue_list.append(queue.Queue(maxsize=epoch_size))

# numero de datos que se van a extraer de cada sensor
num_features = 5
# inicializar los datos que se enviaran al midi
midi_data = Datos(num_sen, num_features)

# set OSC client
parser = argparse.ArgumentParser()
parser.add_argument("--ip", default="127.0.0.1", help="The ip of the OSC server")
parser.add_argument("--port", type=int, default=5005, help="The port the OSC server is listening on")
args = parser.parse_args()

client = udp_client.SimpleUDPClient(args.ip, args.port)

for line in serial_data(macAddress, batteryThreshold, samplingRate, acqChannels, nSamples):
    # the epoch corresponding to each sensor will be stored separately in a list called channels
    channels = []
    sensor_values = line[:,-num_sen:]

    # exclude arrays if the information of some sensor is missing
    if len(sensor_values) < len(queue_list):
        continue
    else:
        # initialize a counter to iterate over the sensors
        i = 0
        for q in queue_list:   
            if q.full():
                epoch = list(q.queue)
                channels.append(epoch)
                # process epoch
                suma = sum(epoch)
                # print("El epoch es: {}".format(epoch))
                # print("La suma del epoch del sensor {} es: {}".format(i, suma))
                # print("Los canales son:{}".format(channels))
                # send the epoch of each sensor on a different osc channel
                client.send_message("/sensor{}".format(i), suma) 
                # TODO - hacer un bundle o algo asi, ver como enviar los tres epochs juntos
                q.queue.clear()
                q.put(sensor_values[i])
                midi_data.update(i,0,sensor_values[i])
                midi_data.update(i,1,suma)
                # TODO - check sensor value format to correctly pile them in a new np.array
            else:
                q.put(sensor_values[i])
                midi_data.update(i,0,sensor_values[i])   
            i+=1
             
    print("El valor de los sensores es: {}".format(sensor_values))
    print(midi_data.get_all_data())
    # print("La cola esta llena:{}".format(q.full()))    
    time.sleep(0.001)