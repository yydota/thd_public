URD = {}

function THD_URD(plyid)
	print("urd is :",plyid)
	for i=1, PlayerResource:GetPlayerCount() do
		local plyhd = PlayerResource:GetPlayer(i-1)
		if plyhd then
			print("plyhd is : ",plyhd:GetPlayerID())
			print("plyhd name is : ",plyhd:GetAssignedHero():GetName())
			-- GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		end
	end
end