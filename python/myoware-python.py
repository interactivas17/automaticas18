import argparse
import random
import numpy as np

from pythonosc import osc_message_builder
from pythonosc import udp_client

import serial, time, queue

# set OSC client
parser = argparse.ArgumentParser()
parser.add_argument("--ip", default="127.0.0.1", help="The ip of the OSC server")
parser.add_argument("--port", type=int, default=5005, help="The port the OSC server is listening on")
args = parser.parse_args()

client = udp_client.SimpleUDPClient(args.ip, args.port)

# ## WARNING:
# Be careful when using readline(). Do specify a timeout when opening the serial port otherwise it could block forever if no newline character is received. Also note that readlines() only works with a timeout. readlines() depends on having a timeout and interprets that as EOF (end of file). It raises an exception if the port is not opened correctly.

# set port and baudrate
#portname = "/dev/tty.usbmodemFA131"
portname = "/dev/tty.HC-05-DevB"
brate = 9600

class Datos():
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
def serial_data(port, baudrate):
    ser = serial.Serial(port, baudrate, timeout=5)

    while True:
        yield ser.readline()

    ser.close()

# initialize queues for each sensor and set the epoch size
epoch_size = 2
q1 = queue.Queue(maxsize=epoch_size)
q2 = queue.Queue(maxsize=epoch_size)
q3 = queue.Queue(maxsize=epoch_size)
queue_list = [q1,q2,q3]


for line in serial_data(portname, brate):
    # the epoch corresponding to each sensor will be stored separately in a list called channels
    channels = []
    outmsg = []
    # parse the serial data
    val = line.strip()
    values = val.decode('ascii')
    values = values.split(',')
    # store the serial data in an array
    array = [float(s) for s in values if s]
    # exclude arrays if the information of some sensor is missing
    if len(array) < len(queue_list):
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
                print("El epoch es: {}".format(epoch))
                print("La suma del epoch del sensor {} es: {}".format(i, suma))
                # print("Los canales son:{}".format(channels))
                # send the epoch of each sensor on a different osc channel
                # TODO - hacer un bundle o algo asi, ver como enviar los tres epochs juntos
                client.send_message("/sensor{}".format(i), suma) 
                q.queue.clear()
                q.put(array[i])            
            else:
                q.put(array[i])
            i+=1
             
    print("El valor del los sensores es: {}".format(array))
    # print("La cola esta llena:{}".format(q.full()))    
    time.sleep(0.001)

