Shuffle_Pressed = function (keys) --洗牌
	-- if not IsServer() then return end
	-- local paixu = {}
	-- local val = keys.val
	-- local plyid = keys.PlayerID
	-- -- DeepPrintTable(keys)
	-- local result = THDSetTeam()
	-- -- print(result[1][1].tiantifen)
	-- local fenshu = 0
	-- for i = 1,#result do 
	-- 	for j = 1, 5 do
	-- 		fenshu = fenshu + result[i][j].tiantifen
	-- 	end
	-- 	table.insert(paixu,fenshu)
	-- 	fenshu = 0
	-- end
	-- 	table.sort(paixu)
	-- 	print_r(paixu)
	-- for i=0, PlayerResource:GetPlayerCount() do
	-- 	local player = PlayerResource:GetPlayer(i)
	-- 	if player then
	-- 		-- print(PlayerResource:GetSteamAccountID(player:GetPlayerID()))
	-- 		local team = DOTA_TEAM_GOODGUYS
	-- 		if RollPercentage(50) then
	-- 			team = DOTA_TEAM_BADGUYS
	-- 		end
	-- 		PlayerResource:SetCustomTeamAssignment( player:GetPlayerID() ,team)
	-- 	end
	-- end
end

function THDSetTeam()
	local atable = {}
	local caculate = {}
	for i = 1,10 do
		atable[i] = {index = i,tiantifen = i * 100}
		table.insert(caculate,atable[i])
	end
	-- print(zuhe(atable,5))
	local result = zuhe(caculate,5)
	return result
end

function zuhe(atable, n)
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
    for i=1, len do
        if meta[i] == 1 then
            table.insert(tmp, atable[i])
        end
    end
    table.insert(result, tmp)

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
        for i=1, len do
            if meta[i] == 1 then
                table.insert(tmp, atable[i])
            end
        end
        table.insert(result, tmp)
    end

    return result
end