module Datasets

using DataFrames

function skinpoints()
  readtable("skin_points.csv",separator=',',header=false)
end

function iris()
  readtable("Iris.csv",separator=';',header=true)
end

function aprobacion()
  readtable("aprobacion.csv",separator=';',header=true)
end

end
