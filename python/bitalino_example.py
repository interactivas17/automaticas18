import time
from bitalino import BITalino

# The macAddress variable on Windows can be "XX:XX:XX:XX:XX:XX" or "COMX"
# while on Mac OS can be "/dev/tty.BITalino-XX-XX-DevB" for devices ending with the last 4 digits of the MAC address or "/dev/tty.BITalino-DevB" for the remaining
macAddress = "/dev/tty.bitalino-DevB"

# This example will collect data for 5 sec.
running_time = 5
    
batteryThreshold = 30
acqChannels = [4,5]
num_sen = len(acqChannels)
samplingRate = 100
nSamples = 1
digitalOutput = [1,1]

# Connect to BITalino
device = BITalino(macAddress)

# Set battery threshold
device.battery(batteryThreshold)

# Read BITalino version
print(device.version())
    
# Start Acquisition
device.start(samplingRate, acqChannels)

start = time.time()
end = time.time()

# crear una instancia del objeto de datos para mandarlos a Midi
num_features = 1
# datos_midi = Datos(num_sen,num_features)


while (end - start) < running_time:
    # Read samples
    samples = []
    samples = device.read(nSamples)
    epoch = samples[:,-2:]
    print(epoch)
    end = time.time()

# Turn BITalino led on
device.trigger(digitalOutput)
    
# Stop acquisition
device.stop()
    
# Close connection
device.close()