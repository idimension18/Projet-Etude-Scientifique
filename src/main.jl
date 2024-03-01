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

#= verify if the postion pos in the map is valid or not 
to be valid, pos must be in the map and not on a wall  =# 
function is_pos_valid(map::Matrix{Char}, pos::Tuple{Int64, Int64}) 
	height = size(map, 1)
	width = size(map, 2)
	
	return pos[1] >= 1 && pos[2] >=1 && pos[1] <= width && pos[2] <= height && map[pos[2], pos[1]] != '@'
end


function flood_fill_rec(map::Matrix{Char}, start::Tuple{Int64, Int64}, ending::Tuple{Int64}, sol::Tuple{Int64, Vector{Tuple{Int, Int64}}})
	if !is_pos_valid(map)
		return (typemax(Int64), sol[2])
	else 
		
	end
end


# flood_fill function 
function flood_fill(map::Matrix{Char}, start::Tuple{Int64, Int64}, ending::Tuple{Int64})
	return flood_fill_rec(map, start, ending,(0, []))
end 
