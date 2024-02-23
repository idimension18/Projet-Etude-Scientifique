function map_to_matrix(path::String)
	file = open(path, "r")
	
	# Read and store the header 
	type = split(readline(file))[2]
	height::Int64 = parse(Int, split(readline(file))[2])
	width::Int64 =  parse(Int, split(readline(file))[2])
	readline(file)

	# Initialize the matrix
	m = fill('.', height, width)
	
	# Read the map content
	i::Int64 = 1
	j::Int64 = 1 
	
	for line in eachline(file)
		for char in line
			m[i, j] = char
			j += 1
		end
		j = 1
		i += 1
	end

	close(file)
	
	return m
end
