push!(LOAD_PATH,dirname(@__FILE__))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../../../Datasets/"))
push!(LOAD_PATH, joinpath(dirname(@__FILE__),"../../../Utils"))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../../"))


using Datasets
using DecisionTree
import ClassificationUtils
cu = ClassificationUtils

(data, labels, labelNames) = Datasets.iris()
attributeIsNumeric = collect(repeated(true,size(data,1)))
attrNames = ["Sepal-Length", "Sepal-Width", "Petal-Length","Petal-Width"]
confidenceLevel = 0.5
conf = DecisionTree.Config(2, 20, attributeIsNumeric, attrNames, labelNames, confidenceLevel, DecisionTree.C45AttributeSelection())
model = DecisionTree.build_model(data, labels, conf)
DecisionTree.pretty_print(model.tree)

predictions = DecisionTree.classify(data, model)

conf_matrix = cu.confusionmatrix(labels, predictions)
println(conf_matrix)
#=
range = 0.05:0.05:0.9
sizes = zeros(length(range))
for i = 1:length(range)
  println("Building tree with confidence $(range[i])")
  conf = C45.C45Config(2, 20, attributeIsNumeric, attrNames, labelNames, range[i])
  model = C45.build_model(data, labels, conf)
  sizes[i] = C45.treeSize(model.tree)
end
using PyPlot
plot(range, sizes)
=#

using PyPlot
"Algorithm Finished"

figure()
n=10
parent=[0,1,45].*n
children=Vector{Int}[[0,0,43].*n,[0,1,2].*n]

#parent=[9,5].*n
#children=Vector{Int}[[3,2].*n, [2,0].*n, [4,3].*n]
c = 0.05:0.01:0.9
parent_errors=[]
children_errors=[]
for x in c
  ep,ec = DecisionTree.compare_parent_and_children(parent,children,x)
  push!(children_errors,ec)
  push!(parent_errors,ep)
end


plot(c,children_errors,"r", label="Children")
plot(c,parent_errors,"b", label="Parent")
legend(loc="upper right",fancybox="true")
