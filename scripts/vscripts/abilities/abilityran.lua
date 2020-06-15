g_ran01_players_flag={}

function Ran01_OnSpellStart(keys)
	local ability=keys.ability
	local caster=keys.caster
	local target=keys.target_points[1]
	local playerid=caster:GetPlayerOwnerID()


	local flag_unit=nil
	if g_ran01_players_flag[playerid] and IsValidEntity(g_ran01_players_flag[playerid]) then
		if (g_ran01_players_flag[playerid]:GetOrigin()-target):Length2D()<=keys.BlinkSelectRange then
			flag_unit=g_ran01_players_flag[playerid]
		else
			g_ran01_players_flag[playerid]:Destroy()
			g_ran01_players_flag[playerid]=nil
		end
	end

	if flag_unit then
		-- blink
		caster:EmitSound("Hero_VengefulSpirit.NetherSwap")
		local pos=flag_unit:GetOrigin()
		flag_unit:SetOrigin(caster:GetOrigin())
		FindClearSpaceForUnit(caster,pos,true)
	else
		caster:EmitSound("Hero_Techies.Sign")
		-- create flag unit
		flag_unit=CreateUnitByName(
			keys.FlagUnitName,
			target,
			true,
			caster,
			caster,
			caster:GetTeam())

		g_ran01_players_flag[playerid]=flag_unit

		ability:ApplyDataDrivenModifier(caster,flag_unit,keys.AuraBuffName,{})
		ability:ApplyDataDrivenModifier(caster,flag_unit,keys.AuraDebuffName,{})
		ability:EndCooldown()
	end
end

function Ran03_OnSpellStart(keys)
	if is_spell_blocked(keys.target) then return end
	local ability=keys.ability
	local caster=keys.caster
	local target=keys.target
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_puck_2"))

	local effectIndex = ParticleManager:CreateParticle("particles/heroes/ran/ability_ran_03_laser.vpcf", PATTACH_CUSTOMORIGIN, caster)

	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 1, target, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 9, caster, 5, "attach_hitloc", Vector(0,0,0), true)

	local damage_table={
			victim=target, 
			attacker=caster, 
			ability=ability,
			damage=ability:GetAbilityDamage(),
			damage_type=ability:GetAbilityDamageType(),
		}
	UnitDamageTarget(damage_table)
	if caster:HasModifier("modifier_item_wanbaochui") and target:IsHero() then
		local deal_mana_damage=target:GetIntellect()*2
		target:ReduceMana(deal_mana_damage)
	end


	local target_unit=target
	local jump_count=1
	local telentjumpCount = FindTelentValue(caster,"special_bonus_unique_puck")
	local jumpAmount = 1
	local jumpex = 0
	if caster:HasModifier("modifier_item_wanbaochui")  then
		jumpex = 2
		caster:ReduceMana(ability:GetManaCost(ability:GetLevel()))
	end
	
	if telentjumpCount > 0 then
		jumpAmount = (keys.JumpCount+jumpex) * telentjumpCount
	else
		jumpAmount = keys.JumpCount+jumpex
	end
	if jumpAmount>1 then
		caster:SetContextThink(
			"ran03_lazer_jumping",
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				local enemies = FindUnitsInRadius(
					caster:GetTeamNumber(),
					target_unit:GetOrigin(),
					nil,
					keys.JumpRadius,
					ability:GetAbilityTargetTeam(),
					ability:GetAbilityTargetType(),
					ability:GetAbilityTargetFlags(),
					FIND_ANY_ORDER,--[[FIND_CLOSEST,]]
					false)
				local next_target=nil
				for _,v in pairs(enemies) do
					if v:IsAlive() then
						if v~=target_unit then
							next_target=v
							break
						end
					end
				end
				if next_target then
					target_unit:EmitSound("Hero_Tinker.Laser")
					effectIndex = ParticleManager:CreateParticle("particles/heroes/ran/ability_ran_03_laser.vpcf", PATTACH_CUSTOMORIGIN, caster)

					ParticleManager:SetParticleControlEnt(effectIndex , 0, target_unit, 5, "attach_hitloc", Vector(0,0,0), true)
					ParticleManager:SetParticleControlEnt(effectIndex , 1, next_target, 5, "attach_hitloc", Vector(0,0,0), true)
					ParticleManager:SetParticleControlEnt(effectIndex , 9, target_unit, 5, "attach_hitloc", Vector(0,0,0), true)

					target_unit=next_target
					damage_table.victim=target_unit
					UnitDamageTarget(damage_table)
					if caster:HasModifier("modifier_item_wanbaochui") and target_unit:IsHero() then
						local deal_mana_damage=target_unit:GetIntellect()*2
						target_unit:ReduceMana(deal_mana_damage)
					end
					next_target:EmitSound("Hero_Tinker.LaserImpact")
				end

				if #enemies == 1 then return end
				jump_count=jump_count+1
				if jump_count>=jumpAmount or target_unit==nil then return nil end
				return keys.JumpInterval
			end,keys.JumpInterval)
	end
end
