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

function benchmark()

    @time rand(Int,1)

    println("SFDP")
    println("SFDP Jagmesh1")
    positions = @time SFDP.layout(jagmesh_adj, Point2f0, tol=0.9, K=1, iterations=10)
    positions = @time SFDP.layout(jagmesh_adj, Point3f0, tol=0.9, K=1, iterations=10)

    println("SFDP Harvard500")
    positions = @time SFDP.layout(harvard_adj, Point2f0, tol=0.9, K=1, iterations=10)
    positions = @time SFDP.layout(harvard_adj, Point3f0, tol=0.9, K=1, iterations=10)

    println("SFDP airtraffic")
    positions = @time SFDP.layout(airtraffic_adj, Point2f0, tol=0.9, K=1, iterations=10)
    positions = @time SFDP.layout(airtraffic_adj, Point3f0, tol=0.9, K=1, iterations=10)

    println("SFDP roadNet")
    positions = @time SFDP.layout(roadnet_adj, Point2f0, tol=0.9, K=1, iterations=10)
    positions = @time SFDP.layout(roadnet_adj, Point3f0, tol=0.9, K=1, iterations=10)

    println("Parallel SFDP")
    println("Parallel SFDP Jagmesh1")
    positions = @time ParallelSFDP.layout(jagmesh_adj, Point2f0, tol=0.9, K=1, iterations=10)
    positions = @time ParallelSFDP.layout(jagmesh_adj, Point3f0, tol=0.9, K=1, iterations=10)

    println("Parallel SFDP Harvard500")
    positions = @time ParallelSFDP.layout(harvard_adj, Point2f0, tol=0.9, K=1, iterations=10)
    positions = @time ParallelSFDP.layout(harvard_adj, Point3f0, tol=0.9, K=1, iterations=10)

    println("Parallel SFDP airtraffic")
    positions = @time ParallelSFDP.layout(airtraffic_adj, Point2f0, tol=0.9, K=1, iterations=10)
    positions = @time ParallelSFDP.layout(airtraffic_adj, Point3f0, tol=0.9, K=1, iterations=10)

    println("Parallel SFDP roadNet")
    positions = @time ParallelSFDP.layout(roadnet_adj, Point2f0, tol=0.9, K=1, iterations=10)
    positions = @time ParallelSFDP.layout(roadnet_adj, Point3f0, tol=0.9, K=1, iterations=10)

    println("Spring")
    println("Spring Jagmesh1")
    positions = @time Spring.layout(jagmesh_adj, Point2f0, C=2.0, iterations=10, initialtemp=2.0)
    positions = @time Spring.layout(jagmesh_adj, Point3f0, C=2.0, iterations=10, initialtemp=2.0)

    println("Spring Harvard500")
    positions = @time Spring.layout(harvard_adj, Point2f0, C=2.0, iterations=10, initialtemp=2.0)
    positions = @time Spring.layout(harvard_adj, Point3f0, C=2.0, iterations=10, initialtemp=2.0)

    println("Spring airtraffic")
    positions = @time Spring.layout(airtraffic_adj, Point2f0, C=2.0, iterations=10, initialtemp=2.0)
    positions = @time Spring.layout(airtraffic_adj, Point3f0, C=2.0, iterations=10, initialtemp=2.0)

    println("Spring roadNet")
    positions = @time Spring.layout(roadnet_adj, Point2f0, C=2.0, iterations=10, initialtemp=2.0)
    positions = @time Spring.layout(roadnet_adj, Point3f0, C=2.0, iterations=10, initialtemp=2.0)

    println("Parallel Spring")

    println("Parallel Spring Jagmesh1")
    positions = @time ParallelSpring.layout(jagmesh_adj, Point2f0, C=2.0, iterations=10, initialtemp=2.0)
    positions = @time ParallelSpring.layout(jagmesh_adj, Point3f0, C=2.0, iterations=10, initialtemp=2.0)

    println("Parallel Spring Harvard500")
    positions = @time ParallelSpring.layout(harvard_adj, Point2f0, C=2.0, iterations=10, initialtemp=2.0)
    positions = @time ParallelSpring.layout(harvard_adj, Point3f0, C=2.0, iterations=10, initialtemp=2.0)

    println("Parallel Spring airtraffic")
    positions = @time ParallelSpring.layout(airtraffic_adj, Point2f0, C=2.0, iterations=10, initialtemp=2.0)
    positions = @time ParallelSpring.layout(airtraffic_adj, Point3f0, C=2.0, iterations=10, initialtemp=2.0)

    println("Parallel Spring roadNet")
    positions = @time ParallelSpring.layout(roadnet_adj, Point2f0, C=2.0, iterations=10, initialtemp=2.0)
    positions = @time ParallelSpring.layout(roadnet_adj, Point3f0, C=2.0, iterations=10, initialtemp=2.0)

end

benchmark()
