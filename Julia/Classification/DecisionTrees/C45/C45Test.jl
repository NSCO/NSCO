push!(LOAD_PATH,dirname(@__FILE__))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../../../Datasets/"))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../../"))
import Datasets
using Datasets
import C45
using C45

(data, labels, labelNames) = Datasets.iris()
attributeIsNumeric = collect(repeated(true,size(data,1)))
attrNames = ["Sepal-Length", "Sepal-Width", "Petal-Length","Petal-Width"]
conf = C45.C45Config(2, 20, attributeIsNumeric, attrNames, labelNames)
model = C45.build_model(data, labels, conf)
C45.pretty_print(model)
