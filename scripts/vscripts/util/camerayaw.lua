function getCameraYaw(plyhd)
	CustomGameEventManager:Send_ServerToPlayer(plyhd, "get_camera_yaw", {} )
end

get_camera_yaw_callback = function (keys)
	if not IsServer() then return end
	print_r(keys)
end