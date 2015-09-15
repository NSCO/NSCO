

push!(LOAD_PATH, joinpath(dirname(@__FILE__),"../Datasets"))
push!(LOAD_PATH, dirname(@__FILE__))

import NaiveBayes
nb = NaiveBayes

x = Array{Any,2}(3,5)
x[:,1] = [3,'a',1]
x[:,2] = [5.1,'b',1]
x[:,3] = [4,'a',2]
x[:,4] = [7.3,'b',2]
x[:,5] = [2,'b',2]

y = x[3,:]
x = x[1:2,:]
t = Matrix(2,1)
t[:,1] = [7,'b']
conf = nb.NaiveBayesConfig([true,false], true)
nbModel = nb.train(x,y,conf)
println(nbModel)
pred = nb.classify(t, nbModel)
#pred = nb.classify(convert(Array{Float64},t), nbModel)
println(pred)

#end
