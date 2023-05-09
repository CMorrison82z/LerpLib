--[[
	Staggered tweens follow the following behavior :

	Smearing = 0 : All values will not begin lerping until the previous element has completed. 
	Smearing = 1 : Identical to a normal Lerp (All elements will complete their lerp together).s
]]

export type Dictionary = {[string] : any}

local m = {}

local function lerp(a, b, t)
	return a + (b - a) * t
end

m.Lerp = lerp

function m.bulkLerp(As : {number}, Bs : {number}, t)
	local r = {}

	for i, a in As do
		table.insert(r, a + (Bs[i] - a) * t)
	end

	return r
end

function m.staggerBulkLerp(As : {number}, Bs : {number}, smearing, t)
	assert(t, "Did not provide time 't'. Did you forget to add 'smearing'?")

	local inverseLength = 1 / #As
	local invTotalItemTime = 1 / lerp(inverseLength, 1, smearing)

	-- Accounting for alternate easingStyles (for examble, Back goes to negative values)
	local staggerMin = math.min(0, t)
	local staggerMax = math.max(1, t)

	local r = {}

	for i, a in As do
		table.insert(r, a + (Bs[i] - a) * math.clamp((t - (inverseLength * (i * (1 - smearing) + smearing - 1))) * invTotalItemTime, staggerMin, staggerMax))
	end

	return r
end

-- Infers the lerping function to use. Note : all types in A and B must be the same!
function m.bulkLerpInferred(As : {any}, Bs : {any}, t)
	local r = {}

	local lerpFunction = type(As[1]) == "number" and lerp or As[1].Lerp

	for i, a in As do
		table.insert(r, lerpFunction(a, Bs[i]. t))
	end

	return r
end

-- Infers the lerping function to use. Note : all types in A and B must be the same!
function m.staggerBulkLerpInferred(As : {any}, Bs : {any}, smearing, t)
	assert(t, "Did not provide time 't'. Did you forget to add 'smearing'?")

	local inverseLength = 1 / #As
	local invTotalItemTime = 1 / lerp(inverseLength, 1, smearing)

	local r = {}

	local lerpFunction = type(As[1]) == "number" and lerp or As[1].Lerp

	-- Accounting for alternate easingStyles (for examble, Back goes to negative values)
	local staggerMin = math.min(0, t)
	local staggerMax = math.max(1, t)

	for i, a in As do
		table.insert(r, lerpFunction(a, Bs[i], math.clamp((t - (inverseLength * (i * (1 - smearing) + smearing - 1))) * invTotalItemTime, staggerMin, staggerMax)))
	end

	return r
end

-- given a propVal pairs from A, will return propVal pairs interpolated to B
function m.objectLerp(aPairs : Dictionary, bPairs : Dictionary, t)
	local r = {}

	for property, value in aPairs do
		local lerpFunction = type(value) == "number" and lerp or value.Lerp

		r[property] = lerpFunction(value, bPairs[property], t)
	end

	return r
end

-- Used for lerping a collection of objects across multiple properties
function m.collectionLerp(aCollection : {Dictionary}, bCollection : {Dictionary}, t)
	local rColl = {}

	for i, aPairs in aCollection do
		local rPairs = {}

		local bPairs = bCollection[i]

		for property, value in aPairs do
			local lerpFunction = type(value) == "number" and lerp or value.Lerp

			rPairs[property] = lerpFunction(value, bPairs[property], t)
		end

		table.insert(rColl, rPairs)
	end

	return rColl
end

-- Used for lerping a collection of objects across multiple properties
function m.collectionStaggerLerp(aCollection : {Dictionary}, bCollection : {Dictionary}, smearing, t)
	assert(t, "Did not provide time 't'. Did you forget to add 'smearing'?")

	local rColl = {}

	local inverseLength = 1 / #aCollection
	local invTotalItemTime = 1 / lerp(inverseLength, 1, smearing)

	-- Accounting for alternate easingStyles (for examble, Back goes to negative values)
	local staggerMin = math.min(0, t)
	local staggerMax = math.max(1, t)

	for i, aPairs in aCollection do
		local rPairs = {}

		local bPairs = bCollection[i]

		for property, value in aPairs do
			local lerpFunction = type(value) == "number" and lerp or value.Lerp

			rPairs[property] = lerpFunction(value, bPairs[property], math.clamp((t - (inverseLength * (i * (1 - smearing) + smearing - 1))) * invTotalItemTime, staggerMin, staggerMax))
		end

		table.insert(rColl, rPairs)
	end

	return rColl
end

do
	local style = {
		Quadratic = {
			In = function(t)
				return t * t
			end,
			Out = function(t)
				return t * (2 - t)
			end,
			InOut = function(t)
				if t < 0.5 then
					return 2 * t * t
				else
					t = 2 * t - 1
					return -0.5 * (t * (t - 2) - 1)
				end
			end
		},
		Cubic = {
			In = function(t)
				return t ^ 3
			end,
			Out = function(t)
				t = t - 1
				return t ^ 3 + 1
			end,
			InOut = function(t)
				if t < 0.5 then
					return 0.5 * t * t * t
				else
					return 0.5 * ((t - 2) * (t * 2 - 2) * (t * 2 - 2) + 2)
				end
			end
		},
		Quartic = {
			In = function(t)
				return t ^ 4
			end,
			Out = function(t)
				t = t - 1
				return 1 - t ^ 4
			end,
			InOut = function(t)
				if t < 0.5 then
					return 8 * t ^ 4
				else
					t = t - 1
					return -8 * t ^ 4 + 1
				end
			end
		},
		Sinusoidal = {
			In = function(t)
				return 1 - math.cos(t * math.pi / 2)
			end,
			Out = function(t)
				return math.sin(t * math.pi / 2)
			end,
			InOut = function(t)
				return 0.5 * (1 - math.cos(math.pi * t))
			end
		},
		Exponential = {
			In = function(t)
				return t == 0 and 0 or math.pow(1024, t - 1)
			end,
			Out = function(t)
				return t == 1 and 1 or 1 - math.pow(2, -10 * t)
			end,
			InOut = function(t)
				if t == 0 then
					return 0
				end
				if t == 1 then
					return 1
				end
				if t < 0.5 then
					return 0.5 * math.pow(1024, t * 2 - 1)
				else
					return 0.5 * (-math.pow(2, -10 * (t * 2 - 1)) + 2)
				end
			end
		},
		Circular = {
			In = function(t)
				return 1 - math.sqrt(1 - t * t)
			end,
			Out = function(t)
				t = t - 1
				return math.sqrt(1 - t * t)
			end,
			InOut = function(t)
				if t < 0.5 then
					return -0.5 * (math.sqrt(1 - t * t * 4) - 1)
				else
					t = 2 * t - 2
					return 0.5 * (math.sqrt(1 - t ^ 2) + 1)
				end
			end
		},
		Elastic = {
			In = function(t)
				if t == 0 then
					return 0
				elseif t == 1 then
					return 1
				else
					local p = 0.3
					local s = p / 4
					return -math.pow(2, 10 * (t - 1)) * math.sin((t - 1 - s) * (2 * math.pi) / p)
				end
			end,
			Out = function(t)
				if t == 0 then
					return 0
				elseif t == 1 then
					return 1
				else
					local p = 0.3
					local s = p / 4
					return math.pow(2, -10 * t) * math.sin((t - s) * (2 * math.pi) / p) + 1
				end
			end,
			InOut = function(t)
				if t == 0 then
					return 0
				elseif t == 1 then
					return 1
				else
					local p = 0.45
					local s = p / 4
					if t < 0.5 then
						return -0.5 * math.pow(2, 10 * (t * 2 - 1)) * math.sin((t * 2 - 1 - s) * (2 * math.pi) / p)
					else
						return math.pow(2, -10 * (t * 2 - 1)) * math.sin((t * 2 - 1 - s) * (2 * math.pi) / p) * 0.5 + 1
					end
				end
			end
		},
		Back = {
			In = function (t)
				local s = 1.70158
				return t * t * ((s + 1) * t - s)
			end,

			Out = function (t)
				local s = 1.70158
				return (t - 1) * (t - 1) * ((s + 1) * (t - 1) + s) + 1
			end,

			InOut = function (t)
				local s = 1.70158 * 1.525
				t = t * 2
				if t < 1 then
					return 0.5 * (t * t * ((s + 1) * t - s))
				else
					t = t - 2
					return 0.5 * (t * t * ((s + 1) * t + s) + 2)
				end
			end
		},
		Bounce = {
			In = function (t)
				t = 1 - t

				if t < (1 / 2.75) then
					return 1 -7.5625 * t * t
				elseif t < (2 / 2.75) then
					t = t - (1.5 / 2.75)
					return 1 - (7.5625 * t * t + 0.75)
				elseif t < (2.5 / 2.75) then
					t = t - (2.25 / 2.75)
					return 1 - (7.5625 * t * t + 0.9375)
				else
					t = t - (2.625 / 2.75)
					return 1 - (7.5625 * t * t + 0.984375)
				end
			end,

			Out = function (t)
				if t < (1 / 2.75) then
					return 7.5625 * t * t
				elseif t < (2 / 2.75) then
					t = t - (1.5 / 2.75)
					return 7.5625 * t * t + 0.75
				elseif t < (2.5 / 2.75) then
					t = t - (2.25 / 2.75)
					return 7.5625 * t * t + 0.9375
				else
					t = t - (2.625 / 2.75)
					return 7.5625 * t * t + 0.984375
				end
			end,

			InOut = function (t)
				local value
				if t < 0.5 then
					t = 1 - 2 * t

					if t < (1 / 2.75) then
						value = 1 - 7.5625 * t * t
					elseif t < (2 / 2.75) then
						t = t - (1.5 / 2.75)
						value = 1 - (7.5625 * t * t + 0.75)
					elseif t < (2.5 / 2.75) then
						t = t - (2.25 / 2.75)
						value = 1 - (7.5625 * t * t + 0.9375)
					else
						t = t - (2.625 / 2.75)
						value = 1 - (7.5625 * t * t + 0.984375)
					end
					
					value /= 2
				else
					t = 2 * t - 1
					
					if t < (1 / 2.75) then
						value = 7.5625 * t * t
					elseif t < (2 / 2.75) then
						t = t - (1.5 / 2.75)
						value = 7.5625 * t * t + 0.75
					elseif t < (2.5 / 2.75) then
						t = t - (2.25 / 2.75)
						value = 7.5625 * t * t + 0.9375
					else
						t = t - (2.625 / 2.75)
						value = 7.5625 * t * t + 0.984375
					end
					
					value = value / 2 + .5
				end
				
				return value
			end            
		}
	}
	
	m.Style = style
end

return m