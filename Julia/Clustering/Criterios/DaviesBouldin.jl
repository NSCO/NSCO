push!(LOAD_PATH,dirname(@__FILE__))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../../Datasets/"))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../../"))
module DaviesBouldin
import ClusterModelModule
cm = ClusterModelModule
export daviesbouldin

function distance(x,y)
  return sqrt(sum((x - y).^2))
end

function daviesbouldin(c::cm.ClusterModel, data::Matrix)
  #the objective is to minimize the index, which represents the similarity
  #between the cluster and its most similar neighbor. To minimize the index,
  #cluster dispersion has to be minimized and inter-cluster distance has to be
  #maximized
  (nAttrs, nExamples) = size(data)
  nClusters = size(c.centroids, 2)
  R = zeros(nClusters, nClusters) #inter-cluster simmilarity = (Si + Sj) / Dij
  S = zeros(nClusters) #intra-cluster dispersion
  #calculate cluster dispersion
  for i=1:nClusters
    sample = data[:, c.assignments .== i]
    S[i] = mean(map(x -> distance(x, c.centroids[:,i]), sample))
  end;
  #calculate inter-cluster distance and fill the R matrix
  for i=1:nClusters-1
    for j=i+1:nClusters
        dist = distance(c.centroids[:,i], c.centroids[:,j])
        if dist > 0
          R[i,j] = (S[i] + S[j]) / dist
        else
          R[i,j] = 0 #the similarity of the cluster with itself will not be taken into account
        end
      R[j,i] = R[i,j] # the R matrix is symmetric
    end
  end
  #the DB index is the average of the highest similarities for each cluster
  return mean(maximum(R, 1))
end

end
