#!/usr/bin/python3

import numpy as np
from matplotlib import pyplot as plt

# Generate a sinusoid at 936kHz amplitude modulated with speech with sample rate 100MHz

from scipy.io import wavfile
audioSampleRate, data = wavfile.read('HelloWorld.wav')

#plt.plot(data)
#plt.show()

sampleRate = 100e6
carrier = 936e3

print(audioSampleRate)
print(sampleRate // audioSampleRate)

interp = int(sampleRate // audioSampleRate)

outfile = open("1bit_rf.txt", "w")

phase = 0
for l,r in data:
	#print (l)
	phase_arr = np.zeros(interp)
	for i in range(0, interp):
		phase_arr[i] = phase
		phase += carrier / sampleRate
	mod = (l / 32768.0) * np.cos(2*np.pi*phase_arr)
	mod += np.random.normal(-0.1,0.1,interp)
	plt.plot(mod)
	plt.show()
	one_bit = np.sign(mod)
	for bit in one_bit:
		if bit < 0:
			outfile.write("0\n")
		else:
			outfile.write("1\n")

outfile.close()

