# Python

## Leer un CSV 
pandas es un paquete de Python para el manejo de datos. Me parece que tiene unas funciones parecidas a las de R.

`[~]$ pip install pandas`

```
 import pandas as pd;
 datos = pd.read_csv('datos.csv');


```
####Acceder a los primeros 3 elementos de una columna
```
 datos["pm25"][0:3]
      0     9.771185
      1     9.993817
      2    10.688618
      Name: pm25, dtype: float64
```
###Describir una columna
```
 datos["pm25"].describe();
       count    576.000000
       mean       9.836358
       std        2.277034
       min        3.382626
       25%        8.548799
       50%       10.046697
       75%       11.356012
       max       18.440731
       Name: pm25, dtype: float64
```

###Hacer un BoxPlot
La librería esta me empieza a gustar. No te rompe las bolas y te deja hacer. Está usando matplotlib
```
datos.boxplot("pm25");
#Entiendo que está haciendo algo asi
import matplotlib.pyplot as plt
fig, axes = plt.subplots(nrows=1, ncols=1, figsize=(6,6));
axes[0, 0].boxplot(datos["pm25"], labels=true);
```

###Hacer un histograma
```
datos["pm25"].hist();
```
### Otra alternativa
#### Leer un CSV 

Me parece que **asciitable** es una librería copada para leer tablas porque admite tablas heterogéneas y ademas adivina automáticamente el formato de las celdas. Y aparentemente se da cuenta de las cabeceras.

`[~]$ pip install asciitable`


 ```
 import asciitable;
 datos =  asciitable.read('data_table.txt'); 
 datos[1:5]
   rec.array([(9.99381725284814, 1027, 'east', -85.842858, 33.26581),
       (10.6886181012839, 1033, 'east', -87.72596, 34.73148),
       (11.3374236874237, 1049, 'east', -85.798919, 34.459133),
       (12.1197644686119, 1055, 'east', -86.032125, 34.018597)], 
       dtype=[('pm25', '<f8'), ('fips', '<i4'), ('region', 'S4'), ('longitude', '<f8'), ('latitude', '<f8')])
```
####Acceder a los primeros 3 elementos de una columna
```
 datos.region[0:3]
     chararray(['east', 'east', 'east'],  dtype='|S4')
```

## Limpiar pantalla

import os

```
def cls():
    os.system(['clear','cls'][os.name == 'nt'])
# now, to clear the screen
cls()
```

## Borrar valores variables

```
>>> import os
>>> clear = lambda: os.system('cls')
>>> clear()

```
  
