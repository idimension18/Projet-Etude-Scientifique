# MAP PARSER
# -------------- 
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


# Tool functions 
# ---------------- 

#= 
	verify if the postion pos in the map is valid or not 
	To be valid, pos must be in the map and not on a wall  
=# 
function is_pos_valid(map::Matrix{Char}, pos::Tuple{Int64, Int64}) 
	height = size(map, 1)
	width = size(map, 2)
	
	return pos[1] >= 1 && pos[2] >=1 && pos[1] <= width && pos[2] <= height && map[pos[2], pos[1]] != '@'
end


function get_distance_to_go_to(map::Matrix{Char}, pos::Tuple{Int64, Int64})
	c:: Char = map[pos[2], pos[1])
	if c == '.'
		return 1
	else
		return 2 
	end
end


# FLOOD FILL IMPLEMENTATION
# ------------------------------
function get_optimal_sol(solutions::Vector{Tuple{Int64, Vector{Tuple{Int64, Int64}}}})
	opti_sol = solutions[1]
	for sol in solutions
		if sol[1] < opti_sol[1]
		opti_sol = sol
	end
	return opti_sol
end


function flood_fill_rec(map::Matrix{Char}, start::Tuple{Int64, Int64}, ending::Tuple{Int64}, sol::Tuple{Int64, Vector{Tuple{Int, Int64}}})
	# store optimal solution from all possible paths 
	opti_sols::Vector{Tuple{Int64, Vector{Tuple{Int64, Int64}}}} = []

	# get optimal solutions from all position paths 
	for next in [(start[1] + 1, start[2]), (start[1] - 1, start[2]), (start[1], start[2] + 1), (start[1], start[2] - 1)]
		if is_pos_valid(map, next) 
			push!(paths, 
			flood_fill_rec(map, next, ending, (sol[1] + get_distance_to_go_to(map, next), [sol[2]; [next]])))
		else
			push!(paths, (typemax(Int64), sol) )
		end
	end 

	# Among theses optimal solution we keep the most optimal 
	return get_optimal_sol(paths)
end


# flood_fill function 
function flood_fill(map::Matrix{Char}, start::Tuple{Int64, Int64}, ending::Tuple{Int64})
	return flood_fill_rec(map, start, ending,(0, []))
end 


