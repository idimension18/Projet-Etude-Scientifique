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

# Get the distance to go to pos
function get_distance_to_go_to(map::Matrix{Char}, pos::Tuple{Int64, Int64})
	c:: Char = map[pos[2], pos[1]]
	if c == '.'
		return 1
	elseif c == 'O'
		return 2
	else 
		return typemax(Int64)
	end
end


# Build the solution from the solution matrix
# --------------------------------------------
function get_g_min(map::Matrix{Char}, solution_matrix::Matrix{Int64}, node::Tuple{Int64, Int64})
	node_min = (node[1]+1 , node[2])
	g_min = solution_matrix[node[2], node[1]+1]
	
	for neighbor in  [(node[1]+1 , node[2]), (node[1]-1, node[2]), (node[1], node[2]+1), (node[1], node[2]-1)]
		if is_pos_valid(map, neighbor) && solution_matrix[neighbor[2], neighbor[1]] < g_min
			g_min = solution_matrix[neighbor[2], neighbor[1]]
			node_min = neighbor
		end
	end

	return (g_min, node_min)
end

function get_path_from_sol(map::Matrix{Char}, solution_matrix::Matrix{Int64}, target::Tuple{Int64, Int64})
	# Directly test if a path was found or not
	if solution_matrix[target[2], target[1]] == typemax(Int64)
		return []
	end

	path = [target]
	node = target
	g = solution_matrix[node[2], node[1]]
	
	while g != 0
		(g, node) = get_g_min(map::Matrix{Char}, solution_matrix, node)
		pushfirst!(path, node)
	end

	return path
end


# Flood fill
# --------------------
# Flood fill algorithm implementation 
function flood_fill(map::Matrix{Char}, start::Tuple{Int64, Int64}, target::Tuple{Int64, Int64})
	# Directly check if target is reachable 
	if !(is_pos_valid(map, target) && is_pos_valid(map, start))
		return (typemax(Int64), [])
	end
	
	# A matrix that store the solution for all vertices  
	solution_map = fill(typemax(Int64), (size(map, 1), size(map, 2)))
	
	queue = [start]
	déjàVue = [start]
	is_target_reached = false
	solution_map[start[2], start[1]] = 0
	
	while queue != [] && !is_target_reached
		# Relax the first vertice from the queue
		node = popfirst!(queue)

		# Exploration of neighbors
		for neighbor in [(node[1]+1 , node[2]), (node[1]-1, node[2]), (node[1], node[2]+1), (node[1], node[2]-1)]
			# Because all weight is 1, when we see the target, we know the g value will be the smallest 
			is_target_reached = neighbor == target

			# update neighbor sol value
			if is_pos_valid(map, neighbor) && !(neighbor in déjàVue)
				solution_map[neighbor[2], neighbor[1]] = solution_map[node[2], node[1]][1] + 1
				push!(queue, neighbor)
			end
			
			push!(déjàVue, neighbor)
		end
	end
	
	return (solution_map[target[2], target[1]], get_path_from_sol(map, solution_map, target))
end


# Dijkstra
# ------------------------
# Remove from queue and return the vectice with the smallest g 
function g_min_pop!(queue::Vector{Tuple{Int64, Int64}}, sol::Matrix{Int64})
	min_dist = queue[1]
	
	for pos in queue
		if sol[pos[2], pos[1]] < sol[min_dist[2], min_dist[1]]
			min_dist = pos
		end
	end

	filter!(x -> x != min_dist, queue)
	
	return min_dist
end

# A* algorithm implementation 
function dijkstra(map::Matrix{Char}, start::Tuple{Int64, Int64}, target::Tuple{Int64, Int64})
	# Directly check if target is reachable 
	if !(is_pos_valid(map, target) && is_pos_valid(map, start))
		return (typemax(Int64), [])
	end

	solution_map::Matrix{Int64} = fill(typemax(Int64), (size(map, 1), size(map, 2)))
	
	queue = [start]
	déjàVue = [start]
	is_target_relaxed = false
	solution_map[start[2], start[1]] = 0
	
	while queue != []
		# Relax the vertice with the smallest heurestic
		node = g_min_pop!(queue, solution_map)

		# if the target is relaxed, we can stop the algorithm
		if node == target 
			break
		end
		
		# Exploration of neighbors
		for neighbor in [(node[1]+1 , node[2]), (node[1]-1, node[2]), (node[1], node[2]+1), (node[1], node[2]-1)]
			# check if neighbor is reachable
			if is_pos_valid(map, neighbor)
				edge_value = get_distance_to_go_to(map, neighbor)

				# update neighbor sol value
				neighbor_dist = solution_map[node[2], node[1]] + edge_value

				if neighbor_dist < solution_map[neighbor[2], neighbor[1]]
					solution_map[neighbor[2], neighbor[1]] = neighbor_dist
				end
				
				# If the neighbor is unseen, we add it to the queue so we can relax it later 
				if !(neighbor in déjàVue)
					push!(déjàVue, neighbor)
					push!(queue, neighbor)
				end
				
			end 
		end
	end

	return (solution_map[target[2], target[1]], get_path_from_sol(map, solution_map, target))
end

# A* 
# --------------
# Return the manhattan distance between pos1 and pos2 
function manhattan_dist(pos1, pos2)
	return abs(pos1[1] - pos2[1]) + abs(pos1[2] - pos2[1])
end

function heurestic_pop!(queue::Vector{Tuple{Int64, Int64}}, sol::Matrix{Int64}, target::Tuple{Int64, Int64})
	current_min = queue[1]
	current_value = sol[current_min[2], current_min[1]] + manhattan_dist(current_min, target)
	
	for pos in queue
		pos_value = sol[pos[2], pos[1]] + manhattan_dist(pos, target)
		if pos_value < current_value
			current_min = pos
			current_value = pos_value
		end
	end

	filter!(x -> x != current_min, queue)
	
	return current_min
end

# A* algorithm implementation 
function AStar(map::Matrix{Char}, start::Tuple{Int64, Int64}, target::Tuple{Int64, Int64})
	# Directly check if target is reachable 
	if !(is_pos_valid(map, target) && is_pos_valid(map, start))
		return (typemax(Int64), [])
	end

	solution_map::Matrix{Int64} =fill(typemax(Int64), (size(map, 1), size(map, 2)))
	
	queue = [start]
	déjàVue = [start]
	is_target_relaxed = false
	solution_map[start[2], start[1]] = 0
	
	while queue != []
		# Relax the vertice with the smallest heurestic
		node = heurestic_pop!(queue, solution_map, target)

		# if the target is relaxed, we can stop the algorithm
		if node == target 
			break
		end
		
		# Exploration of neighbors
		for neighbor in [(node[1]+1 , node[2]), (node[1]-1, node[2]), (node[1], node[2]+1), (node[1], node[2]-1)]
			# check if neighbor is reachable
			if is_pos_valid(map, neighbor)
				edge_value = get_distance_to_go_to(map, neighbor)

				# update neighbor sol value
				neighbor_dist = solution_map[node[2], node[1]] + edge_value

				if neighbor_dist < solution_map[neighbor[2], neighbor[1]]
					solution_map[neighbor[2], neighbor[1]] = neighbor_dist
				end
				
				# If the neighbor is unseen, we add it to the queue so we can relax it later 
				if !(neighbor in déjàVue)
					push!(déjàVue, neighbor)
					push!(queue, neighbor)
				end
				
			end 
		end
	end

	return (solution_map[target[2], target[1]], get_path_from_sol(map, solution_map, target))
end


# Tests  
# -------
function test(path::String, start::Tuple{Int64, Int64}, target::Tuple{Int64, Int64})
	map_matrix = map_to_matrix(path)

	println("Flood fill :")
	println("-------------")
	sol1 = @time flood_fill(map_matrix, start, target)

	println()

	println("Dijkstra :")
	println("------------")
	sol2 = @time dijkstra(map_matrix, start, target)

	println()

	println("A* :")
	println("------------")
	sol3 = @time AStar(map_matrix, start, target)

	print()
end
