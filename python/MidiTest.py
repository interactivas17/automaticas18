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

i = 2 #C menor dorica
x = 0
a = 0



#Sensor Cardiaco 0
heart_beat = 0
tap = mido.Message('note_on', channel=15, note=0, velocity=90) #Nota reservada para el tap tempo (C-2 canal 16)
tap_off = mido.Message('note_off', channel=15, note=0)

#Sensor muscular


# Matriz de escalas
# primera matriz: pentatónica menor C
# segunda matriz: mayor natural C
# tercera matriz: menor dorica C
#cuarta matriz: escala hexatona C
scales = [[0,3,5,7,10,12,15,17,19,22,24,27,29,31,34,36,39,41,43,46,48,51,53,55,58,60,63,65,67,70,72,75,77,79,82,84,87,89,91,94,96,99,101,103,106,108,111,113,115,118,120,123,125,127]
,[0,2,4,5,7,9,11,12,14,16,17,19,21,23,24,26,28,29,31,33,35,36,38,40,41,43,45,47,48,50,52,53,55,57,59,60,62,64,65,67,69,71,72,74,76,77,79,81,83,84,86,88,89,91,93,95,96,98,100,101,103,105,107,108,110,112,113,115,117,119,120,122,124,125,127]
,[0,2,3,5,7,9,10,12,14,15,17,19,21,22,24,26,27,29,31,33,34,36,38,39,41,43,45,46,48,50,51,53,55,57,58,60,62,63,65,67,69,70,72,74,75,77,79,81,82,84,86,87,89,91,93,94,96,98,99,101,103,105,106,108,110,111,113,115,117,118,120,122,123,125,127]
,[0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126]]


print("\nTEST MIDI\n\nEntradas:"+str(mido.get_input_names())+"\n\nSalidas:"+str(mido.get_output_names()))

# Setup
midiIN = mido.open_input('Driver IAC Bus IAC 1')
midiOUT = mido.open_output('Driver IAC Bus IAC 1')





# TEST NOTES

# while True:
# 	n = random.randint(20, 45)
# 	if n >= len(scales[i]):
# 		n=len(scales[i])
# 	msg = mido.Message('note_on', note=scales[i][n], velocity=90, time=1)
# 	msg2 = mido.Message('note_off', note=scales[i][n])

# 	midiOUT.send(msg)
# 	time.sleep(0.500)
# 	midiOUT.send(msg2)



# TEST CONTROL CHANGE
# while True:
# 	msg = mido.Message('control_change', channel=0 ,control=0, value=x)
# 	print(x)
# 	midiOUT.send(msg)
	
# 	if a == 0:
# 		x+=1
# 	else:
# 		x-=1
# 	if x == 127:
# 		a = 1
# 	elif x == 0:
# 		a = 0
# 	time.sleep(0.100)

	





