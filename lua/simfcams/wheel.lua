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
	view.origin = vehicle:LocalToWorld(self.LookPos) + SimfCamManager.FindForward(vehicle) * -50 + SimfCamManager.FindRight(vehicle) * -20
	view.angles = SimfCamManager.FindForward(vehicle):Angle()
	return view
end

function Cam:FirstPerson(ply, view, vehicle)	
	return Cam:WheelCamFL(ply, view, vehicle, pod)
end

function Cam:ThirdPerson(ply, view, vehicle)	
	return Cam:WheelCamFL(ply, view, vehicle, pod)
end

SimfCamManager:RegisterCam(Cam)