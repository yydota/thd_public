
local G_Rune_Bounty_Spwner_List = {}
local G_Rune_PowerUp_Spwner_List = {}

local G_Rune_Bounty_Spwner_List = {}
local G_Rune_PowerUp_Spwner_List = {}

local vec = Vector(0.0,0.0,-512.0)
local checklen = 100

local is_test = not IsDedicatedServer()

local function testprint(keys)
	if not is_test then return end
	print("[Rune]"..keys)
end

function rune_fixer_init()

		G_Rune_Bounty_Spwner_List = Entities:FindAllByClassname("dota_item_rune_spawner_bounty")
		G_Rune_PowerUp_Spwner_List = Entities:FindAllByClassname("dota_item_rune_spawner")
		
		for _,v in pairs(G_Rune_Bounty_Spwner_List) do
			v:SetOrigin(v:GetOrigin()+vec)
		end
		
		for _,v in pairs(G_Rune_PowerUp_Spwner_List) do
			v:SetOrigin(v:GetOrigin()+vec)
		end
	
		first_rune_remove = true
		local rune_init_time = GameRules:GetGameTime()
		testprint('(Init):'.. string.format("%.2f",rune_init_time))
		
		next_remove_time1 = rune_init_time + 0.2
		next_reset_time1 = rune_init_time + 120.2
		
		next_remove_time2 = rune_init_time + 120.2
		next_reset_time2 = rune_init_time + 0.2
		
		GameRules:GetGameModeEntity():SetContextThink(
			"Rune_Power_Controller",
			function()
				--print('[Rune_Power]:'.. string.format("%.2f",GameRules:GetGameTime()))
				-- when should remove then just remove is enough
				if next_remove_time1 + 0.2 < GameRules:GetGameTime() then
					-- 5,15,25...
					testprint( string.format("(Power)Remove when%.2f cur:%.2f",next_remove_time1,GameRules:GetGameTime()) )
					for _,v in pairs(G_Rune_PowerUp_Spwner_List) do
					
						local nearbyRunesNew = Entities:FindAllByClassnameWithin("dota_item_rune", v:GetOrigin(), checklen)
						for _,rune in pairs(nearbyRunesNew) do
							if rune ~= nil then
								UTIL_Remove(rune)
							end
						end
					end
					if first_rune_remove then
						next_remove_time1 = next_remove_time1 + 300.0 -- 5min
						first_rune_remove = false
					else 
						next_remove_time1 = next_remove_time1 + 600.0 -- 15,25...
					end
				
					--recheck deviation
					local x,y = math.modf(next_remove_time1 - rune_init_time);
					if y < 0.2 then next_remove_time1 = next_remove_time1 + 0.01 end
					
				elseif next_reset_time1 + 0.2 < GameRules:GetGameTime() then--should not remove, check old rune exist?
					--2,4,6,8...
					testprint( string.format("(Power)Reset when%.2f cur:%.2f",next_reset_time1,GameRules:GetGameTime()) )
					for _,v in pairs(G_Rune_PowerUp_Spwner_List) do
					
						local nearbyRunesNew = Entities:FindAllByClassnameWithin("dota_item_rune", v:GetOrigin(), 100)
						local nearbyRunesOld = Entities:FindAllByClassnameWithin("dota_item_rune", v:GetOrigin()-vec, 100)
						if #nearbyRunesOld > 0 then
							UTIL_Remove(nearbyRunesOld[1]) --remove old and reset new location
						end
						if #nearbyRunesNew > 0 then
							nearbyRunesNew[1]:SetOrigin(nearbyRunesNew[1]:GetOrigin()-vec)
						end
					end
					next_reset_time1 = next_reset_time1 + 120.0 -- 2,4,6,8,10...
					
					--recheck deviation
					local x,y = math.modf(next_reset_time1 - rune_init_time);
					if y < 0.2 then next_resetme1 = next_reset_time1 + 0.01 end
					
				end
				return 0.03
			end,
			0.03
		)
		
		
		GameRules:GetGameModeEntity():SetContextThink(
			"Rune_Bounty_Controller", --check if the old -5min bounty picked
			function()
				--print('[Rune_Bounty]:'.. string.format("%.2f",GameRules:GetGameTime()))
				-- when should remove then just remove is enough
				if next_reset_time2 + 0.2 < GameRules:GetGameTime() then--should not remove, check old rune exist?
					--0,5,10,15...
					testprint( string.format("(Bounty)Reset when%.2f cur:%.2f",next_reset_time2,GameRules:GetGameTime()) )
					for _,v in pairs(G_Rune_Bounty_Spwner_List) do
					
						local nearbyRunesNew = Entities:FindAllByClassnameWithin("dota_item_rune", v:GetOrigin(), 100)
						local nearbyRunesOld = Entities:FindAllByClassnameWithin("dota_item_rune", v:GetOrigin()-vec, 100)
						if #nearbyRunesOld > 0 then
							UTIL_Remove(nearbyRunesOld[1]) --remove old and reset new location
						end
						if #nearbyRunesNew > 0 then
							nearbyRunesNew[1]:SetOrigin(nearbyRunesNew[1]:GetOrigin()-vec)
						end
					end
					next_reset_time2 = next_reset_time2 + 300.0 -- 2,4,6,8,10...
					
					--recheck deviation
					local x,y = math.modf(next_reset_time2 - rune_init_time);
					if y < 0.2 then next_reset_time2 = next_reset_time2 + 0.01 end
					
				elseif next_remove_time2 + 0.2 < GameRules:GetGameTime() then
					-- 2,4,6,8,10...
					testprint( string.format("(Bounty)Remove when%.2f cur:%.2f",next_remove_time2,GameRules:GetGameTime()) )
					for _,v in pairs(G_Rune_Bounty_Spwner_List) do
					
						local nearbyRunesNew = Entities:FindAllByClassnameWithin("dota_item_rune", v:GetOrigin(), checklen)
						for _,rune in pairs(nearbyRunesNew) do
							if rune ~= nil then
								UTIL_Remove(rune)
							end
						end
					end
					next_remove_time2 = next_remove_time2 + 120.0 -- 2,4,6,8,10..
					
					--recheck deviation
					local x,y = math.modf(next_remove_time2 - rune_init_time);
					if y < 0.2 then next_remove_time2 = next_remove_time2 + 0.01 end
					
				end
				return 0.03
			end,
			0.03
		)
		
end

--backup
--[[
local vec = Vector(0.0,0.0,-512.0)
local checklen = 100

function rune_fixer_init()

		G_Rune_Bounty_Spwner_List = Entities:FindAllByClassname("dota_item_rune_spawner_bounty")
		G_Rune_PowerUp_Spwner_List = Entities:FindAllByClassname("dota_item_rune_spawner")
		
		for _,v in pairs(G_Rune_Bounty_Spwner_List) do
			v:SetOrigin(v:GetOrigin()+vec)
		end
		
		for _,v in pairs(G_Rune_PowerUp_Spwner_List) do
			v:SetOrigin(v:GetOrigin()+vec)
		end
	
		first_rune_remove = true
		next_remove_time1 = GameRules:GetGameTime() + 0.01
		next_reset_time1 = GameRules:GetGameTime() + 120.01
		
		next_remove_time2 = GameRules:GetGameTime() + 120.01
		next_reset_time2 = GameRules:GetGameTime() + 0.01
		
		print('[Rune_Init]:'.. string.format("%.2f",next_remove_time1))
		
		GameRules:GetGameModeEntity():SetContextThink(
			"Rune_Power_Controller",
			function()
				--print('[Rune_Power]:'.. string.format("%.2f",GameRules:GetGameTime()))
				-- when should remove then just remove is enough
				if first_rune_remove or next_remove_time1 < GameRules:GetGameTime() then
					-- 5,15,25...
					
					for _,v in pairs(G_Rune_PowerUp_Spwner_List) do
					
						local nearbyRunesNew = Entities:FindAllByClassnameWithin("dota_item_rune", v:GetOrigin(), checklen)
						for _,rune in pairs(nearbyRunesNew) do
							if rune ~= nil then
								UTIL_Remove(rune)
							end
						end
					end
					if first_rune_remove then
						next_remove_time1 = next_remove_time1 + 300.0 -- 5min
						first_rune_remove = false
					else 
						next_remove_time1 = next_remove_time1 + 600.0 -- 15,25...
					end
				elseif next_reset_time1 < GameRules:GetGameTime() then--should not remove, check old rune exist?
					--2,4,6,8...
					for _,v in pairs(G_Rune_PowerUp_Spwner_List) do
					
						local nearbyRunesNew = Entities:FindAllByClassnameWithin("dota_item_rune", v:GetOrigin(), 100)
						local nearbyRunesOld = Entities:FindAllByClassnameWithin("dota_item_rune", v:GetOrigin()-vec, 100)
						if #nearbyRunesOld > 0 then
							UTIL_Remove(nearbyRunesOld[1]) --remove old and reset new location
						end
						if #nearbyRunesNew > 0 then
							nearbyRunesNew[1]:SetOrigin(nearbyRunesNew[1]:GetOrigin()-vec)
						end
					end
					next_reset_time1 = next_reset_time1 + 120.0 -- 2,4,6,8,10...
				end
				return 0.1
			end,
			0.1
		)
		
		
		GameRules:GetGameModeEntity():SetContextThink(
			"Rune_Bounty_Controller", --check if the old -5min bounty picked
			function()
				--print('[Rune_Bounty]:'.. string.format("%.2f",GameRules:GetGameTime()))
				-- when should remove then just remove is enough
				if next_reset_time2 < GameRules:GetGameTime() then--should not remove, check old rune exist?
					--0,5,10,15...
					for _,v in pairs(G_Rune_Bounty_Spwner_List) do
					
						local nearbyRunesNew = Entities:FindAllByClassnameWithin("dota_item_rune", v:GetOrigin(), 100)
						local nearbyRunesOld = Entities:FindAllByClassnameWithin("dota_item_rune", v:GetOrigin()-vec, 100)
						if #nearbyRunesOld > 0 then
							UTIL_Remove(nearbyRunesOld[1]) --remove old and reset new location
						end
						if #nearbyRunesNew > 0 then
							nearbyRunesNew[1]:SetOrigin(nearbyRunesNew[1]:GetOrigin()-vec)
						end
					end
					next_reset_time2 = next_reset_time2 + 300.0 -- 2,4,6,8,10...
				elseif next_remove_time2 < GameRules:GetGameTime() then
					-- 2,4,6,8,10...
					for _,v in pairs(G_Rune_Bounty_Spwner_List) do
					
						local nearbyRunesNew = Entities:FindAllByClassnameWithin("dota_item_rune", v:GetOrigin(), checklen)
						for _,rune in pairs(nearbyRunesNew) do
							if rune ~= nil then
								UTIL_Remove(rune)
							end
						end
					end
					next_remove_time2 = next_remove_time2 + 120.0 -- 2,4,6,8,10..
				end
				return 0.1
			end,
			0.1
		)
		
end
]]