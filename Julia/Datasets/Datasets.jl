module Datasets

using DataFrames

function skinpoints()
  data=readtable("skin_points.csv",separator=',',header=false)
  x=convert(Matrix,data)
  x'
end

function iris()
  data=readtable("Iris.csv",separator=';',header=true)
  x=convert(Matrix,data[:,1:4])
  y_labels=data[:,5]
  labels=unique(y_labels)
  y=zeros(length(y_labels))
  for i=1:length(labels)
    y[y_labels.==labels[i]]=i
  end
  x',round(Int32,y),labels
end

function aprobacion()
  readtable("aprobacion.csv",separator=';',header=true)
end

end
