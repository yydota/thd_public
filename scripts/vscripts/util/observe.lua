
function observer_init( hero ) --将观察者传送到隔离区
	local location = nil
	if GetMapName() == "1_thdots_map" then
		hero:SetOrigin(Vector(-7915.093750,7660.718750,1024.000000))
	elseif GetMapName() == "dota" then
		hero:SetOrigin(Vector(6401.718750,-6848.625000,256.000000))
	elseif GetMapName() == "4_thdots_with_coach" then
		hero:SetOrigin(Vector(-7915.093750,7660.718750,1024.000000))
	end
end

function CreateObserveSightUnitStatic( caster )
	
	if caster == nil then return end
	--AddFOWViewer( observer:GetTeam(), Vector(0,0,0), 99999, 36000, false)
	local unit = CreateUnitByName(
		"npc_vision_observer_dummy_unit"
		,caster:GetOrigin()
		,false
		,nil
		,nil
		,6
	)

	local abilityGEM = unit:FindAbilityByName("ability_thdots_observer_unit")
	if abilityGEM ~= nil then
		abilityGEM:SetLevel(1)
		unit:CastAbilityImmediately(abilityGEM, 0)
	end

	local ability_dummy_unit = unit:FindAbilityByName("ability_dummy_unit")
	ability_dummy_unit:SetLevel(1)

end

function CreateObserveSightUnit( caster )
	
	if caster == nil then return end
	print("ok")
	local unit = CreateUnitByName(
		"npc_vision_observer_dummy_unit"
		,caster:GetOrigin()
		,false
		,nil
		,nil
		,6
	)

	local abilityGEM = unit:FindAbilityByName("ability_thdots_observer_unit")
	if abilityGEM ~= nil then
		abilityGEM:SetLevel(1)
		unit:CastAbilityImmediately(abilityGEM, 0)
	end

	local ability_dummy_unit = unit:FindAbilityByName("ability_dummy_unit")
	ability_dummy_unit:SetLevel(1)

	unit:SetContextThink("follow_caster", 
		function ()
			unit:SetOrigin(caster:GetOrigin())
			return 0.3
		end, 
	0.3)

end

function CreateObserveSightUnitForAll( ClassName )
	local tt=Entities:FindAllByClassname(ClassName)
	for i=0,#tt do
		CreateObserveSightUnitStatic(tt[i])
	end
end

function enable_coach( plyid, is_observer )
	
	local player = PlayerResource:GetPlayer(plyid)
	if is_observer then --swtich to observer team
		PlayerResource:SetCustomTeamAssignment( plyid ,6 )
	end
	CreateHeroForPlayer("npc_dota_hero_monkey_king", player):RemoveSelf()
	
	PlayerResource:SetGold(plyid, 0, true)
	PlayerResource:SetGold(plyid, 0, false)
	
	player:SetContextThink(DoUniqueString("wait_for_observer_spawn"), 
		function()
			local hero = player:GetAssignedHero()
			if hero then
				observer_init(hero)
				return nil
			else
				return 0.03
			end
		end,
	0.03)
end

ob_enabled = false

function enable_observe( enable_sight )
	
	GameRules:SetCustomGameTeamMaxPlayers( 6, 6 )
	
	if sight_enabled then return end
	
	if enable_sight then --给予观战视野(太多游戏会爆炸)
		CreateObserveSightUnitForAll( "npc_dota_tower" )       --塔
		--CreateObserveSightUnitForAll( "npc_dota_barracks" )  --兵营
		--CreateObserveSightUnitForAll( "npc_dota_fort" )      --基地
		CreateObserveSightUnitForAll( "ent_dota_fountain" )    --泉水
		CreateObserveSightUnitForAll( "npc_dota_watch_tower" ) --前哨
		--CreateObserveSightUnitForAll( "trigger_multiple" )   --刷野点
		sight_enabled = true
	end
	
end


function AddObViews()
	if GetMapName() ~= "1_thdots_map" then
		print("AddObViews")
		AddFOWViewer(5,Vector(0,0,0),4000,9999,false)
		AddFOWViewer(5,Vector(0,4000,0),4000,9999,false)
		AddFOWViewer(5,Vector(0,-4000,0),4000,9999,false)
		AddFOWViewer(5,Vector(4000,0,0),4000,9999,false)
		AddFOWViewer(5,Vector(4000,4000,0),4000,9999,false)
		AddFOWViewer(5,Vector(4000,-4000,0),4000,9999,false)
		AddFOWViewer(5,Vector(-4000,0,0),4000,9999,false)
		AddFOWViewer(5,Vector(-4000,4000,0),4000,9999,false)
		AddFOWViewer(5,Vector(-4000,-4000,0),4000,9999,false)
	end
end