module DBScan

type DBScanConfig
  maximum_distance::Float64 # eps en el codigo viejo
  minimum_points::Int32
end

function build_model(x,c::DBScanConfig)

      dimensions,examples=size(x)
      clusters=zeros(examples)
      #println(examples)
      next_cluster_id=1
      for i=1:examples
          point=x[:,i]
          if clusters[i]!= 0 #already assigned examples dont get reassigned to other clusters
              continue
          end
          points_near_example=points_near(point,x,c)
          #println(points_near_example)
          if (length(points_near_example)>=c.minimum_points) # fullfills conditions to make a new cluster
              assign_to_new_cluster(clusters,x,next_cluster_id,points_near_example,c)
              next_cluster_id+=1
          end
      end
      clusters
end

    function append_all_except_duplicates(a,b)
       for e=a
           if !(e in a)
               a=[a; e]
        end
      end
    end

    function assign_to_new_cluster(clusters,x,new_cluster_id,points_reachable_from_example,c::DBScanConfig)
        i=1
        while i<length(points_reachable_from_example)
            point_index=points_reachable_from_example[i]
            if clusters[point_index]==0
                clusters[point_index]=new_cluster_id
                neightbour=x[:,point_index]
                points_near_neightbour=points_near(neightbour,x,c)
                append_all_except_duplicates(points_reachable_from_example,points_near_neightbour)
            end
            i+=1

        end
    end
    function points_near(point,x,c::DBScanConfig)
        indices=[]
        for i=1:size(x,2)
            possible_neighbour=x[:,i]
            distance_to_possible_neighbour= sqrt(sum( (possible_neighbour-point).^2))
            #println(distance_to_possible_neighbour)
            if distance_to_possible_neighbour<c.maximum_distance
                indices=[indices; i]
            end
        end
        indices
    end

end
