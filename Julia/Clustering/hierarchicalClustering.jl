#using DataFrame
module HierarchicalClustering
export single_linkage_configuration,single_linkage,build_model,HierarchicalConfiguration,Clustering,euclidean_dist
type Clustering
	assignments :: Array{Int64,1}
end

type HierarchicalConfiguration
  metric::Function
  joining_criterion::Function
  k::Integer
end

 function single_linkage(cluster_i::Array{Int64,1}, cluster_j::Array{Int64,1}, data::Matrix, metric::Function)
  dmin = typemax(Int64)
  for i = cluster_i
    for j = cluster_j
        d = metric(data[:,i], data[:,j])
        if (d < dmin)
           dmin = d
        end
    end
  end
  return dmin
end



 function single_linkage_configuration(metric::Function,k::Integer)
    return HierarchicalConfiguration(metric,single_linkage,k)
end


function euclidean_dist(e1, e2)
    return norm(e1 - e2)
end

 function build_model(data::Matrix, conf::HierarchicalConfiguration)
	(nRows, nCols) = size(data)
	assignments = zeros(nRows)
  clusters = Array{Int64,1}[]
  for i=1:nCols
    push!(clusters, [i])
  end
  for c=nCols:-1:conf.k
    println(c)    
    imin = -1
    jmin = -1
    dmin = typemax(Int64)
    for i=1:c-1
      for j=i+1:c
        #distFun is the joining criterion (single, complete, etc)
        d = conf.joining_criterion(clusters[i], clusters[j], data, conf.metric)
        if (d < dmin)
          dmin = d
          imin = i
          jmin = j
        end
      end
    end
    c1 = clusters[imin]
    c2 = clusters[jmin]
    append!(c1, c2)
    splice!(clusters, jmin)
  end
  return clusters
end

end

