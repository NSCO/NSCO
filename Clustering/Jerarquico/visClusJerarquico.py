#!/usr/bin/env python

# embedding_in_qt4.py --- Simple Qt4 application embedding matplotlib canvases
#
# Copyright (C) 2005 Florent Rougon
#               2006 Darren Dale
#
# This file is an example program for matplotlib. It may be used and
# modified with no restriction; raw copies as well as modified versions
# may be distributed without limitation.
from __future__ import unicode_literals
import networkx as nx

import sys
import os
import random
from matplotlib.backends import qt4_compat
use_pyside = qt4_compat.QT_API == qt4_compat.QT_API_PYSIDE
if use_pyside:
    from PySide import QtGui, QtCore
else:
    from PyQt4 import QtGui, QtCore

from numpy import arange, sin, pi
from matplotlib.backends.backend_qt4agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

progname = os.path.basename(sys.argv[0])
progversion = "0.1"


class MyMplCanvas(FigureCanvas):
    """Ultimately, this is a QWidget (as well as a FigureCanvasAgg, etc.)."""
    def __init__(self,parent=None, width=5, height=4, dpi=100):
        fig = Figure(figsize=(width, height), dpi=dpi)
        self.axes = fig.add_subplot(111)
        # We want the axes cleared every time plot() is called
        self.axes.hold(False)

        self.compute_initial_figure()

        #
        FigureCanvas.__init__(self, fig)
        self.setParent(parent)

        FigureCanvas.setSizePolicy(self,
                                   QtGui.QSizePolicy.Expanding,
                                   QtGui.QSizePolicy.Expanding)
        FigureCanvas.updateGeometry(self)

    def compute_initial_figure(self):
        pass


class CanvasClustering(MyMplCanvas):
    def __init__(self,grafos,clus,parent=None, width=5, height=4, dpi=100):
        self.listaGrafos=grafos
        self.clusteres  = clus
        MyMplCanvas.__init__(self,parent,width,height,dpi)
        
    """Simple canvas with a sine plot."""
    def compute_initial_figure(self):
       p=nx.get_node_attributes(self.listaGrafos[0],'pos')       
       nx.draw(self.listaGrafos[0],pos=p, ax=self.axes)         
         
    def actualizarGrafo(self,val):
       p=nx.get_node_attributes(self.listaGrafos[val],'pos')       
       nx.draw(self.listaGrafos[val],pos=p, ax=self.axes)
       self.draw()





class ApplicationWindow(QtGui.QMainWindow):
    def __init__(self,clus,grafos):
        QtGui.QMainWindow.__init__(self)
        self.setAttribute(QtCore.Qt.WA_DeleteOnClose)
        self.setWindowTitle("application main window")     
        self.listaGrafos = grafos
        self.clusteres   = clus

        self.main_widget = QtGui.QWidget(self)

        l = QtGui.QVBoxLayout(self.main_widget)
        self.slider = QtGui.QSlider(self.main_widget)
        self.slider.setOrientation(QtCore.Qt.Horizontal)
        self.slider.setMaximum(len(self.listaGrafos)-1)
        self.slider.setMinimum(0)
        sc = CanvasClustering(self.listaGrafos,self.main_widget, width=5, height=4, dpi=100)
        
        
        
        self.slider.valueChanged.connect(sc.actualizarGrafo)
        
        l.addWidget(sc)
        l.addWidget(self.slider)

        self.main_widget.setFocus()
        self.setCentralWidget(self.main_widget)

        self.statusBar().showMessage("All hail matplotlib!", 2000)



    def closeEvent(self, ce):
       self.close()

from numpy.linalg import norm
from  clusterincluster import clusterInCluster
from matplotlib.pyplot import plot,figure
import matplotlib.pyplot as plt


def clusterJerarquico(fun,datos,k):
    nfilas=datos.shape[0]
    G=nx.Graph()
    for i in range(0,nfilas):
        print(i)                
        G.add_node(i,pos=[datos[i,0],datos[i,1]])    
    listaGrafos  = []
    clus=[]
    clus=[[i] for i in range (0, nfilas)]
    while len(clus) > k:
          print (len(clus))
          imin=0
          rmin=99999999
          jmin=0
          for i in range (0, len(clus)):
                  for j in range (i+1, len(clus)):
                      distancia = fun(clus[i], clus[j] ,datos)              
                      if (rmin > distancia[0] ):
                          rmin=distancia[0]
                          imin=i
                          jmin=j
                          minDist=distancia
          
          clusNuevo=clus[imin] + clus[jmin]
          gNuevo = G.to_undirected()          
          gNuevo.add_edge(minDist[1],minDist[2])          
          listaGrafos.append(gNuevo)
          G=gNuevo
          aux = clus[jmin]        
          clus.remove(clus[imin])
          clus.remove(aux)
          clus.append(clusNuevo)
    return [clus,listaGrafos]
    

def singleLinkage(clusI,clusJ, datos):
    mind=999999999
    
    for i in clusI:
        for j in clusJ:
            d=norm(datos[i,:]-datos[j,:])
            if (d<mind):
                mind=d;
                ii=i
                jj=j
    return [mind, ii, jj]
def averageLinkage(clusI,clusJ, datos):
    maxd=-1
    for i in clusI:
        for j in clusJ:
            d=norm(datos[i,:]-datos[j,:])
            if (d>maxd):
                maxd=d;
                ii=i
                jj=j
    return [maxd, ii, jj]
def completeLinkage(clusI,clusJ, datos):
    maxd=-1
    for i in clusI:
        for j in clusJ:
            d=norm(datos[i,:]-datos[j,:])
            if (d>maxd):
                maxd=d;
                ii=i
                jj=j
    return[ maxd, ii, jj]

                          

datos=clusterInCluster(70)
datos=datos[:,range(0,2)]
[clus, grafo]=clusterJerarquico(completeLinkage,datos,2)

qApp = QtGui.QApplication(sys.argv)

aw = ApplicationWindow(clus,grafo)
aw.setWindowTitle("%s" % progname)
aw.show()
sys.exit(qApp.exec_())
#qApp.exec_()