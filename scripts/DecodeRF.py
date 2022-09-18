#!/usr/bin/python3

import numpy as np
import scipy.signal
from matplotlib import pyplot as plt

rf_file = open("1bit_rf.txt", "r")

sampleRate = 100e6
audioSampleRate = 10e3

decim = int(sampleRate // audioSampleRate)

carrierFreq = 936e3

phase = 0

block = decim * 200

I = np.zeros(block + 3)
Q = np.zeros(block + 3)

i = 0

dataOut = []

j = 0

while j < 1000:

	line = rf_file.readline()

	if not line:
		break

	bit = int(line)
	#print(bit)

	theSin = np.sin(2*np.pi*phase)
	theCos = np.cos(2*np.pi*phase)

	if bit == 0:
		theSin = -np.sin(2*np.pi*phase)
		theCos = -np.cos(2*np.pi*phase)

	phase += carrierFreq / sampleRate

	I[i] = theCos
	Q[i] = theSin

	i += 1

	if i == block:
		i = 0	
		ftyp = 'iir'
		datI1 = scipy.signal.decimate(I, 10, ftype=ftyp)
		datI2 = scipy.signal.decimate(datI1, 10, ftype = ftyp)
		datI3 = scipy.signal.decimate(datI2, 10, ftype = ftyp )
		datI  = scipy.signal.decimate(datI3, 10, ftype = ftyp )

		datQ1 = scipy.signal.decimate(Q, 10, ftype = ftyp )
		datQ2 = scipy.signal.decimate(datQ1, 10, ftype = ftyp )
		datQ3 = scipy.signal.decimate(datQ2, 10, ftype = ftyp )
		datQ  = scipy.signal.decimate(datQ3, 10, ftype = ftyp)

		datI[0] = datI[1]
		datQ[0] = datQ[1]


		norm = np.sqrt(datI*datI + datQ*datQ)

		for n in norm:
			dataOut.append(n)

		j += 1

plt.plot(dataOut)
plt.show()
