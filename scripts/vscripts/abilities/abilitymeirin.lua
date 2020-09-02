
-- MEIRIN04_CONTEXT = 0
-- SATORI_CONTEXT = 0

function OnMeirinexSpellThink(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local modifier = caster:FindModifierByName("modifier_thdots_meirinex_attack")
	local stackcount=keys.stackCount
	if modifier:GetStackCount()<stackcount then
		modifier:IncrementStackCount()
	end
end

function OnMeirinexDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = caster:FindModifierByName("modifier_thdots_meirinex_attack")
	local stackcount=keys.stackCount
	if target:GetTeam() ~= caster:GetTeam() then
		if caster:IsRealHero() and target:IsBuilding()==false and modifier:GetStackCount()>0 and caster:HasModifier("modifier_meirinex") then
			-- local bonusAttack = 0 
			-- local attack = 0
			-- for i=0,5 do
			-- 	item = caster:GetItemInSlot(i)
			-- 	if(item~=nil)then
			-- 		bonusAttack = item:GetSpecialValueFor("bonus_damage")
			-- 		if(bonusAttack~=nil)then
			-- 			attack = bonusAttack + attack
			-- 		end
			-- 	end
			-- end 
			local Damage = caster:GetAverageTrueAttackDamage(caster) * (0.3 + FindTelentValue(caster, "special_bonus_unique_meirin_1"))
			local damage_table = {
				ability = keys.ability,
				victim = target,
				attacker = caster,
				damage = Damage,
				damage_type = DAMAGE_TYPE_PURE, 
				damage_flags = 1
			}
			UnitDamageTarget(damage_table)	
			StartSoundEventFromPosition("Hero_Ancient_Apparition.ChillingTouch.Target", target:GetOrigin())
			UtilStun:UnitStunTarget(caster,target,0.1)
			
			local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_frost_nova_flash_b.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())		
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,target,Damage,nil)
			modifier:DecrementStackCount()
		end
	end 
end 




--[[公主代码博物馆
function OnMeirin01SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = keys.target_points[1]
	FindClearSpaceForUnit(caster,targetPoint,true)
	
	local targets = FindUnitsInRadius(
		caster:GetTeam(),		--caster team
		caster:GetOrigin(),		            --find position
		nil,					    --find entity
		keys.Radius,		        --find radius
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		keys.ability:GetAbilityTargetType(),
		0, FIND_CLOSEST,
		false
	 )

	for _,v in pairs(targets) do
		local damage_table = {
			ability = keys.ability,
			victim = v,
			attacker = caster,
			damage = keys.ability:GetAbilityDamage(),
			damage_type = keys.ability:GetAbilityDamageType(), 
	    	damage_flags = 0
		}
		UnitDamageTarget(damage_table)
	end
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1,0.5)
end]]--

function Skewer(keys)
	local caster = keys.caster
	local ability = keys.ability
	local skewer_speed =  ability:GetLevelSpecialValueFor("skewer_speed", ability:GetLevel() - 1)
	local range = ability:GetLevelSpecialValueFor("range", ability:GetLevel() - 1)
	local point = ability:GetCursorPosition()
	targetPoint = point
	-- Distance and direction variables
	local vector_distance = point - caster:GetAbsOrigin()
	local distance = (vector_distance):Length2D()
	local direction = (vector_distance):Normalized()
	-- If the caster targets over the max range, sets the distance to the max
	if distance > range then
		point = caster:GetAbsOrigin() + range * direction
		distance = range
	end
	
	-- Total distance to travel
	ability.distance = distance
	
	-- Distance traveled per interval
	ability.speed = skewer_speed/30
	
	-- The direction to travel
	ability.direction = direction
	
	-- Distance traveled so far
	ability.traveled_distance = 0
	
	-- Applies the disable modifier
	meirin01time = distance/900
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_skewer_disable_caster", {Duration = meirin01time})
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1,1.5)
end

--[[Author: YOLOSPAGHETTI
	Date: July 15, 2016
	Checks if targets are within range of the skewer]]
function CheckTargets(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	meirin01time = meirin01time -0.01
	local skewer_radius = ability:GetLevelSpecialValueFor("skewer_radius", ability:GetLevel() - 1)
	local hero_offset = ability:GetLevelSpecialValueFor("hero_offset", ability:GetLevel() - 1)

	-- Units to be caught in the skewer
	-- local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, skewer_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
	-- local units = FindUnitsInLine(caster:GetTeamNumber(), caster:GetOrigin(), caster:GetAbsOrigin() + 10*ability.direction, nil, 125 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, false)
	local units = FindUnitsInLine(
	      	caster:GetTeam(),
	      	caster:GetAbsOrigin(),
	      	caster:GetAbsOrigin() + 10 * ability.direction,
	      	nil,
	      	75,
	      	DOTA_UNIT_TARGET_TEAM_ENEMY,
	      	DOTA_UNIT_TARGET_HERO,
	      	0)
	-- Loops through target
	for i,unit in ipairs(units) do
		-- Checks if the target is already affected by skewer
		if unit:HasModifier("modifier_skewer_disable_target") == false then
			-- If not, move it offset in front of the caster
			-- if (unit:GetOrigin() - caster:GetOrigin()):Length2D() < 200 then
			-- 	break 
			-- end
			local new_position = caster:GetAbsOrigin() + hero_offset * ability.direction
			unit:SetAbsOrigin(new_position)
			-- Apply the motion controller to the target
			ability:ApplyDataDrivenModifier(caster, unit, "modifier_skewer_disable_target", {Duration = meirin01time})
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: July 15, 2016
	Applies motion to the target]]
function SkewerMotion(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	-- Move the target while the distance traveled is less than the original distance upon cast
	if target:HasModifier("modifier_ability_thdots_hina04") then --踢转转大招BUG
		target:InterruptMotionControllers(true)
		target:RemoveModifierByName("modifier_skewer_disable_target")
	end
	if not caster:HasModifier("modifier_skewer_disable_caster") then
		target:InterruptMotionControllers(true)
		target:RemoveModifierByName("modifier_skewer_disable_target")
	end
	if ability.traveled_distance < ability.distance then
		target:SetAbsOrigin(target:GetAbsOrigin() + ability.direction * ability.speed)
		-- If the target is the caster, calculate the new travel distance
		if target == caster then
			ability.traveled_distance = ability.traveled_distance + ability.speed
		end
	else
		-- Remove the motion controller once the distance has been traveled
		target:InterruptMotionControllers(true)
		-- Remove the appropriate disable modifier from the target
		if target == caster then
			target:RemoveModifierByName("modifier_skewer_disable_caster")
		else
			target:RemoveModifierByName("modifier_skewer_disable_target")
		end
	end
end







function OnMeirin02Purge(keys)
	local ability = keys.ability
	local caster = keys.caster

	--Purge(bool RemovePositiveBuffs, bool RemoveDebuffs, bool BuffsCreatedThisFrameOnly, bool RemoveStuns, bool RemoveExceptions) 
	caster:Purge(false,true,false,true,false)

end


function OnMeirin02Talent(keys)
	local ability = keys.ability
	local caster = keys.caster

	if FindTelentValue(caster,"special_bonus_unique_dragon_knight_4")==1 then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_meirin02_buff_ex", {})
	end
end


function Meirin03passive(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local helix_modifier = keys.helix_modifier
	local damagetaken = keys.DamageTaken  --所受伤害
	local damageblock = keys.DamageBlock+FindTelentValue(caster,"special_bonus_unique_dragon_knight_2") -- 格挡伤害
	-- print(caster:GetHealth()  +damagetaken)
	-- print(caster:GetHealth() + damageblock)
	-- print(damagetaken)
	-- print(caster:GetHealth() + damagetaken + damageblock < damageblock)
	-- if caster:GetHealth() == 0 and damageblock < damagetaken then
	-- 	return
	-- end
	if damagetaken > damageblock then  
		if caster:GetHealth() == 0 and damagetaken > damageblock then
			return
		else
			caster:SetHealth(caster:GetHealth() + damageblock)
		end
	else
		caster:SetHealth(caster:GetHealth() + damagetaken)					
	end	
	-- If the caster has the helix modifier then do not trigger the counter helix
	-- as its considered to be on cooldown
	if caster:HasModifier(helix_modifier)==false then
		ability:ApplyDataDrivenModifier(caster, caster, helix_modifier, {})
		
	end
end


function Meirin03Damage( keys )
	-- body
	local caster = keys.caster
	local radius = keys.radius
	local damage = keys.damage
	local ability = keys.ability
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0,0, false)
	for _,v in pairs (targets) do
		local damage_table = {
			ability = keys.ability,
			victim = v,
			attacker = caster,
			damage = damage + FindTelentValue(caster, "special_bonus_unique_dragon_knight"), 
			damage_type = keys.ability:GetAbilityDamageType()
			}
		UnitDamageTarget(damage_table)
	end
end
--这一段是公主写的LUA代码，留作纪念
function OnMeirin04SpellStart(keys)
	local caster = keys.caster
	local target = keys.target
	local radius = keys.Radius
	local stunduration = keys.StunDuration
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4,1.5)
	UnitPauseTarget(caster,target,stunduration)
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_fortune_purge_root_pnt.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())		
	
	caster:SetContextThink("ability_thdots_meirin04_attack1", 
		function ()
				local damage_table1 = {
					ability = keys.ability,
					victim = target,
					attacker = caster,
					damage = keys.ability:GetAbilityDamage(),
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
				UnitDamageTarget(damage_table1)
				local effectIndex1 = ParticleManager:CreateParticle("particles/econ/items/disruptor/disruptor_ti8_immortal_weapon/disruptor_ti8_immortal_thunder_strike_aoe.vpcf", PATTACH_CUSTOMORIGIN,target)
				ParticleManager:SetParticleControl(effectIndex1, 0, target:GetOrigin())		
				ParticleManager:DestroyParticleSystem(effectIndex1,false)
				StartSoundEventFromPosition("Hero_Sven.StormBoltImpact", target:GetOrigin())
				StartSoundEventFromPosition("Hero_Sven.StormBoltImpact", caster:GetOrigin())
		end
	,0.75) 
	
	caster:SetContextThink("ability_thdots_meirin04_attack2", 
		function ()
			local damage_table2 = {
				ability = keys.ability,
				victim = target,
				attacker = caster,
				damage = keys.ability:GetAbilityDamage()*1.2,
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = 0
			}
			UnitDamageTarget(damage_table2)
			keys.ability:ApplyDataDrivenModifier(caster,target, "modifier_thdots_meirin04_slow", {})
			ParticleManager:DestroyParticleSystem(effectIndex,true)
			local effectIndex2 = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_death_v2_core.vpcf", PATTACH_CUSTOMORIGIN,target)
			ParticleManager:SetParticleControl(effectIndex2, 0, target:GetOrigin())		
			ParticleManager:DestroyParticleSystem(effectIndex2,false)
			
			StartSoundEventFromPosition("Hero_Sven.StormBoltImpact", target:GetOrigin())
			StartSoundEventFromPosition("Hero_Sven.StormBoltImpact", caster:GetOrigin())
		end
	,1.5) 
	caster:SetContextThink("ability_thdots_meirin04_attack3", 
		function ()
			StartSoundEventFromPosition("Hero_Sven.StormBoltImpact", caster:GetOrigin())
			local effectIndex3 = ParticleManager:CreateParticle("particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_ti8_immortal_pitofmalice_dome.vpcf", PATTACH_CUSTOMORIGIN,caster)
			ParticleManager:SetParticleControl(effectIndex3, 0, caster:GetOrigin())		
			ParticleManager:DestroyParticleSystem(effectIndex3,false)
			local effectIndex4 = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2_shockwave.vpcf", PATTACH_CUSTOMORIGIN,caster)
			ParticleManager:SetParticleControl(effectIndex4, 0, caster:GetOrigin())		
			ParticleManager:DestroyParticleSystem(effectIndex4,false)
			local targets3 = FindUnitsInRadius(
			caster:GetTeam(),		--caster team
			caster:GetOrigin(),		            --find position
			nil,					    --find entity
			radius,		        --find radius
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			keys.ability:GetAbilityTargetType(),
			0, FIND_CLOSEST,
			false
			)
			for _,p in pairs(targets3) do
				local damage_table3 = {
					ability = keys.ability,
					victim = p,
					attacker = caster,
					damage = keys.ability:GetAbilityDamage()*1.5,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = 0
				}
				UnitDamageTarget(damage_table3)
				
				
				StartSoundEventFromPosition("Hero_Sven.StormBoltImpact", p:GetOrigin())
				keys.ability:ApplyDataDrivenModifier(caster,p, "modifier_thdots_meirin04_knockback", {})
			end
		end
	,2.25) 
end
----------------------------
function OnMeirin04Point( keys )
	-- body
	MEIRIN04_POINT = keys.target_points[1]
end

function OnMeirin04( keys )
	-- body
	local caster = keys.caster
	local vec = caster:GetForwardVector()
	local range = 150
	local ability = keys.ability
	local targetPoint = ability:GetCursorPosition()
	local radius = keys.radiu
	local targets = nil
	local stunduration = 1.7
	local time01 = 1.15
	local time02 = 2.52
	local time03 = 4.03
	local vector_distance = MEIRIN04_POINT - caster:GetAbsOrigin()
	if(ability:GetContext("ability_Meirin04_Count") == nil)then
	    ability:SetContextNum("ability_Meirin04_Count",0,0)
	end
	count = ability:GetContext("ability_Meirin04_Count")

	if count == 0 then
		distance = (vector_distance):Length2D()
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4,0.9)
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", PATTACH_POINT,caster)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		local effectIndex = ParticleManager:CreateParticle("particles/econ/items/sven/sven_warcry_ti5/sven_spell_warcry_ti_5.vpcf", PATTACH_POINT,caster)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
	end
	count = count + 0.01
	ability:SetContextNum("ability_Meirin04_Count",count,0)
	-- MEIRIN04_CONTEXT = MEIRIN04_CONTEXT + 0.01	
	if math.abs(count - time01) < 0.001 then
		targets = FindUnitsInRadius(caster:GetTeam(), 
							caster:GetOrigin() , 
							nil, 
							radius, 
							ability:GetAbilityTargetTeam(), 
							ability:GetAbilityTargetType(), 
							0, 
							0, 
							false)
		for _,v in pairs (targets) do
			if not v:IsBuilding() then
				local damage_table = {
					ability = keys.ability,
					victim = v,
					attacker = caster,
					damage = keys.damage01, 
					damage_type = keys.ability:GetAbilityDamageType()
					}
					UnitDamageTarget(damage_table)
					keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_ability_thdots_meirin04_attack01", {Duration = keys.slow_duration})
			end
		end
		local effectIndex1 = ParticleManager:CreateParticle("particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_ti7.vpcf", PATTACH_POINT,caster)
		ParticleManager:DestroyParticleSystem(effectIndex1,false)
		effectIndex1 = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2.vpcf", PATTACH_POINT,caster)
		ParticleManager:DestroyParticleSystem(effectIndex1,false)
		StartSoundEventFromPosition("Hero_ElderTitan.EchoStomp", caster:GetOrigin())
		StartSoundEventFromPosition("Hero_ElderTitan.EchoStomp", caster:GetOrigin())
		StartSoundEventFromPosition("Hero_ElderTitan.EchoStomp", caster:GetOrigin())
	end
	if math.abs(count - time02) < 0.001 then
		targets = FindUnitsInRadius(caster:GetTeam(), 
						caster:GetOrigin() , 
						nil, 
						radius, 
						ability:GetAbilityTargetTeam(), 
						ability:GetAbilityTargetType(), 
						0, 
						0, 
						false)
		for _,v in pairs (targets) do
			if not v:IsBuilding() then
				local damage_table = {
					ability = keys.ability,
					victim = v,
					attacker = caster,
					damage = keys.damage02,
					damage_type = keys.ability:GetAbilityDamageType()
					}
				UnitDamageTarget(damage_table)
				keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_ability_thdots_meirin04_attack02", {Duration = keys.root_duration})
			end
		end

		local effectIndex2 = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2.vpcf", PATTACH_POINT,caster)
		ParticleManager:DestroyParticleSystem(effectIndex2,false)
		StartSoundEventFromPosition("Hero_Sven.StormBoltImpact", caster:GetOrigin())
	end
	if count >= (time02 + 0.5) and count <= time03 then
		caster:SetOrigin(caster:GetAbsOrigin() + 2*vec * (distance/(time03 - time02 +0.5)/100))
	end
	if math.abs(count - time03) < 0.001 then
		targets = FindUnitsInRadius(caster:GetTeam(), 
			caster:GetAbsOrigin() , 
			nil, 
			radius + 500, 
			ability:GetAbilityTargetTeam(), 
			ability:GetAbilityTargetType(), 
			0, 
			0, 
			false)
		for _,v in pairs (targets) do
			if not v:IsBuilding() then
				local damage_table = {
					ability = keys.ability,
					victim = v,
					attacker = caster,
					damage = keys.damage03,
					damage_type = keys.ability:GetAbilityDamageType()
					}
				UnitDamageTarget(damage_table)
				keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_ability_thdots_meirin04_attack03", {Duration = keys.stun_duration})
			end
		end
		local effectIndex3 = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_debut_ground.vpcf", PATTACH_POINT,caster)
		ParticleManager:DestroyParticleSystem(effectIndex3,false)
		effectIndex3 = ParticleManager:CreateParticle("particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_ti7.vpcf", PATTACH_POINT,caster)
		ParticleManager:DestroyParticleSystem(effectIndex3,false)
		effectIndex3 = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2.vpcf", PATTACH_POINT,caster)
		ParticleManager:DestroyParticleSystem(effectIndex3,false)
		StartSoundEventFromPosition("Hero_Sven.StormBoltImpact", caster:GetOrigin())
		StartSoundEventFromPosition("Hero_Sven.StormBoltImpact", caster:GetOrigin())
	end
end

function OnMeirin04Destroy ( keys )
	-- body
	local caster = keys.caster
	FindClearSpaceForUnit(caster,caster:GetAbsOrigin()+1,true)
	-- MEIRIN04_CONTEXT = 0
	count = 0
	keys.ability:SetContextNum("ability_Meirin04_Count",count,0)

end