def clusterInCluster(N=1000,r1=1,r2=5,w1=5,w2=1.0/3,arms=64):
    """clusterInCluster devulve un matriz de Nx3 en el que cada fila es un patron.
    Los puntos dibujan un cluster dentro de otro cluster. Los puntos estan en 
    2D, la tercer columna indica a que cluster pertenece cada punto.
    Parametros:
        N: cantidad de puntos
        r1: radio del cluster interno
        r2: radio del cluster externo
        w1: dispersion de los datos del cluster interno
        w2: dispesion de lso datos del cluster externo
        arms: No me queda claro que hace."""
    
    from numpy.random import rand
    from numpy.random import randint
    import math
    import numpy
    
    N1 = math.floor(N/2);
    N2 = N-N1;
    
    phi1 = rand(N1,1) * 2 * math.pi;
    dist1 = r1 + randint(1,3,[N1, 1])/3 * r1 * w1;
    d1 = numpy.concatenate((numpy.multiply(dist1,numpy.cos(phi1)), numpy.multiply(dist1,numpy.sin(phi1)), numpy.zeros([N1,1])),axis=1);

    perarm = round(N2/arms);
    N2 = int(perarm * arms);
    radperarm = (2*math.pi)/arms;
    phi2 = numpy.matrix((range(1,N2) - numpy.mod(range(1,N2), perarm))/perarm * (radperarm));
    phi2 = phi2.transpose();
    dist2 = numpy.matrix(r2 * (1 - w2/2) + r2 * w2 * numpy.mod(range(1,N2), perarm).transpose()/perarm);
    
    aa = numpy.multiply(dist2,numpy.cos(phi2).transpose())
    bb = numpy.multiply(dist2,numpy.sin(phi2).transpose())
    cc = numpy.ones([1,dist2.shape[1]])
    d2 = numpy.concatenate((aa,bb ,cc ),axis=0).transpose();    
    
    return numpy.concatenate((d1,d2),axis=0);   
    



