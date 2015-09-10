from numpy.random import rand
from numpy import sqrt,sin,cos,zeros,ones
from numpy.random import randint
from math import  pi
import numpy
def  outlier(N=600, r=20, dist=30, outliers=0.04, noise=5):
#function data = outlier(N=600, r=20, dist=30, outliers=0.04, noise=5)
    
    N1 = round(N * (.5-outliers));
    N2 = N1;
    N3 = round(N * outliers);
    N4 = N-N1-N2-N3;

    phi1 = rand(N1,1) * pi;
    r1 = sqrt(rand(N1,1))*r;
    P1 = numpy.concatenate((-dist + r1*sin(phi1), r1*cos(phi1), zeros((N1,1))),axis=1);

    phi2 = rand(N2,1) * pi;
    r2 = sqrt(rand(N2,1))*r;
    P2 = numpy.concatenate((dist - r2*sin(phi2), r2*cos(phi2), 3*ones((N2,1))),axis=1);    
    
    P3 = numpy.concatenate((rand(N3,1)*noise, dist+rand(N3,1)*noise, 2*ones((N3,1))),axis=1);    
    
    P4 = numpy.concatenate((rand(N4,1)*noise, -dist+rand(N4,1)*noise, ones((N4,1))),axis=1);
    
    return   numpy.concatenate((P1, P2, P3, P4),axis=0);

