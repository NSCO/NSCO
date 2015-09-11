push!(LOAD_PATH, pwd())
using Datasets

using PyPlot

subplot(121)
dataset=Datasets.skinpoints()
dataset=dataset[1:100:end,:]
scatter(dataset[1,:], dataset[2,:])
title("Skin points")


subplot(122)
dataset=Datasets.iris()
scatter(dataset[1,:], dataset[2,:])
title("Iris")

#using Gadfly
#using Cairo
#plot(x=dataset[:,1], y=dataset[:,2])#
#draw(PNG("skinpoints_plot.png", 4inch, 3inch), skinpoints_plot)
