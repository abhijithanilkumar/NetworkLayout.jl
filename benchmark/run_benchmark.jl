using BenchmarkTools
using NetworkLayout.SFDP
using NetworkLayout.Spring
using NetworkLayout.ParallelSFDP
using NetworkLayout.ParallelSpring
using LightGraphs
using GeometryTypes
using DelimitedFiles: readdlm
using SparseArrays: sparse


function jagmesh()
    jagmesh_path = joinpath(dirname(@__FILE__), "jagmesh1.mtx")
    array = round.(Int, open(readdlm, jagmesh_path))
    row = array[:,1]
    col = array[:,2]
    entry = [(1:3600)...]
    sparse(row,col,entry)
end
jagmesh_adj = jagmesh()

function harvard()
    harvard_path = joinpath(dirname(@__FILE__), "Harvard500.mtx")
    array = round.(Int, open(readdlm, harvard_path))
    row = array[:,1]
    col = array[:,2]
    entry = [(1:2636)...]
    sparse(row,col,entry)
end
harvard_adj = harvard()

function airtraffic()
    airtraffic_path = joinpath(dirname(@__FILE__), "airtraffic.mtx")
    array = round.(Int, open(readdlm, airtraffic_path))
    row = array[:,1]
    col = array[:,2]
    entry = [(1:2615)...]
    sparse(row,col,entry)
end
airtraffic_adj = airtraffic()

function roadnet()
    roadnet_path = joinpath(dirname(@__FILE__), "roadNet.mtx")
    array = round.(Int, open(readdlm, roadnet_path))
    row = array[:,1]
    col = array[:,2]
    entry = [(1:1541898)...]
    sparse(row,col,entry)
end
roadnet_adj = roadnet()

function benchmark_graphs()

    # Generic parameters
    trials = 3
    time = 100
    iter = 1000
    point = Point2f0

    # SFDP parameters
    tol = 0.9
    K = 1

    # Spring parameters
    C = 2.0
    temp = 2.0

	results = Array{BenchmarkTools.TrialEstimate, 2}(undef, 2, 3)
	idx = 1

    # println("SFDP")
    # println("SFDP Jagmesh1")
    # @benchmark SFDP.layout($jagmesh_adj, $point, tol=$tol, K=$K, iterations=$iter) samples=trials seconds=time
    #
    # println("SFDP Harvard500")
    # @benchmark SFDP.layout($harvard_adj, $point, tol=$tol, K=$K, iterations=$iter) samples=trials seconds=time
    #
    # println("SFDP airtraffic")
    # @benchmark SFDP.layout($airtraffic_adj, $point, tol=$tol, K=$K, iterations=$iter) samples=trials seconds=time

    #println("SFDP roadNet")
    #positions = @time SFDP.layout(roadnet_adj, Point2f0, tol=0.9, K=1, iterations=10)
    #positions = @time SFDP.layout(roadnet_adj, Point3f0, tol=0.9, K=1, iterations=10)

    println("Parallel SFDP")
    println("Parallel SFDP Jagmesh1")
    result_jag = @benchmark ParallelSFDP.layout($jagmesh_adj, $point, tol=$tol, K=$K, iterations=$iter) samples=trials gcsample=true seconds=time

    println("Parallel SFDP Harvard500")
    result_har = @benchmark ParallelSFDP.layout($harvard_adj, $point, tol=$tol, K=$K, iterations=$iter) samples=trials gcsample=true seconds=time

    println("Parallel SFDP airtraffic")
    result_air = @benchmark ParallelSFDP.layout($airtraffic_adj, $point, tol=$tol, K=$K, iterations=$iter) samples=trials gcsample=true seconds=time

	results[idx, :] = vcat(mean(result_jag), mean(result_har), mean(result_air))
    #println("Parallel SFDP roadNet")
    #positions = @time ParallelSFDP.layout(roadnet_adj, Point2f0, tol=0.9, K=1, iterations=10)
    #positions = @time ParallelSFDP.layout(roadnet_adj, Point3f0, tol=0.9, K=1, iterations=10)

    # println("Spring")
    # println("Spring Jagmesh1")
    # @benchmark Spring.layout($jagmesh_adj, $point, C=$C, iterations=$iter, initialtemp=$temp)
    #
    # println("Spring Harvard500")
    # @benchmark Spring.layout($harvard_adj, $point, C=$C, iterations=$iter, initialtemp=$temp)
    #
    # println("Spring airtraffic")
    # @benchmark Spring.layout($airtraffic_adj, $point, C=$C, iterations=$iter, initialtemp=$temp)

    #println("Spring roadNet")
    #positions = @time Spring.layout(roadnet_adj, Point2f0, C=2.0, iterations=10, initialtemp=2.0)
    #positions = @time Spring.layout(roadnet_adj, Point3f0, C=2.0, iterations=10, initialtemp=2.0)

    println("Parallel Spring")

    println("Parallel Spring Jagmesh1")
    result_jag = @benchmark ParallelSpring.layout($jagmesh_adj, $point, C=$C, iterations=$iter, initialtemp=$temp) samples=trials gcsample=true seconds=time

    println("Parallel Spring Harvard500")
    result_har = @benchmark ParallelSpring.layout($harvard_adj, $point, C=$C, iterations=$iter, initialtemp=$temp) samples=trials gcsample=true seconds=time

    println("Parallel Spring airtraffic")
    result_air = @benchmark ParallelSpring.layout($airtraffic_adj, $point, C=$C, iterations=$iter, initialtemp=$temp) samples=trials gcsample=true seconds=time

	results[idx + 1, :] = vcat(mean(result_jag), mean(result_har), mean(result_air))
    #println("Parallel Spring roadNet")
    #positions = @time ParallelSpring.layout(roadnet_adj, Point2f0, C=2.0, iterations=10, initialtemp=2.0)
    #positions = @time ParallelSpring.layout(roadnet_adj, Point3f0, C=2.0, iterations=10, initialtemp=2.0)

	@everywhere GC.gc()

	for result in results
		@show result
	end

	results
end

benchmark_graphs()
