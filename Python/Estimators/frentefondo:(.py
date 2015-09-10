# -*- coding: utf-8 -*-
"""
Created on Thu Aug 20 13:38:27 2015

@author: luciano
"""

from Estimators import ParzenEstimator
from scipy.misc import imread
import numpy as np
from numpy.random import randint
import scipy.stats


def gaussian_window(x,mu,sigma):
    dx  = x-mu
    distance=np.linalg.norm(dx)
    return scipy.stats.norm(mu,sigma).pdf(distance)
  

img = imread('/home/luciano/mariposa.jpg')
height,width,c = img.shape
n_pixels = height*width
pixeles=[]
for x in range(width):
    for y in range(height):
       pixeles.append(img[y,x,:]) 

pixeles = np.array(pixeles)
for escala in np.arange(0.5,6,0.05):
    p =  ParzenEstimator(pixeles,escala,gaussian_window) 
    denom = 0
    num = 0
    for i in pixeles:
        print(i)
        pfg = p.estimate(i)
        denom += pfg        
        num+=pfg*np.log((1-pfg)/pfg)        
    print(-num/denom)
    

       
