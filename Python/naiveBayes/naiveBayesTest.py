# -*- coding: utf-8 -*-
"""
Created on Tue Aug 18 12:00:41 2015

@author: geraq
"""

import numpy as np
import pandas as pd
from sklearn.metrics import confusion_matrix
import NaiveBayes as NB

useIris = True
numerizeLabels = True

if useIris:
    file_path = '../datos/Iris.csv'
    labelCol = 4    
else:    
    file_path = '../datos/Curso2.csv'
    labelCol = 3
    
print 'Reading data...'
df=pd.read_csv(file_path, sep=';',header=0)
data = df.values

labels = data[:,labelCol]
data = data[:,0:labelCol]
(nRows, nCols) = np.shape(data)

if useIris:    
    attrIsNumeric = np.repeat(True, nCols)    
else:    
    attrIsNumeric = np.repeat(False, nCols)
    
if numerizeLabels:
    for (i,c) in enumerate(np.unique(labels)):
        labels[labels == c] = i + 1

useLaplaceCorrection = False
nb = NB.NaiveBayes()
print 'Training...'
nb.train(data, labels, attrIsNumeric) 
print 'Testing...'
predictions = nb.test(data, useLaplaceCorrection)
print 'Printing confusion matrix...'
#print confusion_matrix(labels.astype(float), predictions.T)
print confusion_matrix(labels.astype(float), predictions)
