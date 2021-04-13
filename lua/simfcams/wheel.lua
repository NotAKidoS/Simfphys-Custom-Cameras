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
Cam.Name = "Wheel"
Cam.LookPos = Vector(0,0,0)

function Cam:Init(ply, view, vehicle, pod)
	print("Front left wheel camera started.")

	local vehiclelist = list.Get( "simfphys_vehicles" )[ vehicle:GetSpawn_List() ]
	WheelFL = vehiclelist.Members.CustomWheels and vehiclelist.Members.CustomWheelPosFL or vehicle:WorldToLocal(vehicle:GetAttachment( vehicle:LookupAttachment( "wheel_fl" ) ).Pos)

	if !WheelFL then 
		print("failed to set camera, no front left wheel position found.")
		return false
	end

	self.LookPos = WheelFL + Vector(0,0,10)
	if vehiclelist.Members.CustomWheels then
		self.LookPos.x = math.abs(self.LookPos.x)
		self.LookPos.y = math.abs(self.LookPos.y)
	end
end

--wheel cam FL
function Cam:WheelCamFL(ply, view, vehicle, pod)
	view.origin = vehicle:LocalToWorld(self.LookPos) + FindForward(vehicle) * -50 + FindRight(vehicle) * -20
	view.angles = FindForward(vehicle):Angle()
	return view
end

function Cam:FirstPerson(ply, view, vehicle)	
	return Cam:WheelCamFL(ply, view, vehicle, pod)
end

function Cam:ThirdPerson(ply, view, vehicle)	
	return Cam:WheelCamFL(ply, view, vehicle, pod)
end

SimfCamManager:RegisterCam(Cam)