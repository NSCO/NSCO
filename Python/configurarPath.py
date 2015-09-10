#Un hack horrible para agregar a todas las carpetas al "PATH" de python
#Porque no permite el import de paquetes con path relativo :(

def configurarPath():
   import os
   import sys
   for dirName, subdirList, fileList in os.walk('.'):  
      if any(archivo.endswith(".py") for archivo in fileList):        
        sys.path.append(os.path.abspath(dirName))
        
configurarPath()        

  