# Clustering Jerárquico
## Comparación
En el ejemplo del Cluster in Cluster el método de single linkage es el único que recobra la estructura de los grupos. Métodos como el complete, average o ward fallan, todos estos métodos están diseñados para obtener clusteres elípticos o casi convexos [1].

Debido a la naturaleza del problema que examinan en [2],  se enfocan en métodos jerárquicos como el de vecinos más próximos, vecino mas lejano, el método de Ward y linkage entre grupos y el linkage intra grupos, el linkage de centroide. El objetivo es comprobar la performance de diferentes métodos de clustering cuando se usan conjuntos de datos cóncavos, y también que tipos de estructuras de datos puede revelar estos métodos y asignar correctamente la pertenencia a cada grupo. Las últimas páginas tiene ejemplos de como funciona cada algoritmo. Es interesante para evaluar.

- Michael Steinbach, George Karypis, and Vipin Kumar. "A comparison of document clustering techniques" (2000)
	Los autores llegan a la conclusión de que no siempre el clustering jerárquico obtiene mejores resultados que el particional en clustering de documentos, pero que siempre su costo computacional es mayor.
	Proponen además el algoritmo Bisecting K-means que puede funcionar tanto de forma jerárquica como particional, ya que en cada paso divide el cluster más grande en 2 con un K-means estándar.	
	
- Ying Zhao and George Karypis. "Comparison of Agglomerative and Partitional Document Clustering Algorithms" (2002)	
	Esta va en la misma línea que el anterior, aplicado de vuelta al clustering de documentos. Propone varias funciones objetivo para evaluar las variantes de ambos tipos de algoritmos.
	
- Nikos Hourdakis, Michalis Argyriou, Euripides G. M. Petrakis, and Evangelos E. Milios. "Hierarchical clustering in medical document collections: the Bic-Means method" (2010).
	Otro griego que aparentemente hizo su tesis sobre el trabajo del anterior. Propone una modificación sobre el Bisecting K-means agregando el Bayesian Information Criteria como mecanismo de parada
	en la división de los clusters, como si fuera un árbol de decisión.
	 
###Biblio
[1] Stuetzle W. et. al. "A generalized single linkage method for estimating the cluster tree of a density".

[2] Francetic, Nagode. "Hierarchical Clustering with Concave Data Sets". http://www.stat-d.si/mz/mz2.1/francetic.pdf

## Algoritmos jerárquicos para grandes volúmenes de datos
El número de operaciones para los algoritmos aglomerativos es de orden N^3  y no puede ser menos de O(N^2), por mas poronga que seas programando. 
### El algoritmo CURE
El acrónimo viene de Clustering Usando REpresentantes. La característica innovadora de CURE es que representa a cada cluster, C, por un conjunto de $k>1$ represenatantes denotado RC. Al utilizar múltiples representantes para cada cluster, el algoritmo CURE intenta capturar la forma de cada uno. Sin embargo, con el objetivo de tener en cuenta irregularidades en los bordes de los clsuters, los representantes elegidos inicialmente son empujados hacia la media del cluster. Esta acción es conocida como "achicamiento". 

Inicialmente para cada cluster u, el conjunto de representantes con W_rep contiene solo el punto en el cluster. Luego, en el paso 1, todos los puntos de entrada son insertados en un arbol k-d. Luego se arma una heap tratando a cada punto como un cluster separado. Se Calcula para cada cluster el elemento más cercano y luego se inserta dentro de la min-heap. La clave de la min-heap, (el atributo por el cual se ordena) es la distancia entre el cluster y su vecino más cercano.
Una vez que la heap Q y el arbol T fueron inicializados, los pares de clusters más cercanos se unen hasta que en la min-heap queden k clusters.  El cluster u en el tope de Q es el cluster para el cual u y su vecino más cercano son los pares de cluster más cercanos entre todos. De ese modo, en cada paso se extrae el mínimo de Q y borra a u de Q. El procedimiento de unir es usado para  unir lo pares de clusters u y v, y para calcular los nuevos puntos represenantes para el nuevo cluster w, que son insertados en  T. Los puntos en el cluster w son simplemente la unión de los puntos en los dos clusters u y v que son unidos. El procedimiento de mezcla, selecciona iterativamente puntos bien dispersos.
( well-scattered points). En la primera iteración, el punto mas alejado de la media es elegido como primer punto disperso. En cada iteración subsecuente, un punto del cluster w es elegido de forma que sea el mas alejado del punto previamente elegido. Los puntos luegos son acercados hacia la media por una fracción alpha. 

###El algoritmo ROCK

###El algoritmo CHAMELEON


##Estaría bueno
  * Hablar de que suposiciones hacen los algoritmos jerárquicos acerca de la distribución de los datos
  * Que alternativas hay cuando son muchos, pero muchos. El theodoridis tiene algunos centro. Voy a ver si puedo sacar algo después.

