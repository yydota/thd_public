function IsCreep(unit)
	if unit==nil or unit:IsNull() then
		return false
	end
	if unit:GetClassname() == "npc_dota_creep_lane" then 
		return true 
	end
	if unit:GetClassname() == "npc_dota_creep_siege" then 
		return true 
	end
	return false
end

function OnCheckNearby(keys)
	local caster=keys.caster
	local radius = keys.Radius
	if caster:GetClassname()=="npc_dota_fort" then
		radius = 1060
	end
	local units = FindUnitsInRadius(
				   caster:GetTeam(),						--caster team
				   caster:GetOrigin(),							--find position
				   nil,										--find entity
				   radius,						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   keys.ability:GetAbilityTargetType(),
				   0, FIND_CLOSEST,
				   false
			    )
	for _,v in pairs(units) do
		if IsCreep(v) and v:HasModifier("modifier_thdots_unit_anti_bd")==false then 
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_anti_bd_stop", {})
			break
		elseif caster:HasModifier("modifier_thdots_anti_bd_stop") and v:IsRealHero() then 
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_anti_bd_stop", {})
			break
		end
	end
end

function OnTowerAttacked(keys)
	local caster = keys.caster
	local Attacker = keys.attacker
	if (Attacker:GetTeam() == caster:GetTeam()) then 
		return
	elseif caster:HasModifier("modifier_thdots_anti_bd_stop") == false then
		caster:SetHealth(caster:GetHealth()+keys.DamageTaken+1)	
	end
end