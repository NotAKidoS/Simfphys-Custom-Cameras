--code from simfphys github, used in normal first person cameras
local function GetViewOverride( ent )
	if not IsValid( ent ) then return Vector(0,0,0) end
	
	if not ent.customview then
		local vehiclelist = list.Get( "simfphys_vehicles" )[ ent:GetSpawn_List() ]
		
		if vehiclelist then
			ent.customview = vehiclelist.Members.FirstPersonViewPos or Vector(0,-9,5)
		else
			ent.customview = Vector(0,-9,5)
		end
	end
	
	return ent.customview
end



local Cam = {}
Cam.Name = "Example"

--first person code, this sets the same first person camera as normal simfphys but allowed in all seats
function Cam:ExampleCamFr(ply, view, simfvehicle, pod)

	local viewoverride = GetViewOverride( simfvehicle )
	local X = viewoverride.X
	local Y = viewoverride.Y
	local Z = viewoverride.Z
	view.origin = view.origin + pod:GetForward() * X + pod:GetRight() * Y + pod:GetUp() * Z or view.origin + pod:GetUp() * 5
	view.drawviewer = false
	
	return view
end
--third person code, places the camera in the center of the vehicle 100 units up
function Cam:ExampleCamTh(ply, view, simfvehicle, pod)

	local pos = simfvehicle:GetPos()

	view.origin = pos + Vector(0,0,100)

	return view
end


--these are run for first and third person, allowing you to do different things for both
function Cam:FirstPerson(ply, view, vehicle, pod)	
	return Cam:ExampleCamFr(ply, view, vehicle, pod)	
end
--call whatever function you want above
function Cam:ThirdPerson(ply, view, vehicle, pod)	
	return Cam:ExampleCamTh(ply, view, vehicle, pod)	
end

--adds to the list of cameras
SimfCamManager:RegisterCam(Cam)

--youll be running nak_simf_cam_debug_reload in console a lot ;)