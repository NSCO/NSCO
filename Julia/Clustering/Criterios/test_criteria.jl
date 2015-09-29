push!(LOAD_PATH,dirname(@__FILE__))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../../Datasets/"))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../"))
import Datasets
import Silhouette
using Datasets
using Silhouette
using Dunn
using DaviesBouldin
import HierarchicalClustering
hc = HierarchicalClustering
sl = Silhouette

(data,labels) = Datasets.iris()
#data = data[:,1:100:end]
selected = 4
 configs = [hc.single_linkage_configuration, hc.complete_linkage_configuration,
    hc.average_linkage_configuration, hc.ward_linkage_configuration]

maxK = 20
scoresSilhouette=[]
scoresDunn=[]
scoresDB=[]
for k=2:maxK
  println(k)
  clusterModel=hc.build_model(data, configs[selected](hc.euclidean_dist, k))
  idxSilhouette = mean(Silhouette.silhouette(data,clusterModel.assignments)[1])
  idxDunn       = Dunn.dunn(data,clusterModel.assignments)
  idxDB         = DaviesBouldin.daviesbouldin(clusterModel, data)
  push!(scoresSilhouette,idxSilhouette)
  push!(scoresDunn,idxDunn)
  push!(scoresDB,idxDB)

end
using PyPlot

scatter(2:maxK,scoresSilhouette,color="g")
plot(2:maxK,scoresSilhouette,label="Silueta",color="g")

scatter(2:maxK,scoresDunn,color="r")
plot(2:maxK,scoresDunn,color="r",label="DunnDunn")


scatter(2:maxK,scoresDB,color="b")
plot(2:maxK,scoresDB,color="b",label="Davis Bouldin")
legend(loc="upper right",fancybox="true")
