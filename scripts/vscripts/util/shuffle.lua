TOP = 10			--取前X种排序
PlayerList = {}		--前X种排序的列表
PlayerRatings = {}
TrueList = 1
SHUFFLE_FLAG = false

function THD2_Rating_Catcher( args )
	for k,v in pairs( args ) do
		if v then
			PlayerRatings[k] = v
		end
	end
	GetTHDPlayerRank()
end

Shuffle_Pressed = function (keys) --洗牌，GetTHDPlayerRank获取了10组排列顺序，每点击一次洗牌按钮会优先抽取分差最小的组合序号TrueList
	if not IsServer() then return end
	GetTHDPlayerRank()
	local denominator = 1
	local molecule = 0
	-- print_r(PlayerList[TrueList])
	for i=1,#PlayerList do
		denominator = denominator + PlayerList[i][1]
	end
	molecule = denominator - PlayerList[1][1]
	for i=#PlayerList,1,-1 do
		if RollPercentage(molecule/denominator*100) then
			TrueList = i
			if PlayerList[i-1] == nil then 
				break 
			end
			molecule = molecule - PlayerList[i-1][1]
		end
	end
	THDSetTeam(PlayerList[TrueList])
end

function GetNum()
	return PlayerList[TrueList][1]
end

function THDSetTeam(atable)
	if not IsServer() then return end
	local Team1 = atable[2]
	local Team2 = atable[3]
	local TeamName
	-- print_r(Team1)
	-- print_r(Team2)
	-- print_r(atable[1])
	for i=1, #Team1 do
		local index = RandomInt(1,#Team1)
		Team1[i],Team1[index] = Team1[index],Team1[i]
	end
	for i=1, #Team2 do
		local index = RandomInt(1,#Team2)
		Team2[i],Team2[index] = Team2[index],Team2[i]
	end
	local team = DOTA_TEAM_GOODGUYS
	if RollPercentage(50) then
		team = DOTA_TEAM_BADGUYS
	end
	for i=1,#Team1 do
		if Team1[i] == nil then break end
		-- print("NOTEAM")
		-- print(Team1[i].plyhd:GetPlayerID())
		PlayerResource:SetCustomTeamAssignment(Team1[i].plyhd:GetPlayerID(),DOTA_TEAM_NOTEAM)
	end
	-- print("team1-------------------------")
	for i=1,#Team1 do
		if Team1[i] == nil then break end
		-- print(Team1[i].plyhd:GetPlayerID())
		-- print(team)
		PlayerResource:SetCustomTeamAssignment(Team1[i].plyhd:GetPlayerID(),team)
	end
	-- print_r("Team1 is:")
	-- print_r(Team1)
	-- print("1",team)
	if team == DOTA_TEAM_GOODGUYS then
		team = DOTA_TEAM_BADGUYS
	else
		team = DOTA_TEAM_GOODGUYS
	end
	TeamName = GetTeamName(team)
	if #Team2 == 0 then return end
	for i=1,#Team2 do
		-- print("NOTEAM")
		-- print(Team2[i].plyhd:GetPlayerID())
		if Team2[i] == nil then break end
		PlayerResource:SetCustomTeamAssignment(Team2[i].plyhd:GetPlayerID(),DOTA_TEAM_NOTEAM)
	end
	-- print("team2-------------------------")
	for i=1,#Team2 do
		if Team2[i] == nil then break end
		-- print(Team2[i].plyhd:GetPlayerID())
		-- print(team)
		PlayerResource:SetCustomTeamAssignment(Team2[i].plyhd:GetPlayerID(),team)
	end
	-- print("2",team)
	-- print_r("Team2 is:")
	-- print_r(Team2)
end

function GetTHDPlayerRank()
	if not IsServer() then return end
	if SHUFFLE_FLAG == true then
		return
	end
	SHUFFLE_FLAG = true
	------------------------------------------------
	local List = {}
	local player = {plyhd = nil, SteamID = nil,tiantifen = 0}
	for i=1, PlayerResource:GetPlayerCount() do
		local plyhd = PlayerResource:GetPlayer(i-1)
		if plyhd then
			-- print("tiantifen is :",PlayerRatings[tostring(PlayerResource:GetSteamID(plyhd:GetPlayerID()))])
			local tiantifen = PlayerRatings[tostring(PlayerResource:GetSteamID(plyhd:GetPlayerID()))] or 600
			player = {plyhd = plyhd,SteamID = PlayerResource:GetSteamID(plyhd:GetPlayerID()),tiantifen = tiantifen}
			PlayerResource:SetCustomTeamAssignment(plyhd:GetPlayerID(),DOTA_TEAM_NOTEAM)
			table.insert(List,player)
		end
	end
	-- List[1].tiantifen = 656
	-- List[2].tiantifen = 780
	-- List[3].tiantifen = 413
	-- List[4].tiantifen = 358
	-- List[5].tiantifen = 752
	-- List[6].tiantifen = 600
	-- List[7].tiantifen = 652
	-- List[8].tiantifen = 427
	-- List[9].tiantifen = 877
	-- List[10].tiantifen = 1044
	local result = zuhe(List,math.ceil(#List/2))
		-- print_r(result)
	for i=1,TOP do
		if result[i*2-1] ~= nil then
			table.insert(PlayerList,result[i*2-1])
		end
	end
	----------------测试代码--------------
	-- local List = {}
	-- local player = {["plyhd"] = nil, ["SteamID"] = nil,["tiantifen"] = 0}
	-- for i=1,10 do
	-- 	player = {plyhd = i,SteamID = 10*i,tiantifen = i*10}
	-- 	table.insert(List,player)
	-- end
	-- local result = zuhe(List,math.ceil(#List/2))
	-- for i=1,TOP do
	-- 	table.insert(PlayerList,result[i])
	-- end
	-------------------------------------------
end

function zuhe(atable, n) --网上抄的排列代码
	if not IsServer() then return end
    if n > #atable then
        return {}
    end

    local len = #atable
    local meta = {}
    -- init meta data
    for i=1, len do
        if i <= n then
            table.insert(meta, 1)
        else
            table.insert(meta, 0)
        end
    end

    local result = {}

    -- 记录一次组合
    local tmp = {}
    local tmp2 = {}
    local fenshu1 = 0
    local fenshu2 = 0
    for i=1, len do
        if meta[i] == 1 then
            table.insert(tmp, atable[i])
            fenshu1 = fenshu1 + atable[i].tiantifen
        end
        if meta[i] == 0 then
        	table.insert(tmp2,atable[i])
        	fenshu2 = fenshu2 + atable[i].tiantifen
        end
    end
    -- print_r(tmp)
    -- print_r(tmp2)
    table.insert(result,{math.abs(fenshu1 - fenshu2),tmp,tmp2})
    while true do
        -- 前面连续的0
        local zero_count = 0
        for i=1, len-n do
            if meta[i] == 0 then
                zero_count = zero_count + 1
            else
                break
            end
        end
        -- 前m-n位都是0，说明处理结束
        if zero_count == len-n then
            break
        end

        local idx
        for j=1, len-1 do
            -- 10 交换为 01
            if meta[j]==1 and meta[j+1] == 0 then
                meta[j], meta[j+1] = meta[j+1], meta[j]
                idx = j
                break
            end
        end
        -- 将idx左边所有的1移到最左边
        local k = idx-1
        local count = 0
        while count <= k do
            for i=k, 2, -1 do
                if meta[i] == 1 then
                    meta[i], meta[i-1] = meta[i-1], meta[i]
                end
            end
            count = count + 1
        end

        -- 记录一次组合
        local tmp = {}
        local tmp2 = {}
        local fenshu1 = 0
    	local fenshu2 = 0
        for i=1, len do
            if meta[i] == 1 then
                table.insert(tmp, atable[i])
                fenshu1 = fenshu1 + atable[i].tiantifen --记录Team1分数
                -- print_r(atable[i])
            end
            if meta[i] == 0 then
	        	table.insert(tmp2,atable[i])
	        	fenshu2 = fenshu2 + atable[i].tiantifen --记录Team2分数
        	end
        end
        table.insert(result,{math.abs(fenshu1 - fenshu2),tmp,tmp2})  --将分差与队员记录
        fenshu1 = 0
        fenshu2 = 0
    end
    table.sort(result, function(a, b) if a[1]<b[1] then return true end end ) --根据最小分差排序
    return result
end