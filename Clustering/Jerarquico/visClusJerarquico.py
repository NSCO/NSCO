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

from linkage import *
import sys
import os
import random
from  matplotlib.backends import qt_compat
use_pyside = qt_compat.QT_API == qt_compat.QT_API_PYSIDE
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
    def __init__(self,grafos,colores,parent=None, width=5, height=4, dpi=100):
        self.listaGrafos=grafos
        self.colores = colores
        MyMplCanvas.__init__(self,parent,width,height,dpi)
        
    """Simple canvas with a sine plot."""
    def compute_initial_figure(self):
       self.dibujarGrafo(0)     
         
    def actualizarGrafo(self,val):        
       self.dibujarGrafo(val)
       self.draw()
    def dibujarGrafo(self,  indice):
       p=nx.get_node_attributes(self.listaGrafos[indice],'pos')       
       nx.draw_networkx(self.listaGrafos[indice],
                        pos=p, 
                        ax=self.axes,
                        node_color=self.colores[indice],
                        with_labels=False,
                        alpha=0.5,
                        node_size=150)
        





class ApplicationWindow(QtGui.QMainWindow):
    def __init__(self,colores,grafos):
        QtGui.QMainWindow.__init__(self)
        self.setAttribute(QtCore.Qt.WA_DeleteOnClose)
        self.setWindowTitle("application main window")     
        self.listaGrafos = grafos
        self.colores   = colores

        self.main_widget = QtGui.QWidget(self)

        l = QtGui.QVBoxLayout(self.main_widget)
        self.slider = QtGui.QSlider(self.main_widget)
        self.slider.setOrientation(QtCore.Qt.Horizontal)
        self.slider.setMaximum(len(self.listaGrafos)-1)
        self.slider.setMinimum(0)
        sc = CanvasClustering(self.listaGrafos,self.colores,self.main_widget, width=5, height=4, dpi=100)
        
        
        
        self.slider.valueChanged.connect(sc.actualizarGrafo)
        
        l.addWidget(sc)
        l.addWidget(self.slider)

        self.main_widget.setFocus()
        self.setCentralWidget(self.main_widget)

        self.statusBar().showMessage("All hail matplotlib!", 2000)



    def closeEvent(self, ce):
       self.close()


from  clusterincluster import clusterInCluster
from matplotlib.pyplot import plot,figure
import matplotlib.pyplot as plt


def clusterJerarquico(fun,datos,k):
    nfilas=datos.shape[0]
    G=nx.Graph()
    colores=[]
    for i in range(0,nfilas):                     
        G.add_node(i,pos=[datos[i,0],datos[i,1]])  
        colores.append([random.random(), random.random(),random.random(),random.random()])
    listaGrafos=[ G ]
    listaColores=[ colores ]
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
          color = list(listaColores[len(listaColores)-1])
          for i in clus[jmin]:
              color[i] = color[clus[imin][0]]
          listaColores.append(color)
          gNuevo = G.to_undirected()          
          gNuevo.add_edge(minDist[1],minDist[2])          
          listaGrafos.append(gNuevo)
          G=gNuevo
          aux = clus[jmin]        
          clus.remove(clus[imin])
          clus.remove(aux)
          clus.append(clusNuevo)
    return [listaColores,listaGrafos]
    



def main():
  datos=clusterInCluster(150)
  datos=datos[:,range(0,2)]
  [colores, grafo]=clusterJerarquico(averageLinkage,datos,2)
  qApp = QtGui.QApplication(sys.argv)
  aw = ApplicationWindow(colores,grafo)
  aw.setWindowTitle("%s" % progname)
  aw.show()
  return qApp.exec_()                    
  
if __name__ == '__main__':
    main()

#qApp.exec_()