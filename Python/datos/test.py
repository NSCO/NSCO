import pandas as pd;
import matplotlib.pyplot as plt
import numpy as np

file_path = 'C:/Users/geraq/Documents/Python/NSCO/datos/avgpm25.csv';
datos = pd.read_csv(file_path);
datos["pm25"][0:3];
datos["pm25"].describe();
datos.boxplot("pm25");
(fig, axes) = plt.subplots(nrows=2, ncols=2, figsize=(6,6));

axes[0, 0].boxplot(datos["pm25"]);
axes[1, 1].hist(datos["pm25"], color="green");
# este es un scatter plot común en el que todos los puntos tienen 0 en
# el eje Y, o sea que están alineados horizontalmente.
# zeros() funciona como en matlab, y shape es como size() de matlab.
# "b+" es el formato de los puntos, como el plot() de matlab.
# "b+" hace puntos azules con forma de signo más.
# ms es "marker size", el tamaño de los puntos en el scatter plot.
axes[1, 1].plot(datos["pm25"], np.zeros(datos["pm25"].shape), 'b+', ms=5)  # rug plot


 
 
 
 
 