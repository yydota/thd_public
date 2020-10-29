
G_IsAIMode = false
G_IsFastCDMode = false
G_IsFastRespawnMode = false
G_IsCloneMode = false
G_IsFCloneMode = false
Bot_Mode = false
-- look at precache, if map == "dota" then enable for default

player_per_team = 5 --default
cur_bot_dif = 1 -- easy
fast_respawn_val = 20 -- fast respawn mode's respawn time
G_Bot_Push_All_Time = {40,30,20,10}

G_Bot_List = {}
G_Bot_Buff_List = {}
G_Bot_Diff_Text = {"easy","normal","hard","lunatic"}

G_Bot_Level = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

function GetValidConnectedCount()
	local ret = 0
	for i=0,233 do
		if PlayerResource:GetConnectionState(i) == 2 then
			ret = ret + 1
		end
	end
	return ret
end

function THD2_SetBotMode(val) Bot_Mode = val end
function THD2_SetFCDMode(val) G_IsFastCDMode = val end
function THD2_SetFRSMode(val) G_IsFastRespawnMode = val end
function THD2_SetFRSTime(val) fast_respawn_val = val end
function THD2_SetPlayerPerTeam(val)
	if GetMapName()=="dota" and 
		cur_bot_heros_size + GetValidConnectedCount() < val * 2 
		then
		val = math.floor((cur_bot_heros_size + GetValidConnectedCount())/2.0)
	end
	player_per_team = val
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, val )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, val )
	return val
end
function THD2_SetBotThinking(val)
	G_IsAIMode = val
	GameRules:GetGameModeEntity():SetBotThinkingEnabled(val)
end
function THD2_SetCloneMode(val)
	G_IsCloneMode = val
	if val ~= true then G_IsFCloneMode = false end
	GameRules:SetSameHeroSelectionEnabled(val)
end
function THD2_SetFCloneMode(val)
	G_IsFCloneMode = val
	if val == true then THD2_SetCloneMode(true) end
end

function THD2_GetBotMode() return Bot_Mode end
function THD2_GetFCDMode() return G_IsFastCDMode end
function THD2_GetFRSMode() return G_IsFastRespawnMode end
function THD2_GetFRSTime() return fast_respawn_val end
function THD2_GetBotDiff() return cur_bot_dif end
function THD2_GetBotDiffName() return G_Bot_Diff_Text[cur_bot_dif] end
function THD2_GetBotThinking(val) G_IsAIMode = val end
function THD2_GetPlayerPerTeam(val) return player_per_team end


--to ban some girls(which is not work done XD)
cur_bot_heros_size = 13
tot_bot_heros_size = 33
G_BOT_USED = 
{
	false ,
	false ,
	false ,
	false ,
	false ,
	
	true ,
	false ,
	false ,
	false ,
	false ,
	
	true ,
	false ,
	true ,
	true ,
	true ,
	
	true ,
	false ,
	true ,
	true ,
	false ,
	
	true ,
	true ,
	true ,
	true ,
	true ,
	
	true ,
	true ,
	true ,
	true ,
	true ,
	
	true ,
	true ,
	false ,
}

G_Bot_Random_Hero = 
{	
	"npc_dota_hero_lina",					--红白
	"npc_dota_hero_juggernaut",				--妖梦
	"npc_dota_hero_slark",					--文文
	"npc_dota_hero_earthshaker",			--天子
	"npc_dota_hero_life_stealer",			--⑩
	
	"npc_dota_hero_crystal_maiden",			--黑白
	"npc_dota_hero_drow_ranger",			--恋
	"npc_dota_hero_mirana",					--兔子
	"npc_dota_hero_chaos_knight",			--妹红
	"npc_dota_hero_centaur",				--红三
	
	"npc_dota_hero_tidehunter",				--西瓜
	"npc_dota_hero_clinkz",					--虫子
	"npc_dota_hero_axe",					--⑨
	"npc_dota_hero_naga_siren",				--二妹
	"npc_dota_hero_storm_spirit",			--四季
	
	"npc_dota_hero_razor",					--衣玖
	"npc_dota_hero_dark_seer",				--白莲
	"npc_dota_hero_furion",					--辉夜
	"npc_dota_hero_kunkka",					--船长
	"npc_dota_hero_lion",					--早苗
	
	"npc_dota_hero_necrolyte",				--uuz
	"npc_dota_hero_puck",					--蓝
	"npc_dota_hero_sniper",					--空
	"npc_dota_hero_tinker",					--教授
	"npc_dota_hero_venomancer" ,			--花妈
	
	"npc_dota_hero_zuus",					--神妈
	"npc_dota_hero_warlock",				--大妹
	"npc_dota_hero_bounty_hunter",			--狗花
	"npc_dota_hero_silencer",				--永琳
	"npc_dota_hero_obsidian_destroyer",		--紫
	
	"npc_dota_hero_templar_assassin",		--16
	"npc_dota_hero_visage",					--小爱
	"npc_dota_hero_viper",					--毒人偶
}

G_Bots_Ability_Add = {
	--0X
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16,  0,0,0,0,0  },
	{2,1,2,1,2,  6,2,1,1,10,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,1,2,1,  6,1,2,2,10,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,3,2,2,  6,2,3,3,11,  3,6,1,1,13, 1,0,6,0,15,  0,0,0,0,16,  0,0,0,0,0  },
	
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16,  0,0,0,0,0  }, --marisa wait for fix
	{2,1,3,3,3,  2,3,2,2,10,  6,6,1,1,13, 1,0,6,0,14,  0,0,0,0,16,  0,0,0,0,0  },
	{2,1,1,3,1,  6,1,3,3,10,  3,6,2,2,12, 2,0,6,0,14,  0,0,0,0,17,  0,0,0,0,0  },
	{2,1,2,3,2,  6,2,3,3,10,  3,6,1,1,13, 1,0,6,0,15,  0,0,0,0,16,  0,0,0,0,0  },
	{1,3,1,3,1,  6,1,3,3,10,  2,6,2,2,13, 2,0,6,0,14,  0,0,0,0,17,  0,0,0,0,0  },
	
	--1X
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16,  0,0,0,0,0  }, -- suika wait for fix
	{2,1,2,3,2,  6,2,3,3,11,  3,6,1,1,13, 1,0,6,0,14,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,1,2,1,  6,1,2,2,10,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,3,2,2,  6,2,3,3,11,  3,6,1,1,13, 1,0,6,0,15,  0,0,0,0,16,  0,0,0,0,0  },
	
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16,  0,0,0,0,0  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,1,2,1,  6,1,2,2,10,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,3,1,1,  6,1,3,3,11,  3,6,2,2,12, 2,0,6,0,15,  0,0,0,0,16,  0,0,0,0,0  }, --sanae
	
	--2X(预留)
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16,  0,0,0,0,0  },
	{2,1,2,3,2,  6,2,3,3,11,  3,6,1,1,13, 1,0,6,0,14,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,1,2,1,  6,1,2,2,10,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,3,2,2,  6,2,3,3,11,  3,6,1,1,13, 1,0,6,0,15,  0,0,0,0,16,  0,0,0,0,0  },
	
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16,  0,0,0,0,0  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,1,2,1,  6,1,2,2,10,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,3,1,1,  6,1,3,3,11,  3,6,2,2,12, 2,0,6,0,15,  0,0,0,0,16,  0,0,0,0,0  },
	
	--3X
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16,  0,0,0,0,0  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17,  0,0,0,0,0  },
	{1,2,3,2,2,  6,2,1,1,10,  1,6,3,3,13, 3,0,6,0,15,  0,0,0,0,16,  0,0,0,0,0  }, --medicine
}

function THD2_BotUpGradeAbility(hero)
	print("THDOTSGameMode:BotUpGradeAbility")
	
	local hName = hero:GetClassname()
	local hIndex = -1
	for i=0,233 do
		if G_Bot_Random_Hero[i] == hName then
			hIndex = i
			break
		end
	end
	
	if hIndex < 0 then
		print('THDOTSGameMode:BotUpGradeAbility: Error: invalid hero name: ' .. hName )
	else
		local v = hero:GetPlayerOwnerID()
		local lvl = hero:GetLevel()
		--print(lvl)
		if lvl == nil then
			lvl = 1
		end
		if G_Bot_Level[v] == nil then
			G_Bot_Level[v] = 0
		end
		--print(lvl)
		for i=G_Bot_Level[v]+1,lvl do
			if i > 25 then break end 
			local j = G_Bots_Ability_Add[hIndex][i] - 1 --abilitys is 0~n-1, but vals set as 1~n
			local ability = hero:GetAbilityByIndex(j)
			if ability~=nil then
				local level = math.min((ability:GetLevel() + 1),ability:GetMaxLevel())
				ability:SetLevel(level)
			end
		end
		
		G_Bot_Level[v] = lvl
		hero:SetAbilityPoints(0)
		
	end
	
	
end

function THD2_ChangeBotDifficulty( player, dif )
	
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_STRATEGY_TIME then -- can't change difficulty in game
		Say(player, "Can't change bot's difficulty after bot spawned!",false)
		print("THDOTSGameMode:ChangeBotDifficulty: Error: Can't Change difficulty after bot spawned")
		return
	end
	if dif <=0 or dif > 4 then --invalid difficulty
		Say(player, "invalid difficulty!",false)
		print("THDOTSGameMode:ChangeBotDifficulty: Error: invalid difficulty")
		return
	end
	cur_bot_dif = dif
	
	local text = G_Bot_Diff_Text[dif]
	Say(player, "Bot Difficulty set to " .. text, false)
	print("Bot Difficulty set to " .. text)
	
	-- not modify at here now, see state changes
	--[[
	for k,v in pairs(G_Bot_List) do
		local tHero = PlayerResource:GetPlayer(v):GetAssignedHero()
		tHero:SetBotDifficulty(dif)
	end
	
	for k,v in pairs(G_Bot_Buff_List) do
		v:SetLevel(dif)
	end
	]]--
end

function THD2_AddBot()

			print("changing to bot mod...")
			print(GameRules:IsCheatMode()) --debug
			
			--DOTA2 的bot加载机制十分弱智
			--如果你进游戏的时候是作弊模式, 那么你就可以控制机器人了
			--但如果不是作弊模式会创建不了机器人
			--所以唯一的办法就是先开作弊创建机器人, 然后进游戏前关掉作弊, 进游戏以后再打开作弊并开启机器人脚本
			--十分弱智不是嘛qwq ? 
			--    来自zdw1999
			
			--[[
			
			local ply = nil
			for i=0,9 do --检测机器人将要使用的位置
				ply = PlayerResource:GetPlayer(i)
				if ply==nil then
					table.insert(G_Bot_List,i)
				end
			end
			--用bot填充空位
			SendToServerConsole('dota_bot_populate')
			SendToServerConsole('dota_bot_set_difficulty 3') --难度为hard
			--设置AI活动
			--local GameMode = GameRules:GetGameModeEntity()
			--GameMode:SetBotThinkingEnabled(true) --不要在这里开启脚本
			--设置AI推塔的最高级别
			--GameMode:SetBotsMaxPushTier(5)
			
			--在这里先关闭cheats, 等进游戏后执行 -startbot
			SendToServerConsole('sv_cheats 0')
			
			--]]
			
			--old bot load style
			--SendToServerConsole('sv_cheats 1')
			--print(GameRules:IsCheatMode()) --debug
			--G_IsAIMode = true
			
			--为了能够方便控制机器人的技能点和属性, 这里使用旧方式加载bot
			
			local GameMode = GameRules:GetGameModeEntity()
			local ply = nil
			local goodcnt = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
			local badcnt = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
			
			--清除玩家选择的英雄
				for i=0,233 do
					ply = PlayerResource:GetPlayer(i)
					if ply ~= nil then
						local tHeroName = PlayerResource:GetSelectedHeroName(i)
						print( 'Player ' .. string.format("%d",i) .. ' picked ' .. tHeroName )
						if tHeroName ~= nil then
							for j=0,233 do
								if G_Bot_Random_Hero[j] == tHeroName then
									G_BOT_USED[j] = true
									break
								end
							end
						end
					end
				end
				
			-- 创建bot
			
			for i=0,233 do
				ply = PlayerResource:GetPlayer(i)
				if ply ~= nil then
					print(string.format("player %d is not nil",i))
				end
				
				if goodcnt >= player_per_team and badcnt >= player_per_team then
					break
				end
				
				if ply == nil then
					local int = RandomInt(1, tot_bot_heros_size)
					while(G_BOT_USED[int])
					do
						int = RandomInt(1, tot_bot_heros_size)
					end
					bot_team = true
					if goodcnt >= player_per_team then
						bot_team = false
					end
					if bot_team == true then
						goodcnt = goodcnt + 1
					else 
						badcnt = badcnt + 1
					end
					--table.insert(G_Bot_List,i)
					Tutorial:AddBot(G_Bot_Random_Hero[int],'','',bot_team)
					G_BOT_USED[int]=true
					
				end
			end
			
			for i=0,233 do
				if PlayerResource:GetPlayer(i) ~= nil and PlayerResource:GetConnectionState(i) == 1 then
					table.insert(G_Bot_List,i)
					print(i)
				end
			end
			--如果存在机器人则启动AI
			
			if #G_Bot_List > 0 then
				THD2_SetBotMode(true)
				--设置AI活动
				GameRules:GetGameModeEntity():SetBotThinkingEnabled(true)
				--设置AI推塔的最高级别
				GameRules:GetGameModeEntity():SetBotsMaxPushTier(cur_bot_dif + 2)
				--for i=0,9 do
				--	if PlayerResource:GetConnectionState(i)==1 then
				--		plyhd = PlayerResource:GetPlayer(keys.userid-1)
				--		plyhd:
				--	end
				--end
			end
			
			--在这里先关闭cheats, 等进游戏后执行 -startbot
			--G_IsAIMode = false
			--SendToServerConsole('sv_cheats 0')
			--print(GameRules:IsCheatMode()) --debug
			
			--Say(nil, "Bot Spawned...",false)
			print("Bot Spawned...") --debug
			
end

function THD2_FirstAddBuff( hero )

			-- set bot's default ability level
		    if THD2_GetBotMode() == true then
			    local plyID = hero:GetPlayerOwnerID()
			    for k,v in pairs(G_Bot_List) do
			    	if v == plyID then
						local bot_buff_ability = hero:AddAbility("ability_common_bot_buff") --bot mana buff
						if bot_buff_ability ~= nil then
							table.insert(G_Bot_Buff_List,bot_buff_ability)
							bot_buff_ability:SetLevel(cur_bot_dif) -- bot's default difficulty
						end
						hero:SetBotDifficulty(cur_bot_dif)
						THD2_BotUpGradeAbility(hero) -- init abilities
						--[[
						for i=0,16 do
						 	local ability = hero:GetAbilityByIndex(i)
							if ability~=nil then
								local level = 1 or ability:GetMaxLevel()
								ability:SetLevel(level)
							end
						end
						]]--
				 	end
				end
			end
			
			if G_IsFastCDMode then --Fast CoolDown
				local fastCDability = hero:AddAbility("ability_fast_cd_buff")
				if fastCDability ~= nil then
					fastCDability:SetLevel(1)
				end
			end
			
end

function THD2_BotPushAllWithDelay()

		GameRules:GetGameModeEntity():SetContextThink(
			"Bot Push All",
			function()
				GameRules:GetGameModeEntity():SetBotsMaxPushTier(6)
				return nil
			end,
			G_Bot_Push_All_Time[cur_bot_dif] * 60.0
		)
end

function THD2_Special_OnLevelUp()
	
	if THD2_GetBotMode() == true then
	    for k,v in pairs(G_Bot_List) do
	    	--if v == keys.player then
			-- just updata every bot is ok
    			local ply = PlayerResource:GetPlayer(v)
	    		local hero = ply:GetAssignedHero()
				THD2_BotUpGradeAbility(hero)
		 	--end
		end
	end
	
end

function THD2_MakePlayerRepick( plyid , heroname, penalty )
	if penalty == nil then penalty = true end
    if GameRules:State_Get() == 4 and G_IsFCloneMode then return end --强制克隆时不能在4阶段repick
    if GameRules:State_Get() >= 5 then return end --显然游戏开始后不能repick
	local plyhd = PlayerResource:GetPlayer(plyid)
	if PlayerResource:HasSelectedHero(plyid) == false then return end
	if penalty then
		if PlayerResource:HasRandomed(plyid) then 
			PlayerResource:ModifyGold(plyid,-200,true,0); -- -200 gold
		end
		PlayerResource:ModifyGold(plyid,-100,true,0); -- -100 gold
	end
	local tmp = plyhd:GetAssignedHero();
	CreateHeroForPlayer(heroname, plyhd):RemoveSelf();
	if tmp~=nil then tmp:RemoveSelf() end
end

function THD2_ForcePlayerRepick( plyid , heroname )
	local plyhd = PlayerResource:GetPlayer(plyid)
	if PlayerResource:HasSelectedHero(plyid) == false then return end
	local tmp = plyhd:GetAssignedHero();
	if GameRules:State_Get() <= 5 then
		CreateHeroForPlayer(heroname, plyhd):RemoveSelf();
	else
		CreateHeroForPlayer(heroname, plyhd);
	end
	if tmp~=nil then tmp:RemoveSelf() end
end

function THD2_ForceClone()

	print('!!!')
	if G_IsAIMode or not G_IsFCloneMode then return end
	
	local H_table = {}
	
	for playerId = 0, 233 do
		if PlayerResource:IsValidTeamPlayerID(playerId) then
			print(playerId)
			local team = PlayerResource:GetTeam(playerId)
			local hero = PlayerResource:GetSelectedHeroName(playerId)
			
			local val = 1
			if PlayerResource:IsFakeClient(playerId) then val = 99 end
			print(val)
			
			if H_table[team] == nil then H_table[team] = {} end
			if H_table[team][hero] == nil then H_table[team][hero] = 0 end
			H_table[team][hero] = H_table[team][hero] + val
			
		end
	end
	
	local H_result = {}

	for playerId = 0, 233 do
		if PlayerResource:IsValidTeamPlayerID(playerId) then
			local team = PlayerResource:GetTeam(playerId)
			local hero = PlayerResource:GetSelectedHeroName(playerId)
			
			if H_result[team] == nil then
				H_result[team] = hero
			elseif H_table[team][H_result[team]] < H_table[team][hero] then
				H_result[team] = hero
			end
			
		end
	end

	for playerId = 0, 233 do
		if PlayerResource:IsValidTeamPlayerID(playerId) then
			local team = PlayerResource:GetTeam(playerId)
			local hero = PlayerResource:GetSelectedHeroName(playerId)
			
			if hero ~= H_result[team] then
				THD2_ForcePlayerRepick(playerId , H_result[team])
			end
			
		end
	end

end

function THD2_BotThinker()
	
	if THD2_GetBotMode() == true then
	    for k,v in pairs(G_Bot_List) do
	    	--if v == keys.player then
			-- just updata every bot is ok
    			local ply = PlayerResource:GetPlayer(v)
	    		local hero = ply:GetAssignedHero()
				THD2_BotUpGradeAbility(hero)
		 	--end
		end
	end
	
end
