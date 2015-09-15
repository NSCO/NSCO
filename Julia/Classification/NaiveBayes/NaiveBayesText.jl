push!(LOAD_PATH, joinpath(dirname(@__FILE__),"../../Datasets"))
push!(LOAD_PATH, joinpath(dirname(@__FILE__),"../../Utils"))
push!(LOAD_PATH, dirname(@__FILE__))
import Datasets
import TextTools


import NaiveBayes
nb = NaiveBayes
data =Datasets.movie_revies()
(nrows,ncols) = size(data)
bag_of_words =bagofwords(data[:,1])
ocurrences = ocurrencematrix(data[:,1],bag_of_words)
labels   =  data[:,2]
attribute_types = repeat([false],outer=[size(ocurrences,1),1])
conf = nb.NaiveBayesConfig(attribute_types, true)
nbModel = nb.train(ocurrences,labels,conf)

t = vector_representation("Morgan Freeman sucks",bag_of_words)
pred = nb.classify(t, nbModel)
