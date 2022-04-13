

# -*- coding: utf-8 -*-

"""

Atmospheric radiocarbon and box model



Written by Jim Randerson on 1/12/17

"""



import numpy as np

import matplotlib.pyplot as py



#read in merged 14c file

datafilename = "mergedatm14C.txt" #name of file containing data

f = open(datafilename, "r")

i = 0

for j in f:

    i = i + 1

f.close()



filelength    = i #number of lines in file

headerlen     = 1 #number of file header lines

npoints       = (filelength-headerlen)  #estimate the number of data points

# npoints = npoints1-9 # hincast to year 2000

time          = np.zeros(npoints) #create an array to hold the data

D14Catm       = np.zeros(npoints) #create an array to hold the data



f = open(datafilename, "r")

for i in range(headerlen):

    headerline = f.readline()

    # print headerline



for i in range(npoints):

    aline       = f.readline()

    elements    = aline.split("\t")

    time[i]     = float(elements[0])

    D14Catm[i]  = float(elements[1])

f.close

#*** finish reading in merged long radiocarbon D14C time series


npp            = np.zeros(npoints)

Rh             = np.zeros(npoints)

Cb             = np.zeros(npoints)

RatmdivRstd    = np.zeros(npoints)

CbRdivRstd     = np.zeros(npoints)



tauradio       = 8267.0 # radioactive decay turnover time

taudecomp      = 2000.0  # decomposition loss turnover time

taueff         = 1.0/(1.0/taudecomp + 1.0/tauradio) #combined turnover time

dt             = 1 # time step of integration 1 year



npplevel       = 1.0 #gc/m2/yr

npp[0]         = npplevel

Rh             = np.zeros(npoints)

Cb[0]          = npplevel*taudecomp

D14Cbioss      = ((npplevel/Cb[0])*taueff*(D14Catm[0]/1000.0 +1) - 1.0)*1000



#print "tau: %.1f taueff: %.1f D14Catm (per mil): %.1f D14Cbio(per mil): %.1f" % (taudecomp,taueff,D14Catm[0],D14Cbioss)



CbRdivRstd[0]  = npplevel*taueff*((D14Catm[0]/1000.0) + 1.0)



AtmRdivRstd    = D14Catm/1000.0 + 1.0

#print "Initial soil C: %.1f and soil D14C (per mil):%.1f" % (Cb[0],(CbRdivRstd[0]/Cb[0]-1.0)*1000.00)



for i in range(1,npoints):

    npp[i]         = npplevel

    Rh[i]          = Cb[i-1]/taudecomp

    Cb[i]          = Cb[i-1] + (npp[i] - Rh[i])*dt



    CbRdivRstd[i]  = CbRdivRstd[i-1] + (npp[i]*AtmRdivRstd[i]- CbRdivRstd[i-1]/taueff)*dt



D14Cbio = ((CbRdivRstd/Cb)-1.0)*1000.0


#print "Final biomass D14C: %.1f" % D14Cbio[-1]




py.close(0)

py.figure(0,figsize=(8, 6), dpi=80)

py.plot(time, D14Catm, color="blue", linewidth=2.0, label="Atm. D14C Intcal13 and Hua merged")

py.plot(time, D14Cbio, color="green", linewidth=2.0, label="Soil D14C")

py.legend(loc='upper left')

py.ylabel('D14C (per mil)',fontsize=15)

py.xlabel('Calendar year', fontsize=15)

py.tick_params(labelsize=12)

py.show()



py.close(1)

py.figure(1,figsize=(8, 6), dpi=80)

py.plot(time, D14Catm, color="blue", linewidth=2.0, label="Atm. D14C Intcal13 and Hua merged")

py.plot(time, D14Cbio, color="green", linewidth=2.0, label="Soil D14C ")

py.legend(loc='upper left')

py.xlim(1940, 2016)

py.ylim(-200, 900)

py.ylabel('D14C (per mil)',fontsize=15)

py.xlabel('Calendar year', fontsize=15)

py.tick_params(labelsize=12)

py.show()
