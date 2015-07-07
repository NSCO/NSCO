# Clustering Jerárquico
## Algoritmos jerárquicos para grandes volúmenes de datos
El número de operaciones para los algoritmos aglomerativos es de orden N^3  y no puede ser menos de O(N^2), por mas poronga que seas programando. 
### El algoritmo CURE
El acrónimo viene de Clustering Usando REpresentantes. La característica innovadora de CURE es que representa a cada cluster, C, por un conjunto de $k>1$ represenatantes denotado RC. Al utilizar múltiples representantes para cada cluster, el algoritmo CURE intenta capturar la forma de cada uno. Sin embargo, con el objetivo de tener en cuenta irregularidades en los bordes de los clsuters, los representantes elegidos inicialmente son empujados hacia la media del cluster. Esta acción es conocida como "achicamiento". 

Inicialmente para cada cluster u, el conjunto de representantes con W_rep contiene solo el punto en el cluster. Luego, en el paso 1, todos los puntos de entrada son insertados en un arbol k-d. Luego se arma una heap tratando a cada punto como un cluster separado. Se Calcula para cada cluster el elemento más cercano y luego se inserta dentro de la min-heap. La clave de la min-heap, (el atributo por el cual se ordena) es la distancia entre el cluster y su vecino más cercano.
Una vez que la heap Q y el arbol T fueron inicializados, los pares de clusters más cercanos se unen hasta que en la min-heap queden k clusters.  El cluster u en el tope de Q es el cluster para el cual u y su vecino más cercano son los pares de cluster más cercanos entre todos. De ese modo, en cada paso se extrae el mínimo de Q y borra a u de Q. El procedimiento de unir es usado para  unir lo pares de clusters u y v, y para calcular los nuevos puntos represenantes para el nuevo cluster w, que son insertados en




##Estaría bueno
  * Hablar de que suposiciones hacen los algoritmos jerárquicos acerca de la distribución de los datos
  * Que alternativas hay cuando son muchos, pero muchos. El theodoridis tiene algunos centro. Voy a ver si puedo sacar algo después.
