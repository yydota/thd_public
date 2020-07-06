URD = {}
Team1 = {}
Team2 = {}
Team1_count = 0
Team2_count = 0
FLAG1 = true
FLAG2 = true
TIME_DURATION = 60  --投票的持续时间
TIME_FLAG = 120		--投票的CD
WINER_TEAM = nil

function THD_URD(plyid,plyhd)
	if GetMapName() ~= "1_thdots_map" then return end
	-- print_r(Team1)
	-- print_r(Team2)
	print(plyhd:GetAssignedHero():GetOrigin())
	siege_print()
	if GameRules:GetDOTATime(false, false) < 900 then
		Say(plyhd, "15分钟后才可以投降", true)
		return
	end
	if not FLAG1 then
		Say(plyhd, "2分钟内无法再次投降", true)
		return
	end
	--------------------测试代码
	-- if Team2_count == 1 then
	-- 	print("text")
	-- 	Team2[1] = {["ID"]=1,["TF"] = true }
	-- 	print_r(Team2)
	-- end
	-- if Team2_count == 2 then
	-- 	print("text")
	-- 	Team2[2] = {["ID"]=2,["TF"] = true }
	-- 	print_r(Team2)
	-- end
	-- if Team2_count == 3 then
	-- 	print("text")
	-- 	Team2[3] = {["ID"]=3,["TF"] = true }
	-- 	print_r(Team2)
	-- end
	-- GameRules:SendCustomMessage("<font color='#00FFFF'>Welcome to Touhou Defence of the shrines Re;mixed DOTS:R.</font>", 0, 0)	
	if Team1[plyid] ~= nil then
		if not FLAG1 then
			Say(plyhd, "2分钟内无法再次投降", true)
			return
		end
		print("Team1[".. plyid .. "] is " .. Team1[plyid].ID)
		Team1[plyid].TF = true
		print("Team1[".. plyid .. "].TF is " ..tostring(Team1[plyid].TF))
		if Team1_count == 0 then
			Team1_count = 1
			Say(plyhd, ".发起了投降,输入-urd投票投降，当前票数:"..Team1_count.."/4", true)
			Team1_Interval(plyid,plyhd)
		end
	end
	if Team2[plyid] ~= nil then
		if not FLAG2 then
			Say(plyhd, "2分钟内无法再次投降", true)
			return
		end
		print("Team2[".. plyid .. "] is " .. Team2[plyid].ID)
		Team2[plyid].TF = true
		print("Team2[".. plyid .. "].TF is " ..tostring(Team2[plyid].TF))
		if Team2_count == 0 then
			Team2_count = 1
			Say(plyhd, ".发起了投降,输入-urd投票投降，当前票数:"..Team2_count.."/4", true)
			Team2_Interval(plyid,plyhd)
		end
	end
end

function URD_initialize()
	for i=1, PlayerResource:GetPlayerCount() do
		local plyhd = PlayerResource:GetPlayer(i-1)
		if plyhd then
			-- print("plyhd team is : ",plyhd:GetTeam())
			-- print("plyhd ID is : ",plyhd:GetPlayerID())
			-- GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
			if plyhd:GetTeam() == DOTA_TEAM_GOODGUYS then
				Team1[plyhd:GetPlayerID()] = {["ID"]=plyhd:GetPlayerID(),["TF"] = 0 }
			elseif plyhd:GetTeam() == DOTA_TEAM_BADGUYS then
				Team2[plyhd:GetPlayerID()] = {["ID"]=plyhd:GetPlayerID(),["TF"] = 0 }
			end
		end
	end
	-- print_r(Team1)
	-- print_r(Team2)
	-- print("initialize success")
end

function Team1_Interval(plyid,plyhd)
	local time = 0
	GameRules:GetGameModeEntity():SetContextThink("urd_interval", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if time < TIME_DURATION then
				local count = 0
				for _,v in pairs(Team1) do
					if v.TF == true then
						count = count + 1
					end
				end
				if count > Team1_count then
					print("tou piao  + 1")
					Team1_count = count
					Say(plyhd, ".同意投降，当前票数:"..Team1_count.."/4", true)
				end
				if Team1_count >= 4 then
					print("SS shengli")
					GameRules:SendCustomMessage("<font color='#00FFFF'>Hakurei Shrine投降，游戏将在10秒后结束</font>", 0, 0)
					WINER_TEAM = DOTA_TEAM_BADGUYS
					local end_time = 0
					GameRules:GetGameModeEntity():SetContextThink("urd_hakurei", 
						function()
							if GameRules:IsGamePaused() then return 0.03 end
							if end_time >= 10 then
								GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
								return nil
							end
						end_time = end_time + 0.03
						return 0.03
						end
						,
						0)
					return nil
				end
			else
				print("end")
				Say(plyhd, ".投降失败，当前票数:"..Team1_count.."/4。2分钟以内无法再次发起投降", true)
				FLAG1 = false
				FLAG1_interval()
				for _,v in pairs(Team1) do
					v.TF = 0
				end
				print_r(Team1)
				Team1_count = 0
				return nil
			end
		time = time + 0.03
		return 0.03
		end
		,
		0)
end

function Team2_Interval(plyid,plyhd)
	local time = 0
	GameRules:GetGameModeEntity():SetContextThink("urd_interval", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if time < TIME_DURATION then
				local count = 0
				for _,v in pairs(Team2) do
					if v.TF == true then
						count = count + 1
					end
				end
				if count > Team2_count then
					print("tou piao  + 1")
					Team2_count = count
					Say(plyhd, ".同意投降，当前票数:"..Team2_count.."/4", true)
				end
				if Team2_count >= 4 then
					print("BL shengli")
					WINER_TEAM = DOTA_TEAM_GOODGUYS
					GameRules:SendCustomMessage("<font color='#00FFFF'>Moriya Shrine投降，游戏将在10秒后结束</font>", 0, 0)	
					local end_time = 0
					GameRules:GetGameModeEntity():SetContextThink("urd_moriya", 
						function()
							if GameRules:IsGamePaused() then return 0.03 end
							if end_time >= 10 then
								GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
								return nil
							end
						end_time = end_time + 0.03
						return 0.03
						end
						,
						0)
					return nil
				end
			else
				print("end")
				Say(plyhd, ".投降失败，当前票数:"..Team2_count.."/4。2分钟以内无法再次发起投降", true)
				FLAG2 = false
				FLAG2_interval()
				for _,v in pairs(Team2) do
					v.TF = 0
				end
				print_r(Team2)
				Team2_count = 0
				return nil
			end
		time = time + 0.03
		return 0.03
		end
		,
		0)
end

function FLAG1_interval()
	local end_time = 0
	GameRules:GetGameModeEntity():SetContextThink("urd_moriya", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if end_time >= TIME_FLAG then
				FLAG1 = true
				return nil
			end
		end_time = end_time + 0.03
		return 0.03
		end
		,
		0)
end

function FLAG2_interval()
	local end_time = 0
	GameRules:GetGameModeEntity():SetContextThink("urd_moriya", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if end_time >= TIME_FLAG then
				FLAG2 = true
				return nil
			end
		end_time = end_time + 0.03
		return 0.03
		end
		,
		0)
end

function ClearTeam1()
	for _,v in pairs(Team1) do
		v.TF = 0
	end
	Team1_count = 0
end

function ClearTeam2()
	for _,v in pairs(Team2) do
		v.TF = 0
	end
	Team2_count = 0
end

function GetWinerteam()
	return WINER_TEAM
end