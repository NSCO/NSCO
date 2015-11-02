module MeanShift

using Clustering
using Distributions
using PDMats
using DBScan
using InitialMeans

type Parameters <: Clustering.Parameters
    learning_rate::Float64
    window_size::Float64
    window::Function
    iterations::Int
end

type Model <: Clustering.Model
  means::Clustering.FloatInput
end

type Result <: Clustering.Result
  clusters::Clustering.Hard
  mean_estimates::Clustering.FloatInput
end

get_clusters(r::Result)=r.clusters

using PyPlot

function fit(original_data::Clustering.FloatInput,p::Parameters)
    x = deepcopy(original_data)
    examples=size(x,2)
    for j=1:p.iterations
        for i=1:examples
            x[:,i] = shift(x[:,i],original_data,p)
        end

    end

    scatter(x=x[1,:],y=x[2,:], color="r",marker="o")
    maximum_distance=0.05
    minimum_points=2
    p_dbscan=DBScan.Parameters(maximum_distance,minimum_points)
    r,m=DBScan.fit(x,p_dbscan)
    clusters=DBScan.get_clusters(r)
    means=InitialMeans.means_from_clustering(x,clusters)
    Result(clusters,x),Model(means)
end


function shift(pattern::Vector{Float64}, x::Clustering.FloatInput, p::Parameters)
    denominator = 0
    numerator   = 0
    examples=size(x,2)
    for i=1:examples
        point=x[:,i]
        estimation = p.window(point,pattern,p.window_size)
        denominator = denominator + estimation
        numerator   = numerator   + estimation*point
    end
    mean_shift = (numerator/denominator) - pattern
    return pattern + p.learning_rate *(mean_shift)
end



function gaussian_window(x,mu,sigma)
    var=IsoNormal(mu, ScalMat(size(x,1),sigma) )
    return pdf(var,x)
end


end
