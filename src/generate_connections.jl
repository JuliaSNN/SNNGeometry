
"""
Returns connection strength matrix for all neurons
    df_conn is a dataframe with for each quintuplet (pre_type, pre_layer, post_type, post_layer, post_compartment)
        the function with parameters that give the connection probability and strength distribution
    v is a list of all neurons with their position, type and compartment.
"""
function generate_connections(df_conn, v; sparseM = true)
    N = length(v)
    n = size(df_conn, 1)
    M = zeros(N, N)

    overview = get_neuron_idx_overview(v) #the
    m = size(overview, 1) #number of triplets (type,layer,compartment)

    println("Connecting [type,layer,comp] to [type,layer,comp]")
    k = 0
    for conntype in eachrow(df_conn)
        k += 1
        #find indices of neurons eligible for this connection type
        overview_pre_i = findfirst(
            (overview.Type .== conntype.pre_type)     #note the LHS is a column of overview, while the RHS is a single cell of df_conn
            .& (overview.Layer .== conntype.pre_layer)    # for each of these
            .& (overview.Comp .== "s"),
        )
        overview_post_i = findfirst(
            (overview.Type .== conntype.post_type) .&
            (overview.Layer .== conntype.post_layer) .&
            (overview.Comp .== conntype.post_compartment),
        )

        #the probability function for assigning connection:
        prob_f = select_connection_prob_function(
            conntype.prob_func,
            conntype.prob_func_p1,
            conntype.prob_func_p2,
        )
        #the distribution of the strength of said connection:
        str_d = select_connection_strength_distribution(
            conntype.str_func,
            conntype.str_func_p1,
            conntype.str_func_p2,
        )
        return prob_f

        @printf(
            "\r%3d/%d   %s -> %s",
            k,
            n,
            string(Vector(overview[overview_pre_i, Not("Idx")])),
            string(Vector(overview[overview_post_i, Not("Idx")]))
        )

        ξ = 1 ## Scaling factor for the prob function
        if prob_f != "skip"
            for i in overview.Idx[overview_pre_i]
                for j in overview.Idx[overview_post_i]
                    x = distance(v[i], v[j])
                    if rand() < prob_f(x / ξ) # This should have some sort of scaling factor. Because x is a distance and prob_f should take a number
                        M[i, j] = rand(str_d)
                    end
                end
            end
        end
    end
    @printf("\n")
    if sparseM
        M = sparse(M) #filling up the sparse matrix from the start froze julia, so I only make it sparse in the end.
    end
    return M
end

function select_connection_prob_function(func, p1, p2)
    if func == "N"
        return prob_N(x) = exp(-x^2 / (2 * p1^2)) # 1/(√(2*π)*p1)*
    elseif func == "LN"
        γ = 1 + p2^2 / p1^2
        μ = log(p1 / sqrt(γ))
        σ = sqrt(log(γ))
        return prob_LN(x) = exp(-(log(x) - μ)^2 / (2 * σ^2)) #1/(x*σ*√(2*π))*
    elseif func == "c"
        return prob_constant(x) = p1
    elseif func == "0"
        return "skip"
    else
        error("unknown function with label: ", func)
    end
    return "skip"
end

function select_connection_strength_distribution(func, p1, p2)
    if func == "N"
        d = Distribution.Normal(p1, p2)  #GeometryBasics also exports a "Normal"
    elseif func == "LN"
        d = myLogNormal(p1, p2)
    elseif func == "c"
        d = Distributions.Normal(p1, 0.0) #zero variance normal draws just the mean value.
    elseif func == "0"
        d = "skip"
    else
        error("unknown function with label: ", func)
    end
    return d
end

function myLogNormal(m, std)
    γ = 1 + std^2 / m^2
    μ = log(m / sqrt(γ))
    σ = sqrt(log(γ))

    return LogNormal(μ, σ)
end
