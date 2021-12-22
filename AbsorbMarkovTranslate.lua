local AMC = {}

function getCombs(probabilities)
	local combs = {}
	local pattern = ""
	local c

	local Tr = ""
	local Tq = { "." }
	combs[#combs + 1] = {}
	for j, v in ipairs(probabilities) do
		table.insert(combs[#combs], {})
		c = utf8.char(64 + j)
		probabilities[c] = v
		combs[1][j][1] = c
		Tr = Tr .. c
		pattern = pattern .. c .. "+"
	end

	-- O( (numP)choose(N) )
	for i = 2, probabilities.numP - 1 do
		combs[#combs + 1] = {}
		for j = 1, #combs[i - 1] - 1 do
			table.insert(combs[#combs], {})
			for k = j + 1, #combs[i - 1] do
				for m = 1, #combs[i - 1][k] do
					combs[i][j][#combs[i][j] + 1] = combs[1][j][1] .. combs[i - 1][k][m]
				end
			end
		end
	end

	for i = 1, probabilities.numP - 1 do
		for j = 1, #combs[i] do
			for k = 1, #combs[i][j] do
				Tq[#Tq + 1] = combs[i][j][k]
			end
		end
	end

	return { Tq = Tq, Tr = Tr }
end

function makeT(probabilities, combs, T, T0)
	local Tq = combs.Tq
	local O = 1 - probabilities.sum
	local sz = T0.size

	-- Q
	T0[1][1] = O
	T[1][1] = O
	local total = 0
	for j = 1, probabilities.numP do
		T0[1][j + 1] = probabilities[j]
		T[1][j + 1] = probabilities[j]
		total = total + probabilities[j]
	end

	-- R
	T0[1][sz] = 1 - total
	T[1][sz] = 1 - total

	-- I
	T0[sz][sz] = 1
	T[sz][sz] = 1

	local str
	for i = 2, #Tq do
		total = 0
		for j = i + 1, #Tq do
			if Tq[i]:len() ~= Tq[j]:len() then
				str = Tq[j]
				for v in Tq[i]:gmatch(".") do
					if str:match(v) then
						str = str:gsub(v, "")
					end
				end
				if str:len() == 1 then
					T0[i][j] = T0[i][j] + probabilities[str]
					T[i][j] = T[i][j] + probabilities[str]
					total = total + probabilities[str]
				end
			end
		end

		for c in Tq[i]:gmatch(".") do
			T0[i][i] = T0[i][i] + probabilities[c] + O
			T[i][i] = T[i][i] + probabilities[c] + O
		end

		T0[i][sz] = 1 - (total + T0[i][i])
		T[i][sz] = 1 - (total + T[i][i])
	end
end

function matrix(rows, cols, init)
	M = {}
	s = 0
	e = 100
	if rows == 1 then
		for i = 1, cols do
			M[i] = init or math.random(s, e)
		end
	elseif cols == 1 then
		for i = 1, rows do
			M[i] = init or math.random(s, e)
		end
	else
		for i = 1, rows do
			M[i] = {}
			for j = 1, cols do
				M[i][j] = init or math.random(s, e)
			end
		end
	end

	M.rows = rows
	M.cols = cols

	return M
end

function inverse(M)
	local T = { size = M.size }
	for i = 1, M.size do
		T[i] = {}
		for j = 1, M.size do
			T[i][j] = 0
		end
	end

	local function inverse(sr, sc, size)
		if size == 2 then
			local det = M[sr][sc] * M[sr + 1][sc + 1]
			T[sr][sc] = M[sr + 1][sc + 1] / det
			T[sr][sc + 1] = -M[sr][sc + 1] / det
			T[sr + 1][sc + 1] = M[sr][sc] / det
		else
			inverse(sr, sc, size/2) -- A^-1
			inverse(sr + size/2, sc + size/2, size/2) -- D^-1

			-- t = (A^-1)B
			local total
			for i = sr, sr + size/2 - 1 do
				for j = sc + size/2, sc + size - 1 do
					total = 0
					for k = i, sr + size/2 - 1 do
						total = total + T[i][k] * M[k][j]
					end
					T[i][j] = total
				end
			end

			-- t(D^-1)
			for i = sr, sr + size/2 - 1 do
				for j = sc + size - 1, sc + size/2, -1 do
					total = 0
					for k = sc + size/2, j do
						total = total + T[i][k] * T[k][j]
					end
					T[i][j] = -total
				end
			end
		end

		return T
	end

	return inverse(1, 1, M.size)
end

function fundamental(M)
	local size = M.size
	local N = matrix(size, size, 0)
	N.size = size

	for i = 1, size - 1 do
		for j = i + 1, size - 1 do
			N[i][j] = -M[i][j]
		end
		N[i][i] = 1 - M[i][i]
	end
	for i = 1, size - 1 do
		N[i][size] = 0
		N[size][i] = 0
	end
	N[size][size] = 1

	return inverse(N)
end

function AMC.Transition(probabilities)
	local size = 2 ^ probabilities.numP
	local T0 = matrix(size, size, 0)
	local T = matrix(size, size, 0)
	T0.size = size
	T.size = size

	local combs = getCombs(probabilities)
	makeT(probabilities, combs, T, T0)

	F = fundamental(T0)

	function T.expected()
		local E = matrix(size - 1, 1, 0)
		local total

		for i = 1, size - 1 do
			total = 0
			for j = i, size - 1 do
				total = total + F[i][j]
			end
			E[i] = total
		end

		return E
	end

	function T.std(e)
		local E = e or T.expected()
		local S = matrix(size - 1, 1, 0)
		local total

		for i = 1, size - 1 do
			total = 0
			for j = i + 1, size - 1 do
				total = total + 2 * F[i][j] * E[j]
			end
			S[i] = math.sqrt(total + (2 * F[i][i] - 1) * E[i] - E[i] * E[i])
		end

		return S
	end

	function T.iterate()
		local temp = {}

		local total
		for i = 1, size - 1 do
			-- update upper triangle of Q
			for j = i, size - 1 do
				total = 0
				for k = i, j do
					temp[k] = temp[k] or {}
					temp[k][j] = temp[k][j] or T[k][j]
					total = total + T0[i][k] * temp[k][j]
				end
				T[i][j] = total
			end

			-- update R
			total = 0
			for j = i, size - 1 do
				temp[j][size] = temp[j][size] or T[j][size]
				total = total + T0[i][j] * temp[j][size]
			end
			T[i][size] = total + T0[i][size]
		end
	end

	function T.toString()
		local str
		print(table.concat(combs.Tq, " ") .. " | " .. combs.Tr)
		for i = 1, size do
			str = {}
			for j = 1, size - 1 do
				str[#str + 1] = T[i][j] == 0 and 0 or (T[i][j] or "_")
			end
			str[#str + 1] = "|"
			str[#str + 1] = T[i][size] == 0 and 0 or (T[i][size] or "_")
			print(table.concat(str, " "))
		end
	end

	function T.T0() return T0 end
	function T.Transient() return combs.Tq end
	function T.Absorbing() return combs.Tr end

	return T
end

return AMC
