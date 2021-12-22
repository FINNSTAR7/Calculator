local AMC = require "AbsorbMarkovTranslate"

function tonum(str)
	if tonumber(str) then
		return tonumber(str)
	end

	local t = {}
	for d in string.gmatch(str, "([^/])") do
		table.insert(t, d)
	end

	return tonumber(t[1]) / tonumber(t[2] or 1)
end

local probabilities = { numP = 0, sum = 0 }
print("Probabilities:")
for str in string.gmatch(io.read(), "%d+%.?/?%d*") do
	probabilities.sum = probabilities.sum + tonum(str)
	probabilities.numP = probabilities.numP + 1
	table.insert(probabilities, tonum(str))
end

if probabilities.sum > 1 then
	for i = 1, probabilities.numP do
		probabilities[i] = probabilities[i] / probabilities.sum
	end
	probabilities.sum = 1
end

local probs = io.open("probs.txt", "w")
for i = 1, probabilities.numP do
	probs:write(probabilities[i] .. "\n")
end
probs:close()

local T = AMC.Transition(probabilities)

local E = T.expected()
local S = T.std(E)
print("\nExpected Number of Trials:	", E[1])
print("Standard Dev. of Expectation:", S[1])

print("\nCalculating Distribution...")
local data = io.open("data.txt", "w")
local count = probabilities.numP
local last = 0

if probabilities.numP == 1 then
	data:write("1, " .. T[1][2] .. ", " .. T[1][2] .. "\n")
	count = 2
	last = T[1][2]
end

for _ = 1, count - 2 do
	T.iterate()
end

local sz = 2 ^ probabilities.numP
repeat
	T.iterate()
	data:write(count .. ", " .. (T[1][sz] - last) .. ", " .. T[1][sz] .. "\n")
	last = T[1][sz]
	count = count + 1
until last >= 0.9999
data:close()

print("Done!")
