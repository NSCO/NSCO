module MatrixUtil

function max_index(A)
  ind2sub(size(A), indmax(A))
end

function indmaximum2(A::Array{Float64,2},dim)
  @assert 1<=dim && dim<=2
  s=size(A)
  n=s[dim]
  #other_dim=dim % 2 + 1
  ind=zeros(Int,n)
  for i=1:n
    slice=slicedim(A,dim,i)
    indexes=max_index(vec(slice))
    ind[i]=indexes[1]
  end
  ind
end

function indmaximum(A,dim)
  s=size(A)
  n=s[dim]
  ind=[]
  for i=1:n
    slice=slicedim(A,dim,i)
    indexes=max_index(slice)
    indexes_array=[indexes...]
    splice!(indexes_array,dim)
    push!(ind,indexes_array)
  end
  ind
end


end
