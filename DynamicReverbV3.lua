--[[

Author: Purple Dude With A Golf Cap on Discord

How long it took: like almost 2 months (still on-going)


	This is rather expensive to run,
	I do NOT recommend using this if you are at all concerned with performance.
	Maybe one day I might parallelize it, but for now, this works.





	Recreation of the first version which I made for personal use.
	V2 fixes a lot of problems with the first iteration of this module; mainly related to how I handled absorption.
	Now that V3 is out I'll tell you what I added. In this update I added Late reflection and  early reflection. which is already a huge update BUT another thing I changed is I rewrote the reflection system entirely.
	The reflection system might be over the top but hey, it's a technical marvel that I even got the damn thing to work, and not just work but work in the best possible way ever
	I cannot tell you how [fliping] long it took to get the reflect() to even fire a single ray and bounce ONCE. it got me so tired when I finished it. You can just modify the reflect() to suit your needs just please remember how long it took to even write it
	You are free to use this as you wish, and please notify me if you find any bugs.
	Credit is not required but appreciated! or i'll find out, somehow (jk its all good)




	---Quick Start Guide---
		1. Require the module (duh). Make sure you do this on the client, as it doesn't make much sense to have the server calculate the reverb (also it doesn't work serverside anyway).
		2. Make sure the following ModuleScripts are present inside the reverb engine (castray and goodsignal)
		3. Create rayParams with SoundReverbV2.newRayParams() to specify where to shoot rays from, how many rays, etc.
		4. Make a new ReverbObject with SoundReverbV2.new(RayParams: rayParams?, SoundParams: soundParams?), and you can pass your params through with it.
		5. Add your sound(s) with ReverbObject:AddSound(MySound)
		6. Start the raycasting with ReverbObject:StartUpdate(), and you are done!
		
		--EX:
			local ReverbMod = require(...) -- module path
			local MySound: Sound = (...) -- sound path
			local Part: BasePart = MySound.Parent -- part to track
			local RayParam = ReverbMod.newRayParams(Part, 8, 40, 100, true, true)
			local ReverbObj = ReverbMod.new(RayParam)

			ReverbObj:AddSound(MySound)
			ReverbObj:StartUpdate()
		--
	--------------------
	
	
	---Documentation---
	---------------------------------------
	---------------------------------------
	---------------------------------------
	[Functions]
	
	Note: You don't have to fill out every single argument, some defaults usually work well enough (except for PositionOrPart, which will default to [0,0,0]).
	# SoundReverbV2.newRayParams( 
		PositionOrPart: Vector3 | BasePart, -- Where to shoot rays from, if you supply a part then that part will be automatically tracked, if a Vector3 then you will have to update it yourself with ReverbObject:UpdatePosition()
		MaxReflections: number, -- How many reflections can occur.
		RaysPerStep: number, -- How many rays we shoot per step.
		MaxDistance: number, -- How far those rays can travel before being stopped.
		IgnoreTransparentParts: boolean, -- Determines if rays can hit transparent parts.
		DebugMode: boolean -- Shows rays if true. [Green = Reflected, Purple = Absorbed, Red = Missed]
	)
			returns rayParams

	


	Note: You don't have to fill out every single argument, some defaults usually work well enough.
	# SoundReverbV2.newSoundParams(
		LerpTime: number, -- How long the lerp between one value to another is (i.e. Going from 1->0 with a LerpTime of 2 would take 2 seconds)
		GroupVolume: number, -- Volume of the sound group; mostly useless, just modify the sound itself.
		Do3DMuffle: boolean, -- Whether or not to muffle sounds behind walls/where the camera can't see them.
	)
			returns soundParams
	
	# SoundReverbV2.new(
		RayParams: RayParams?, [Optional] -- Specified rayParams, created with SoundReverbV2.newRayParams()
		SoundParams: SoundParams?, [Optional] -- Specified soundParams, created with SoundReverbV2.newSoundParams()
	)
			returns ReverbObject
	
	Note: Any sound you add to this will use the reverb calculated from the same point, if you want multiple sounds at different points you will have to make a new ReverbObject for that. 
	# ReverbObject:AddSound(
		Sound: Sound -- Sound to apply reverb to.
	)
	
	# ReverbObject:RemoveSound(
		Sound: Sound -- Sound you want to stop updating.
		RemoveReverb: boolean -- Whether or not to destroy the reverb SoundGroup.
	)
	
	# ReverbObject:StartUpdate() -- Starts firing rays,
	
	# ReverbObject:StopUpdate() -- Stops firing rays, and keeps the same reverb values.
	
	Note: Only use this if you didn't supply a part in the rayParams.
	# ReverbObject:UpdatePosition(
		Vector: Vector3 -- New emission position.
	)
	
	# ReverbObject:SetEmitObject(
		Part: BasePart -- Sets a part to emit from, set it to nil if you want to stop using a part and instead update it with ReverbObject:UpdatePosition()
	)
	
	# ReverbObject:UpdateRayParams(
		RayParams: rayParams -- self-explanatory
	)
	
	# ReverbObject:UpdateRayParams(
		SoundParams: soundParams -- self-explanatory
	)
	
	# ReverbObject:SetReferenceCamera(
		CameraObject: Camera -- Camera used to determine whether or not you can see the sound's source, used for muffling. It's defaulted to CurrentCamera but you can change it if you want.
	)
	
	---------------------------------------
	---------------------------------------
	---------------------------------------
	[Properties]
	
	> SoundReverbV2.MaterialDensity: {["Material"]: number} -- Table of materials that dictates how dense things are, changes HighGain slightly.
	> SoundReverbV2.MaterialReflectiveness: {["Material"]: number} -- Table of materials that dictates how reflective things are, changes WetLevel, RayBounces, and Diffusion.
	
	> ReverbObject.FilterDescendantsInstances: {any} -- Equivalent to RaycastParams.FilterDescendantsInstances
	> ReverbObject.LatestResult: {EqualizerSoundEffect: {any}, ReverbSoundEffect: {any}} -- Table of calculated properties for the sound effects, updates on a heartbeat.
	> ReverbObject.LastPerformanceTick: number -- How long (in ms) it took to do everything, updates on a heartbeat.
	> ReverbObject.AutoApplyList: {Sound} -- Table of sounds to apply reverb to.
	> ReverbObject.StepComplete: RBXScriptSignal -- Signal that you can connect to, fires every heartbeat AFTER everything has been applied.
]]

local VersionNumber = 4? --I'm not certain if the modifications I done to the code would work since I'm writing the code on my school laptop
			--and since my laptop dont have roblox im just hoping for the best that it works
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local CastVisuals = require(script.CastVisuals) --you need this scripts. IDK why all are asking like Jesus
local GoodSignal = require(script.GoodSignal) --you need these scripts. IDK why yall are asking like Jesus

local SoundReverbV2 = { -- self-explanitory 
	MaterialDensity = {-- now the materials are educated guesses. I tried to base every material to the real world so
		Plastic = 0.6,
		ForceField = 0.2,
		Concrete = 0.9,
		Glass = 0.6,
		Grass = 0.2,
		SmoothPlastic = 0.65,
		Cobblestone = 0.85,
		Fabric = 0.3,
		Wood = 0.5,
		WoodPlanks = 0.55,
		Brick = 0.8,
		Sand = 0.4,
		Salt = 0.45,
		Ice = 0.65,
		Metal = 0.9,
		DiamondPlate = 0.95,
		Marble = 0.85,
		Limestone = 0.75,
		Slate = 0.7,
		Granite = 0.9,
		Neon = 0.5,
		CorrodedMetal = 0.85,
		Foil = 0.2,
		Asphalt = 0.7,
		LeafyGrass = 0.15,
		Mud = 0.5,
		Pavement = 0.75,
		Rock = 0.8,
		Snow = 0.2,
		Water = 0.7
	},
	MaterialReflectiveness = {-- another educated guess, change it to whatever you want
		Plastic = 0.5,
		ForceField = 1,
		Glass = 0.7,
		Grass = 0.2,
		SmoothPlastic = 0.55,
		Cobblestone = 0.3,
		Concrete = 0.25,
		Fabric = 0.05,
		Wood = 0.2,
		WoodPlanks = 0.25,
		Brick = 0.2,
		Sand = 0.1,
		Salt = 0.15,
		Ice = 0.6,
		Metal = 0.95,
		DiamondPlate = 0.85,
		Marble = 0.7,
		Limestone = 0.4,
		Slate = 0.3,
		Granite = 0.35,
		Neon = 0.6,
		CorrodedMetal = 0.4,
		Foil = 0.8,
		Asphalt = 0.1,
		LeafyGrass = 0.15,
		Mud = 0.05,
		Pavement = 0.2,
		Rock = 0.25,
		Snow = 0.3,
		Water = 0.8
	},
	MaterialFrequency = { -- about time I got working on this. 
	    	Plastic     = {Low=0.05, Mid=0.10, High=0.15},--the frequency in which the material absorbs from low to high. (i can't exactly find it easily so I just approximated the value)
    		ForceField  = {Low=0.02, Mid=0.03, High=0.04},
    		Concrete    = {Low=0.05, Mid=0.10, High=0.15},
    		Glass       = {Low=0.02, Mid=0.03, High=0.04},
    		Grass       = {Low=0.15, Mid=0.20, High=0.25},
    		SmoothPlastic = {Low=0.05, Mid=0.10, High=0.15},
    		Cobblestone = {Low=0.10, Mid=0.15, High=0.20},
    		Fabric      = {Low=0.05 , Mid=0.15 , High=0.25}, 
    		Wood        = {Low=0.12 , Mid=0.18 , High=0.23}, 
    		WoodPlanks  = {Low=0.10 , Mid=0.15 , High=0.20}, 
    		Brick       = {Low=0.12 , Mid=0.20 , High=0.30}, 
    		Sand        = {Low=0.15 , Mid=0.25 , High=0.35},
    		Salt        = {Low=0.06 , Mid=0.10 , High=0.14}, 
    		Ice         = {Low=0.02 , Mid=0.04 , High=0.06}, 
    		Metal       = {Low=0.05 , Mid=0.07 , High=0.09}, 
    		DiamondPlate ={Low=0.04 , Mid=0.06 , High=0.08}, 
    		Marble      = {Low=0.08 , Mid=0.12 , High=0.16}, 
    		Limestone    = {Low=0.09 , Mid=0.13 , High=0.17}, 
    		Slate        = {Low=0.07 , Mid=0.11 , High=0.15}, 
    		Granite      = {Low=0.05 , Mid=0.07 , High=0.09}, 
    		Neon        = {Low=.03 , Mid=.05 , High=.07}, 
    		CorrodedMetal ={Low=.06 , Mid=.08 , High=.10}, 
    		Foil        = {Low=.02 , Mid=.04 , High=.06}, 
    		Asphalt      = {Low=.10 , Mid=.15 , High=.20},
    		LeafyGrass   ={Low=.05 , Mid=.08 , High=.12}, 
    		Mud          ={Low=.12 , Mid=.18 , High=.24}, 
    		Pavement     ={Low=.08 , Mid=.12 , High=.16}, 
    		Rock         ={Low=.10 , Mid=.15 , High=.20}, 
    		Snow         ={Low=.02, Mid=.04, High=.06}, 
    		Water        ={Low=.01, Mid=.02, High=.03} 
	}
}

local ReverbObject = {}
ReverbObject.__index = ReverbObject

if RunService:IsServer() then -- cant be run on the server side, why would you bruh
	error("SoundReverbV2 can only be required on the client.")
end

function SoundReverbV2.newRayParams(PositionOrPart, MaxReflections, RaysPerStep, MaxDistance, IgnoreTransparentParts, DebugMode)
	local RayParams = {}
	RayParams.Position = PositionOrPart or Vector3.new()
	RayParams.MaxReflections = MaxReflections or 4 -- how much the rays can reflect per hit before being finalized
	RayParams.RaysPerStep = RaysPerStep or 40 -- how many rays per framerate basically 
	RayParams.MaxDistance = MaxDistance or 500 -- distances are in studs
	RayParams.IgnoreTransparentParts = IgnoreTransparentParts or true -- self-explanatory
	RayParams.DebugMode = DebugMode or false -- fancy line thing (it just shows the rays)
	return RayParams
end

function SoundReverbV2.newSoundParams(LerpTime, GroupVolume, Do3DMuffle)
	local SoundParams = {}
	SoundParams.LerpTime = LerpTime or 0.15 -- smooths out the sounds transition and such
	SoundParams.GroupVolume = GroupVolume or 0.5-- how loud is it
	SoundParams.Do3DMuffle = Do3DMuffle or true -- a stupid way of handling occlusion (ill replace this [silly] [ahh] method later when I get back home)
	return SoundParams
end

function SoundReverbV2.new(RayParams, SoundParams) --defines most of the function to make the reverb thing work with other scripts.
	local self = setmetatable({
		_ReferenceCamera = workspace.CurrentCamera, -- slop
		_RayParams = RayParams or SoundReverbV2.newRayParams(),
		_SoundParams = SoundParams or SoundReverbV2.newSoundParams(),
		_SteppedUpdate = nil,
		_DebugFolder = nil,
		_RandomSeed = Random.new(math.round(os.clock())),
		_EmitPosition = nil,
		_EmitObject = nil,
		FilterDescendantsInstances = {},
		LatestResult = {
			EqualizerSoundEffect = {},
			ReverbSoundEffect = {},
		},
		LastPerformanceTick = 0,
		StepComplete = GoodSignal.new(),
		AutoApplyList = {},
	}, ReverbObject)

	self._DebugFolder = workspace:FindFirstChild("SoundReverbV2DebugRays") --creates a folder to store most of the rays in debug mode.
	if not self._DebugFolder and self._RayParams.DebugMode then
		self._DebugFolder = Instance.new("Folder", workspace)
		self._DebugFolder.Name = "SoundReverbV2DebugRays" -- idk why i have to say this but yall should not be messing with this unless you know what your doing
	end

	if typeof(self._RayParams.Position) == "Vector3" then --finds the part or thing that you want to give reverb to.
		self._EmitPosition = self._RayParams.Position
	elseif typeof(self._RayParams.Position) == "Instance" then
		assert(self._RayParams.Position:IsA("BasePart"), "Expected BasePart; got '"..self._RayParams.Position.ClassName.."'.")
		self._EmitObject = self._RayParams.Position
		self._EmitPosition = self._EmitObject.Position
	else
		error("Expected BasePart or Vector3; got '"..typeof(self._RayParams.Position).."'.")
	end

	return self
end

function ReverbObject:_CreateRayVisual(Origin, Direction, Magnitude, Color, Transparency) -- debug [slop] (just read the functions name)
	local self = self
	Color = Color or Color3.new(0,1,0) -- flashy colors (don't try to edit this value, go into CastVisual and change it from there)
	Transparency = Transparency or 0 -- opaque or transparency 
	local CastVisual = CastVisuals.new(Color, self._DebugFolder) 
	CastVisual:Draw(Origin, Direction, Magnitude, Transparency)
end

function ReverbObject:_UpdateStep() -- where most of the juicy math and code stuff is contained inside.
	local self=self --its itself 🤯
	local Filter = table.clone(self.FilterDescendantsInstances)

	local function Normalize(Value, Min, Max) -- normalized so i don't get random ahh bugs
		return (Value - Min)/(Max-Min)
	end

	local function _3DSound() -- 3d sound (it sucks [doo doo] for what I had in mind but it's fine for rn)
		local _, Listener = SoundService:GetListener()
		local ListenerPosition
		if Listener then
			if Listener:IsA("BasePart") then
				ListenerPosition = Listener.Position
			else
				ListenerPosition = Listener.Position
			end
		else
			ListenerPosition = self._ReferenceCamera.CFrame.Position
		end

		local Direction = (self._EmitPosition - ListenerPosition).Unit
		local Distance = (self._EmitPosition - ListenerPosition).Magnitude

		-- Perform a ray cast from the listener to the sound source
		local RaycastParam = RaycastParams.new()
		RaycastParam.FilterType = Enum.RaycastFilterType.Exclude
		RaycastParam.FilterDescendantsInstances = self.FilterDescendantsInstances

		local Raycast = workspace:Raycast(ListenerPosition, Direction * Distance, RaycastParam)

		if Raycast then
			-- If there's an obstruction, calculate the occlusion factor
			local ObstructionDistance = (Raycast.Position - ListenerPosition).Magnitude
			local OcclusionFactor = ObstructionDistance / Distance
			return -10 * OcclusionFactor
		else
			-- If there's no obstruction, return 0 (no muffling)
			return 0
		end
	end

	local function GetMaterialStat(MaterialName: string) -- yells at you if you're missing a material from the list above
		if not SoundReverbV2.MaterialDensity[MaterialName] or not SoundReverbV2.MaterialReflectiveness[MaterialName] then
			if script:GetAttribute("MaterialWarn") then
				warn("Material '"..MaterialName.."' does not have a Density or Reflectiveness set; defaulting to 'Plastic'")
			end
			MaterialName = "Plastic" -- if the material that the ray hits has no density or reflectiveness, then it will just default to plastic.
		end
		return SoundReverbV2.MaterialDensity[MaterialName], SoundReverbV2.MaterialReflectiveness[MaterialName]
	end

	local function RandomDirection() -- makes random directions 🤯
		local Direction = self._RandomSeed:NextUnitVector()
		return Direction
	end

	local function FrequencyAbsorption(materialName: string, distance: number, temperature: number, humidity: number) --IT DONE 😭
	    local properties = SoundReverbV2.MaterialFrequency[materialName] or SoundReverbV2.MaterialFrequency.Plastic
	    local tempFactor = 1 + (temperature - 20) * 0.01 -- temperature. 
	    local humidityFactor = 1 - (humidity / 100) * 0.5 -- humidity.
	    local adjustedLow = properties.Low * tempFactor * humidityFactor
	    local adjustedMid = properties.Mid * tempFactor * humidityFactor
	    local adjustedHigh = properties.High * tempFactor * humidityFactor
	
	    local function calculateBandAbsorption(adjustedCoefficient: number, distance: number)
	        local alpha = adjustedCoefficient
	        local absorption = (1 - math.exp(-alpha * distance)) / (1 + alpha * distance)
	        local frequencyAdjustment = 1 + (0.1 * (math.log10(distance + 1)))
	        return absorption * frequencyAdjustment
	    end
	
	    return {
	        Low = calculateBandAbsorption(adjustedLow, distance),
	        Mid = calculateBandAbsorption(adjustedMid, distance),
	        High = calculateBandAbsorption(adjustedHigh, distance)
	    }
	end
	
	local function Diffusion(incidentDirection: Vector3, normal: Vector3, materialName: string)
	    local properties = SoundReverbV2.MaterialReflectiveness[materialName] or SoundReverbV2.MaterialReflectiveness.Plastic
	    local roughness = 0.1 -- i wonder what this does 🤔. messing with this  value will make the rays more chaotic and unpredictable 
	
	    local reflectedDirection = incidentDirection - (2 * incidentDirection:Dot(normal) * normal)
	
	    local function randomVectorInHemisphere(normal: Vector3)
	        local u = math.random()
	        local v = math.random()
	        local theta = 2 * math.pi * u
	        local phi = math.acos(2 * v - 1)
	        local x = math.sin(phi) * math.cos(theta)
	        local y = math.sin(phi) * math.sin(theta)
	        local z = math.cos(phi)
	        local randomVector = Vector3.new(x, y, z)
	
	        return (randomVector:Dot(normal) < 0) and -randomVector or randomVector
	    end
	
	    local diffuseDirection = randomVectorInHemisphere(normal) * roughness
	    return reflectedDirection:Lerp(diffuseDirection, properties)
	end
	local function Reflect(direction, normal) -- a way to handle reflection (recommend skipping over this because it's very long)
		-- math math math it's just a whole bunch of math. I lost my mind trying to code this
		-- Ultra-high precision arithmetic helper functions
		local function arbitraryPrecisionAdd(a, b, precision) -- Roblox please add arbitrary things soon. i actually hate doing this
			local sum = a + b
			local error = (a - sum) + b
			for _ = 1, precision do
				sum = sum + error
				error = error - (sum - a - b)
			end
			return sum
		end

		local function arbitraryPrecisionMultiply(a, b, precision)
			local product = a * b
			local error = a * b - product
			for _ = 1, precision do
				local correction = error * (1 + 2^-53)
				product = product + correction
				error = error - correction
			end
			return product
		end

		local function arbitraryPrecisionSqrt(x, iterations)
			local r = x
			for _ = 1, iterations do
				r = 0.5 * (r + x / r)
			end
			return r
		end

		local function ultraPreciseNormalize(v)
			local x, y, z = v.X, v.Y, v.Z
			local lengthSquared = arbitraryPrecisionAdd(
				arbitraryPrecisionAdd(
					arbitraryPrecisionMultiply(x, x, 100),
					arbitraryPrecisionMultiply(y, y, 100),
					100
				),
				arbitraryPrecisionMultiply(z, z, 100),
				100
			)
			if lengthSquared == 0 then return Vector3.new() end

			local length = arbitraryPrecisionSqrt(lengthSquared, 100)
			local invLength = 1 / length
			return Vector3.new(
				arbitraryPrecisionMultiply(x, invLength, 100),
				arbitraryPrecisionMultiply(y, invLength, 100),
				arbitraryPrecisionMultiply(z, invLength, 100)
			)
		end

		local function extendedPrecisionDot(v1, v2)
			local sum, c = 0, 0
			local components = {"X", "Y", "Z"}
			for _, comp in ipairs(components) do
				local product = arbitraryPrecisionMultiply(v1[comp], v2[comp], 100)
				local t = arbitraryPrecisionAdd(sum, product, 100)
				if math.abs(sum) >= math.abs(product) then
					c = arbitraryPrecisionAdd(c, arbitraryPrecisionAdd((sum - t), product, 100), 100)
				else
					c = arbitraryPrecisionAdd(c, arbitraryPrecisionAdd((product - t), sum, 100), 100)
				end
				sum = t
			end
			return arbitraryPrecisionAdd(sum, c, 100)
		end

		direction = ultraPreciseNormalize(direction)
		normal = ultraPreciseNormalize(normal)

		local dot = extendedPrecisionDot(direction, normal)

		local function extendedPrecisionClamp(value, min, max)
			if value < min then return min end
			if value > max then return max end
			return value
		end
		dot = extendedPrecisionClamp(dot, -1, 1)

		local scale = arbitraryPrecisionMultiply(2, dot, 100)
		local rx = arbitraryPrecisionAdd(direction.X, -arbitraryPrecisionMultiply(scale, normal.X, 100), 100)
		local ry = arbitraryPrecisionAdd(direction.Y, -arbitraryPrecisionMultiply(scale, normal.Y, 100), 100)
		local rz = arbitraryPrecisionAdd(direction.Z, -arbitraryPrecisionMultiply(scale, normal.Z, 100), 100)
		local reflectedVector = Vector3.new(rx, ry, rz)

		
		local dotReflectedNormal = extendedPrecisionDot(reflectedVector, normal)
		reflectedVector = Vector3.new(
			arbitraryPrecisionAdd(reflectedVector.X, -arbitraryPrecisionMultiply(normal.X, dotReflectedNormal, 100), 100),
			arbitraryPrecisionAdd(reflectedVector.Y, -arbitraryPrecisionMultiply(normal.Y, dotReflectedNormal, 100), 100),
			arbitraryPrecisionAdd(reflectedVector.Z, -arbitraryPrecisionMultiply(normal.Z, dotReflectedNormal, 100), 100)
		)

		reflectedVector = ultraPreciseNormalize(reflectedVector)

		for _ = 1, 50 do
			local finalDot = extendedPrecisionDot(reflectedVector, normal)
			if math.abs(finalDot) > 1e-100 then
				reflectedVector = ultraPreciseNormalize(Vector3.new(
					arbitraryPrecisionAdd(reflectedVector.X, -arbitraryPrecisionMultiply(normal.X, finalDot, 120), 120),
					arbitraryPrecisionAdd(reflectedVector.Y, -arbitraryPrecisionMultiply(normal.Y, finalDot, 120), 120),
					arbitraryPrecisionAdd(reflectedVector.Z, -arbitraryPrecisionMultiply(normal.Z, finalDot, 120), 120)
					))
			else
				break
			end
		end

		local function quaternionFromVectors(u, v)
			local w = arbitraryPrecisionAdd(1, extendedPrecisionDot(u, v), 100)
			local x = arbitraryPrecisionAdd(arbitraryPrecisionMultiply(u.Y, v.Z, 100), -arbitraryPrecisionMultiply(u.Z, v.Y, 100), 100)
			local y = arbitraryPrecisionAdd(arbitraryPrecisionMultiply(u.Z, v.X, 100), -arbitraryPrecisionMultiply(u.X, v.Z, 100), 100)
			local z = arbitraryPrecisionAdd(arbitraryPrecisionMultiply(u.X, v.Y, 100), -arbitraryPrecisionMultiply(u.Y, v.X, 100), 100)
			return {w=w, x=x, y=y, z=z}
		end

		local function quaternionRotateVector(q, v) -- each dimension has to be calculated individually for their quaternion vector. I'm so [fricking] tired Please help
			local qw, qx, qy, qz = q.w, q.x, q.y, q.z -- please do not mess with this value otherwise your cooked and this code will not work at all
			local x = arbitraryPrecisionAdd(
				arbitraryPrecisionMultiply(arbitraryPrecisionAdd(1, -arbitraryPrecisionMultiply(2, arbitraryPrecisionAdd(arbitraryPrecisionMultiply(qy, qy, 100), arbitraryPrecisionMultiply(qz, qz, 100), 100), 100), 100), v.X, 100),
				arbitraryPrecisionAdd(
					arbitraryPrecisionMultiply(arbitraryPrecisionAdd(arbitraryPrecisionMultiply(2, arbitraryPrecisionMultiply(qx, qy, 100), 100), -arbitraryPrecisionMultiply(2, arbitraryPrecisionMultiply(qz, qw, 100), 100), 100), v.Y, 100),
					arbitraryPrecisionMultiply(arbitraryPrecisionAdd(arbitraryPrecisionMultiply(2, arbitraryPrecisionMultiply(qx, qz, 100), 100), arbitraryPrecisionMultiply(2, arbitraryPrecisionMultiply(qy, qw, 100), 100), 100), v.Z, 100),
					100
				),
				100
			)
			local y = arbitraryPrecisionAdd(
				arbitraryPrecisionMultiply(arbitraryPrecisionAdd(arbitraryPrecisionMultiply(2, arbitraryPrecisionMultiply(qx, qy, 100), 100), arbitraryPrecisionMultiply(2, arbitraryPrecisionMultiply(qz, qw, 100), 100), 100), v.X, 100),
				arbitraryPrecisionAdd(
					arbitraryPrecisionMultiply(arbitraryPrecisionAdd(1, -arbitraryPrecisionMultiply(2, arbitraryPrecisionAdd(arbitraryPrecisionMultiply(qx, qx, 100), arbitraryPrecisionMultiply(qz, qz, 100), 100), 100), 100), v.Y, 100),
					arbitraryPrecisionMultiply(arbitraryPrecisionAdd(arbitraryPrecisionMultiply(2, arbitraryPrecisionMultiply(qy, qz, 100), 100), -arbitraryPrecisionMultiply(2, arbitraryPrecisionMultiply(qx, qw, 100), 100), 100), v.Z, 100),
					100
				),
				100
			)
			local z = arbitraryPrecisionAdd(
				arbitraryPrecisionMultiply(arbitraryPrecisionAdd(arbitraryPrecisionMultiply(2, arbitraryPrecisionMultiply(qx, qz, 100), 100), -arbitraryPrecisionMultiply(2, arbitraryPrecisionMultiply(qy, qw, 100), 100), 100), v.X, 100),
				arbitraryPrecisionAdd(
					arbitraryPrecisionMultiply(arbitraryPrecisionAdd(arbitraryPrecisionMultiply(2, arbitraryPrecisionMultiply(qy, qz, 100), 100), arbitraryPrecisionMultiply(2, arbitraryPrecisionMultiply(qx, qw, 100), 100), 100), v.Y, 100),
					arbitraryPrecisionMultiply(arbitraryPrecisionAdd(1, -arbitraryPrecisionMultiply(2, arbitraryPrecisionAdd(arbitraryPrecisionMultiply(qx, qx, 100), arbitraryPrecisionMultiply(qy, qy, 100), 100), 100), 100), v.Z, 100),
					100
				),
				100
			)
			return Vector3.new(x, y, z)
		end

		local rotationQuaternion = quaternionFromVectors(direction, reflectedVector)
		local finalReflectedVector = quaternionRotateVector(rotationQuaternion, direction)

		-- Final ultra-precise normalization
		return ultraPreciseNormalize(finalReflectedVector)
	end


	local function ShootRay(Origin: Vector3, Direction: Vector3, Filter: {any}) -- actually starts firing the rays
		local RaycastParam = RaycastParams.new()
		RaycastParam.FilterType = Enum.RaycastFilterType.Exclude -- Roblox please do not actually remove this function :sob: i need it plz (dw it wont break anything, its just im using this in my game and roblox is saying "its depercated"
		RaycastParam.FilterDescendantsInstances = Filter
		local Raycast = workspace:Raycast(Origin, Direction*self._RayParams.MaxDistance, RaycastParam)
		if Raycast then
			if not Raycast.Instance:IsA("BasePart") then
				return
			end
			if not self._RayParams.IgnoreTransparentParts then
				return
			end
			if Raycast.Instance.Transparency == 1 then
				table.insert(Filter, Raycast.Instance)
				Raycast = ShootRay(Origin, Direction, Filter)
			end
		end
		return Raycast
	end

	local function CanSeeCam(Filter: {}) -- determines if the camera can see the sound source (don't worry about it, its for _3Dsound)
		local Player = game:GetService("Players").LocalPlayer
		local Character = Player.Character
		if Character then
			table.insert(Filter, Character)
		end
		local RaycastParam = RaycastParams.new()
		RaycastParam.FilterType = Enum.RaycastFilterType.Exclude
		RaycastParam.FilterDescendantsInstances = Filter
		local MiddleOfViewport = self._ReferenceCamera.ViewportSize/2 
		local SightOrigin = self._ReferenceCamera.CFrame.Position
		local Direction = (self._EmitPosition - SightOrigin).Unit * ((self._EmitPosition - SightOrigin).Magnitude + 0.01)
		local SightRaycast = workspace:Raycast(SightOrigin, Direction, RaycastParam)
		if SightRaycast then
			if not SightRaycast.Instance:IsA("BasePart") then
				return false
			end
			if not self._RayParams.IgnoreTransparentParts then
				return false
			end
			local TruthValue
			if SightRaycast.Instance.Transparency == 1 then
				table.insert(Filter, SightRaycast.Instance)
				TruthValue = CanSeeCam(Filter)
			end
			return TruthValue
		end
		if SightRaycast then
			return false
		end
		return true
	end
	
	local function GetDistanceWeight(Distance: number) -- determines how far the rays are
		-- Constants with high precision
		local E = 2.7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274  -- Base of the natural logarithm (e to a 100 digits)
		-- you can change the digit to be smaller.
		local LOG_E = 1.0  -- Natural log of e is 1
		local POWER = 1.6 -- power :O
		local OFFSET = 0.8

		-- Ensure Distance is non-negative
		Distance = math.max(Distance, 0)

		-- Clamp Distance to avoid potential issues
		local ClampedDistance = math.clamp(Distance, 1, self._RayParams.MaxDistance)

		-- Calculate natural logarithm using change of base formula
		local LogValue = math.log10(ClampedDistance) / math.log10(E)

		-- Use math.pow for more accurate power calculation
		local PowerResult = math.pow(LogValue, POWER)

		-- Perform final calculation
		local Result = PowerResult - OFFSET

		-- Handle potential floating point errors
		if math.abs(Result) < 1e-10 then
			Result = 0
		end

		return Result
	end




	-- now here was my thought process. I wanted to design a truly endless and modular Reverb system that is 1: very accurate (if needed) and 2: the coder has control over what it wants.
	-- that's why there is a lot of over-engineered slop at the top because I want to see what I can get away with

	local function DoRayLoop() -- after the engine starts, this line handles most of the logic on finding all of those ray results
		local RaySample: SoundRayResult = {
			HitArray = {},
			Bounces = 0,
			AbsorptionAmount = 0,
			DensityAmount = 0,
			TotalDistance = 0,
		}
		local LastRaycast
		local Direction: Vector3

		for Reflections = 0, self._RayParams.MaxReflections, 1 do
			local Normal
			local Origin = self._EmitPosition
			if LastRaycast then
				Origin = LastRaycast.Position
				Normal = LastRaycast.Normal
			end
			if Normal and Direction then
				Direction = Reflect(Direction, Normal)
			else
				Direction = RandomDirection()
			end
			local Raycast = ShootRay(Origin, Direction, Filter)
			if not Raycast then
				if self._RayParams.DebugMode then
					self:_CreateRayVisual(Origin, Direction, self._RayParams.MaxDistance, Color3.new(1,0,0), 0.5)
				end
				return RaySample
			end
			local MaterialDensity, MaterialReflectiveness = GetMaterialStat(Raycast.Material.Name)
			table.insert(RaySample.HitArray, {Instance = Raycast.Instance, Position = Raycast.Position})
			local AbsorptionChance = (1-MaterialReflectiveness) - 0.0001
			RaySample.TotalDistance += Raycast.Distance
			if AbsorptionChance > self._RandomSeed:NextNumber() then
				if self._RayParams.DebugMode then
					self:_CreateRayVisual(Origin, Direction, Raycast.Distance, Color3.new(0.635294, 0, 1), 0)
				end
				RaySample.AbsorptionAmount += 1-MaterialReflectiveness
				RaySample.DensityAmount += MaterialDensity
				return RaySample
			end
			RaySample.Bounces += 1
			RaySample.AbsorptionAmount += ((1-MaterialReflectiveness/2))/self._RayParams.MaxReflections
			RaySample.DensityAmount += MaterialDensity/self._RayParams.MaxReflections
			if self._RayParams.DebugMode then
				self:_CreateRayVisual(Origin, Direction, Raycast.Distance, Color3.new(1, 1, 1), 0)
			end
			LastRaycast = Raycast
		end
		return RaySample
	end




	local BaseDecayTime = 1.0 -- Adjust this value based on your desired base decay time
	local DistanceFactor = 0.7 -- Adjust to control how much distance affects decay time
	local AbsorptionFactor = 0.5 -- Adjust to control how much absorption affects decay time
	local MaxDecayTime = 10.0 -- What do you think dawg
	local MinDecayTime = 0.1 -- what do you think dawg




	local RaySampleArray = {}
	for RayCount = 1, self._RayParams.RaysPerStep, 1 do
		local Reflected = false
		local LastRaycast = nil

		local RaySample = DoRayLoop()

		table.insert(RaySampleArray, RaySample)
	end

	local function arbitraryPrecisionAdd(a, b, precision) -- math >:( not even hard just [fricking] annoying to code
		local sum = a + b
		local error = (a - sum) + b
		for _ = 1, precision do
			sum = sum + error
			error = error - (sum - a - b)
		end
		return sum
	end

	local function arbitraryPrecisionMultiply(a, b, precision)
		local product = a * b
		local error = a * b - product
		for _ = 1, precision do
			local correction = error * (1 + 2^-53)
			product = product + correction
			error = error - correction
		end
		return product
	end

	local function arbitraryPrecisionDivide(a, b, precision)
		local quotient = a / b
		for _ = 1, precision do
			quotient = quotient + (a - quotient * b) / b
		end
		return quotient
	end

	local function arbitraryPrecisionSqrt(x, iterations)
		local r = x
		for _ = 1, iterations do
			r = 0.5 * (r + x / r)
		end
		return r -- r
	end

	local AveragedSample = { -- after the loop finds the value, the value it gets sent here.
		TotalBounces = 0,
		Density = 0,
		Absorption = 0,
		Distance = 0,
		AverageBounces = 0,
		DistanceWeight = 0,
		TotalDistance = 0
	}

	local highPrecision = 100  -- adjust this for even higher precision (it's very computationally powerful so just keep it at 100)

	for _, RaySample in ipairs(RaySampleArray) do
		local bouncesPlus1 = arbitraryPrecisionAdd(RaySample.Bounces, 1, highPrecision)
		local raysPerStep = self._RayParams.RaysPerStep

		AveragedSample.Density = arbitraryPrecisionAdd( -- thankfully the reflection system contains most of the function so i don't have to create so much math
			AveragedSample.Density,
			arbitraryPrecisionDivide(
				arbitraryPrecisionDivide(RaySample.DensityAmount, bouncesPlus1, highPrecision),
				raysPerStep,
				highPrecision
			),
			highPrecision
		)

		AveragedSample.Absorption = arbitraryPrecisionAdd(
			AveragedSample.Absorption,
			arbitraryPrecisionDivide(
				arbitraryPrecisionDivide(RaySample.AbsorptionAmount, bouncesPlus1, highPrecision),
				raysPerStep,
				highPrecision
			),
			highPrecision
		)

		local distanceWeight = GetDistanceWeight(
			arbitraryPrecisionDivide(RaySample.TotalDistance, bouncesPlus1, highPrecision)
		)
		AveragedSample.DistanceWeight = arbitraryPrecisionAdd(
			AveragedSample.DistanceWeight,
			arbitraryPrecisionDivide(distanceWeight, raysPerStep, highPrecision),
			highPrecision
		)

		AveragedSample.TotalDistance = arbitraryPrecisionAdd(
			AveragedSample.TotalDistance,
			RaySample.TotalDistance,
			highPrecision
		)

		AveragedSample.TotalBounces = arbitraryPrecisionAdd(
			AveragedSample.TotalBounces,
			arbitraryPrecisionDivide(RaySample.Bounces, raysPerStep, highPrecision),
			highPrecision
		)

		AveragedSample.AverageBounces = arbitraryPrecisionAdd(
			AveragedSample.AverageBounces,
			arbitraryPrecisionDivide(
				arbitraryPrecisionDivide(RaySample.Bounces, bouncesPlus1, highPrecision),
				raysPerStep,
				highPrecision
			),
			highPrecision
		)
	end

	local function clamp(value, min, max) -- clamps the number so they don't go overboard for Roblox standards
		return math.min(math.max(value, min), max)
	end

	local FinalResult = {-- defines the actual reverberation values that Roblox has
		EqualizerSoundEffect = { 
			HighGain = 0,
			MidGain = 0,
			LowGain = 0
		},
		ReverbSoundEffect = {
			Density = 0,
			WetLevel = 0,
			Diffusion = 0,
			DryLevel = 0,
		}
	}
		--Now here is where the actual reverb thing gets applied 
	FinalResult.ReverbSoundEffect.Density = AveragedSample.Density

	FinalResult.ReverbSoundEffect.DecayTime = clamp(
		arbitraryPrecisionAdd(
			0.1,
			arbitraryPrecisionAdd(
				arbitraryPrecisionMultiply(2, AveragedSample.DistanceWeight, highPrecision),
				arbitraryPrecisionMultiply(3, AveragedSample.Density, highPrecision),
				highPrecision
			),
			highPrecision
		),
		0.1,
		20
	)

	FinalResult.ReverbSoundEffect.WetLevel = clamp(
		arbitraryPrecisionAdd(
			-20,
			arbitraryPrecisionAdd(
				arbitraryPrecisionMultiply(30, AveragedSample.AverageBounces, highPrecision),
				arbitraryPrecisionMultiply(5, arbitraryPrecisionAdd(-4, AveragedSample.DistanceWeight, highPrecision), highPrecision),
				highPrecision
			),
			highPrecision
		),
		-80,
		0
	)

	FinalResult.ReverbSoundEffect.Diffusion = clamp(
		arbitraryPrecisionAdd(
			0.2,
			arbitraryPrecisionMultiply(
				0.8,
				arbitraryPrecisionMultiply(
					arbitraryPrecisionAdd(1, -AveragedSample.AverageBounces, highPrecision),
					arbitraryPrecisionAdd(1, -AveragedSample.Absorption, highPrecision),
					highPrecision
				),
				highPrecision
			),
			highPrecision
		),
		0,
		1
	)

	FinalResult.ReverbSoundEffect.DryLevel = clamp(
		arbitraryPrecisionAdd(
			-10,
			arbitraryPrecisionAdd(
				arbitraryPrecisionMultiply(20, arbitraryPrecisionAdd(1, -AveragedSample.Absorption, highPrecision), highPrecision),
				arbitraryPrecisionMultiply(5, AveragedSample.DistanceWeight, highPrecision),
				highPrecision
			),
			highPrecision
		),
		-10,
		6
	)

	FinalResult.EqualizerSoundEffect.HighGain = arbitraryPrecisionAdd(-AveragedSample.Density, _3DSound(), highPrecision)

 	-- i would of placed it somewhere good but for right now this works even though its in a not so good spot

	local EarlyReflections = {}
	local MaxEarlyReflections = 12 -- Number of early reflections to consider
	local EarlyReflectionDelay = 0.02 -- Delay between early reflections in seconds

	local TotalRays = self._RayParams.RaysPerStep
	local TotalReflections = 0
	local TotalAbsorptions = 0
	local TotalMisses = 0
	local AverageDistance = 0
	local AverageDensity = 0
	local AverageReflectiveness = 0

	for i = 1, TotalRays do -- the new early reflection and late reflection are here
		local Direction = RandomDirection()
		local Origin = self._EmitPosition
		local RaycastParam = RaycastParams.new()
		RaycastParam.FilterType = Enum.RaycastFilterType.Exclude
		RaycastParam.FilterDescendantsInstances = Filter
		RaycastParam.IgnoreWater = true

		local ReflectionCount = 0
		local TotalDistance = 0
		local LastHit = nil

		while ReflectionCount < self._RayParams.MaxReflections do
			local RayResult = workspace:Raycast(Origin, Direction * self._RayParams.MaxDistance, RaycastParam)

			if RayResult then
				local HitDistance = (RayResult.Position - Origin).Magnitude
				TotalDistance += HitDistance

				-- Early Reflection Logic
				if ReflectionCount < MaxEarlyReflections then
					table.insert(EarlyReflections, {
						Distance = TotalDistance,
						Delay = TotalDistance / 343 + ReflectionCount * EarlyReflectionDelay, -- 343 m/s is speed of sound
						Intensity = 1 / (TotalDistance * TotalDistance) -- Inverse square law
					})
				end

				local MaterialName = RayResult.Material.Name
				local Density, Reflectiveness = GetMaterialStat(MaterialName)

				AverageDensity += Density
				AverageReflectiveness += Reflectiveness

				if self._RayParams.DebugMode then
					self:_CreateRayVisual(Origin, Direction * HitDistance, HitDistance, Color3.new(0,1,0), 0.75)
				end

				if self._RandomSeed:NextNumber() > Reflectiveness then
					TotalAbsorptions += 1
					if self._RayParams.DebugMode then
						self:_CreateRayVisual(RayResult.Position, RayResult.Normal, 2, Color3.new(1,0,1), 0)
					end
					break
				end

				Origin = RayResult.Position
				Direction = Reflect(Direction, RayResult.Normal)
				ReflectionCount += 1
				TotalReflections += 1
				LastHit = RayResult
			else
				TotalMisses += 1
				if self._RayParams.DebugMode then
					self:_CreateRayVisual(Origin, Direction * self._RayParams.MaxDistance, self._RayParams.MaxDistance, Color3.new(1,0,0), 0.75)
				end
				break
			end
		end

		AverageDistance += TotalDistance
	end

	AverageDistance /= TotalRays
	AverageDensity /= (TotalReflections + TotalAbsorptions)
	AverageReflectiveness /= (TotalReflections + TotalAbsorptions)
	
	
	-- Process Early Reflections
	local EarlyReflectionGain = 0
	for _, reflection in ipairs(EarlyReflections) do
		EarlyReflectionGain += reflection.Intensity
	end
	EarlyReflectionGain = EarlyReflectionGain / #EarlyReflections

	-- Calculate reverb parameters
	local Diffusion = Normalize(TotalReflections / TotalRays, 0, self._RayParams.MaxReflections)
	local DecayTime = AverageDistance / 343 * 2 -- 343 m/s is speed of sound
	local Density = AverageDensity
	local WetLevel = AverageReflectiveness

	-- Apply early reflections to reverb parameters
	Diffusion = Diffusion * (1 + EarlyReflectionGain)
	DecayTime = DecayTime * (1 - EarlyReflectionGain * 0.2) -- Slightly reduce decay time based on early reflections
	WetLevel = WetLevel * (1 + EarlyReflectionGain * 0.5)

	local LateReflectionCount = 50 -- Number of late reflections to simulate
	local LateReflectionStartTime = 0.08 -- 80 ms, typical transition from early to late reflections
	local LateReflectionDecayTime = 1.5 -- Adjustable based on room size
	
	local EarlyReflections = {}
	local LateReflections = {}
	local MaxEarlyReflections = 10
	local EarlyReflectionDelay = 0.02
	
	local LateReflectionEnergy = 0
	for i = 1, LateReflectionCount do
		local delay = LateReflectionStartTime + i * (LateReflectionDecayTime / LateReflectionCount)
		local energy = math.exp(-delay / LateReflectionDecayTime)
		LateReflectionEnergy = LateReflectionEnergy + energy
		table.insert(LateReflections, {
			Delay = delay,
			Energy = energy
		})
	end
	
	function ReverbObject:CalculateEarlyReflectionGain(EarlyReflections)
		local totalGain = 0
		for _, reflection in ipairs(EarlyReflections) do
			totalGain = totalGain + reflection.Intensity
		end
		return totalGain / #EarlyReflections
	end

	function ReverbObject:CalculateLateReflectionGain(LateReflections)
		local totalGain = 0
		for _, reflection in ipairs(LateReflections) do
			totalGain = totalGain + reflection.Energy
		end
		return totalGain / #LateReflections
	end

	function ReverbObject:EstimateRoomSize(AverageDistance)
		-- Simple estimation based on average ray distance
		return math.clamp(AverageDistance / 10, 0, 1)
	end

	function ReverbObject:CalculateReverberance(LateReflections, RoomSize)
		local lateDensity = #LateReflections / LateReflectionCount
		return math.clamp(lateDensity * RoomSize, 0, 1)
	end
	
	-- Normalize late reflection energy
	for _, reflection in ipairs(LateReflections) do
		reflection.Energy = reflection.Energy / LateReflectionEnergy
	end

	-- Calculate reverb parameters
	local Diffusion = Normalize(TotalReflections / TotalRays, 0, self._RayParams.MaxReflections)
	local DecayTime = AverageDistance / 343 * 2 -- 343 m/s is speed of sound
	local Density = AverageDensity
	local WetLevel = AverageReflectiveness

	-- Apply early and late reflections to reverb parameters
	local EarlyReflectionGain = self:CalculateEarlyReflectionGain(EarlyReflections)
	local LateReflectionGain = self:CalculateLateReflectionGain(LateReflections)

	Diffusion = Diffusion * (1 + EarlyReflectionGain * 0.5 + LateReflectionGain * 0.5)
	DecayTime = DecayTime * (1 + LateReflectionGain * 0.2)
	WetLevel = WetLevel * (1 + EarlyReflectionGain * 0.3 + LateReflectionGain * 0.7)

	-- Additional late reflection effects
	local RoomSize = self:EstimateRoomSize(AverageDistance)
	local Reverberance = self:CalculateReverberance(LateReflections, RoomSize)

	-- Update LatestResult with new parameters
	self.LatestResult.ReverbSoundEffect.Diffusion = Diffusion
	self.LatestResult.ReverbSoundEffect.DecayTime = DecayTime
	self.LatestResult.ReverbSoundEffect.Density = Density
	self.LatestResult.ReverbSoundEffect.WetLevel = WetLevel
	self.LatestResult.ReverbSoundEffect.Reverberance = Reverberance
	
	

	if self._SoundParams.Do3DMuffle then
		if not CanSeeCam(Filter) then
			FinalResult.EqualizerSoundEffect.HighGain = arbitraryPrecisionAdd(
				FinalResult.EqualizerSoundEffect.HighGain,
				arbitraryPrecisionMultiply(
					-20,
					arbitraryPrecisionDivide((self._ReferenceCamera.CFrame.Position - self._EmitPosition).Magnitude, 40, highPrecision),
					highPrecision
				),
				highPrecision
			)
		else
			FinalResult.EqualizerSoundEffect.HighGain = arbitraryPrecisionAdd(
				FinalResult.EqualizerSoundEffect.HighGain,
				arbitraryPrecisionMultiply(
					-2,
					arbitraryPrecisionDivide((self._ReferenceCamera.CFrame.Position - self._EmitPosition).Magnitude, 40, highPrecision),
					highPrecision
				),
				highPrecision
			)
		end
	end

	self.LatestResult = FinalResult
end
function ReverbObject:AddSound(Sound: Sound)
	local self: ObjectMeta = self

	if table.find(self.AutoApplyList, Sound) then
		warn("'"..Sound.Name.."' is already on auto apply list.")
		return
	end

	table.insert(self.AutoApplyList, Sound)
end

function ReverbObject:RemoveSound(Sound: Sound, RemoveReverb: boolean) -- what do you think it does bruh
	local self: ObjectMeta = self

	RemoveReverb = RemoveReverb or true

	if not table.find(self.AutoApplyList, Sound) then
		warn("Could not find '"..Sound.Name.."' on auto apply list.")
		return
	end

	if RemoveReverb then
		for i, Object in Sound:GetChildren() do
			if Object:IsA("SoundGroup") then
				Object:Destroy()
			end
		end
	end

	table.remove(self.AutoApplyList, table.find(self.AutoApplyList, Sound))
end

function ReverbObject:ApplyToSound(Sound: Sound, dt: number)
	local self: ObjectMeta = self

	local function lerp(a, b, t)
		return a + (b - a) * t
	end

	local SoundGroup: SoundGroup = Sound:FindFirstChildWhichIsA("SoundGroup")

	if not SoundGroup then
		SoundGroup = Instance.new("SoundGroup", Sound)
		SoundGroup.Name = "SoundReverbV"..VersionNumber.."Group"
	end

	SoundGroup.Volume = self._SoundParams.GroupVolume
	Sound.SoundGroup = SoundGroup

	local EqualizerInstance = SoundGroup:FindFirstChildWhichIsA("EqualizerSoundEffect")
	local ReverbInstance = SoundGroup:FindFirstChildWhichIsA("ReverbSoundEffect")

	if not EqualizerInstance then
		EqualizerInstance = Instance.new("EqualizerSoundEffect", SoundGroup)
		EqualizerInstance.Name = "SoundReverbV"..VersionNumber.."Equalizer"
	end
	if not ReverbInstance then
		ReverbInstance = Instance.new("ReverbSoundEffect", SoundGroup)
		ReverbInstance.Name = "SoundReverbV"..VersionNumber.."Reverb"
	end

	for Property, Value in self.LatestResult.EqualizerSoundEffect do
		EqualizerInstance[Property] = lerp(EqualizerInstance[Property], Value, 1/self._SoundParams.LerpTime * dt)
	end

	for Property, Value in self.LatestResult.ReverbSoundEffect do
		ReverbInstance[Property] = lerp(ReverbInstance[Property], Value, 1/self._SoundParams.LerpTime * dt)
	end
end

function ReverbObject:StartUpdate()
	local self: ObjectMeta = self

	if self._SteppedUpdate then
		return
	end

	self._SteppedUpdate = RunService.Heartbeat:Connect(function (dt)
		local StartTime = os.clock()

		if self._DebugFolder then
			if self._DebugFolder:FindFirstChild("CastOriginPart") then

				for _, Object in self._DebugFolder.CastOriginPart:GetChildren() do
					Object:Destroy()	
				end
			end

		end

		if self._EmitObject then
			self._EmitPosition = self._EmitObject.Position
		end

		for _, Sound in self.AutoApplyList do
			self:ApplyToSound(Sound, dt)
		end

		self:_UpdateStep()
		self.LastPerformanceTick = (os.clock() - StartTime)*1e3
		self.StepComplete:Fire()
	end)
end

function ReverbObject:StopUpdate()
	local self: ObjectMeta = self

	if not self._SteppedUpdate then
		return
	end

	self._SteppedUpdate:Disconnect()
	self._SteppedUpdate = nil
end

function ReverbObject:UpdatePosition(Vector: Vector3)
	if self._EmitObject then
		warn("Emit object is already set; don't use UpdatePosition.") -- yeah dont use UpdatePosition, its trash
	end

	self._EmitPosition = Vector
end

function ReverbObject:SetEmitObject(BasePart: BasePart)
	self._EmitObject = BasePart 
end

function ReverbObject:UpdateRayParams(RayParams: RayParams)
	self._RayParams = RayParams
end

function ReverbObject:UpdateSoundParams(SoundParams: SoundParams)
	self._SoundParams = SoundParams
end

function ReverbObject:SetReferenceCamera(CameraObject: Camera)
	local self: ObjectMeta = self
	assert(CameraObject.ClassName == "Camera", "Expected Camera; Got "..CameraObject.ClassName.."'.")
	self._ReferenceCamera = CameraObject
end

return SoundReverbV2
