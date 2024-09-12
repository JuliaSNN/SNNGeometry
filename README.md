# SNNGeometry Package

The **SNNGeometry** package is a Julia-based tool for generating and managing the geometry and connections of spiking neural networks (SNNs).

## Key Features
- Extract parameters from an `.xlsx` file or generate them manually.
- Generate neuron positions based on type, layer, and compartment parameters.
- Create comprehensive connection matrices for all neurons.
- Subset the matrix into manageable parts by type and/or compartment.

## Usage Example

```julia
using DataFrames
import SNNGeometry: get_connection_parameters_from_xlsx, generate_positions, get_neuron_idx_overview, generate_connections, subset_by_type, subset_by_type_and_compartment

# Extract parameters from an xlsx file, default "test_input/test.xlsx" or specify filename
df_conn, df_dens, df_size, df_dend = get_connection_parameters_from_xlsx(joinpath(dirname(@__FILE__), "../test_input/newnumbers.xlsx"))

# Generate neuron positions based on the parameters
v = generate_positions(df_dens, df_size, df_dend)

# Get an overview of what numbers in the list correspond to which type, layer, compartment
overview = get_neuron_idx_overview(v)

# Generate a sparse connection matrix for all neurons
M = generate_connections(df_conn, v)

# Subset the matrix into smaller parts by type and/or compartment
I2ToEs = subset_by_type(M, v, "I2", "Es")
EpToEpq = subset_by_type_and_compartment(M, v, "Ep", "Ep", "q")
I1ToEpp = subset_by_type_and_compartment(M, v, "I1", "Ep", "p")
```

## Note:

The `generate_connections` function can be memory-intensive. It generates a large matrix that is subsequently converted to a sparse matrix to optimize memory usage.

## Requirements

Julia programming language
DataFrames.jl package

## Installation
Add the SNNGeometry package to your Julia environment:

```
julia
Copy code
using Pkg
Pkg.add("SNNGeometry")
````


## Contributing
Contributions are welcome! Please fork the repository and create a pull request with your changes.

## License

The MIT License is a permissive open-source license commonly used in scientific and software development projects. 