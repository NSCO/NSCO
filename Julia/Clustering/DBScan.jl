module DBScan

using Clustering

type Parameters <: Clustering.Parameters
  maximum_distance::Float64 # eps en el codigo viejo
  minimum_points::Int32
end

type Model <: Clustering.Model
  clusters::Clustering.Hard
end

type Result <: Clustering.Result
  clusters::Clustering.Hard
end

get_clusters(r::Result)=r.clusters

function fit(x::Clustering.FloatInput,p::Parameters)
      dimensions,examples=size(x)
      clusters=zeros(Int,examples)
      next_cluster_id=1
      for i=1:examples
          point=x[:,i]
          if clusters[i]!= 0 #already assigned examples dont get reassigned to other clusters
              continue
          end
          points_near_example=points_near(point,x,p)
          #println(points_near_example)
          if (length(points_near_example)>=p.minimum_points) # fullfills conditions to make a new cluster
              clusters[i]=next_cluster_id
              assign_to_new_cluster(clusters,x,next_cluster_id,points_near_example,p)
              next_cluster_id+=1
          end
      end
      Result(clusters),Model(clusters)
end

function append_all_except_duplicates{T}(a::Vector{T},b::Vector{T})
   for e=b
       if !(e in a)
           push!(a,e)
    end
  end
end

function assign_to_new_cluster(clusters::Clustering.Hard,x::Clustering.FloatInput,new_cluster_id::Int,points_reachable_from_example::Clustering.Hard,p::Parameters)
    i=1
    while i<length(points_reachable_from_example)
        point_index=points_reachable_from_example[i]
        if clusters[point_index]==0
            clusters[point_index]=new_cluster_id
            neightbour=x[:,point_index]
            points_near_neightbour=points_near(neightbour,x,p)
            if (length(points_near_neightbour)>=p.minimum_points) # fullfills conditions for core point
              append_all_except_duplicates(points_reachable_from_example,points_near_neightbour)
            end
        end
        i+=1
    end
end

function points_near(point::Vector{Float64},x::Clustering.FloatInput,p::Parameters)
    indices=Int[]
    #use Distances and pairwise
    for i=1:size(x,2)
        possible_neighbour=x[:,i]
        distance_to_possible_neighbour= sqrt(sum((possible_neighbour-point).^2))
        #println(distance_to_possible_neighbour)
        if distance_to_possible_neighbour<p.maximum_distance
            indices=[indices; i]
        end
    end
    indices
end

end
