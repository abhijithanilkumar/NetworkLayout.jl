"""
    Use the spring/repulsion model of Fruchterman and Reingold (1991):
        Attractive force:  f_a(d) =  d^2 / k
        Repulsive force:  f_r(d) = -k^2 / d
    where d is distance between two vertices and the optimal distance
    between vertices k is defined as C * sqrt( area / num_vertices )
    where C is a parameter we can adjust

    Arguments:
    adj_matrix    Adjacency matrix of some type. Non-zero of the eltype
                  of the matrix is used to determine if a link exists,
                  but currently no sense of magnitude
    C             Constant to fiddle with density of resulting layout
    iterations    Number of iterations we apply the forces
    initialtemp   Initial "temperature", controls movement per iteration
"""
module ParallelSpring

using SharedArrays
using Distributed
using GeometryTypes
using LinearAlgebra: norm

struct Layout{M<:SharedArray, P<:SharedArray, F<:SharedArray, T<:AbstractFloat}
  adj_matrix::M
  positions::P
  force::F
  C::T
  iterations::Int
  initialtemp::T
end

function Layout(
        adj_matrix,
        PT::Type{Point{N,T}}=Point{2, Float64};
        startpositions=(2*rand(PT, size(adj_matrix,1)) .- 1),
        C=2.0, iterations=100, initialtemp=2.0
    ) where {N, T}
    nodes = size(adj_matrix, 1)
    Layout(SharedArray(Matrix(adj_matrix)), SharedArray(startpositions), SharedArray(zeros(PT, nodes)), T(C), Int(iterations), T(initialtemp))
end

layout(adj_matrix, dim::Int; kw_args...) = layout(adj_matrix, Point{dim,Float64}; kw_args...)

function layout(
        adj_matrix, PT::Type{Point{N,T}}=Point{2, Float64};
        startpositions = (2*rand(PT, size(adj_matrix,1)) .- 1),
        kw_args...
    ) where {N, T}
    layout!(adj_matrix,startpositions;kw_args...)
end

function layout!(
         adj_matrix,
         startpositions::AbstractVector{Point{N,T}};
         kw_args...
    ) where {N, T}
    size(adj_matrix, 1) != size(adj_matrix, 2) && error("Adj. matrix must be square.")
    # Layout object for the graph
    network = Layout(adj_matrix, Point{N,T}; startpositions=startpositions, kw_args...)
    next = iterate(network)
    while next != nothing
        (i, state) = next
        next = iterate(network, state)
    end

    #cleanup SharedArrays
    cleanup_shared(network.adj_matrix)
    cleanup_shared(network.force)

    return network.positions
end

function iterate(network::Layout)
   network.iterations == 1 && return nothing
   return network, 1
end

function iterate(network::Layout{M, P, F, T}, state) where {M, P, F, T}
    # The optimal distance bewteen vertices
    adj_matrix = network.adj_matrix
    N = size(adj_matrix,1)
    force = network.force
    fill!(force, zero(eltype(F)))
    locs = network.positions
    C = network.C
    iterations = network.iterations
    initialtemp = network.initialtemp
    N = size(adj_matrix,1)
    K = C * sqrt(4.0 / N)

    @sync begin
           for p in procs(adj_matrix)
               @async remotecall_wait(compute_force!, p, adj_matrix, locs, force, K, N)
           end
    end

    # Cool down
    temp = initialtemp / state

    @sync begin
           for p in procs(force)
               @async remotecall_wait(compute_locs!, p, force, temp, locs)
           end
    end

    network.iterations == state && return nothing
    return network, (state+1)
end

function loop_range(adj_matrix)
    nchunks = length(procs(adj_matrix))
    idx = indexpids(adj_matrix)
    if idx == 0
        return 1, 1
    end
    splits = [round(Int, s) for s in range(0, stop=size(adj_matrix,1), length=nchunks+1)]
    return splits[idx]+1,splits[idx+1]
end

function compute_force!(adj_matrix, locs, force, K, N)
    start_i, end_i = loop_range(adj_matrix)
    Ftype = eltype(force)
    for i in start_i:end_i
        force_vec = Ftype(0)
        for j = 1:N
            i == j && continue
            d   = norm(locs[j]-locs[i])
            if adj_matrix[i,j] != zero(eltype(adj_matrix)) || adj_matrix[j,i] != zero(eltype(adj_matrix))
                F_d = d / K - K^2 / d^2
            else
                F_d = -K^2 / d^2
            end
            force_vec += Ftype(F_d*(locs[j]-locs[i]))
        end
        force[i] = force_vec
    end
end

function compute_locs!(force, temp, locs)
    start_i, end_i = loop_range(force)
    for i in start_i:end_i
        force_mag  = norm(force[i])
        scale      = min(force_mag, temp)/force_mag
        locs[i]   += force[i] * scale
    end
end

function cleanup_shared(shared_array)
    foreach(shared_array.refs) do r
        @spawnat r.where finalize(fetch(r))
    end
    finalize(shared_array.s)
    finalize(shared_array)
end

end #end of module
