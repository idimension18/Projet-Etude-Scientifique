using DataStructures, Images

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


# Image rendering
# ---------------
# Colors Constantes 
black = RGB(1, 1, 1)
white = RGB(0, 0, 0)

green = RGB(0, 1, 0)
red = RGB(1, 0, 0)
blue = RGB(0, 0, 1)

orange = RGB(1, 0.5, 0)
brown = RGB(150/255, 75/255, 0)

function solution_to_image(map::Matrix{Char}, path::Vector{Tuple{Int64, Int64}}, start::Tuple{Int64, Int64}, target::Tuple{Int64, Int64})
	image= fill(white, (size(map, 1), size(map, 2)))

	for i in 1:size(map, 1)
		for j in 1:size(map, 1)
			if (j, i) in path
				if (j, i) in [start, target]
					image[i, j] = orange
				else 
					image[i, j] = red
				end
			else
				if map[i, j] == 'W'
					image[i, j] = blue
				elseif map[i, j] == 'S'
					image[i, j] = green
				elseif map[i, j] == '.'
					image[i, j] = black
				elseif map[i, j] == 'T'
					image[i, j] = brown
				end
			end
		end
	end
	
	display(image)
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
	
	return pos[1] >= 1 && pos[2] >= 1 && pos[1] <= width && pos[2] <= height && map[pos[2], pos[1]] != '@'
end

# Get the distance to go to pos
function get_distance_to_go_to(map::Matrix{Char}, pos::Tuple{Int64, Int64})
	c::Char = map[pos[2], pos[1]]
	if c == 'S'
		return 5
	elseif c == 'W'
		return 8
	else
		return 1
	end
end


# Build the solution from the solution matrix
# --------------------------------------------
function get_path_from_sol(map::Matrix{Char}, solution_matrix::Matrix{Tuple{Int64, Tuple{Int64, Int64}}}, target::Tuple{Int64, Int64})
	# Directly test if a path was found or not
	if solution_matrix[target[2], target[1]][1] == typemax(Int64)
		return []
	end
	
	node = target
	path::Vector{Tuple{Int64, Int64}} = []
	 
	while node != (-1, -1)
		push!(path, node)
		node = solution_matrix[node[2], node[1]][2]
	end

	reverse!(path)

	return path
end


# Flood fill
# --------------------
# Flood fill algorithm implementation 
function flood_fill(map::Matrix{Char}, start::Tuple{Int64, Int64}, target::Tuple{Int64, Int64})
	node_seen = 1
	# Directly check if target is reachable 
	if !(is_pos_valid(map, target) && is_pos_valid(map, start))
		return (typemax(Int64), [])
	end
	
	# A matrix that store the solution for all vertices  
	solution_map::Matrix{Tuple{Int64, Tuple{Int64, Int64}}} = 
		fill((typemax(Int64), (-1, -1)), (size(map, 1), size(map, 2)))
	solution_map[start[2], start[1]] = (0, (-1, -1))
		
	queue::Vector{Tuple{Int64, Int64}} = [start]
	
	déjàVue::Matrix{Bool} = fill(false, (size(map, 1), size(map, 2)))
	déjàVue[start[2], start[1]] = true

	is_target_reached = false
	
	while queue != [] && !is_target_reached
		# Relax the first vertice from the queue
		node = popfirst!(queue)

		# Exploration of neighbors
		for neighbor in [(node[1]+1 , node[2]), (node[1]-1, node[2]), (node[1], node[2]+1), (node[1], node[2]-1)]
			# Because all weight is 1, when we see the target, we know the g value will be the smallest 
			is_target_reached = neighbor == target

			# update neighbor sol value
			if is_pos_valid(map, neighbor) && !déjàVue[neighbor[2], neighbor[1]]
				node_seen += 1 
			
				solution_map[neighbor[2], neighbor[1]] = (solution_map[node[2], node[1]][1] + 1, node)
				push!(queue, neighbor)
			end
			
			déjàVue[neighbor[2], neighbor[1]] = true 
		end
	end
	
	return (solution_map[target[2], target[1]][1], get_path_from_sol(map, solution_map, target), node_seen)
end


# Dijkstra
# ------------------------
# Dijsktra  algorithm implementation 
function dijkstra(map::Matrix{Char}, start::Tuple{Int64, Int64}, target::Tuple{Int64, Int64})
	node_seen = 0 
	
	# Directly check if target is reachable 
	if !(is_pos_valid(map, target) && is_pos_valid(map, start))
		return (typemax(Int64), [])
	end

	# A matrix that store the solution for all vertices  
	solution_map::Matrix{Tuple{Int64, Tuple{Int64, Int64}}} = 
		fill((typemax(Int64), (-1, -1)), (size(map, 1), size(map, 2)))
	solution_map[start[2], start[1]] = (0, (-1, -1))
	
	min_heap::MutableBinaryHeap{Tuple{Int64, Tuple{Int64, Int64}}} = 
		MutableBinaryHeap{Tuple{Int64, Tuple{Int64, Int64}}}(Base.By(first))
	address_dict = Dict()
	address_dict[start] = push!(min_heap, (0, start))
	
	déjàVue::Matrix{Bool} = fill(false, (size(map, 1), size(map, 2)))
	déjàVue[start[2], start[1]] = true
	
	while !isempty(min_heap)
		# Relax the vertice with the smallest heurestic
		node = pop!(min_heap)[2]

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
				neighbor_dist = solution_map[node[2], node[1]][1] + edge_value

				if neighbor_dist < solution_map[neighbor[2], neighbor[1]][1]
					solution_map[neighbor[2], neighbor[1]] = (neighbor_dist, node)
					
					if !déjàVue[neighbor[2], neighbor[1]]
						address_dict[neighbor] = push!(min_heap, (neighbor_dist, neighbor))
						déjàVue[neighbor[2], neighbor[1]] = true

						node_seen += 1 
					else
						update!(min_heap, address_dict[neighbor], (neighbor_dist, neighbor))
					end
				end
			end 
		end
	end

	return (solution_map[target[2], target[1]][1], get_path_from_sol(map, solution_map, target), node_seen)
end


# A* 
# --------------
# Return the manhattan distance between pos1 and pos2 
function manhattan_dist(pos1, pos2)
	return abs(pos1[1] - pos2[1]) + abs(pos1[2] - pos2[1])
end


# A* algorithm implementation 
function Astar(map::Matrix{Char}, start::Tuple{Int64, Int64}, target::Tuple{Int64, Int64})
	node_seen = 0 
	
	# Directly check if target is reachable 
	if !(is_pos_valid(map, target) && is_pos_valid(map, start))
		return (typemax(Int64), [])
	end

	# A matrix that store the solution for all vertices  
	solution_map::Matrix{Tuple{Int64, Tuple{Int64, Int64}}} = 
		fill((typemax(Int64), (-1, -1)), (size(map, 1), size(map, 2)))
	solution_map[start[2], start[1]] = (0, (-1, -1))
	
	min_heap::MutableBinaryHeap{Tuple{Int64, Tuple{Int64, Int64}}} = 
		MutableBinaryHeap{Tuple{Int64, Tuple{Int64, Int64}}}(Base.By(first))
	address_dict = Dict()
	address_dict[start] = push!(min_heap, (0, start))
	
	déjàVue::Matrix{Bool} = fill(false, (size(map, 1), size(map, 2)))
	déjàVue[start[2], start[1]] = true
	
	while !isempty(min_heap)
		# Relax the vertice with the smallest heurestic
		node = pop!(min_heap)[2]
		
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
				neighbor_dist = solution_map[node[2], node[1]][1] + edge_value

				if neighbor_dist < solution_map[neighbor[2], neighbor[1]][1]
					solution_map[neighbor[2], neighbor[1]] = (neighbor_dist, node)
					
					if !déjàVue[neighbor[2], neighbor[1]]
						address_dict[neighbor] = push!(min_heap, (neighbor_dist + manhattan_dist(neighbor, target), neighbor))
						déjàVue[neighbor[2], neighbor[1]] = true

						node_seen += 1 
					else
						update!(min_heap, address_dict[neighbor], (neighbor_dist + manhattan_dist(neighbor, target), neighbor))
					end
				end
			end 
		end
	end

	return (solution_map[target[2], target[1]][1], get_path_from_sol(map, solution_map, target), node_seen)
end


# Weighted A*  (WA)
# -----------------------
function WAstar(map::Matrix{Char}, start::Tuple{Int64, Int64}, target::Tuple{Int64, Int64}, w::Float64)
	node_seen = 0 
	
	# Directly check if target is reachable 
	if !(is_pos_valid(map, target) && is_pos_valid(map, start))
		return (typemax(Int64), [])
	end

	# A matrix that store the solution for all vertices  
	solution_map::Matrix{Tuple{Int64, Tuple{Int64, Int64}}} = 
		fill((typemax(Int64), (-1, -1)), (size(map, 1), size(map, 2)))
	solution_map[start[2], start[1]] = (0, (-1, -1))
	
	min_heap::MutableBinaryHeap{Tuple{Float64, Tuple{Int64, Int64}}} = 
		MutableBinaryHeap{Tuple{Float64, Tuple{Int64, Int64}}}(Base.By(first))
	address_dict = Dict()
	address_dict[start] = push!(min_heap, (0, start))
	
	déjàVue::Matrix{Bool} = fill(false, (size(map, 1), size(map, 2)))
	déjàVue[start[2], start[1]] = true
	
	while !isempty(min_heap)
		# Relax the vertice with the smallest heurestic
		node = pop!(min_heap)[2]
		
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
				neighbor_dist = solution_map[node[2], node[1]][1] + edge_value

				if neighbor_dist < solution_map[neighbor[2], neighbor[1]][1]
					solution_map[neighbor[2], neighbor[1]] = (neighbor_dist, node)
					
					if !déjàVue[neighbor[2], neighbor[1]]
						address_dict[neighbor] = push!(min_heap, (neighbor_dist + w * manhattan_dist(neighbor, target), neighbor))
						déjàVue[neighbor[2], neighbor[1]] = true

						node_seen += 1 
					else
						update!(min_heap, address_dict[neighbor], (neighbor_dist + w * manhattan_dist(neighbor, target), neighbor))
					end
				end
			end 
		end
	end

	return (solution_map[target[2], target[1]][1], get_path_from_sol(map, solution_map, target), node_seen)
end

# Tests  
# -------
function test(fname::String, D::Tuple{Int64, Int64}, A::Tuple{Int64, Int64})
	map_matrix = map_to_matrix(fname)

	println("Flood Fill :")
	println("------------")
	sol = @time flood_fill(map_matrix, D, A)
	println("Distance trouvée : ", sol[1])
	println("Nombre de case vue : ", sol[3])
	solution_to_image(map_matrix, sol[2], D, A)
	
	println()

	println("Dijkstra :")
	println("------------")
	sol = @time dijkstra(map_matrix, D, A)
	println("Distance trouvée : ", sol[1])
	println("Nombre de case vue : ", sol[3])
	solution_to_image(map_matrix, sol[2], D, A)

	println()

	println("A* :")
	println("------------")
	sol = @time Astar(map_matrix, D, A)
	println("Distance trouvée : ", sol[1])
	println("Nombre de case vue : ", sol[3])
	solution_to_image(map_matrix, sol[2], D, A)
end

function algoFloodFill(fname, D, A)
	map_matrix = map_to_matrix(fname)
	
	println("Flood Fill :")
	println("------------")
	sol = @time flood_fill(map_matrix, D, A)
	println("Distance trouvée : ", sol[1])
	println("Nombre de case vue : ", sol[3])
	solution_to_image(map_matrix, sol[2], D, A)
end

function algoDijkstra(fname, D, A)
	map_matrix = map_to_matrix(fname)
	
	println("Dijkstra :")
	println("------------")
	sol = @time dijkstra(map_matrix, D, A)
	println("Distance trouvée : ", sol[1])
	println("Nombre de case vue : ", sol[3])
	solution_to_image(map_matrix, sol[2], D, A)
end


function algoAstar(fname, D, A)
	map_matrix = map_to_matrix(fname)
	
	println("A* :")
	println("------------")
	sol = @time Astar(map_matrix, D, A)
	println("Distance trouvée : ", sol[1])
	println("Nombre de case vue : ", sol[3])
	solution_to_image(map_matrix, sol[2], D, A)
end


function algoWA(fname, D, A, w)
	map_matrix = map_to_matrix(fname)
	
	println("WA ", w, " : ")
	println("------------")
	sol = @time WAstar(map_matrix, D, A, w)
	println("Distance trouvée : ", sol[1])
	println("Nombre de case vue : ", sol[3])
	solution_to_image(map_matrix, sol[2], D, A)
end


# arrivee (189, 193)      depart (226, 437)
