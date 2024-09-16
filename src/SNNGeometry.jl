module SNNGeometry

using GeometryBasics
using DataFrames
using LinearAlgebra
using Distributions
using Printf
using SparseArrays
using XLSX

#set up the NeuronPoint type
prototype = meta(Point(0.0, 0.0, 0.0), type = "Ep", layer = 1, comp = "s")
NeuronPoint = typeof(prototype) #the type of our neurons. a 3D Point with metadata type,layer,compartment
import Base.zero
Base.zero(::Type{NeuronPoint}) = prototype   #zeros(NeuronPoint,n) now works :)

include("handle_input/conn_DataFrame.jl")
include("handle_input/from_xlsx.jl")
include("generate_positions.jl")
include("distance.jl")
include("generate_connections.jl")
include("subsetting.jl")
include("flatten.jl")


greet() = zeros(NeuronPoint, 3)

end # module
