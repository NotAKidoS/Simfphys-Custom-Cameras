local function DefineSimfForward(vehicle)
	--get the vehicles list and if it has custom wheels
	local vehlist = list.Get( "simfphys_vehicles" )[ vehicle:GetSpawn_List() ]
	local CustomWheels = vehlist.Members.CustomWheels
	--create a table with all the wheel locations, determines if custom wheel or attachment locations are needed
	local WheelTable = {}
	WheelTable.FL = CustomWheels and vehicle:LocalToWorld( vehlist.Members.CustomWheelPosFL ) or vehicle:GetAttachment( vehicle:LookupAttachment( "wheel_fl" ) ).Pos
	WheelTable.FR = CustomWheels and vehicle:LocalToWorld( vehlist.Members.CustomWheelPosFR ) or vehicle:GetAttachment( vehicle:LookupAttachment( "wheel_fr" ) ).Pos
	WheelTable.RL = CustomWheels and vehicle:LocalToWorld( vehlist.Members.CustomWheelPosRL ) or vehicle:GetAttachment( vehicle:LookupAttachment( "wheel_rl" ) ).Pos
	WheelTable.RR = CustomWheels and vehicle:LocalToWorld( vehlist.Members.CustomWheelPosRR ) or vehicle:GetAttachment( vehicle:LookupAttachment( "wheel_rr" ) ).Pos

	--find the local forward direction based on wheel location to angles
	local pAngL = vehicle:WorldToLocalAngles( ((WheelTable.FL + WheelTable.FR) / 2 - (WheelTable.RL + WheelTable.RR) / 2):Angle() )
	pAngL.r = 0
	pAngL.p = 0

	--save the local forward direction
	vehicle.forward = pAngL

	--find the right direction from the forward direction
	local yAngL = pAngL - Angle(0,90,0)
	yAngL:Normalize()

	--save the right local direction
	vehicle.right = yAngL
end

local function FindForward(vehicle)
	if !vehicle.forward then DefineSimfForward(vehicle) end
	return vehicle:LocalToWorldAngles( vehicle.forward ):Forward()
end
local function FindRight(vehicle)
	if !vehicle.forward then DefineSimfForward(vehicle) end
	return vehicle:LocalToWorldAngles( vehicle.right ):Forward()
end

local Cam = {}
Cam.Name = "Hood"
Cam.LookPos = Vector(0,0,0)

function Cam:Init(ply, view, vehicle, pod)
	print("Hood camera started.")

	if !vehicle.EnginePos then
		print("Camera failed to start, no engine position found!")
		return false 
	end

	local tr = util.TraceLine( {
		start = vehicle:LocalToWorld(vehicle.EnginePos + Vector(0,0,100)),
		endpos = vehicle:LocalToWorld(vehicle.EnginePos),
		filter = function( hitent ) if ( vehicle == hitent ) then return true end end
	} )

	if tr.Entity then
		self.LookPos = vehicle:WorldToLocal(tr.HitPos)
	else
		self.LookPos = vehicle.EnginePos + Vector(0,0,20)
	end

	self.LookPos = self.LookPos + Vector(0,0,10)
end

function Cam:EngineCam(ply, view, vehicle, pod)
	view.origin = vehicle:LocalToWorld(self.LookPos)
	view.angles = FindForward(vehicle)
	view.angles = view.angles:Angle()
	return view
end

function Cam:FirstPerson(ply, view, vehicle)	
	return Cam:EngineCam(ply, view, vehicle, pod)
end

function Cam:ThirdPerson(ply, view, vehicle)	
	return Cam:EngineCam(ply, view, vehicle, pod)
end

SimfCamManager:RegisterCam(Cam)