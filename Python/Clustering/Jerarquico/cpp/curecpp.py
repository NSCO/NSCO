from curecpp import curecpp
import numpy as np
b = np.random.random((100,3))
c= np.array([[1,2,3,4,5.0], 
             [4,5,6,7,8]])

print(c)
print(c.dtype.type)
print(curecpp(c,3,5,0.5))
