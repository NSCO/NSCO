module DecisionTree
using Distributions
export build_model, pretty_print

abstract AbstractTreeNode

type LeafTreeNode <: AbstractTreeNode
    labelName::AbstractString
    label::Integer
    countForClass::Array{Int,1}
end

type InternalNominalTreeNode <:  AbstractTreeNode
    attributeName::AbstractString
    attributeIndex::Integer
    children::Dict{Any, AbstractTreeNode}
    countForClass::Array{Int,1}
end

type InternalNumericTreeNode <:AbstractTreeNode
    attributeName::AbstractString
    attributeIndex::Integer
    children::Dict{Any, AbstractTreeNode}
    cutPoint::Float64
    countForClass::Array{Int,1}
end
abstract AttributeSelectionMethod
type RandomAttributeSelection <: AttributeSelectionMethod
end
type C45AttributeSelection <: AttributeSelectionMethod
end
type Config
    minLeafNodeSize::Integer
    maximalDepth::Integer
    attributeIsNumeric:: Array{Bool, 1}
    attributeNames:: Array{AbstractString, 1}
    labelNames:: Array{AbstractString, 1}
    confidenceLevel::Float64
    attributeSelection::AttributeSelectionMethod
end

type Model
  tree::AbstractTreeNode
  conf::Config
end

#=function copy(conf::Config)
  return Config(conf.minLeafNodeSize, conf.maximalDepth,
    Base.copy(conf.attributeIsNumeric), Base.copy(conf.attributeNames),
    Base.copy(conf.labelNames),
    conf.confidenceLevel)
end=#


function calculate_attribute_class_entropy(classes,classRange,indexesForAttr)
    attrClassEntropy  = 0
    nClasses = length(classRange)
    nB = sum(indexesForAttr)
    for c=1:length(classRange)
      #nBC es la cantidad de elementos que tienen el valor x en el attr y son de clase classRange[c]
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

function select_attribute(D::Matrix, attributeIsNumeric::Array{Bool,1}, classes, conf::C45AttributeSelection)
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

function get_label_histogram(labelNames::Vector{AbstractString}, classes)
  classRange = 1:length(labelNames)
  countForClass = zeros(length(classRange))
  for i=1:length(classRange)
      countForClass[i] = sum(classes .== classRange[i])
  end
  return countForClass
end

function create_node(D::Matrix, classes, conf::Config, depth)
    countForClass = get_label_histogram(conf.labelNames, classes)
    if (stopping_condition_met(D, classes, conf, depth))
       #create a leaf node
       selectedIndex = indmax(countForClass)
       treeNode =  LeafTreeNode(conf.labelNames[selectedIndex], selectedIndex, countForClass)
    else
      #create an internal node with a child node per attr value
      (entropyMin, selectedAttributeIndex, cutPoint) =  select_attribute(D, conf.attributeIsNumeric, classes,conf.attributeSelection)
      if (conf.attributeIsNumeric[selectedAttributeIndex])
          treeNode = InternalNumericTreeNode(conf.attributeNames[selectedAttributeIndex], selectedAttributeIndex, Dict{Any,AbstractTreeNode}(), cutPoint, countForClass)
          filtered_indexes_less = D[selectedAttributeIndex,:] .<= cutPoint
          filtered_indexes_greater = !filtered_indexes_less
          newDLess                 = D[:,filtered_indexes_less]
          newClassesLess           = classes'[filtered_indexes_less]
          newDGreater              = D[:,filtered_indexes_greater]
          newClassesGreater        = classes'[filtered_indexes_greater]
          #True si el valor es menor igual al punto de corte
          treeNode.children[ true ] = create_node(newDLess, newClassesLess, deepcopy(conf), depth + 1)
          #False si el valor es mayor al punto de corte
          treeNode.children[ false ] = create_node(newDGreater, newClassesGreater, deepcopy(conf), depth + 1)
      else
          treeNode = InternalNominalTreeNode(conf.attributeNames[selectedAttributeIndex], selectedAttributeIndex, Dict{Any,AbstractTreeNode}(), countForClass)
          for attributeValue in cutPoint #cutPoint is attrRange
              attributeValueIdx     = D[selectedAttributeIndex,:] .== attributeValue
              columnsIndexes        = 1:size(D,1) .!= selectedAttributeIndex
              conf.attributeNames     = conf.attributeNames[columnIndexes]
              conf.attributeIsNumeric = conf.attributeIsNumeric[columnIndexes]
              newClasses            = classes'[attributeValueIdx]
              newD                  = D[columnIndexes, attributeValueIdx]
              treeNode.children[ attributeValue ] = create_node(newD, newClasses, deepcopy(conf), depth + 1)
          end #is nominal
      end # is not leaf
      childrenHistograms = [ node.countForClass::Vector{Int} for node in values(treeNode.children)]
      (errorParent, errorChild) = compare_parent_and_children(treeNode.countForClass,childrenHistograms,conf.confidenceLevel)
      if (errorParent < errorChild)
        selectedIndex = indmax(treeNode.countForClass)
        treeNode = LeafTreeNode(conf.labelNames[selectedIndex], selectedIndex, treeNode.countForClass)
      end
    end
    return treeNode
end

function build_model(D::Matrix, classes, conf::Config)
   depth = 0
   node =  create_node(D, classes, deepcopy(conf), depth)
   return Model(node, conf)
end

function pretty_print(n::LeafTreeNode,margin::Integer)
      println(string(repeat(" " ,margin),"Class: ",n.labelName))
end

function pretty_print(n::InternalNumericTreeNode,margin::Integer)
    println(string(repeat(" " ,margin),"Attribute: ", n.attributeName))
   for key in keys(n.children)
     child = n.children[key]
     if key
       println(string(repeat(" " ,margin), "Branch: <= ", n.cutPoint))
     else
       println(string(repeat(" " ,margin), "Branch: > ", n.cutPoint))
     end
     pretty_print(child, margin + 4)
   end
 end


function pretty_print(n::InternalNominalTreeNode,margin::Integer)
    println(string(repeat(" " ,margin),"Attribute: ", n.attributeName))
     #for children in values(n.childrens)
     for key in keys(n.children)
       child = n.children[key]
       println(string(repeat(" " ,margin), "Branch: ", key))
       pretty_print(child, margin + 4)
     end
end



function pretty_print(n)
    pretty_print(n,0)
end


function classify_example(example, tree::LeafTreeNode, conf::Config)
    return tree.label
end

function classify_example(example, tree::InternalNumericTreeNode, conf::Config)
    attrIndex = find(conf.attributeNames .== tree.attributeName)
    attrIndex = attrIndex[1]
    goLeft = example[attrIndex] <= tree.cutPoint
    child = tree.children[goLeft]
    return classify_example(example, child, conf)
end

function classify_example(example, m::Model)
  return classify_example(example, m.tree, m.conf)
end

function classify_example(example, tree::InternalNominalTreeNode, conf::Config)
    attrIndex = find(conf.attributeNames .== tree.attributeName)
    attrIndex = attrIndex[1]
    if haskey(tree.children, example[attrIndex])
      child = tree.children[example[attrIndex]]
      return classify_example(example, child, conf)
    else
      return 0 #value not found, output unknown prediction
    end
end

function classify(data::Matrix, model::Model)
  (nAttrs, nExamples) = size(data)
  predictions = zeros(Int, nExamples)
  for i=1:nExamples
    predictions[i] = classify_example(data[:,i], model)
  end
  return predictions
end
function error_estimation()

  num1=f+((z^2)/(2*N))
  num2=(f/N) - ((f*f)/N)+ (z*z)/(4*(N^2))
  numerador = num1+z*sqrt(num2)
  denominador = 1 + (z*z)/N
  return numerador/denominador
end

function error_upper_bound(e::Integer, n::Integer, c::Float64)
  # e is the number of successes (or failures)
  # n is the number of runs of the experiment (size of the sample)
  #f = e/n is the proportion of successes (or failures)
  # 1 - c is the confidence level of the test
  # P (x < z) = 1 - c
  # or
  # P (x > z) = c
  f = e/n
  z = (quantile(Normal(), 1-c))
  return (f + (z*z / 2n) + z * sqrt(f*(1-f)/n + z*z/(4n*n))) / (z*z/n + 1)
end

function classification_error(label_hist::Array{Int,1}, c::Float64)
  selected_label = indmax(label_hist)
  sample_size = sum(label_hist)
  errors = sample_size - label_hist[selected_label]
  error_proportion = errors / sample_size
  return (error_proportion, error_upper_bound(errors, sample_size, c))
end

function compare_parent_and_children(parent::Array{Int,1}, children::Vector{Vector{Int}}, c::Float64)
  #parent and all children are lists with the quantities of elements for each label
  #all list measure the same
  #it is assumed that the sum of all children are equal to the parent.
  (parent_error, parent_error_estimate) = classification_error(parent, c)
  children_error = zeros(length(children))
  partition_error = 0 #weighted sum of all children error
  for i=1:length(children)
    child = children[i]
    (error, estimate) = classification_error(child, c)
    children_error[i] = estimate
    partition_error += (sum(child)) * children_error[i]
  end
  partition_error /= sum(parent)
  (parent_error_estimate, partition_error)
end

function treeSize(treeNode::LeafTreeNode)
  return 1
end

function treeSize(treeNode::AbstractTreeNode)
    suma = 1
    for (key, child) in treeNode.children
        suma = suma + treeSize(child)
    end
    return suma
end

end
