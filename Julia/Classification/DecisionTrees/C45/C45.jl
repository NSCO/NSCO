module C45
export build_model, pretty_print

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
    attributeIsNumeric:: Array{Bool, 1}
    attributeNames:: Array{AbstractString, 1}
    labelNames:: Array{AbstractString, 1}
end

function copy(conf::C45Config)
  return C45Config(conf.minLeafNodeSize, conf.maximalDepth,
    Base.copy(conf.attributeIsNumeric), Base.copy(conf.attributeNames),
    Base.copy(conf.labelNames))
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

function select_attribute(D::Matrix, attributeIsNumeric::Array{Bool,1}, classes)
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

function stopping_condition_met(D, classes, conf, depth)
  return (size(D,2) < conf.minLeafNodeSize) | (length(unique(classes)) == 1) |
         (depth == conf.maximalDepth)
end

function create_node(D::Matrix, classes, conf::C45Config, depth)
    #if (size(D,2) < conf.minLeafNodeSize) || (length(unique(classes)) <= 1)
    if (stopping_condition_met(D, classes, conf, depth))
       #create a leaf node
       #classRange = unique(classes)
       classRange = 1:length(conf.labelNames)
       countForClass = zeros(length(classRange))
       for i=1:length(classRange)
           countForClass[i] = sum(classes .== classRange[i])
       end
       treeNode =  TreeNode("", 0, Dict{Any,TreeNode}(), 0, conf.labelNames[indmax(countForClass)])
    else
      #create an intern node with a child node per attr value
      (entropyMin, selectedAttributeIndex, cutPoint) =  select_attribute(D, conf.attributeIsNumeric, classes)
      if (conf.attributeIsNumeric[selectedAttributeIndex])
          treeNode = TreeNode(conf.attributeNames[selectedAttributeIndex], selectedAttributeIndex, Dict{Any,TreeNode}(), cutPoint, "")
          filtered_indexes_less = D[selectedAttributeIndex,:] .<= cutPoint
          filtered_indexes_greater = !filtered_indexes_less
          newDLess                 = D[:,filtered_indexes_less]
          newClassesLess           = classes'[filtered_indexes_less]
          newDGreater              = D[:,filtered_indexes_greater]
          newClassesGreater        = classes'[filtered_indexes_greater]
          #True si el valor es menor igual al punto de corte
          treeNode.childrens[ true ] = create_node(newDLess, newClassesLess, copy(conf), depth + 1)
          #False si el valor es mayor al punto de corte
          treeNode.childrens[ false ] = create_node(newDGreater, newClassesGreater, copy(conf), depth + 1)
      else
          treeNode =TreeNode(conf.attributeNames[selectedAttributeIndex], selectedAttributeIndex, Dict{Any,TreeNode}(), 0, "")
          for attributeValue in cutPoint #cutPoint is attrRange
              attributeValueIdx     = D[selectedAttributeIndex,:] .== attributeValue
              columnsIndexes        = 1:size(D,1) .!= selectedAttributeIndex
              conf.attributeNames     = conf.attributeNames[columnIndexes]
              conf.attributeIsNumeric = conf.attributeIsNumeric[columnIndexes]
              newClasses            = classes'[attributeValueIdx]
              newD                  = D[columnIndexes, attributeValueIdx]
              treeNode.childrens[ attributeValue ] = create_node(newD, newClasses, copy(conf), depth + 1)
          end
      end
    end
    return treeNode
end

function build_model(D::Matrix, classes, conf::C45Config)
   depth = 0
   node =  create_node(D, classes, copy(conf), depth)
   return node
end

function pretty_print(n, margin::Integer)
   if ( n.attributeIndex != 0) #not a leaf node
     #TODO: distinguish between numeric and nominal in a better way
     if (n.cutPoint == 0) #nominal
       println(string(repeat(" " ,margin),"Attribute: ",n.attributeName))
       #for children in values(n.childrens)
       for key in keys(n.childrens)
         child = n.childrens[key]
         println(string(repeat(" " ,margin), "Branch: ", key))
         pretty_print(child, margin + 4)
       end
     else
       println(string(repeat(" " ,margin),"Attribute: ",n.attributeName))
       #for children in values(n.childrens)
       for key in keys(n.childrens)
         child = n.childrens[key]
         if key
           println(string(repeat(" " ,margin), "Branch: <", n.cutPoint))
         else
           println(string(repeat(" " ,margin), "Branch: >", n.cutPoint))
         end
         pretty_print(child, margin + 4)
       end
     end

  else
       println(string(repeat(" " ,margin),"Class: ",n.className))
  end

end

function pretty_print(n)
    pretty_print(n,0)
end

end
