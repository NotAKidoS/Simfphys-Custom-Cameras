if CLIENT then

	--add simfcammanager list
	SimfCamManager = {}
	SimfCamManager.Cams = {}
	SimfCamManager.CurCam = "Cinematic"
	SimfCamManager.view = {}
	
	
	function SimfCamManager.DefineSimfForward(vehicle)
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

	function SimfCamManager.FindForward(vehicle)
		if !vehicle.forward then SimfCamManager.DefineSimfForward(vehicle) end
		return vehicle:LocalToWorldAngles( vehicle.forward ):Forward()
	end
	function SimfCamManager.FindRight(vehicle)
		if !vehicle.forward then SimfCamManager.DefineSimfForward(vehicle) end
		return vehicle:LocalToWorldAngles( vehicle.right ):Forward()
	end

	--registers the camera in the cam list
	function SimfCamManager:RegisterCam(cam)
		if !cam.Name then
			cam.Name = "No Name"
		end
		self.Cams[cam.Name] = cam
	end
	--remove the addon cameras and reload them
	function SimfCamManager:Refresh()
		self.Cams = {}
		self:Init()
	end
	--find the addon cameras and runs their code
	function SimfCamManager:Init()
		local cams = file.Find("lua/simfcams/*.lua", "GAME")

		for _, plugin in ipairs( cams ) do
			include( "simfcams/"..plugin )
		end
	end
	--find the names of the cameras
	function SimfCamManager:GetTableOfCamNames()
		local names = {}
		local count = 0
		for k, v in pairs(self.Cams) do
			count = count + 1
			names[count] = k
		end
		return names
	end

	--convars
	CreateClientConVar("nak_simf_cam", 0, true, false, "Enable custom camera.")
	CreateClientConVar("nak_simf_cam_select", "Cinematic", true, false, "Select custom camera.")
	concommand.Add("nak_simf_cam_debug_reload", function( ply, cmd, args )
		SimfCamManager:Refresh()
		print("Reloaded cameras list!")
	end)
	concommand.Add("nak_simf_cam_list", function( ply, cmd, args )
		PrintTable(SimfCamManager:GetTableOfCamNames())
	end)

	--run hook
	local function EnableCams()
		SimfCamManager:Init()
		hook.Add("CalcVehicleView", "zSimf_View_Custom_Cam", function(pod, ply, view)
			local vehiclebase = ply:GetSimfphys()
			if not IsValid( vehiclebase ) then return end

			local ConvarCheck = GetConVar("nak_simf_cam"):GetInt()
			if (ConvarCheck == 0) then 
				if ply.nak_simf_cam_selected != nil then ply.nak_simf_cam_selected = nil end
				return 
			end

			if pod.GetThirdPersonMode == nil or ply:GetViewEntity() ~= ply  then
				return
			end

			view.drawviewer = true

			local SelectedCamera = GetConVar("nak_simf_cam_select"):GetString()
			
			if !SimfCamManager.Cams[SelectedCamera] then return end

			if ply.nak_simf_cam_selected != SelectedCamera then
				SimfCamManager.Cams[SelectedCamera]:Init(ply, view, vehiclebase, pod)
			end
			
			ply.nak_simf_cam_selected = SelectedCamera
			
			if pod:GetThirdPersonMode() then
				view = SimfCamManager.Cams[SelectedCamera]:ThirdPerson(ply, view, vehiclebase, pod)
			else
				view = SimfCamManager.Cams[SelectedCamera]:FirstPerson(ply, view, vehiclebase, pod)
			end

			return view 
		end)
	end

	hook.Add( "Initialize", "zSimf_View_Custom_Cam_Start", EnableCams )
	EnableCams()
end        