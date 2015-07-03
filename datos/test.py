import pandas as pd;
import matplotlib.pyplot as plt
import numpy as np

file_path = 'C:/Users/geraq/Documents/Python/NSCO/datos/avgpm25.csv';
datos = pd.read_csv(file_path);
datos["pm25"][0:3];
datos["pm25"].describe();
datos.boxplot("pm25");
(fig, axes) = plt.subplots(nrows=2, ncols=2, figsize=(6,6));
#axes[0, 0].boxplot(datos["pm25"], labels=True);
axes[0, 0].boxplot(datos["pm25"]);
axes[1,1].hist(datos["pm25"], color="green");
axes[1,1].plot(datos["pm25"], np.zeros(datos["pm25"].shape), 'b+', ms=20)  # rug plot

#fig2 = axes[0, 0].boxplot(datos["pm25"]);
#axes.boxplot(datos["pm25"]);
#datos["pm25"].hist();
#ax = fig.add_subplot(111);
#x1 = datos["pm25"];
#ax.plot(x1, np.zeros(x1.shape), 'b+', ms=20)  # rug plot
#ax.plot(x1, np.zeros(x1.shape), 'b+', ms=20)  # rug plot
#x_eval = np.linspace(-10, 10, num=200)
 
 
 
 
 