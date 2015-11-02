module Datasets 

using DataFrames

function skinpoints()
  data=readtable(joinpath(dirname(@__FILE__),"skin_points.csv"),separator=',',header=false)
  x=convert(Matrix,data)
  x'
end

function skinpoints_small_normalized()
  x=Datasets.skinpoints()
  x=x[:,1:20:end]
  x=convert(Matrix{Float64},x)
  row_sum = maximum(x,2)
  x    = x ./ row_sum
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

function make_circles(samples::Int=100,separation_factor::Float64=.5)
  if (separation_factor > 1 || separation_factor < 0)
         throw(DomainError("separation_factor has to be between 0 and 1.") )
  end
  elements = linspace(0, 2 * pi,samples)
  outer_circ_x = cos(elements)
  outer_circ_y = sin(elements)
  inner_circ_x = outer_circ_x * separation_factor
  inner_circ_y = outer_circ_y * separation_factor
  x = [outer_circ_x;inner_circ_x ]
  y = [outer_circ_y;inner_circ_y ]
  circles = [x y]'

  #shuffle
  shuffled_order=shuffle(collect(1:size(circles,2)))
  circles[:,1:end]=circles[:,shuffled_order]
  #if (noise!=nothing)
 #   perturbation =  rand(noise, 2,samples)
#    circles+=perturbation
  #end
  return circles
end

function make_moons(samples::Int=100,separation_factor::Float64=1.0)
  if (separation_factor < 0)
         throw(DomainError())
  end
  elements = linspace(0,  pi,samples)
  outer_circ_x = cos(elements) * separation_factor
  outer_circ_y = sin(elements) * separation_factor
  inner_circ_x = separation_factor - outer_circ_x
  inner_circ_y =  - outer_circ_y
  x = [outer_circ_x;inner_circ_x ]
  y = [outer_circ_y;inner_circ_y ]
  moons = [x y]'

  #shuffle
  shuffled_order=shuffle(collect(1:size(moons,2)))
  moons[:,1:end]=moons[:,shuffled_order]
  #if (noise!=nothing)
 #   perturbation =  rand(noise, 2,samples)
#    moons+=perturbation
  #end
  return moons
end


function make_gaussian_blobs_random_centers(samples::Int=100,features::Int=2,k::Int=3,sigma::Float64=1.0)
    centers= rand(features,k)
    make_gaussian_blobs(samples,centers,sigma)
end
function make_gaussian_blobs(samples::Int,centers::Array{Float64,2},sigma::Float64=1.0)
  if (sigma <= 0)
         throw(DomainError("need sigma >= 0") )
  end
  features,k=size(centers)
  cov=sigma*eye(features)
  data=zeros(features,k*samples)
  for i in 1:k
      var = Distributions.MvNormal(centers[:,i],cov)
      data[:, (i-1)*samples+1:i*samples] = rand(var,samples)
  end

  shuffled_order=shuffle(collect(1:size(data,2)))
  data[:,1:end]=data[:,shuffled_order]

  return data
end

end
