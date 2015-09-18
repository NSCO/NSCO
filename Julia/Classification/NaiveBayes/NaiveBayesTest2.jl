push!(LOAD_PATH, joinpath(dirname(@__FILE__),"../../Datasets"))
push!(LOAD_PATH, joinpath(dirname(@__FILE__),"../../Utils"))
push!(LOAD_PATH, dirname(@__FILE__))

import Datasets
import NaiveBayes
import ClassificationUtils
cu = ClassificationUtils

nb = NaiveBayes
x,y,labels = Datasets.iris()

attrIsNumeric = collect(repeated(true, 4))
useLaplacianCorrection = true
conf = nb.NaiveBayesConfig(attrIsNumeric, useLaplacianCorrection)
nbModel = nb.train(x, y', conf)
#println(nbModel)
pred = nb.classify(x, nbModel)
#println(pred)
conf_matrix = cu.confusionmatrix(y, pred)
println(conf_matrix)
