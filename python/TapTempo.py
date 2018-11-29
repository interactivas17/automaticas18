import mido
import time
 
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

#Sensor Cardiaco
sc = 0 # Ubicacion del sensor cardiaco en Datos
hay_latido = 1 # Ubicacion del feature en Datos
heart_beat = 0
tap = mido.Message('note_on', channel=15, note=0, velocity=90) #Nota reservada para el tap tempo (C-2 canal 16)
tap_off = mido.Message('note_off', channel=15, note=0)

#Control de tempo con sensor cardiaco (0,1)
	while True:
		if (heart_beat==0):
			heart_beat = midi_data.get_data(sc, hay_latido)
			if(heart_beat==1):
				# Cada vez que cambia de estado a 1 se manda un tap
				midiOUT.send(tap)
				time.sleep(0.3)
				midiOUT.send(tap_off)
			else:
				time.sleep(0.01)
