module Datasets

using DataFrames

function skinpoints()
  data=readtable(joinpath(dirname(@__FILE__),"skin_points.csv"),separator=',',header=false)
  x=convert(Matrix,data)
  x'
end

function hill_valley_train()
    data = readtable(joinpath(dirname(@__FILE__),"Hill_Valley_with_noise_Training.data"),separator=',',header=true)
    data = convert(Matrix,data)
    y_labels=round(Int,data[:,end])
    data =   data[:,1:end-1]
    return (data',vec(y_labels+1))
end

function hill_valley_test()
    data = readtable(joinpath(dirname(@__FILE__),"Hill_Valley_with_noise_Testing.data"),separator=',',header=true)
    data = convert(Matrix,data)
    y_labels=round(Int,data[:,end])
    data =   data[:,1:end-1]
    return (data',vec(y_labels+1))
end

function iris()
  #data=readtable("Iris.csv",separator=';',header=true)
  data=readtable(joinpath(dirname(@__FILE__),"Iris.csv"),separator=';',header=true)
  x=convert(Matrix,data[:,1:4])
  y_labels=data[:,5]
  labels=unique(y_labels)
  y=zeros(length(y_labels))
  for i=1:length(labels)
    y[y_labels.==labels[i]]=i
  end
  x',round(Int32,y),labels
  #x', y, labels
end
function movie_revies()
  return  readdlm(joinpath(dirname(@__FILE__),"movie_reviews.txt"),'\t', quotes=false)
end
function aprobacion()
  readtable("aprobacion.csv",separator=';',header=true)
end

end
