
push!(LOAD_PATH, joinpath(dirname(@__FILE__),"../Datasets"))
push!(LOAD_PATH, dirname(@__FILE__))


using Datasets
import MeanShift
ms=MeanShift

using PyCall
pygui(:qt)
using PyPlot
data=Datasets.skinpoints()
data=data[:,1:100:end]
data=convert(Matrix{Float64},data)
row_sum = maximum(data,2)
data    = data ./ row_sum


c=ms.MeanShiftConfig(1.0,0.002,gaussian_window)

println("Running algorithm...")

clusters=ms.build_model(data,c)
