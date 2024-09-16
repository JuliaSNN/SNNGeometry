

function subset_by_type_and_compartment(M, v, preType, postType, postCompartment)
    ov = get_neuron_idx_overview(v)

    #find indices of neurons eligible for this connection type
    ovPrei = findall((ov.Type .== preType)     #note the LHS is a column of overview, while the RHS is a single string
    .& (ov.Comp .== "s"))
    ovPosti = findall((ov.Type .== postType) .& (ov.Comp .== postCompartment))
    #findall because it finds entries for multiple layers, and we want to merge that

    if isempty(ovPrei) || isempty(ovPosti)
        error(
            "could not find neurons to subset from M.\novPrei = ",
            ovPrei,
            "\novPosti = ",
            ovPosti,
        )
    end

    #get the neuron indices from the vector of ranges
    iPre = vcat(ov.Idx[ovPrei]...)
    jPost = vcat(ov.Idx[ovPosti]...)

    return M[iPre, jPost]
end

function subset_by_type(M, v, preType, postType)
    ov = get_neuron_idx_overview(v)

    #find indices of neurons eligible for this connection type
    ovPrei = findall((ov.Type .== preType)     #note the LHS is a column of overview, while the RHS is a single string
    .& (ov.Comp .== "s"))
    ovPosti = findall((ov.Type .== postType))
    #findall because it finds entries for multiple layers, and we want to merge that

    if isempty(ovPrei) || isempty(ovPosti)
        error(
            "could not find neurons to subset from M.\novPrei = ",
            ovPrei,
            "\novPosti = ",
            ovPosti,
        )
    end

    #get the neuron indices from the vector of ranges
    iPre = vcat(ov.Idx[ovPrei]...)
    jPost = vcat(ov.Idx[ovPosti]...)

    return M[iPre, jPost]
end

"""
Create a Dictionary, with String => SparseMatrix type,
that holds connectivity matrices for each (preType,postType,postCompartment) triplet.
(or pairs without the compartment for non-tripod postTypes.)

The keys are single strings formatted as:
preType* "To" *postType*postCompartment

d = create_subset_dict(M,v,types=["Ep","Es","I1","I2"], tripodTypes=["Ep"])
"""
function create_subset_dict(M, v, types = ["Ep", "Es", "I1", "I2"], tripodTypes = ["Ep"])
    d = Dict{String,SparseMatrixCSC{Float64,Int64}}()
    s = sc = ""
    compartments = ["q", "p", "s"]
    for pre in types
        for post in types
            s = pre * "To" * post
            if post in tripodTypes
                for comp in compartments
                    sc = s * comp
                    d[sc] = subset_by_type_and_compartment(M, v, pre, post, comp)
                end
            else
                d[s] = subset_by_type(M, v, pre, post)
            end
        end
    end
    return d
end
