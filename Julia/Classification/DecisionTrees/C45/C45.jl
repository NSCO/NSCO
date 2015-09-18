type TreeNode
    attributeName::String
    attributeIndex::Integer
    childrens::Dict{Any,TreeNode}
    cutPoint::Float64    
end

type C45Config
    minLeafNodeSize::Integer
    maximalDepth::Integer    
end
function build_model(D::Matrix,attributeIsNumeric::Array{Bool,1},class::Array{Any,1},conf::C45Config)
   
end
    
function calculate_attribute_class_entropy(classes,classRange,indexesForAttr)
    attrClassEntropy  = 0
    for c=1:length(classRange)
      #nBC es la cantidad de elementos que tienen el valor x en el attr y son de clase classRange(c)
      indexesForClass = (classes .== classRange[c]) & (indexesForAttr)
      nBC = sum(indexesForClass)
      if (nBC != 0)
          attrClassEntropy -=  (nBC/nB) * (log2(nBC/nB) / log2(nClasses))# for a given class, log base nClasses      RESTICULA
      end             
    end #for c in classRange
    return attrClassEntropy
end

function calculate_numeric_attribute_entropy(D::Matrix,i,classes)
    minimumCutPoint = typemax(Float64)
    classRange = unique(classes)
    attrRange = sort(unique(D[i,:])) 
    #For every possible cut
    for a=1:length(attrRange)-1
      cutPoint = attrRange[a] + attrRange[a+1] / 2;     
      indexesForAttr = D[i, :] .<= cutPoint;          
      #calculate entropy for the given cut point    
	    #left and right branches
      cutPointEntropy=0
      for x = [true,false]
        nB = sum(indexesForAttr .== x)    
        indexesForAttr = indexesForAttr .== x    
        branchEntropy = (nB / nExamples) * calculate_attribute_class_entropy(classRange,indexesForAttr)
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
      attrValueEntropy = (nB / nExamples) * calculate_attribute_class_entropy(classRange,indexesForAttr)
      attrEntropy = attrEntropy + attrValueEntropy
    end # for a in attrRange             
  return (attrEntropy, attrRange)
end

function select_attribute(D::Matrix,attributeIsNumeric::Array{Bool,1},classes::Array{Any,1})
     (nAttributes,nPatterns) = size(D)
    classRange  = sort(unique(class))
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

function create_node(D::Matrix,attributeNames::Array{String,1},attributeIsNumeric::Array{Bool,1},classes::Array{Any,1},conf::C45Config)
  (entropyMin,selectedAttributeIndex,cutPoint) =  select_attribute(D,attributeIsNumeric,classes)
    if (attributeIsNumeric[selectedAttributeIndex])
        treeNode =TreeNode(attributeNames[selectedAttributeIndex], selectedAttributeIndex, Dict{Any,TreeNode}(), cutPoint)
        filtered_indexes_less = D[selectedAttributeIndex,:] .<= cutPoint
        filtered_indexes_greater = !filtered_indexes_less  
        newDLess                 = copy(D[:,filtered_indexes_less])
        newClassesLess           = classes[filtered_indexes_less]
        newDGreater              = copy(D[:,filtered_indexes_greater])
        newClassesGreater        = classes[filtered_indexes_greater]
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
            newClasses            = classes[attributeValueIdx]
            newD                  = copy(D[columnsIndexes,attributeValueIdx])                        
            
            treeNode.childrens[ attributeValue ] = create_node(newD, newAttributeNames,newAttributeIsNumeric,newClasses)
        end
    end
    return treeNode
end

