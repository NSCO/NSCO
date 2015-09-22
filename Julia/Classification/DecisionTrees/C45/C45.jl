module C45


type TreeNode
    attributeName::AbstractString
    attributeIndex::Integer
    childrens::Dict{Any,TreeNode}
    cutPoint::Float64
    className
end

type C45Config
    minLeafNodeSize::Integer
    maximalDepth::Integer
end


function calculate_attribute_class_entropy(classes,classRange,indexesForAttr)
    attrClassEntropy  =
    nClasses = length(classRange)
    nB = sum(indexesForAttr)
    for c=1:length(classRange)
      #nBC es la cantidad de elementos que tienen el valor x en el attr y son de clase classRange(c)
      indexesForClass = (classes .== classRange[c]) & (indexesForAttr')
      nBC = sum(indexesForClass)
      if (nBC != 0)
          attrClassEntropy -=  (nBC/nB) * (log2(nBC/nB) / log2(nClasses))# for a given class, log base nClasses      RESTICULA
      end
    end #for c in classRange
    return attrClassEntropy
end

function calculate_numeric_attribute_entropy(D::Matrix,i,classes)
    (nAttributes,nExamples) = size(D)
    minimumCutEntropy = typemax(Float64)
    classRange = unique(classes)
    attrRange = sort(unique(D[i,:]))
    minimumCutPoint = 0
    #For every possible cut
    for a=1:length(attrRange)-1
      cutPoint = (attrRange[a] + attrRange[a+1]) / 2.0;
      indexesForAttr = D[i, :] .<= cutPoint;
      #calculate entropy for the given cut point
	    #left and right branches
      cutPointEntropy=0
      for x = [true,false]
        nB = sum(indexesForAttr .== x)
        indexesForAttr = indexesForAttr .== x
        branchEntropy = (nB / nExamples) * calculate_attribute_class_entropy(classes,classRange,indexesForAttr)
        cutPointEntropy = cutPointEntropy + branchEntropy
      end #for x
      if (minimumCutEntropy > cutPointEntropy)
            minimumCutEntropy  = cutPointEntropy
            minimumCutPoint    = cutPoint

      end
      #select the cut point with the least entropy
    end #for a in attrRange
    return (minimumCutEntropy,minimumCutPoint)
end

function calculate_nominal_attribute_entropy(D::Matrix,i,classes)
    attrEntropy = 0
    attrRange = sort(unique(D[i,:]))
    for a=1:length(attrRange)
      indexesForAttr = D[i,:] .== attrRange[a]
      nB = sum(indexesForAttr); #examples with value a in attr
      attrValueEntropy = (nB / nExamples) * calculate_attribute_class_entropy(classes,classRange,indexesForAttr)
      attrEntropy = attrEntropy + attrValueEntropy
    end # for a in attrRange
  return (attrEntropy, attrRange)
end

function select_attribute(D::Matrix,attributeIsNumeric::Array{Bool,1},classes)
    (nAttributes,nPatterns) = size(D)
    classRange  = sort(unique(classes))
    nClasses    = length(classRange)
    attrEntropy = zeros(nAttributes)
    cutPoints   = Array{Any,1}(nAttributes)
    for i=1:nAttributes
        if (attributeIsNumeric[i])
            (attrEntropy[i],cutPoints[i]) = calculate_numeric_attribute_entropy(D,i,classes)
        else
            (attrEntropy[i],cutPoints[i]) = calculate_nominal_attribute_entropy(D,i,classes)
        end
    end
    (entropyMin,indexMin) = findmin(attrEntropy)
    return (entropyMin,indexMin,cutPoints[indexMin])
end

function create_node(D::Matrix,attributeNames,attributeIsNumeric::Array{Bool,1},classes,conf::C45Config)

     if (size(D,2) <= 5) || (length(unique(classes)) <= 1)
       classRange = unique(classes)
       countForClass = zeros(length(classRange))
       i=1
       for class in classRange
           countForClass[i] = sum(classes.==class)
           i=i+1
       end

       treeNode =  TreeNode("", 0, Dict{Any,TreeNode}(), 0,attributeNames[indmax(countForClass)])
    else

      (entropyMin,selectedAttributeIndex,cutPoint) =  select_attribute(D,attributeIsNumeric,classes)

      if (attributeIsNumeric[selectedAttributeIndex])
          treeNode =TreeNode(attributeNames[selectedAttributeIndex], selectedAttributeIndex, Dict{Any,TreeNode}(), cutPoint,"")
          filtered_indexes_less = D[selectedAttributeIndex,:] .<= cutPoint
          filtered_indexes_greater = !filtered_indexes_less

          newDLess                 = copy(D[:,filtered_indexes_less])
          newClassesLess           = classes'[filtered_indexes_less]
          newDGreater              = copy(D[:,filtered_indexes_greater])
          newClassesGreater        = classes'[filtered_indexes_greater]
          #True si el valor es menor igual al punto de corte



              treeNode.childrens[ true ] = create_node(newDLess,attributeNames,attributeIsNumeric,newClassesLess,conf)

          #False si el valor es mayor al punto de corte


            treeNode.childrens[ true ] = create_node(newDGreater,attributeNames,attributeIsNumeric,newClassesGreater,conf)

      else
          treeNode =TreeNode(attributeNames[selectedAttributeIndex], selectedAttributeIndex, Dict{Any,TreeNode}(), 0)
          for attributeValue in cutPoint #cutPoint is attrRange

              attributeValueIdx     = D[selectedAttributeIndex,:].==attributeValue
              columnsIndexes        = 1:size(D,1) .!= selectedAttributeIndex
              newAttributeNames     = attributeNames[attributeValueIdx]
              newAttributeIsNumeric = newAttributeIsNumeric[attributeValueIdx]
              newClasses            = classes'[attributeValueIdx]
              newD                  = copy(D[columnsIndexes,attributeValueIdx])


                treeNode.childrens[ attributeValue ] = create_node(newD, newAttributeNames,newAttributeIsNumeric,newClasses)

          end
      end
    end
    return treeNode
end
function build_model(D::Matrix,attributeNames,attributeIsNumeric::Array{Bool,1},classes,conf::C45Config)
   node =  create_node(D,attributeNames,attributeIsNumeric,classes,conf)
   return node
end
function margin(margin::Integer)

end
function pretty_print(n, margin::Integer)
   if ( n.attributeIndex != 0)
      println(string(repeat(" " ,margin),"Attribute: ",n.attributeName))
      for children in values(n.childrens)
        pretty_print(children,margin+10)
      end
  else
       println(string(repeat(" " ,margin),"Class: ",n.className))
  end

end
 function pretty_print(n)
    pretty_print(n,0)

end
end

push!(LOAD_PATH,dirname(@__FILE__))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../../../Datasets/"))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../../"))
import Datasets
using Datasets
import C45
using C45

(data, labels, label_range) = Datasets.iris()
attributeIsNumeric = collect(repeated(true,size(data,1)))
model = C45.build_model(data,["Sepal-Length", "Sepal-Width", "Petal-Length","Petal-Width"],attributeIsNumeric, labels, C45.C45Config(17,345))
C45.pretty_print(model)
