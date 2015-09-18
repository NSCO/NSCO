module TextTools
export ocurrencematrix,vector_representation,bagofwords
function fullstrip(s::String, r::String)
    replace(s, Set(r), "")
end
function strip(s::String)
  testr = ",!/\\().?¿!"
  return lowercase(fullstrip(s,testr))
end
function bagofwords(data)
   nrows= length(data)
   bag_of_words = Set{String}()
  for i in 1:nrows
     for word in split(strip(data[i]),' ')
        push!(bag_of_words, word)
     end
  end
  return collect(bag_of_words)
end
function vector_representation(text::String,bag_of_words)
     words = split(strip(text),' ')
     indexes = findin(bag_of_words,words)
     ocurrence = zeros(1, length(bag_of_words))
     ocurrence[indexes]=1
     return ocurrence'
end
function ocurrencematrix(data, bag_of_words)
  nrows = length(data)
  ocurrence = zeros( length(bag_of_words),nrows)
   for i in 1:nrows     
     ocurrence[:,i]=vector_representation(data[i], bag_of_words)  
   end
   return ocurrence
end
end
