

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
