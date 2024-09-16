
function empty_conn_df()
    df = DataFrame(
        pre_type = String[],
        pre_layer = Int64[],
        post_type = String[],
        post_layer = Int64[],
        post_compartment = String[],
        prob_func = String[],
        prob_func_p1 = Float64[],
        prob_func_p2 = Float64[],
        str_func = String[],
        str_func_p1 = Float64[],
        str_func_p2 = Float64[],
    )
end
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
