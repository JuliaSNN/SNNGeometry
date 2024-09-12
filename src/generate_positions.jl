

function generate_positions(df_dens,df_size, df_dend)

    LayerDims = Vector{NeuronPoint}(undef,3)
    for i=1:3
        LayerDims[i] = meta( Point(Vector(df_size[i,Not("Layer")])...), type="Ep",layer=df_size[i,"Layer"],comp="s")
    end

    #this block just checks some numbers
    Volume_per_Layer = [p[1]*p[2]*p[3] for p in LayerDims]
    Density_per_Layer= zeros(3)
    Density_per_Type= Dict{String,Float64}("Ep"=>0,"Es"=>0,"I1"=>0,"I2"=>0)
    for ro in eachrow(df_dens)
        Density_per_Layer[ ro["Layer"] ] += ro["Density (neurons/mm^3)"]
    end
    for ro in eachrow(df_dens)
        Density_per_Type[ ro["Type"] ] += ro["Density (neurons/mm^3)"]
    end
    TotalNeurons = round(Int,dot(Volume_per_Layer,Density_per_Layer))
    TotalCompartments = round(Int,sum(Volume_per_Layer)/3*(3*Density_per_Type["Ep"]+Density_per_Type["Es"]+Density_per_Type["I1"]+Density_per_Type["I2"]))
    println("TotalNeurons = ",TotalNeurons)
    println("TotalCompartments = ",TotalCompartments)

    #This block generates the positions
    #for each layer and each type, generate positions
    v = zeros(NeuronPoint,TotalCompartments)
    dens = 10000
    xr,yr,zr = 1.0,1.0,1.0 #(mm)
    distr = Product([Uniform(0,xr),Uniform(0,yr),Uniform(0,zr)])
    i=1; j=0
    #z = zeros(NeuronPoint,1000)
    for ro in eachrow(df_dens)
        l = ro["Layer"]
        t = ro["Type"]
        dens = ro["Density (neurons/mm^3)"]
        xr,yr,zr = LayerDims[l][1:3]

        #easy way to fill space is to just fix the number of neurons used
        distr = Product([Uniform(0,xr),Uniform(0,yr),Uniform(0,zr)])
        n = round(Int,xr*yr*zr*dens) #number of this type in this layer

        #generate
        v[i:i+n-1] .= meta.(  Point3.([xyz for xyz in eachcol(rand(distr,n))]) , type=t,layer=l,comp="s" )

        if t=="Ep" #pyramidal neurons get compartments with locations
            for r in eachrow(df_dend)
                j+=n
                comp = r["Compartment"]
                len = r["Length"]
                ϕ   = r["Angle"]/180*π
                θ   = rand(Uniform(0,2π),n)
                r   = len*sin(ϕ)

                v[i+j:i+j+n-1] .= meta.(      Point.(v[i:i+n-1])
                                          .+ Point3.([ [r*sin(θθ),r*cos(θθ),len*cos(ϕ)] for θθ in θ])
                                        , type = t, layer=l, comp = comp
                                       )
            end
        end
        i+=n+j
        j=0
    end

    v
end

"""
    returns Dataframe with index ranges of each (type,layer,compartment) triplet from list of all neurons v
"""
function get_neuron_idx_overview(v)
    df = DataFrame( Idx = UnitRange{Int64}[],
                    Type = String[],
                    Layer= Int64[],
                    Comp = String[],
                )

    i=1;j=0;i_old=1
    oldmeta = meta(v[1])
    n = length(v)
    for i=1:n
        if meta(v[i])!=oldmeta
            push!(df, [i_old:i-1, oldmeta.type, oldmeta.layer, oldmeta.comp])
            i_old = i
            oldmeta = meta(v[i])
        end
    end
    push!(df, [i_old:n, v[n].type, v[n].layer, v[n].comp])
    df
end
