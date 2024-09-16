using Logging

function get_connection_parameters_from_xlsx()
    fn = joinpath(dirname(@__FILE__), "../../test_input/test.xlsx")
    get_connection_parameters_from_xlsx(fn)
end

function get_connection_parameters_from_xlsx(fn)
    xf = XLSX.readxlsx(fn)

    #Connectivity
    conn_sheet = xf["Connectivity"]
    nrow, ncol = size(conn_sheet[:])

    col_type_idx = findall(
        !ismissing,
        conn_sheet[string("A1:", number_to_xlxs_column_name(ncol), 1)][:],
    )
    col_layer_idx = findall(
        !ismissing,
        conn_sheet[string("A2:", number_to_xlxs_column_name(ncol), 2)][:],
    )
    col_comp_idx = findall(
        !ismissing,
        conn_sheet[string("A3:", number_to_xlxs_column_name(ncol), 3)][:],
    )
    row_type_idx = findall(!ismissing, conn_sheet[string("A1:A", nrow)][:])
    row_layer_idx = findall(!ismissing, conn_sheet[string("B1:B", nrow)][:])
    types = conn_sheet[string("A1:", number_to_xlxs_column_name(ncol), 1)][col_type_idx]
    layers = conn_sheet[string("A2:", number_to_xlxs_column_name(ncol), 2)][col_layer_idx]
    comps = conn_sheet[string("A3:", number_to_xlxs_column_name(ncol), 3)][col_comp_idx]

    function parse_conn_pos(i, j)
        pre_type = types[findlast(<=(i), row_type_idx)]
        pre_layer = layers[findlast(<=(i), row_layer_idx)]  # if we want string type layers ever again put string() around this
        post_type = types[findlast(<=(j), col_type_idx)]
        post_layer = layers[findlast(<=(j), col_layer_idx)]  # and here
        post_comp = comps[findlast(<=(j), col_comp_idx)]

        return pre_type, pre_layer, post_type, post_layer, post_comp
    end

    df_conn = empty_conn_df()
    nrow = row_layer_idx[end] #don't consider comments under table anymore
    topleft = 4, 3
    botright = nrow, ncol
    for i = topleft[1]:botright[1]
        for j = topleft[2]:botright[2]
            push!(df_conn, [parse_conn_pos(i, j)..., parse_conn_entry(conn_sheet[i, j])...])
        end
    end

    @info "Importing connectivity map from: $fn"
    # df_dens = XLSX.readtable(fn, "Density",infer_eltypes=true)
    # @warn "Table: df_dens"
    # return df_dens

    #now for the Dataframes of Density and Layer Sizes
    df_dens = DataFrame(XLSX.readtable(fn, "Density", infer_eltypes = true))
    df_size = DataFrame(XLSX.readtable(fn, "Layer Sizes", infer_eltypes = true))
    df_dend = DataFrame(XLSX.readtable(fn, "Dendrites", infer_eltypes = true))

    return df_conn, df_dens, df_size, df_dend
end



function parse_conn_func(s2)    #parses "XX(a,b"                        ## or "c"       ## or "b(10)"
    func = "0"
    p1 = 0
    p2 = 0

    s3 = split(s2, "(")       ## s3 = "XX","a,b"                      ## s3 = "c"     ## s3 = "b","10"
    func = s3[1]
    if length(s3) > 1             ## if the "a,b" part is there
        s4 = split(s3[2], ",")
        p1 = parse(Float64, s4[1])
        if length(s4) > 1
            p2 = parse(Float64, s4[2])
        end
    end
    return func, p1, p2
end

function parse_conn_entry(s)
    prob_func = "0"
    prob_func_p1 = 0
    prob_func_p2 = 0
    str_func = "0"
    str_func_p1 = 0
    str_func_p2 = 0
    if !in(s, ["0", 0, 0.0])           ## s = "XX(a,b), YY(c,d)""              ## s = "c"      ## s = "b(10)"
        s2 = split(s, ")")           ## s2 = "XX(a,b", ", YY(c,d", ""        ## s2 = "c"     ## s2 = "b(10", ""
        #get prob fun
        prob_func, prob_func_p1, prob_func_p2 = parse_conn_func(s2[1])
        #get str func
        if length(s2) > 1
            s2[2] = s2[2][2:end] #removes comma
            if s2[2][1] == ' '
                s2[2] = s2[2][2:end] #removes space
            end
            str_func, str_func_p1, str_func_p2 = parse_conn_func(s2[2])
        end
    end
    return prob_func, prob_func_p1, prob_func_p2, str_func, str_func_p1, str_func_p2
end

function number_to_xlxs_column_name(i)
    if i > 27 * 26
        error("function number_to_xlxs_column_name(i) only defined up to i=27*26=", 27 * 26)
    end

    d, r = (i - 1) ÷ 26, mod1(i, 26)

    ab = [
        "A",
        "B",
        "C",
        "D",
        "E",
        "F",
        "G",
        "H",
        "I",
        "J",
        "K",
        "L",
        "M",
        "N",
        "O",
        "P",
        "Q",
        "R",
        "S",
        "T",
        "U",
        "V",
        "W",
        "X",
        "Y",
        "Z",
    ]
    if d == 0
        return ab[r]
    else
        return string(ab[d], ab[r])
    end
end




# connections
#end up with datastruct
# pre_type,
# pre_layer,
# post_type,
# post_layer,
# post_compartment,
# prob_func,
# prob_func_p1,
# prob_func_p2,
# str_func,
# str_func_p1,
# str_func_p2,

# density
# datastruct
# type layer dens (neurons/mm^3)

# space
# layer x y z (mm)
