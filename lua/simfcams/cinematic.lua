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
Cam.Name = "Cinematic"

Cam.CamChangeDel = CurTime() 
Cam.CurCam = 1
Cam.LastCam = 1
Cam.NrOfCams = 7
Cam.CamFuncs = {}
Cam.LookPos = Vector(0,0,0)
Cam.newAng = Angle(0,0,0)
Cam.newPos = Vector(0,0,0)

function Cam:Init()
	print("Cinematic camera started.")
end

--face cam
Cam.CamFuncs[1] = function(self, ply, view, vehicle, change)	

	if change then
		self.CamChangeDel = CurTime() + math.random(1,3)
	end

	view.origin = ply:EyePos() + FindForward(vehicle) * 80 + vehicle:GetUp() * 9
	view.angles = FindForward(vehicle) * -1
	view.angles = view.angles:Angle()
	return view
end

--random placement cam
Cam.CamFuncs[2] = function(self, ply, view, vehicle, change)	

	if change then
		self.LookPos = vehicle:GetPos() + Vector( math.random(-500,500) ,math.random(-500,500),math.random(-100,100))
		
		local Trace = {}
		Trace.start = vehicle:GetPos()
		Trace.endpos = self.LookPos
		Trace.mask = MASK_NPCWORLDSTATIC
		local tr = util.TraceLine(Trace)
		
		if tr.Hit then
			self.LookPos = tr.HitPos + tr.HitNormal * 20
		end				
		self.CamChangeDel = CurTime() + math.random(3,5)
	end

	view.angles = vehicle:GetPos() - self.LookPos
	view.angles = view.angles:Angle()
	view.origin = self.LookPos
	
	local Trace = {}
	Trace.start = vehicle:GetPos()
	Trace.endpos = self.LookPos
	Trace.mask = MASK_NPCWORLDSTATIC
	local tr = util.TraceLine(Trace)
	
	if tr.Hit then
		self.CamChangeDel = 0
	end
	
	return view
end

--driveby front cam, place camera randomly in front
Cam.CamFuncs[3] = function(self, ply, view, vehicle, change)	

	if change then
		self.LookPos = vehicle:GetPos() + FindForward(vehicle) * 500 + Vector( math.random(-50,50) ,math.random(-50,50),math.random(-50,50) )

		local tr = util.TraceLine({
			start = vehicle:GetPos(),
			endpos = self.LookPos,
			mask = MASK_NPCWORLDSTATIC,
		})
		
		if tr.Hit then
			self.LookPos = tr.HitPos + tr.HitNormal * 20
		end				
		self.CamChangeDel = CurTime() + math.random(3,5)
	end

	view.angles = vehicle:GetPos() - self.LookPos
	view.angles = view.angles:Angle()
	view.origin = self.LookPos

	local tr = util.TraceLine({
		start = vehicle:GetPos(),
		endpos = self.LookPos,
		mask = MASK_NPCWORLDSTATIC,
	})

	if tr.Hit then
		self.CamChangeDel = 0
	end		

	return view
end

--top cam
Cam.CamFuncs[4] = function(self, ply, view, vehicle, change)	

	if change then
		self.CamChangeDel = CurTime() + math.random(2,4)
	end

	local mn, mx = vehicle:GetModelBounds()
	view.origin = vehicle:GetPos() + Vector(0,0, mx.z + 500)
	
	local Trace = {}
	Trace.start = vehicle:GetPos()
	Trace.endpos = view.origin
	Trace.mask = MASK_NPCWORLDSTATIC
	local tr = util.TraceLine(Trace)
	
	if tr.Hit then
		view.origin = tr.HitPos + tr.HitNormal * 10
	end		
	
	view.angles = Angle(90,0,0)

	return view
end

--wheel cam FL
Cam.CamFuncs[5] = function(self, ply, view, vehicle, change)

	if change then
		local vehiclelist = list.Get( "simfphys_vehicles" )[ vehicle:GetSpawn_List() ]
		WheelFL = vehiclelist.Members.CustomWheels and vehiclelist.Members.CustomWheelPosFL or vehicle:WorldToLocal(vehicle:GetAttachment( vehicle:LookupAttachment( "wheel_fl" ) ).Pos)
		if !WheelFL then return false end
		self.LookPos = WheelFL + Vector(0,0,10)
		if vehiclelist.Members.CustomWheels then
			self.LookPos.x = math.abs(self.LookPos.x)
			self.LookPos.y = math.abs(self.LookPos.y)
		end
		self.CamChangeDel = CurTime() + math.random(3,5)
	end

	view.origin = vehicle:LocalToWorld(self.LookPos) + FindForward(vehicle) * -50 + FindRight(vehicle) * -20
	view.angles = FindForward(vehicle):Angle()
	return view
end

--engine pos cam
Cam.CamFuncs[6] = function(self, ply, view, vehicle, change)	

	if change then
		if !vehicle.EnginePos then return false end

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
		self.CamChangeDel = CurTime() + math.random(2,4)
	end

	view.origin = vehicle:LocalToWorld(self.LookPos)
	view.angles = FindForward(vehicle)
	view.angles = view.angles:Angle()
	return view
end
--engine pos cam flipped backwards
Cam.CamFuncs[7] = function( self, ply, view, vehicle, change)	

	if change then
		if !vehicle.EnginePos then return false end

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

		self.CamChangeDel = CurTime() + math.random(2,4)
	end

	view.origin = vehicle:LocalToWorld(self.LookPos)
	view.angles = FindForward(vehicle) * -1
	view.angles = view.angles:Angle()
	return view
end

--logic for choosing the camera, forwards values to calcvehicleview hook
function Cam:CinematicFunc(ply, view, vehicle)	
	if self.CamChangeDel < CurTime() then
		local camnum = math.random(1, self.NrOfCams)
		-- local camnum = 4

		if self.CamFuncs[camnum]( self, ply, view, vehicle, false) then
			self.CurCam = camnum
		end

		return self.CamFuncs[self.CurCam]( self, ply, view, vehicle, true)
	end
	
	if ply:KeyPressed( 1 ) then
		self.CamChangeDel = CurTime() + 0.2
	end

	return self.CamFuncs[self.CurCam]( self, ply, view, vehicle, false)
end

function Cam:FirstPerson(ply, view, vehicle)	
	return Cam:CinematicFunc(ply, view, vehicle)	
end

function Cam:ThirdPerson(ply, view, vehicle)	
	return Cam:CinematicFunc(ply, view, vehicle)	
end

SimfCamManager:RegisterCam(Cam)