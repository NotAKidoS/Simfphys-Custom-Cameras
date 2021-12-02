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
	view.angles = SimfCamManager.FindForward(vehicle)
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