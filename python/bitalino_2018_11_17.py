import argparse
import mido
import numpy as np
import serial
#import neurokit as nk
#import pandas as pd
#import seaborn as sns

#from pythonosc import osc_message_builder
from pythonosc import udp_client

import time, queue, csv, random
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

# Traduce los valores a un rango

def translate(value, leftMin, leftMax, rightMin, rightMax):
    # Figure out how 'wide' each range is
    leftSpan = leftMax - leftMin
    rightSpan = rightMax - rightMin

    if(value > leftMax) :
        return rightMax

    if(value < leftMin) :
        return rightMin


    # Convert the left range into a 0-1 range (float)
    valueScaled = float(value - leftMin) / float(leftSpan)

    # Convert the 0-1 range into a value in the right range.
    return rightMin + (valueScaled * rightSpan)


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
#macAddress = "98:d3:31:30:54:ca"

batteryThreshold = 30
acqChannels = [1,2,3]
sensor_names = ['EMG','ACC','ECG']
num_sen = len(acqChannels)
samplingRate = 100
nSamples = 1

# initialize queues for each sensor and set the epoch size
epoch_size = 100
queue_list = []
for s in range(num_sen):
    queue_list.append(queue.Queue(maxsize=epoch_size))





#MIDI PART

# Matriz de escalas
# primera matriz: pentatónica menor C
# segunda matriz: mayor natural C
# tercera matriz: menor dorica C
#cuarta matriz: escala hexatona C
scales = [[0,3,5,7,10,12,15,17,19,22,24,27,29,31,34,36,39,41,43,46,48,51,53,55,58,60,63,65,67,70,72,75,77,79,82,84,87,89,91,94,96,99,101,103,106,108,111,113,115,118,120,123,125,127]
,[0,2,4,5,7,9,11,12,14,16,17,19,21,23,24,26,28,29,31,33,35,36,38,40,41,43,45,47,48,50,52,53,55,57,59,60,62,64,65,67,69,71,72,74,76,77,79,81,83,84,86,88,89,91,93,95,96,98,100,101,103,105,107,108,110,112,113,115,117,119,120,122,124,125,127]
,[0,2,3,5,7,9,10,12,14,15,17,19,21,22,24,26,27,29,31,33,34,36,38,39,41,43,45,46,48,50,51,53,55,57,58,60,62,63,65,67,69,70,72,74,75,77,79,81,82,84,86,87,89,91,93,94,96,98,99,101,103,105,106,108,110,111,113,115,117,118,120,122,123,125,127]
,[0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126]]


# numero de datos que se van a extraer de cada sensor
num_features = 5
# inicializar los datos que se enviaran al midi
midi_data = Datos(num_sen, num_features)
#inicialazing midi functions
tap = mido.Message('note_on', channel=15, note=0, velocity=90) #Nota reservada para el tap tempo (C-2 canal 16)
tap_off = mido.Message('note_off', channel=15, note=0)

print("\nTEST MIDI\n\nEntradas:"+str(mido.get_input_names())+"\n\nSalidas:"+str(mido.get_output_names()))

# Setup


midiIN = mido.open_input('midiBus IAC Bus 1')
midiOUT_1 = mido.open_output('midiBus IAC Bus 1')
midiOUT_2 = mido.open_output('midiBus IAC Bus 2')
midiOUT_3 = mido.open_output('midiBus IAC Bus 3')



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
# parser.add_argument("--ip", default="192.168.1.104", help="The ip of the OSC server")
# parser.add_argument("--port", type=int, default=12000, help="The port the OSC server is listening on")
parser.add_argument("--ip", default="127.0.0.1", help="The ip of the OSC server")
parser.add_argument("--port", type=int, default=5005, help="The port the OSC server is listening on")
args = parser.parse_args()

client = udp_client.SimpleUDPClient(args.ip, args.port)

for line in serial_data(macAddress, batteryThreshold, samplingRate, acqChannels, nSamples):
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
                epoch = np.array(q.queue)
                # process epoch
                suma = sum(epoch)
                q.queue.clear()
                q.put(sensor_values[i])
                midi_data.update(i,0,sensor_values[i])
                midi_data.update(i,1,suma)
            else:
                q.put(sensor_values[i])
                midi_data.update(i,0,sensor_values[i])
            i+=1
    # convert the sensor values to a string to send them as an OSC message
    sensor_value_str = str(sensor_values)
    sensor_value_OSCmsg = sensor_value_str.strip('[]')
    client.send_message("/sensores", sensor_value_OSCmsg)

    mappedValue1 = int( translate(sensor_values[0],260,290,0,125))
    mappedValue2 = int( translate(sensor_values[1],0,1020,0,125))
    mappedValue3 = int( translate(sensor_values[2],7,25,0,125))


    print(mappedValue1,mappedValue2,mappedValue3)

    msg1 = mido.Message('control_change', channel=0, control=0, value=mappedValue1)
    msg2 = mido.Message('control_change', channel=0, control=0, value=mappedValue2)
    msg3 = mido.Message('control_change', channel=0, control=0, value=mappedValue3)


    midiOUT_1.send(msg1)
    midiOUT_2.send(msg2)
    midiOUT_3.send(msg3)

    print("El valor de los sensores es: {}".format(sensor_values))
    #print(midi_data.get_all_data())
    # time.sleep(0.001)
