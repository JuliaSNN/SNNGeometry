using DataFrames

import SNNGeometry: get_connection_parameters_from_xlsx
import SNNGeometry: generate_positions
import SNNGeometry: get_neuron_idx_overview
import SNNGeometry: generate_connections
import SNNGeometry: subset_by_type
import SNNGeometry: subset_by_type_and_compartment

println()

#this module can take parameters from an xlsx file.
#calling the function without filename uses the example file "test_input/test.xlsx"
#it returns DataFrames with all relevant parameters.
#you are free to generate these dataframes in other ways than using the xlsx file.
df_conn, df_dens, df_size, df_dend = get_connection_parameters_from_xlsx(
    joinpath(dirname(@__FILE__), "../test_input/newnumbers.xlsx"),
) #or specify a (filename)


#from the parameters we generate positions for all neurons+compartments,
# depending on their layer and type and the densities and dimensions of the layers
v = generate_positions(df_dens, df_size, df_dend)
#entries in this array have the type NeuronPoint, which is a PointMeta type,
#  this is a 3D Point, with the extra 'metadata': type, layer, compartment


#this gives an overview of what numbers in the list correspond to what type,layer,compartment
overview = get_neuron_idx_overview(v)

#this generates a BIG connection matrix for all neurons.
# input is the dataframe of connection types and the array of NeuronPoint s.
# the function uses a lot of memory, but in the end it returns a sparse matrix, freeing up the memory again.
@time M = generate_connections(df_conn, v)

#You can also take only some entries of the connection dataframe and use only those to generate connections.
#df_conn2 = DataFrame( df_conn[176:179,:] )


#print how many connections were made and how many were possible in total.
#println("matrix entries: ", sum(>(0.0),M), " / ", length(M))

#subsetting the matrix into managable parts is done like this:
# I2ToEs  = subset_by_type(M,v, "I2", "Es")
# EpToEpq = subset_by_type_and_compartment(M,v,"Ep","Ep","q")
# I1ToEpp = subset_by_type_and_compartment(M,v,"I1","Ep","p")
