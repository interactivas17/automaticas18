import serial, time, queue


def serial_data(port, baudrate):
    ser = serial.Serial(port, baudrate)

    while True:
        yield ser.readline()

    ser.close()

for line in serial_data("/dev/tty.HC-05-DevB", 9600):
    val = line.strip()
    values = val.decode('ascii')
    print(values)
    values = values.split(',')
    array = [float(s) for s in values if s]
    print("El valor del sensor es: {}".format(array))
    time.sleep(0.001)