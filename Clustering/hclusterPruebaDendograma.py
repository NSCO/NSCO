# -*- coding: utf-8 -*-
"""
Created on Mon Jul  6 12:21:15 2015

@author: emi
"""
import hcluster
from hcluster import pdist,linkage,dendrogram
import numpy
from numpy.random import rand

def main():
    print "hola"
    X = rand(10,100)
    X[0:5,:] *= 2
    Y = pdist(X)
    Z = linkage(Y)
    dendrogram(Z)
    

main()