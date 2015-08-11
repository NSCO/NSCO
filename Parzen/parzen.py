# -*- coding: utf-8 -*-
"""
Created on Tue Aug 11 07:34:16 2015

@author: emi
"""
import numpy as np;

import matplotlib.pyplot as plt;
import numpy as np
def p(centro,puntos,h):
    suma = 0
    for x in puntos:

        res = (abs(x-centro) <= h/2.0)
        if (res):
            suma+=1
    return (1.0/len(puntos))*(1/h**2.0)*suma
    

puntos = np.random.uniform(0,6,[1,550])[0]
pasos = 0.001
h=1
resultados = []
for centro in np.arange(0,7,pasos):
    resultados.append(p(centro,puntos,h))
    
plt.plot(np.arange(0,7,pasos),resultados)
plt.ylim((0,1))

