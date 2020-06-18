WebApi = WebApi or {}

local isTesting = IsInToolsMode() and false
local serverHost = "https://thd2.cc"

function WebApi:SetTesting(val)
	isTesting = val
end

function WebApi:Send(path, data, onSuccess, onError)
	local request = CreateHTTPRequestScriptVM("POST", serverHost .. "/api/" .. path..".php")
	if isTesting then
		print("Request to " .. path)
		DeepPrintTable(data)
	end

	--request:SetHTTPRequestHeaderValue("Dedicated-Server-Key", dedicatedServerKey)
	if data ~= nil then
		request:SetHTTPRequestRawPostBody("application/json", json.encode(data))
	end

	request:Send(function(response)
		if response.StatusCode == 200 then
			local data = {}
			if response.Body then
				print("Response from " .. path .. ":")
				local status, result = pcall(json.decode, response.Body)
				if isTesting then
					if status then
						DeepPrintTable(result)
					else
						print(response.Body)
					end
				end
				if status then
					data = result
				else
					data = response.Body
				end
			end
			if onSuccess then
				DeepPrintTable(data)
				onSuccess(data, response.StatusCode)
			end
		else
			if isTesting then
				print("Error from " .. path .. ": " .. response.StatusCode)
				if response.Body then
					local status, result = pcall(json.decode, response.Body)
					if status then
						DeepPrintTable(result)
					else
						print(response.Body)
					end
				end
			end
			if onError then
				-- TODO: Is response.Body nullable?
				onError(response.Body or "Unknown error (" .. response.StatusCode .. ")", response.StatusCode)
			end
		end
	end)
end

function WebApi:BeforeMatch( onSuccess )
	local requestBody = {}
	if isTesting then
		table.insert(requestBody, "76561198087376860")
	end
	for i = 0, 233 do
		if PlayerResource:IsValidPlayerID(i) then
			table.insert(requestBody, tostring(PlayerResource:GetSteamID(i)))
		end
	end

	WebApi:Send("beforematch", requestBody, onSuccess)
	-- GetTHDPlayerRank()
end

function WebApi:AfterMatch()
	
	--地图是1_thdots_map,10min以上,10人以上,只剩一方基地才是有效比赛结果
	if GetMapName() ~= "1_thdots_map" then return end

	if not isTesting then
		if GameRules:IsCheatMode() then return end
		if GameRules:GetDOTATime(false, false) < 600 then return end
	end
	
	local winnerTeam = -1
	local forts=Entities:FindAllByClassname("npc_dota_fort")
	for _,v in pairs(forts) do
		local team = v:GetTeam()
		local hp = v:GetHealth()
		if hp > 0.1 then
			if winnerTeam ~= -1 then
				winnerTeam = -999
				break
			else
				winnerTeam = team
			end
		end
	end
	
	if winnerTeam < 0 then return end
	
	local requestBody = {
		matchId = isTesting and RandomInt(1, 10000000) or tonumber(tostring(GameRules:GetMatchID())),
		duration = math.floor(GameRules:GetDOTATime(false, false)),
		mapName = GetMapName(),
		winner = winnerTeam,

		players = {}
	}

	for playerId = 0, 233 do
		if PlayerResource:IsValidTeamPlayerID(playerId) and not PlayerResource:IsFakeClient(playerId) then
			local playerData = {
				playerId = playerId,
				steamId = tostring(PlayerResource:GetSteamID(playerId)),
				team = PlayerResource:GetTeam(playerId),

				hero = PlayerResource:GetSelectedHeroName(playerId),
				pickReason = PlayerResource:HasRandomed(playerId) and "random" or "pick",
				kills = PlayerResource:GetKills(playerId),
				deaths = PlayerResource:GetDeaths(playerId),
				assists = PlayerResource:GetAssists(playerId),
				level = 0,
				items = {},
			}

			local hero = PlayerResource:GetSelectedHeroEntity(playerId)
			if IsValidEntity(hero) then
				playerData.level = hero:GetLevel()
				for slot = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6 do
					local item = hero:GetItemInSlot(slot)
					if item then
						table.insert(playerData.items, {
							slot = slot,
							name = item:GetAbilityName(),
							charges = item:GetCurrentCharges()
						})
					end
				end
			end

			table.insert(requestBody.players, playerData)
		end
	end

	if isTesting or #requestBody.players >= 10 then
		WebApi:Send("aftermatch", requestBody)
	end
end

RegisterCustomEventListener("Shuffle_Pressed", function()
	if WebApi.firstPlayerLoaded then return end
	WebApi.firstPlayerLoaded = true
	print('call before match')
	--数据返回部分目前还没做,先收集数据
	--WebApi:BeforeMatch()
end)
