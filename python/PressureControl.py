import mido
import time
import random
import numpy


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


# SENSORES
s = 8 # Numero de sensores
f = 8 # Numero de datos por sensor
midi_data = Datos(s,f)

# Sensor de presión
sp1 = 1 # ubicación de los sensores de presion en Datos
sp2 = 2
sp3 = 3
sp4 = 4
#PREGUNTAR VALOR MAXIMO
max_p = 1100 # por ejemplo

while True

    p1 = midi_data.get_data(sp1,0) # Valor del sensor de presion
    # FALTA REPARTIR VALORES EQUITATIVAMENTE
    cc_p1 = (p1/max_p)*127 #Escalado de valores
    cc_p1_msg = mido.Message('control_change', channel=0 ,control=0, value=cc_p1) # Canal 0 / CC 0
    midiOUT.send(cc_p1_msg)

    p2 = midi_data.get_data(sp2,0) # Valor del sensor de presion
    # FALTA REPARTIR VALORES EQUITATIVAMENTE
    cc_p2 = (p2/max_p)*127 #Escalado de valores
    cc_p2_msg = mido.Message('control_change', channel=0 ,control=1, value=cc_p2) # Canal 0 / CC 1
    midiOUT.send(cc_p2_msg)

    p3 = midi_data.get_data(sp3,0) # Valor del sensor de presion
    # FALTA REPARTIR VALORES EQUITATIVAMENTE
    cc_p3 = (p3/max_p)*127 #Escalado de valores
    cc_p3_msg = mido.Message('control_change', channel=0 ,control=2, value=cc_p3) # Canal 0 / CC 2
    midiOUT.send(cc_p3_msg)

    p4 = midi_data.get_data(sp4,0) # Valor del sensor de presion
    # FALTA REPARTIR VALORES EQUITATIVAMENTE
    cc_p4 = (p4/max_p)*127 #Escalado de valores
    cc_p4_msg = mido.Message('control_change', channel=0 ,control=3, value=cc_p4) # Canal 0 / CC 3
    midiOUT.send(cc_p4_msg)


    time.sleep(0.01)

