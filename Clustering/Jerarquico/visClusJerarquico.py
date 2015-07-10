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
    def __init__(self,listaClusters, parent=None, ,width=5, height=4, dpi=100):
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
    """Simple canvas with a sine plot."""
    def compute_initial_figure(self):
        t = arange(0.0, 3.0, 0.01)
        s = sin(2*pi*t)
        self.axes.plot(t, s)


class MyDynamicMplCanvas(MyMplCanvas):
    """A canvas that updates itself every second with a new plot."""
    def __init__(self, *args, **kwargs):
        MyMplCanvas.__init__(self, *args, **kwargs)
        timer = QtCore.QTimer(self)
        timer.timeout.connect(self.update_figure)
        timer.start(1000)

    def compute_initial_figure(self):
        self.axes.plot([0, 1, 2, 3], [1, 2, 0, 4], 'r')

    def update_figure(self):
        # Build a list of 4 random integers between 0 and 10 (both inclusive)
        l = [random.randint(0, 10) for i in range(4)]

        self.axes.plot([0, 1, 2, 3], l, 'r')
        self.draw()


class ApplicationWindow(QtGui.QMainWindow):
    def __init__(self,clus,grafo):
        QtGui.QMainWindow.__init__(self)
        self.setAttribute(QtCore.Qt.WA_DeleteOnClose)
        self.setWindowTitle("application main window")     
        self.listaGrafos = grafos
        self.clusteres   = clus

        self.main_widget = QtGui.QWidget(self)

        l = QtGui.QVBoxLayout(self.main_widget)
        self.slider = QtGui.QSlider(self.main_widget)
        self.slider.setOrientation(QtCore.Qt.Horizontal)
        sc = CanvasClustering(self.listaGrafos,self.main_widget, width=5, height=4, dpi=100)
        
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
    G.add_nodes_from([0,datos.shape[0]])
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
                      if (rmin > distancia ):
                          rmin=distancia
                          imin=i
                          jmin=j
          clusNuevo=clus[imin] + clus[jmin]
          gNuevo = G.copy()          
          gNuevo.add_edge(imin,jmin)
          listaGrafos.append(gNuevo)
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
    return mind
def averageLinkage(clusI,clusJ, datos):
    maxd=-1
    for i in clusI:
        for j in clusJ:
            d=norm(datos[i,:]-datos[j,:])
            if (d>maxd):
                maxd=d;
    return maxd
def completeLinkage(clusI,clusJ, datos):
    maxd=-1
    for i in clusI:
        for j in clusJ:
            d=norm(datos[i,:]-datos[j,:])
            if (d>maxd):
                maxd=d;
    return maxd

                          

datos=clusterInCluster(70)
datos=datos[:,range(0,2)]
[clus, grafo]=clusterJerarquico(completeLinkage,datos,2)

qApp = QtGui.QApplication(sys.argv)

aw = ApplicationWindow(clus,grafo)
aw.setWindowTitle("%s" % progname)
aw.show()
sys.exit(qApp.exec_())
#qApp.exec_()