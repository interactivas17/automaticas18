import argparse
import numpy as np
import neurokit as nk
import pandas as pd
import seaborn as sns

from pythonosc import osc_message_builder
from pythonosc import udp_client

import time, queue, csv
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
sensor_names = ['EMG']
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

# All the data will be saved in a CVS file
filename = 'bitalino_{}_data_session_{}.csv'.format(sensor_names[0],time.strftime("%Y_%m_%d-%H_%M"))
# IMPORTANT!: set this value to False if you don't want to record the session data, set to True otherwise
save_data = False
if save_data:
    with open(filename, 'a') as f:
        writer = csv.writer(f)
        writer.writerow(sensor_names)

# set OSC client
parser = argparse.ArgumentParser()
parser.add_argument("--ip", default="192.168.1.104", help="The ip of the OSC server")
parser.add_argument("--port", type=int, default=12000, help="The port the OSC server is listening on")
# parser.add_argument("--ip", default="192.168.1.104", help="The ip of the OSC server")
# parser.add_argument("--port", type=int, default=12000, help="The port the OSC server is listening on")
args = parser.parse_args()

client = udp_client.SimpleUDPClient(args.ip, args.port)

for line in serial_data(macAddress, batteryThreshold, samplingRate, acqChannels, nSamples):
    # the epoch corresponding to each sensor will be stored separately in a list called channels
    channels = []
    # extract the sensor raw value from the data that comes out of Bitalino
    sensor_values = line[:,-num_sen:]
    sensor_values = sensor_values[0]

    # exclude arrays if the information of some sensor is missing
    if len(sensor_values) < len(queue_list):
        continue
    else:
        if save_data:
            # write sensor values to a CVS file
            with open(filename, 'a') as f:
                writer = csv.writer(f)
                writer.writerow(sensor_values)
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
    # convert the sensor values to a string to send them as an OSC message
    sensor_value_str = str(sensor_values)
    sensor_value_OSCmsg = sensor_value_str.strip('[]')
    client.send_message("/sensores", sensor_value_OSCmsg)
    print("El valor de los sensores es: {}".format(sensor_values))
    print(midi_data.get_all_data())
    # print("La cola esta llena:{}".format(q.full()))    
    # time.sleep(0.001)