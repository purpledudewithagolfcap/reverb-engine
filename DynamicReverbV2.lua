--[[
	This is rather expensive to run,
	I do NOT recommend using this if you are at all concerned with performance.
	Maybe one day I might parallelize it, but for now, this works.

	Please be aware today that this update HEAVLIY focuses on math so just download this file and go on with your merry way. But honestly please check the code to see if it fits your needs.

	A lot of you folks asked a whole bunch of questions; I'll answer them here in this list:
	(The questions are from the Google Form results) 

	Q: Do you work alone? A: Yes.

	Q: How do I start coding A: Don't be asking me how to start. If you're passionate about coding then just search up YT tutorials. otherwise don't try to code because it's popular.

	Q: Can I work with you? A: Not directly, the code is open-source which you can edit to fit whatever scenario.

	Q: serugjgni5b4tu54 A: Yes?

	Q: How do I contact you? A: If you have Discord you can get in touch with me. My name is Purpledudewithagolfcap

	Q: bloxwitch A: Garry's Mod reference?

	Q: How long will you update this for? A: Not determined. Maybe if I get tired or burned out it might stop but for right now I don't have a plan on stopping.

	Q: [REDACTED BECAUSE IT IS A BUNCH OF SLURS] A: Why thank you for those nice words.

	Q: If anyone stole this code or didn't credit you will you do anything about it? A: No, I can't do much in terms of legal action. But I can criticize them to hell.

	Q: release every single project you have i know you have a car engine in the work and like this gun engine thing too so please release them to me or the public. Otherwise ill copy your game and get it myself A: Fuck no. I'm not going to release something in WIP. The car engine may be finished but I'm not going to leak this project to you or anyone because they said so. Fucking Leeches.

	Q: (@)JE#J)#F A: no

	Q:  A: How did you submit nothing?

	V2 fixes a lot of problems with the first iteration of this module; mainly related to how I handled absorption.
	Now for V2/5 it mostly improves on the math behind the reflection system. I focused hard on the reflection because of how important it is.
	If you do not like this update please give me a notice or just rewrite the function to be what you intend.
	You are free to use this as you wish, and please notify me if you find any bugs.
	Credit is not required but appreciated!
	
	---Quick Start Guide---
		1. Require the module (duh). Make sure you do this on the client, as it doesn't make much sense to have the server calculate the reverb (also it doesn't work serverside anyways).
		2. Create rayParams with SoundReverbV2.newRayParams() to specify where to shoot rays from, how many rays, etc.
		3. Make a new ReverbObject with SoundReverbV2.new(RayParams: rayParams?, SoundParams: soundParams?), and you can pass your params through with it.
		4. Add your sound(s) with ReverbObject:AddSound(MySound)
		5. Start the raycasting with ReverbObject:StartUpdate(), and you are done!
		
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

local VersionNumber = 2.5
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local CastVisuals = require(script.CastVisuals)
local GoodSignal = require(script.GoodSignal)

local SoundReverbV2 = {
	MaterialDensity = {
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
	MaterialReflectiveness = {
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
	}
}

local ReverbObject = {}
ReverbObject.__index = ReverbObject

if RunService:IsServer() then
	error("SoundReverbV2 can only be required on the client.")
end

function SoundReverbV2.newRayParams(PositionOrPart, MaxReflections, RaysPerStep, MaxDistance, IgnoreTransparentParts, DebugMode)
	local RayParams = {}
	RayParams.Position = PositionOrPart or Vector3.new()
	RayParams.MaxReflections = MaxReflections or 4
	RayParams.RaysPerStep = RaysPerStep or 40
	RayParams.MaxDistance = MaxDistance or 500
	RayParams.IgnoreTransparentParts = IgnoreTransparentParts or true
	RayParams.DebugMode = DebugMode or false
	return RayParams
end

function SoundReverbV2.newSoundParams(LerpTime, GroupVolume, Do3DMuffle)
	local SoundParams = {}
	SoundParams.LerpTime = LerpTime or 0.15
	SoundParams.GroupVolume = GroupVolume or 0.5
	SoundParams.Do3DMuffle = Do3DMuffle or true
	return SoundParams
end

function SoundReverbV2.new(RayParams, SoundParams)
	local self = setmetatable({
		_ReferenceCamera = workspace.CurrentCamera,
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

	self._DebugFolder = workspace:FindFirstChild("SoundReverbV2DebugRays")
	if not self._DebugFolder and self._RayParams.DebugMode then
		self._DebugFolder = Instance.new("Folder", workspace)
		self._DebugFolder.Name = "SoundReverbV2DebugRays"
	end

	if typeof(self._RayParams.Position) == "Vector3" then
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

function ReverbObject:_CreateRayVisual(Origin, Direction, Magnitude, Color, Transparency)
	local self = self
	Color = Color or Color3.new(0,1,0)
	Transparency = Transparency or 0
	local CastVisual = CastVisuals.new(Color, self._DebugFolder)
	CastVisual:Draw(Origin, Direction, Magnitude, Transparency)
end

function ReverbObject:_UpdateStep()
	local self=self
	local Filter = table.clone(self.FilterDescendantsInstances)

	local function Normalize(Value, Min, Max)
		return (Value - Min)/(Max-Min)
	end

	local function _3DSound()
		local _, Listener = SoundService:GetListener()
		if Listener then
			if Listener:IsA("BasePart") then
				Listener = Listener.CFrame
			end
		else
			Listener = self._ReferenceCamera.CFrame
		end
		local Facing = Listener.LookVector
		local Vector = (self._EmitPosition - Listener.Position).unit
		Facing = Vector3.new(Facing.X,0,Facing.Z)
		Vector = Vector3.new(Vector.X,0,Vector.Z)
		local Angle = math.acos(Facing:Dot(Vector)/(Facing.magnitude*Vector.magnitude))
		return -(10 * ((Angle/math.pi)^2))
	end

	local function GetMaterialStat(MaterialName: string)
		if not SoundReverbV2.MaterialDensity[MaterialName] or not SoundReverbV2.MaterialReflectiveness[MaterialName] then
			if script:GetAttribute("MaterialWarn") then
				warn("Material '"..MaterialName.."' does not have a Density or Reflectiveness set; defaulting to 'Plastic'")
			end
			MaterialName = "Plastic"
		end
		return SoundReverbV2.MaterialDensity[MaterialName], SoundReverbV2.MaterialReflectiveness[MaterialName]
	end

	local function RandomDirection()
		local Direction = self._RandomSeed:NextUnitVector()
		return Direction
	end
-- This took fucking months to figure out. Why did I go through the effort of making the Reflect() super accurate? because I was designing the engine for a game. The main-
-- -purpose of the game was to avoid some monster that can hear things and such. While it may not be optimal for performance, it is more accurate than any other sound tracing system out there.
-- But yeah you can rewrite this function to fit whatever needs you have. But just know how much pain and sweat I put into this single line. While it sounds painful it did teach me more about-
-- -how Lua or just ROBLOX in general handles math and such. It's pretty decent for normal uses until we get shit like this. Now I did a shit ton of searching to figure out this mess. I've only just now started high school.
	
	local function Reflect(direction, normal)
		-- Ultra-high precision arithmetic helper functions
		local function arbitraryPrecisionAdd(a, b, precision)
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

		-- Ultra-high precision normalization
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

		-- Kahan-Babuška-Neumaier summation for extended-precision dot product
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

		-- Normalize input vectors with ultra-high precision
		direction = ultraPreciseNormalize(direction)
		normal = ultraPreciseNormalize(normal)

		-- Calculate dot product with extended precision
		local dot = extendedPrecisionDot(direction, normal)

		-- Clamp dot product with extended precision
		local function extendedPrecisionClamp(value, min, max)
			if value < min then return min end
			if value > max then return max end
			return value
		end
		dot = extendedPrecisionClamp(dot, -1, 1)

		-- Calculate reflection vector using arbitrary-precision arithmetic
		local scale = arbitraryPrecisionMultiply(2, dot, 100)
		local rx = arbitraryPrecisionAdd(direction.X, -arbitraryPrecisionMultiply(scale, normal.X, 100), 100)
		local ry = arbitraryPrecisionAdd(direction.Y, -arbitraryPrecisionMultiply(scale, normal.Y, 100), 100)
		local rz = arbitraryPrecisionAdd(direction.Z, -arbitraryPrecisionMultiply(scale, normal.Z, 100), 100)

		local reflectedVector = Vector3.new(rx, ry, rz)

		-- Apply Gram-Schmidt process with arbitrary-precision arithmetic
		local dotReflectedNormal = extendedPrecisionDot(reflectedVector, normal)
		reflectedVector = Vector3.new(
			arbitraryPrecisionAdd(reflectedVector.X, -arbitraryPrecisionMultiply(normal.X, dotReflectedNormal, 100), 100),
			arbitraryPrecisionAdd(reflectedVector.Y, -arbitraryPrecisionMultiply(normal.Y, dotReflectedNormal, 100), 100),
			arbitraryPrecisionAdd(reflectedVector.Z, -arbitraryPrecisionMultiply(normal.Z, dotReflectedNormal, 100), 100)
		)

		-- Ensure output is normalized using ultra-high precision normalization
		reflectedVector = ultraPreciseNormalize(reflectedVector)

		-- Apply iterative correction with increased precision
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

		-- Final validation using quaternion rotation
		local function quaternionFromVectors(u, v)
			local w = arbitraryPrecisionAdd(1, extendedPrecisionDot(u, v), 100)
			local x = arbitraryPrecisionAdd(arbitraryPrecisionMultiply(u.Y, v.Z, 100), -arbitraryPrecisionMultiply(u.Z, v.Y, 100), 100)
			local y = arbitraryPrecisionAdd(arbitraryPrecisionMultiply(u.Z, v.X, 100), -arbitraryPrecisionMultiply(u.X, v.Z, 100), 100)
			local z = arbitraryPrecisionAdd(arbitraryPrecisionMultiply(u.X, v.Y, 100), -arbitraryPrecisionMultiply(u.Y, v.X, 100), 100)
			return {w=w, x=x, y=y, z=z}
		end

		local function quaternionRotateVector(q, v)
			local qw, qx, qy, qz = q.w, q.x, q.y, q.z
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


	local function ShootRay(Origin: Vector3, Direction: Vector3, Filter: {any})
		local RaycastParam = RaycastParams.new()
		RaycastParam.FilterType = Enum.RaycastFilterType.Exclude
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

	local function CanSeeCam(Filter: {})
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
	----------------------------------------------------------EXPERIMENTAL MODE DO NOT MESS WITH------------------------------------
	-- Helper function to calculate atmospheric attenuation
	local function GetDistanceWeight(Distance: number)
		-- Constants with high precision
		local E = 2.7182818284590452353602874713527  -- Base of natural logarithm (e)
		local LOG_E = 1.0  -- Natural log of e is 1
		local POWER = 1.6
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

	------------------------------------------------------------EXPERIMENTAL MODE ENDS HERE------------------------------------------------------------------------------




	-- now here was my thought process. I wanted to design a truely endless and modular Reverb system that is 1: very accurate (if needed) and 2: the coder has control on what it wants.
	-- thats why there is alot of over-engineered slop here because i want to see what i can get away with

	local function DoRayLoop()
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
					self:_CreateRayVisual(Origin, Direction, Raycast.Distance, Color3.new(0.5,0,1), 0)
				end
				RaySample.AbsorptionAmount += 1-MaterialReflectiveness
				RaySample.DensityAmount += MaterialDensity
				return RaySample
			end
			RaySample.Bounces += 1
			RaySample.AbsorptionAmount += ((1-MaterialReflectiveness/2))/self._RayParams.MaxReflections
			RaySample.DensityAmount += MaterialDensity/self._RayParams.MaxReflections
			if self._RayParams.DebugMode then
				self:_CreateRayVisual(Origin, Direction, Raycast.Distance, Color3.new(0,1,0), 0)
			end
			LastRaycast = Raycast
		end
		return RaySample
	end




	local BaseDecayTime = 1.0 -- Adjust this value based on your desired base decay time
	local DistanceFactor = 0.7 -- Adjust to control how much distance affects decay time
	local AbsorptionFactor = 0.5 -- Adjust to control how much absorption affects decay time
	local MaxDecayTime = 10.0
	local MinDecayTime = 0.1




	local RaySampleArray = {}
	for RayCount = 1, self._RayParams.RaysPerStep, 1 do
		local Reflected = false
		local LastRaycast: RaycastResult = nil

		local RaySample = DoRayLoop()

		table.insert(RaySampleArray, RaySample)
	end

	local AveragedSample = {
		TotalBounces = 0;
		Density = 0;
		Absorption = 0;
		Distance = 0;
		AverageBounces = 0;
		DistanceWeight = 0;
		TotalDistance = 0;
	}

	local DensityFactor = math.clamp(AveragedSample.Density, 0, 1)
	local BaseDensity = 0.  -- Adjust this base value as needed
	local MaxDensity = 1.0   -- Maximum density value

	for _, RaySample: SoundRayResult in RaySampleArray do
		AveragedSample.Density += RaySample.DensityAmount / (RaySample.Bounces+1) / self._RayParams.RaysPerStep
		AveragedSample.Absorption += RaySample.AbsorptionAmount / (RaySample.Bounces+1) / self._RayParams.RaysPerStep
		AveragedSample.DistanceWeight += GetDistanceWeight(RaySample.TotalDistance/(RaySample.Bounces+1)) / self._RayParams.RaysPerStep
		AveragedSample.TotalDistance += RaySample.TotalDistance
		AveragedSample.TotalBounces += RaySample.Bounces / self._RayParams.RaysPerStep
		AveragedSample.AverageBounces += RaySample.Bounces / (RaySample.Bounces+1) / self._RayParams.RaysPerStep
	end



	local FinalResult = {
		EqualizerSoundEffect = {
			HighGain = 0;
			MidGain = 0;
			LowGain = 0
		};

		ReverbSoundEffect = {
			Density = 0;
			WetLevel = 0;
			Diffusion = 0;
			DryLevel = 0;
		};
	}



	FinalResult.ReverbSoundEffect.Density = AveragedSample.Density
	FinalResult.ReverbSoundEffect.DecayTime = math.clamp(
		0.1 + (2 * AveragedSample.DistanceWeight) + (3 * AveragedSample.Density),
		0.1,
		20
	)
	FinalResult.ReverbSoundEffect.WetLevel = math.clamp(-20 + (30 * AveragedSample.AverageBounces) + (5 * (-4+AveragedSample.DistanceWeight)), -80, 0)
	FinalResult.ReverbSoundEffect.Diffusion = math.clamp(0.2 + (0.8 * (1 - AveragedSample.AverageBounces) * (1-AveragedSample.Absorption)), 0, 1)

	-- Calculate DryLevel (this took so long to find out holy)
	FinalResult.ReverbSoundEffect.DryLevel = math.clamp(-10 + (20 * (1 - AveragedSample.Absorption)) + (5 * AveragedSample.DistanceWeight), -10, 6)


	FinalResult.EqualizerSoundEffect.HighGain = -AveragedSample.Density + _3DSound()
	if self._SoundParams.Do3DMuffle then

		if not CanSeeCam(Filter) then
			FinalResult.EqualizerSoundEffect.HighGain -= 20 * (self._ReferenceCamera.CFrame.Position-self._EmitPosition).Magnitude/40
		else
			FinalResult.EqualizerSoundEffect.HighGain -= 2 * (self._ReferenceCamera.CFrame.Position-self._EmitPosition).Magnitude/40
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

function ReverbObject:RemoveSound(Sound: Sound, RemoveReverb: boolean)
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
		warn("Emit object is already set; don't use UpdatePosition.")
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
