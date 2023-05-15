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

-- Defined as a partial function for the sake of caching expensive calculations
local function getSmearer(smearing, len)
	local inverseLength = 1 / len
	local invTotalItemTime = 1 / lerp(inverseLength, 1, smearing)

	return function(t, i)
		return math.clamp((t - (inverseLength * (i * (1 - smearing) + smearing - 1))) * invTotalItemTime, math.min(0, t), math.max(1, t))
	end
end

m.Lerp = lerp
m.Smearer = getSmearer

--[[
	o = {
		A = 1,
		B = 2,
		.
		.
		.
	}

	local os = {o}
	
	local ps = {props}

	for i, lerped in lerper(ps) do
		2
	end
]]
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