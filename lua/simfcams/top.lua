CreateClientConVar("nak_simf_cam_topcamdistance", "500", true, false, "Camera distance from vehicle.")

local Cam = {}
Cam.Name = "Top"
Cam.TopDist = 500

function Cam:Init()
	Cam.TopDist = GetConVarNumber( "nak_simf_cam_topcamdistance" )
	print("Top camera started.")
	print("Camera distance set to: " .. Cam.TopDist)
end

function Cam:TopCam(ply, view, vehicle)

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

function Cam:FirstPerson(ply, view, vehicle)	
	return Cam:TopCam(ply, view, vehicle)	
end

function Cam:ThirdPerson(ply, view, vehicle)	
	return Cam:TopCam(ply, view, vehicle)	
end

SimfCamManager:RegisterCam(Cam)