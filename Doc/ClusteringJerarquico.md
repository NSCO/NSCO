# Clustering Jerárquico
## Algoritmos jerárquicos para grandes volúmenes de datos
El número de operaciones para los algoritmos aglomerativos es de orden N^3  y no puede ser menos de O(N^2), por mas poronga que seas programando. 
### El algoritmo CURE
El acrónimo viene de Clustering Usando REpresentantes. La característica innovadora de CURE es que representa a cada cluster, C, por un conjunto de $k>1$ represenatantes denotado RC. Al utilizar múltiples representantes para cada cluster, el algoritmo CURE intenta capturar la forma de cada uno. Sin embargo, con el objetivo de tener en cuenta irregularidades en los bordes de los clsuters, los representantes elegidos inicialmente son empujados hacia la media del cluster. Esta acción es conocida como "achicamiento". More specifically, for each C the set RC is



##Estaría bueno
  * Hablar de que suposiciones hacen los algoritmos jerárquicos acerca de la distribución de los datos
  * Que alternativas hay cuando son muchos, pero muchos. El theodoridis tiene algunos centro. Voy a ver si puedo sacar algo después.
