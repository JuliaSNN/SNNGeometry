### A Pluto.jl notebook ###
# v0.18.2

using Markdown
using InteractiveUtils

# ╔═╡ 6f9960b0-da05-4d3b-b02a-f57e1f1581d0
begin
    import Pkg
    # careful: this is _not_ a reproducible environment
    # activate the global environment
    Pkg.activate()
end

# ╔═╡ 3f996ea4-c951-4337-ad46-6f0fba7bc9fd
begin
    include("/home/dicbro/Coding/NetGeo/src/NetGeo.jl")
    import .NetGeo
end

# ╔═╡ 44011e78-9f1a-44ef-ab78-3c9354bb56a6
md"""
# NetGeo.jl

The point of this package is to generate the connectivity matrix of a customly parametrized neocortical microcolumn with multiple types of neurons, including point neurons and tripod neurons.

## The distribution of neurons.

The microcolumn consists of different layers each with their own distribution of neurontypes. We first define the spatial dimensions of the layers. Then we want to fill this space with neurons of different types. The neurons are uniformly distributed, but with densities dependend on type and layer.

```math
\displaylines{
\text{type} \times \text{layer} \rightarrow \text{density}
}
```
With 4 types and 3 layers, we have 12 densities to specify. This is easy to parametrize.

## The connections
With the neurons placed, we want them to form connections. The connection probability is distance dependent, but also dependent on the types of neurons involved, the layer they are in, and whether the synapse is formed close to the soma or onto a dendritic compartment of the tripod model. For connections that are established, the synaptic strength should also be specified, or taken from a distribution that can be dependent on the same set as the connection probability. 

```math
\displaylines{
\text{pre\_type} \times \text{pre\_layer} \times \text{post\_type} \times \text{post\_layer} \times \text{post\_compartment}\\
\rightarrow\\
\text{connection\_prob\_function\_with\_parameters} \times \text{synamptic\_strength\_distribution\_with\_parameters}
}
```
With 4 neuron types, one of which is a tripod, and 3 layers, there are 216 combinations for which we want to specify the connection probability and strength distribution functions with their parameters. With so many parameters one can quickly lose track of entries in a big parameter file, so I decided to make a paramter matrix in an excel file: [link](https://docs.google.com/spreadsheets/d/e/2PACX-1vQoo9gpPxNX3rpSFzlmIsnZ_HA76RcpvC7BR_tmoeEcRqrJnIXcKodWxnApLGliO2Qf_ENtF51t0oE8/pub?output=xlsx)


"""




# ╔═╡ ea33e652-9b4a-40f3-bbf7-061f725b91ba
md"## Code Example"

# ╔═╡ fb7f7442-ea00-4d1b-8747-7869110ef409
md"
First let's load all parameters from the excel file into DataFrames that the rest of the module understands:
"

# ╔═╡ fa7a0865-4ff9-45d3-b845-359022370d1d
df_conn, df_dens, df_size, df_dend = NetGeo.get_connection_parameters_from_xlsx(
    "/home/dicbro/Coding/NetGeo/test_input/newnumbers.xlsx",
)


# ╔═╡ eaba4c42-499a-4bc4-a5b3-51d0d1ef19a8
md"The naming convention for the compartments of the tripod neuron are q,p and s:"

# ╔═╡ fd51545b-4062-446f-8c62-86ca82e6b412
md"""![qps](https://i.imgur.com/exUu6Wv.png)"""

# ╔═╡ 892f73a7-49d9-4144-83e1-5bc9878609d2
md"The following function takes the density and layer dimension dataframes and generates the neuron positions. It returns an array of NeuronPoints, which are points with metadata 'type', 'layer', 'compartment'."

# ╔═╡ b0d13692-ef8c-4e1d-9eb9-84226a621444
v = NetGeo.generate_positions(df_dens, df_size, df_dend)

# ╔═╡ 3879f7d0-58ac-4eaa-ba82-c0603954c20f
begin
    using GeometryBasics
    meta.(v)
end

# ╔═╡ 359e5ac5-922b-4a38-9984-9978b0ab4f99
md"To show the metadata you can use `v[1].type`, `v[1].layer` and `v[1].comp`, or to access it all at once:"

# ╔═╡ 80c3be02-e3cb-4df9-b40d-08c8c370fe05
md"The following function gives you the index ranges for each neuron type/layer/comp:"

# ╔═╡ 6262f209-a1f3-4c60-8581-207061cbf795
overview = NetGeo.get_neuron_idx_overview(v)

# ╔═╡ f55c27f6-bc88-4387-84c6-6b24689cfb0b
md"You pass only the NeuronPoint array to other functions, but get_neuron_idx_overview is called internally often."

# ╔═╡ 2335acaf-13c0-40bd-94c1-f0f60f253aca
md"""### Generate all connections
This function takes the connection parameter DataFrame and the list of neurons. It then generates all connections based on the specified functions and distances. It takes a while and it takes a lot of memory, but at least you get the memory back as the function converts the connection matrix to a SparseArray in the end.
"""

# ╔═╡ f43fa0d0-e5b3-404f-b07f-fbb99d5a02eb
M = NetGeo.generate_connections(df_conn, v)

# ╔═╡ ad2d3f51-8dc3-48f4-bdd6-668deabbba6c
possibleConnections = length(M)

# ╔═╡ 9894649b-b037-4f24-af52-4b499d4a3e42
actualConnections = sum(>(0.0), M)

# ╔═╡ 9408ca78-f83e-4d2c-8f01-33a7320eb403
sparsity = actualConnections / possibleConnections

# ╔═╡ 9551a4c7-bb85-43df-822e-9a4e2fd54724
md"""
### Subsetting
For your aplications you might not want to work with one big connectivity matrix. I've made some functions which allow you to simply indicate by types (and compartments) what part of the matrix you want.
"""

# ╔═╡ b9743807-74e8-46f6-b512-662d7125ab79
I2ToEs = NetGeo.subset_by_type(M, v, "I2", "Es")


# ╔═╡ 6b6a2f83-a8e0-40c0-a415-955f28f2d537
EpToEpq = NetGeo.subset_by_type_and_compartment(M, v, "Ep", "Ep", "q")


# ╔═╡ d463b256-a1c2-4c90-aa34-c70a3a890cd2
I1ToEpp = NetGeo.subset_by_type_and_compartment(M, v, "I1", "Ep", "p")

# ╔═╡ 10f8796f-0b3a-4258-bdbb-bba87c0142e5
sum(>(0), I2ToEs[:, 6000])

# ╔═╡ 8c2f2b61-ee7b-47ad-95ba-a26172e1edbb
sum(>(0), EpToEpq[end, :])

# ╔═╡ e77b84a0-099e-47b3-89b3-d6beda8dcad2
md"I also made this function to make all the subsets for you, but maybe you want to edit the function to your preffered naming conventions."

# ╔═╡ e17c7751-48bd-42b1-8a8e-e990fd94a48c
subsetDict = NetGeo.create_subset_dict(M, v)

# ╔═╡ 0cd81408-288d-4f1e-ba91-e9f1d2bc56c5
md"""
### What can be added and improved
- Standard parameters could be more realistic. Right now the mm scale of the column and the neuronal densities are somewhat realistic, but the distance dependence of connections is just made up.
- Each layer has it's own frame of reference coordinates. Neurons connecting between layers are envisioned to have a dendrite branching point in the target layer at the same coordinates as their soma in their own layer. The distance to target neurons is then computed from this branching point.
- Neurons that are near a layer border are not considered close to neurons on the other side of the border.
- Tripod compartments stick out outside the layer boundaries.
- `generate_position` looks for the type "Ep" to assign tripod compartments to, this could be handled more dynamically. Also the Density\_per\_Type dictionary is initialised for the 4 types "Ep","Es","I1" and "I2". This could and should by dynamic as well. (The `generate_connections` function was written more ambitiously and **is** blind to specific names)
- more connection distribution functions could be implemented.
- Tripod dimensions (lengths and angles) could be made layer and type specific.
"""

# ╔═╡ c4b829cc-58d0-4b12-8620-84914ad47d13


# ╔═╡ 84f3c5b3-24da-4ad0-af1f-6653f2b2829e
md"""
### Misc


The next block is just there to load my package environment
"""

# ╔═╡ Cell order:
# ╟─44011e78-9f1a-44ef-ab78-3c9354bb56a6
# ╟─ea33e652-9b4a-40f3-bbf7-061f725b91ba
# ╠═3f996ea4-c951-4337-ad46-6f0fba7bc9fd
# ╟─fb7f7442-ea00-4d1b-8747-7869110ef409
# ╠═fa7a0865-4ff9-45d3-b845-359022370d1d
# ╟─eaba4c42-499a-4bc4-a5b3-51d0d1ef19a8
# ╟─fd51545b-4062-446f-8c62-86ca82e6b412
# ╟─892f73a7-49d9-4144-83e1-5bc9878609d2
# ╠═b0d13692-ef8c-4e1d-9eb9-84226a621444
# ╟─359e5ac5-922b-4a38-9984-9978b0ab4f99
# ╠═3879f7d0-58ac-4eaa-ba82-c0603954c20f
# ╟─80c3be02-e3cb-4df9-b40d-08c8c370fe05
# ╠═6262f209-a1f3-4c60-8581-207061cbf795
# ╟─f55c27f6-bc88-4387-84c6-6b24689cfb0b
# ╠═2335acaf-13c0-40bd-94c1-f0f60f253aca
# ╠═f43fa0d0-e5b3-404f-b07f-fbb99d5a02eb
# ╠═ad2d3f51-8dc3-48f4-bdd6-668deabbba6c
# ╠═9894649b-b037-4f24-af52-4b499d4a3e42
# ╠═9408ca78-f83e-4d2c-8f01-33a7320eb403
# ╟─9551a4c7-bb85-43df-822e-9a4e2fd54724
# ╠═b9743807-74e8-46f6-b512-662d7125ab79
# ╠═6b6a2f83-a8e0-40c0-a415-955f28f2d537
# ╠═d463b256-a1c2-4c90-aa34-c70a3a890cd2
# ╠═10f8796f-0b3a-4258-bdbb-bba87c0142e5
# ╠═8c2f2b61-ee7b-47ad-95ba-a26172e1edbb
# ╟─e77b84a0-099e-47b3-89b3-d6beda8dcad2
# ╠═e17c7751-48bd-42b1-8a8e-e990fd94a48c
# ╟─0cd81408-288d-4f1e-ba91-e9f1d2bc56c5
# ╠═c4b829cc-58d0-4b12-8620-84914ad47d13
# ╟─84f3c5b3-24da-4ad0-af1f-6653f2b2829e
# ╠═6f9960b0-da05-4d3b-b02a-f57e1f1581d0
