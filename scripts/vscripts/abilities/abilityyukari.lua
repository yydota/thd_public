

g_creeps_name={
	"npc_dota_goodguys_siege",
	"npc_dota_goodguys_siege_upgraded",
	"npc_dota_badguys_siege",
	"npc_dota_badguys_siege_upgraded",
	"npc_dota_creep_goodguys_melee",
	"npc_dota_creep_goodguys_melee_upgraded",
	"npc_dota_creep_goodguys_ranged",
	"npc_dota_creep_goodguys_ranged_upgraded",
	"npc_dota_creep_badguys_melee",
	"npc_dota_creep_badguys_melee_upgraded",
	"npc_dota_creep_badguys_ranged",
	"npc_dota_creep_badguys_ranged_upgraded"
}
g_yukari_players_gap={}
Yukari01_MODIFIER_FALLDOWN_NAME="modifier_thdots_yukari01_falldown"
Yukari02_MODIFIER_HIDDEN_NAME="modifier_thdots_yukari02_hidden"
Yukari02_MODIFIER_COUNTER_NAME="modifier_thdots_yukari02_counter"
anti_bd_modifier_name="modifier_thdots_unit_anti_bd"

function Yukari_CanMovetoGap(unit)
	if unit==nil or unit:IsNull() then
		return false
	end
	for _,name in pairs(g_creeps_name) do
		if name==unit:GetUnitName() then return true end
	end
end

function Yukari_FalldownUnitInGap(caster,pos)
	local caster=caster
	local Ability01=caster:FindAbilityByName("ability_thdots_yukari01")
	local playerid=caster:GetPlayerOwnerID()
	if Ability01 and g_yukari_players_gap[playerid] then
		local unit_in_gap=nil
		for _,u in pairs(g_yukari_players_gap[playerid]) do
			if u==nil or u:IsNull() then
				unit_in_gap=u
			else
				unit_in_gap=u
				break
			end
		end
		if unit_in_gap then
			local effectIndex = ParticleManager:CreateParticle("particles/heroes/yukari/ability_yukari_02_body.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(effectIndex, 3, pos)
			caster:EmitSound("Hero_ObsidianDestroyer.AstralImprisonment.End")

			local ability_level=Ability01:GetLevel()
			if ability_level<1 then ability_level=1 end
			unit_in_gap:SetOrigin(pos)
			unit_in_gap:RemoveModifierByNameAndCaster(Yukari02_MODIFIER_HIDDEN_NAME,caster)
			Ability01:ApplyDataDrivenModifier(caster,unit_in_gap,Yukari01_MODIFIER_FALLDOWN_NAME,{})
			local falldown_time=Ability01:GetLevelSpecialValueFor("falldown_time",ability_level)
			local end_time=GameRules:GetGameTime()+falldown_time
			local vz=pos.z
			unit_in_gap:SetContextThink(
				"yukari01_falldown",
				function ()
					if GameRules:IsGamePaused() then return 0.03 end
					local now_time=GameRules:GetGameTime()
					pos.z=vz+500*(end_time-now_time)/falldown_time
					unit_in_gap:SetOrigin(pos)
					if now_time>=end_time then
						local ability_level_now=Ability01:GetLevel()
						Ability01:SetLevel(ability_level)

						unit_in_gap:EmitSound("Ability.TossImpact")
						local damage_table={
							victim=nil, 
							attacker=caster, 
							ability=Ability01,
							damage=Ability01:GetAbilityDamage(),
							damage_type=Ability01:GetAbilityDamageType(),
						}
						local enemies = FindUnitsInRadius(
							caster:GetTeamNumber(),
							pos,
							nil,
							Ability01:GetLevelSpecialValueFor("radius",ability_level),
							Ability01:GetAbilityTargetTeam(),
							Ability01:GetAbilityTargetType(),
							Ability01:GetAbilityTargetFlags(),
							FIND_ANY_ORDER,--[[FIND_CLOSEST,]]
							false)
						for _,u in pairs(enemies) do
							damage_table.victim=u
							UnitDamageTarget(damage_table)
							UtilStun:UnitStunTarget(caster,u,Ability01:GetLevelSpecialValueFor("stun_duration",ability_level)+FindTelentValue(caster, "special_bonus_unique_outworld_devourer"))
						end

						UnitDamageTarget{
							victim=unit_in_gap,
							attacker=caster,
							ability=Ability01,
							damage=Ability01:GetLevelSpecialValueFor("damage_unit_base",ability_level)+unit_in_gap:GetMaxHealth()*Ability01:GetLevelSpecialValueFor("damage_unit_pct",ability_level)*0.01,
							damage_type=DAMAGE_TYPE_PURE
						}
						if unit_in_gap:IsAlive() then
							FindClearSpaceForUnit(unit_in_gap,pos,true)
						end
						if ability_level~=ability_level_now then Ability01:SetLevel(ability_level_now) end
						return nil
					end
					return 0.03
				end,0)
			return true
		end
	end
	return false
end

function yukariEx_SpellStart(keys)
	local ability=keys.ability
	local caster=keys.caster
	local target=keys.target_points[1]

	local falldown_count=0

	-- local unit = CreateUnitByName(
	-- 	"npc_thdots_unit_yukari_ex_unit"
	-- 	,target
	-- 	,false
	-- 	,caster
	-- 	,caster
	-- 	,caster:GetTeam()
	-- )
	-- local ability_dummy_unit = unit:FindAbilityByName("ability_dummy_unit")
	-- ability_dummy_unit:SetLevel(1)

	caster:SetContextThink(
		"yukariEx_main_loop",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if falldown_count<keys.FalldownNum then
				if Yukari_FalldownUnitInGap(caster,target+RandomVector(RandomFloat(0,keys.Radius))) then
					falldown_count=falldown_count+1
					return keys.FalldownInterval
				end
			end
			if falldown_count==0 then
				ability:RefundManaCost()
				ability:EndCooldown()
			end
			-- unit:RemoveSelf()
			return nil
		end,0)
end

function YukariEx_OnIntervalThink(keys)
	local ability=keys.ability
	local caster=keys.caster
	local ability_lvl=math.floor(1+(caster:GetLevel()-1)/5)
	if ability_lvl~=ability:GetLevel() then
		ability:SetLevel(ability_lvl)
	end
end

function Yukari01_OnSpellStart(keys)
	local ability=keys.ability
	local caster=keys.caster
	local target=keys.target_points[1]

	if not Yukari_FalldownUnitInGap(caster,target) then
		ability:RefundManaCost()
		ability:EndCooldown()
	end
end

function Yukari02_OnHiddenStart(keys)
	local caster=keys.caster
	local target=keys.target
	if target:IsNull()==false and target ~= nil then
		if  caster:GetTeam() ~= target:GetTeam() and is_spell_blocked(keys.target) then 
			target:RemoveModifierByName("modifier_thdots_yukari02_hidden")
			return 
		end
	end
	local ability=keys.ability
	local unit = CreateUnitByName(
		"npc_thdots_unit_yukari01_unit"
		,target:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	local ability_dummy_unit = unit:FindAbilityByName("ability_dummy_unit")
	ability_dummy_unit:SetLevel(1)

	target:EmitSound("Hero_ObsidianDestroyer.AstralImprisonment")

	local e = ParticleManager:CreateParticle("particles/heroes/yukari/ability_yukari_02_vortex_2.vpcf", PATTACH_CUSTOMORIGIN, unit)
	ParticleManager:SetParticleControl(e, 0, unit:GetOrigin())

	--unit:StartGesture(ACT_DOTA_DIE)

	caster.ability_yukari01_unit = unit
	target:AddNoDraw()
	if Yukari_CanMovetoGap(target) then
		local playerid=caster:GetPlayerOwnerID()
		g_yukari_players_gap[playerid]=g_yukari_players_gap[playerid] or {}
		g_yukari_players_gap[playerid][target]=target

		local stack_num=caster:GetModifierStackCount(Yukari02_MODIFIER_COUNTER_NAME,caster)+1
		if not caster:HasModifier(Yukari02_MODIFIER_COUNTER_NAME) then
			ability:ApplyDataDrivenModifier(caster,caster,Yukari02_MODIFIER_COUNTER_NAME,{})
		end
		caster:SetModifierStackCount(Yukari02_MODIFIER_COUNTER_NAME,caster,stack_num)
		unit:SetContextThink(DoUniqueString("ability_yukari_02_hidden_unit_remove"), 
		function ()
				if GameRules:IsGamePaused() then return 0.03 end
				ParticleManager:DestroyParticle(e,false)
				unit:RemoveSelf()
			end, 
		0.8)
		target:SetOrigin(Vector(-7907,7624,1024))
	else
		unit:StartGesture(ACT_DOTA_SPAWN)
		unit:SetContextThink(DoUniqueString("ability_yukari_02_hidden_unit_remove"), 
		function ()
				if GameRules:IsGamePaused() then return 0.03 end
				unit:RemoveSelf()
			end, 
		keys.HeroHiddenDuration + 0.5)
	end
end

function Yukari02_OnHiddenEnd(keys)
	local caster=keys.caster
	local target=keys.target

	target:EmitSound("Hero_ObsidianDestroyer.AstralImprisonment.End")
	target:StopSound("Hero_ObsidianDestroyer.AstralImprisonment")
	target:RemoveNoDraw()

	if caster.ability_yukari01_unit ~= nil and caster.ability_yukari01_unit:IsNull() == false then 
		caster.ability_yukari01_unit:StartGesture(ACT_DOTA_SPAWN)
		caster.ability_yukari01_unit:SetContextThink(DoUniqueString("ability_yukari_02_hidden_unit_remove"), 
		function ()
				if GameRules:IsGamePaused() then return 0.03 end
				caster.ability_yukari01_unit:RemoveSelf()
			end, 
		0.5)
	end

	if Yukari_CanMovetoGap(target) then
		local playerid=caster:GetPlayerOwnerID()
		g_yukari_players_gap[playerid]=g_yukari_players_gap[playerid] or {}
		g_yukari_players_gap[playerid][target]=nil

		local stack_num=caster:GetModifierStackCount(Yukari02_MODIFIER_COUNTER_NAME,caster)-1
		if stack_num==0 then
			caster:RemoveModifierByNameAndCaster(Yukari02_MODIFIER_COUNTER_NAME,caster)
		elseif stack_num>0 then
			caster:SetModifierStackCount(Yukari02_MODIFIER_COUNTER_NAME,caster,stack_num)
		end		
	end
end

function Yukari02_OnSpellStart(keys)
	local ability=keys.ability
	local caster=keys.caster
	local target=keys.target
	local Caster = keys.caster
	local CasterName = Caster:GetClassname()
	local duration = keys.HeroHiddenDuration + FindTelentValue(caster, "special_bonus_unique_outworld_devourer_2")
	if Yukari_CanMovetoGap(target) then
		keys.ability:ApplyDataDrivenModifier(caster, target, anti_bd_modifier_name, {})
	end
	local stack_num=caster:GetModifierStackCount(Yukari02_MODIFIER_COUNTER_NAME,caster)

	if stack_num >= 9999 then return end

	if Yukari_CanMovetoGap(target) then
		ability:ApplyDataDrivenModifier(caster, target, Yukari02_MODIFIER_HIDDEN_NAME, {})
		if CasterName == "npc_dota_hero_obsidian_destroyer" then
			local AbilityEx=caster:FindAbilityByName("ability_thdots_yukariEx")
			if not AbilityEx then
				AbilityEx=caster:AddAbility("ability_thdots_yukariEx")
			end
			AbilityEx:SetLevel(1)
		end
	else
		ability:ApplyDataDrivenModifier(caster, target, Yukari02_MODIFIER_HIDDEN_NAME, {Duration=duration})
	end
end

function Yukari03_OnSpellStart(keys)
	local ability=keys.ability
	local caster=keys.caster
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_outworld_devourer_3"))
	local target=keys.target_points[1]
	--[[if FindTelentValue(caster,"special_bonus_unique_outworld_devourer")==0 then
		local e1 = ParticleManager:CreateParticle("particles/heroes/yukari/ability_yukari_03_teleport_light.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(e1, 0, caster:GetOrigin())

		local e2 = ParticleManager:CreateParticle("particles/heroes/yukari/ability_yukari_03_teleport_light.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(e2, 0, target)

		caster.Yukari03_effect_1 = e1
		caster.Yukari03_effect_2 = e2]]--
	
	local e1 = ParticleManager:CreateParticle("particles/heroes/yukari/ability_yukari_03_teleport_light.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(e1, 0, caster:GetOrigin())

	local e2 = ParticleManager:CreateParticle("particles/heroes/yukari/ability_yukari_03_teleport_light.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(e2, 0, target)

	caster.Yukari03_effect_1 = e1
	caster.Yukari03_effect_2 = e2
	

end

function Yukari03_OnChannelSucceeded(keys)
	local ability=keys.ability
	local caster=keys.caster
	local target=keys.target_points[1]

	local e1 = ParticleManager:CreateParticle("particles/heroes/yukari/ability_yukari_03_teleportflash.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(e1, 0, caster:GetOrigin())

	FindClearSpaceForUnit(caster,target,true)

	local e2 = ParticleManager:CreateParticle("particles/heroes/yukari/ability_yukari_03_teleportflash2.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(e2, 0, caster:GetOrigin())
	
	caster:EmitSound("Hero_Dark_Seer.Ion_Shield_Start")

	ParticleManager:DestroyParticle(caster.Yukari03_effect_1 or -1,false)
	ParticleManager:DestroyParticle(caster.Yukari03_effect_2 or -1,false)
	
	if caster:HasModifier("modifier_item_wanbaochui") then
		local intdamage=caster:GetIntellect()*4
		local enemies=FindUnitsInRadius(
						caster:GetTeamNumber(),
						caster:GetOrigin(),
						nil,
						375,
						DOTA_UNIT_TARGET_TEAM_ENEMY,
						DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
						DOTA_UNIT_TARGET_FLAG_NONE,
						FIND_ANY_ORDER,
						false)
		for _,v in pairs(enemies) do
			damage_table={
				victim=v, 
				attacker=caster, 
				damage=intdamage,
				damage_type=DAMAGE_TYPE_MAGICAL,
			}
			UnitDamageTarget(damage_table)	
		end
	end
	
end

function Yukari03_OnChannelInterrupted(keys)
	local ability=keys.ability
	local caster=keys.caster
	local target=keys.target

	ability:RefundManaCost()
	ability:EndCooldown()

	ParticleManager:DestroyParticle(caster.Yukari03_effect_1 or -1,false)
	ParticleManager:DestroyParticle(caster.Yukari03_effect_2 or -1,false)
end

function Yukari03_OnIntervalThink(keys)
	local ability=keys.ability
	local caster=keys.caster
	local Ability02=caster:FindAbilityByName("ability_thdots_yukari02")
	local Caster = keys.caster
	local CasterName = Caster:GetClassname()

	if CasterName == "npc_dota_hero_obsidian_destroyer" and caster:IsRealHero() then
		caster.add_unit_to_gap_time=caster.add_unit_to_gap_time or GameRules:GetGameTime()

		if Ability02 and GameRules:GetGameTime()-caster.add_unit_to_gap_time>=(ability:GetCooldown(ability:GetLevel())-caster:GetLevel())*0.7 then
			caster.add_unit_to_gap_time=GameRules:GetGameTime()
			local creep=CreateUnitByName(
				g_creeps_name[RandomInt(1,#g_creeps_name)],
				caster:GetOrigin(),
				false,
				caster,
				caster,
				caster:GetTeam())
			if creep then
				Ability02:ApplyDataDrivenModifier(caster,creep,Yukari02_MODIFIER_HIDDEN_NAME,{})
				Ability02:ApplyDataDrivenModifier(caster,creep,anti_bd_modifier_name,{})
				--creep:AddNewModifier(caster,ability,Yukari02_MODIFIER_HIDDEN_NAME,{})
				creep:SetHealth(creep:GetMaxHealth()*0.20)
			end
		end
	end
end

function Yukari04_OnSpellStart(keys)
	local ability=keys.ability
	local caster=keys.caster
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_outworld_devourer_4"))
	local target=keys.target_points[1]
	local vecPos=nil
	local lvl=ability:GetLevel()

	if lvl==1 then
		local allies = FindUnitsInRadius(
			caster:GetTeamNumber(),
			target,
			nil,
			keys.TargetRange,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_CLOSEST,
			false)
		if #allies>0 then 
			vecPos=allies[1]:GetOrigin()
		end
--[[		for _,u in pairs(allies) do
			print("IsBuilding:"..tostring(u:IsBuilding()))
			if u:GetName()=="npc_dota_tower" then
				vecPos=u:GetOrigin()
				break
			end
		end]]
	elseif lvl==2 then
		local allies = FindUnitsInRadius(
			caster:GetTeamNumber(),
			target,
			nil,
			keys.TargetRange,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
			FIND_CLOSEST,
			false)
		if #allies>0 then 
			vecPos=allies[1]:GetOrigin()
		end
	elseif lvl==3 then
		vecPos=target
	end
	

	if vecPos then
		local tick=0
		local tick_interval=keys.BarrageFireInterval
		local channel_start_time=GameRules:GetGameTime()
		local barrage_radius=keys.BarrageRadius
		local barrage_speed=1000
		local rotate_radian=1.57
		local rotate_speed=-0.08

		local e1 = ParticleManager:CreateParticle("particles/heroes/yukari/ability_yukari_04_magical.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(e1, 0, vecPos)

		local e2 = ParticleManager:CreateParticle("particles/heroes/yukari/ability_yukari_04_magical.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(e2, 0, vecPos)


		caster:EmitSound("Hero_Enigma.BlackHole.Cast.Chasm")
		caster:EmitSound("Hero_Enigma.Black_Hole")

		caster:SetContextThink(
			"yukari04_main_loop",
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				if caster:IsChanneling() then
					for i=1,keys.BarrageSpawnPoint do
						local radius=keys.MinRadius--+(keys.MaxRadius-keys.MinRadius)*(GameRules:GetGameTime()-channel_start_time)/ability:GetChannelTime()
						local radian=math.pi*2*(i/keys.BarrageSpawnPoint)+tick*rotate_speed
						local vecSpawn=caster:GetOrigin()+Vector(
							math.cos(radian)*radius,
							math.sin(radian)*radius,
							0)
						local vecEnd=caster:GetOrigin()+Vector(
							math.cos(radian+rotate_radian)*keys.MaxRadius,
							math.sin(radian+rotate_radian)*keys.MaxRadius,
							0)
						local distance=(vecEnd-vecSpawn):Length2D()
						local velocity=(vecEnd-vecSpawn):Normalized()*barrage_speed

						local projectileTable1 = {
						   	Ability=ability,
							EffectName=keys.EffectName,
							vSpawnOrigin=vecSpawn,
							fDistance=distance,
							fStartRadius=barrage_radius,
							fEndRadius=barrage_radius,
							Source=caster,
							bHasFrontalCone=false,
							bReplaceExisting=false,
							iUnittargetTeam=ability:GetAbilityTargetTeam(),
							iUnitTargetFlags=ability:GetAbilityTargetFlags(),
							iUnittargetType=ability:GetAbilityTargetType(),
							fExpireTime=GameRules:GetGameTime()+ability:GetChannelTime(),
							bDeleteOnHit=false,
							vVelocity=velocity,
							bProvidesVision=false,
						}
						ProjectileManager:CreateLinearProjectile(projectileTable1)

						local vecSpawn2=vecPos+Vector(
							math.cos(radian)*keys.MaxRadius,
							math.sin(radian)*keys.MaxRadius,
							0)
						local vecEnd2=vecPos+Vector(
							math.cos(radian+rotate_radian)*radius,
							math.sin(radian+rotate_radian)*radius,
							0)
						local velocity=(vecEnd2-vecSpawn2):Normalized()*barrage_speed

						local projectileTable2 = {
						   	Ability=ability,
							EffectName=keys.EffectName,
							vSpawnOrigin=vecSpawn2,
							fDistance=distance,
							fStartRadius=barrage_radius,
							fEndRadius=barrage_radius,
							Source=caster,
							bHasFrontalCone=false,
							bReplaceExisting=false,
							iUnittargetTeam=ability:GetAbilityTargetTeam(),
							iUnitTargetFlags=ability:GetAbilityTargetFlags(),
							iUnittargetType=ability:GetAbilityTargetType(),
							fExpireTime=GameRules:GetGameTime()+ability:GetChannelTime(),
							bDeleteOnHit=false,
							vVelocity=velocity,
							bProvidesVision=false,
						}
						ProjectileManager:CreateLinearProjectile(projectileTable2)
						
					end
					tick=tick+1
					return tick_interval
				else
					local Ability02=caster:FindAbilityByName("ability_thdots_yukari02")
					local teleport_radius=keys.MinRadius+(keys.MaxRadius-keys.MinRadius)*(GameRules:GetGameTime()-channel_start_time)/ability:GetChannelTime()
					local units=FindUnitsInRadius(
						caster:GetTeamNumber(),
						caster:GetOrigin(),
						nil,
						teleport_radius,
						DOTA_UNIT_TARGET_TEAM_BOTH,
						DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
						DOTA_UNIT_TARGET_FLAG_NONE,
						FIND_ANY_ORDER,
						false)
					for _,u in pairs(units) do
						if Yukari_CanMovetoGap(u) and u:GetTeam()~=caster:GetTeam() and Ability02 then
							Ability02:ApplyDataDrivenModifier(caster,u,Yukari02_MODIFIER_HIDDEN_NAME,{})
							Ability02:ApplyDataDrivenModifier(caster,creep,anti_bd_modifier_name,{})
							--u:AddNewModifier(caster,ability,Yukari02_MODIFIER_HIDDEN_NAME,{})
						elseif u:IsControllableByAnyPlayer() and u:GetTeam()==caster:GetTeam() then
							local e3 = ParticleManager:CreateParticle("particles/heroes/yukari/ability_yukari_03_teleportflash.vpcf", PATTACH_CUSTOMORIGIN, caster)
							ParticleManager:SetParticleControl(e3, 0, caster:GetOrigin())

							FindClearSpaceForUnit(u,vecPos,true)
							local e4 = ParticleManager:CreateParticle("particles/heroes/yukari/ability_yukari_03_teleportflash2.vpcf", PATTACH_CUSTOMORIGIN, caster)
							ParticleManager:SetParticleControl(e4, 0, caster:GetOrigin())
						end
					end
					caster:StopSound("Hero_Enigma.BlackHole.Cast.Chasm")
					caster:StopSound("Hero_Enigma.Black_Hole")
					caster:EmitSound("Hero_Enigma.Black_Hole.Stop")
					ParticleManager:DestroyParticle(e1,true)
					ParticleManager:DestroyParticle(e2,true)
					if caster:HasModifier("modifier_item_wanbaochui") then
						local intdamage=caster:GetIntellect()*4
						local enemies=FindUnitsInRadius(
										caster:GetTeamNumber(),
										caster:GetOrigin(),
										nil,
										750,
										DOTA_UNIT_TARGET_TEAM_ENEMY,
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
										DOTA_UNIT_TARGET_FLAG_NONE,
										FIND_ANY_ORDER,
										false)
						for _,v in pairs(enemies) do
							damage_table={
								victim=v, 
								attacker=caster, 
								damage=intdamage,
								damage_type=DAMAGE_TYPE_MAGICAL,
							}
							UnitDamageTarget(damage_table)	
						end
					end
					return nil
				end
			end,0)
	else
		caster:SetContextThink(
			"yukari04_end_channel",
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				caster:StopSound("Hero_Enigma.BlackHole.Cast.Chasm")
				caster:StopSound("Hero_Enigma.Black_Hole")
				ability:EndChannel(true)
				ability:RefundManaCost()
				ability:EndCooldown()
				return nil
			end,0)
	end
    local exradius=keys.BarrageRadius
	caster:SetContextThink(
			"yukari04_exdamage",
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				if caster:IsChanneling() and exradius < keys.MaxRadius then 
					local targets = FindUnitsInRadius(
							caster:GetTeam(),		--caster team
							keys.target_points[1],		--find position
							nil,					--find entity
							exradius,		--find radius
							DOTA_UNIT_TARGET_TEAM_ENEMY,
							keys.ability:GetAbilityTargetType(),
							0, 
							FIND_CLOSEST,
							false
						)
						exradius=exradius+25
						for _,v in pairs(targets) do
							local damage_table = {
								ability = keys.ability,
								victim = v,
								attacker = caster,
								damage = keys.Exdamage,
								damage_type = keys.ability:GetAbilityDamageType(), 
								damage_flags = keys.ability:GetAbilityTargetFlags()
							}
							UnitDamageTarget(damage_table)
						end
				else
					return nil
				end		
				return 0.1	
			end,				
	0)

end

function Yukari04_OnProjectileHitUnit(keys)
	local ability=keys.ability
	local caster=keys.caster
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		local damage_table = {
			ability = keys.ability,
			victim = v,
			attacker = caster,
			damage = keys.BarrageDamage,
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = keys.ability:GetAbilityTargetFlags()
		}
		UnitDamageTarget(damage_table)
	end
end


