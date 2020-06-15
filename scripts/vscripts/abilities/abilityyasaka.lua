function YasakaExActivex_OnInterval(keys)
	local Caster=keys.caster
	local Target=keys.target
	local Ability=keys.ability
	if not Target:HasModifier(keys.buff_name) then
		Ability:ApplyDataDrivenModifier(Caster, Target, keys.buff_name, {})
	end
end

function YasakaExBuff_OnInterval(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	local hBuff=Target:FindModifierByNameAndCaster(keys.buff_name,Caster)
	if not hBuff then return end

	local time_now=GameRules:GetGameTime()

	if not hBuff.change_stack_time then hBuff.change_stack_time=time_now end
	local last_change_time=hBuff.change_stack_time

	if Target:HasModifier(keys.activex_name) or Target:HasModifier("modifier_thdots_yasaka04_buff") then
		if hBuff:GetStackCount()==0 or (hBuff:GetStackCount()<keys.max_stack and time_now-last_change_time>=keys.add_interval) then
			hBuff:IncrementStackCount()
			hBuff.change_stack_time=time_now
		end
	else
		if time_now-last_change_time>=keys.sub_interval then
			hBuff:DecrementStackCount()
			hBuff.change_stack_time=time_now
			if hBuff:GetStackCount()<=0 then
				hBuff:Destroy()
			end
		end
	end
end

function Yasaka01_OnSpellStart(keys)	
	local Ability=keys.ability
	local Caster=keys.caster
	

	local TargetPoint=keys.target_points[1]	
	Caster:SetContextThink(
		"yasaka01_main_loop",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			local enemies=FindUnitsInRadius(
						Caster:GetTeamNumber(),
						TargetPoint,
						nil,
						keys.DamageRadius,
						Ability:GetAbilityTargetTeam(),
						Ability:GetAbilityTargetType(),
						Ability:GetAbilityTargetFlags(),
						FIND_ANY_ORDER,
						false)
			for _,v in pairs(enemies) do
				damage_table={
					victim=v, 
					attacker=Caster, 
					damage=Ability:GetAbilityDamage(),
					damage_type=Ability:GetAbilityDamageType(),
				}
				UnitDamageTarget(damage_table)

				UtilStun:UnitStunTarget(Caster,v,keys.StunDuration)
			end
			Caster:EmitSound("Hero_EarthSpirit.BoulderSmash.Target")
			return nil
		end,0.5)	
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/kanako/ability_kanako_041.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, TargetPoint)
	ParticleManager:SetParticleControl(effectIndex, 1, TargetPoint)
	ParticleManager:SetParticleControl(effectIndex, 3, TargetPoint)
	ParticleManager:DestroyParticleSystemTime(effectIndex,1.0)
	Caster:EmitSound("Visage_Familar.StoneForm.Cast")
	GridNav:DestroyTreesAroundPoint(TargetPoint, keys.DamageRadius, true)
end

function Yasaka02_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster

	local radius=keys.radius
	local tick_interval=keys.tick_interval
	local offset=60

	local damage_table={
		victim=nil, 
		attacker=Caster, 
		ability=Ability, 
		damage=Ability:GetAbilityDamage()*tick_interval,
		damage_type=Ability:GetAbilityDamageType(),
	}

	local effectIndex = ParticleManager:CreateParticle("particles/heroes/kanako/ability_kanako_02.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, Caster, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.duration)

	Ability:ApplyDataDrivenModifier(Caster, Caster, keys.icon_name, {duration=keys.duration})
	local inside_enemies=FindUnitsInRadius(
			Caster:GetTeamNumber(),
			Caster:GetOrigin(),
			nil,
			radius,
			Ability:GetAbilityTargetTeam(),
			Ability:GetAbilityTargetType(),
			Ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER,
			false)
	for _,v in pairs(inside_enemies) do
		Ability:ApplyDataDrivenModifier(Caster, v, keys.debuff_name, {duration=keys.duration})
	end

	local OnThinkEnd=function ()
		-- 
	end

	Caster:SetContextThink(
		"yasaka02_main_loop",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if Ability:IsNull() or not Caster:HasModifier(keys.icon_name)  then 
				OnThinkEnd()
				return nil
			end
			local origin=Caster:GetOrigin()

			ProjectileManager:ProjectileDodge(Caster)

			for k,v in pairs(inside_enemies) do
				if not v:HasModifier(keys.debuff_name) or v:IsNull() or not v:IsAlive() then
					inside_enemies[k]=nil
				else
					if not v:IsPositionInRange(origin,radius) and (v:HasModifier("modifier_thdots_yugi04_think_interval") == false) and v:IsHero() and v:IsPositionInRange(origin,1000) then
						local new_pos=origin+(origin-v:GetOrigin()):Normalized()*(radius-offset)
						FindClearSpaceForUnit(v, new_pos, true)
						local effectIndex1 = ParticleManager:CreateParticle("particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_l.vpcf", PATTACH_CUSTOMORIGIN, nil)
						ParticleManager:SetParticleControl(effectIndex1, 0, new_pos)
						ParticleManager:SetParticleControl(effectIndex1, 1, new_pos)
						Caster:EmitSound("Hero_Dark_Seer.Ion_Shield_Start")
					end
				end
			end

			local enemies=FindUnitsInRadius(
				Caster:GetTeamNumber(),
				Caster:GetOrigin(),
				nil,
				radius,
				Ability:GetAbilityTargetTeam(),
				Ability:GetAbilityTargetType(),
				Ability:GetAbilityTargetFlags(),
				FIND_ANY_ORDER,
				false)
			for _,v in pairs(enemies) do
				
				if not v:HasModifier(keys.debuff_name) and (v:HasModifier("modifier_thdots_yugi04_think_interval") == false) and v:IsHero() then
					local new_pos=origin+(origin-v:GetOrigin()):Normalized()*(radius+offset)
					FindClearSpaceForUnit(v, new_pos, true)
					local effectIndex2 = ParticleManager:CreateParticle("particles/econ/events/fall_major_2015/teleport_end_fallmjr_2015_l.vpcf", PATTACH_CUSTOMORIGIN, nil)
					ParticleManager:SetParticleControl(effectIndex2, 0, new_pos)
					ParticleManager:SetParticleControl(effectIndex2, 1, new_pos)
					Caster:EmitSound("Hero_Dark_Seer.Ion_Shield_Start")
				end

				if v:GetTeam() ~= Caster:GetTeam() then
					damage_table.victim=v
					UnitDamageTarget(damage_table)
				end
			end
			return keys.tick_interval
		end,0)
end

function Yasaka03_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	if Caster:HasModifier("modifier_item_wanbaochui") then
		THDReduceCooldown(keys.ability,-6)
	end

	if Target: IsBuilding() then
		if Caster:HasModifier("modifier_item_wanbaochui") and Caster:GetTeam()==Target:GetTeam() then
			Target:Heal(keys.heal_amt, Caster)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,Target,keys.heal_amt,nil)
			Ability:ApplyDataDrivenModifier(Caster, Target, keys.buff_name, {})
		else
			Ability:RefundManaCost()
			Ability:EndCooldown()
			return
		end		
	
	else	
		if Caster:GetTeam()==Target:GetTeam() then
			Target:Heal(keys.heal_amt, Caster)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,Target,keys.heal_amt,nil)
			Ability:ApplyDataDrivenModifier(Caster, Target, keys.buff_name, {})
		else
			if not is_spell_blocked(Target) then
				Ability:ApplyDataDrivenModifier(Caster, Target, keys.debuff_name, {})
				local damage_table = {
				ability = keys.ability,
				victim = Target,
				attacker = Caster,
				damage = keys.ability:GetAbilityDamage(),
				damage_type = keys.ability:GetAbilityDamageType(), 
				damage_flags = keys.ability:GetAbilityTargetFlags()
				}
			UnitDamageTarget(damage_table) 			
			end
		end
	end
end

function ReplaceAbilities(caster,src,dst)
	local abilitySrc=caster:FindAbilityByName(src)
	local abilityDst=caster:FindAbilityByName(dst)
	if abilitySrc and not abilityDst then
		local lvl=abilitySrc:GetLevel()
		caster:RemoveAbility(src)
		caster:AddAbility(dst)
		abilityDst=caster:FindAbilityByName(dst)
		abilityDst:SetLevel(lvl)
	end
end

function Yakasa04_OnSpellStart( keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local AbilityEx=Caster:FindAbilityByName("ability_thdots_yasakaEx")
	if Caster:HasModifier("modifier_thdots_yasaka04_buff") then
		Caster:RemoveModifierByName("modifier_thdots_yasaka04_buff")
		local cd=Ability:GetCooldown(Ability:GetLevel())+FindTelentValue(Caster,"special_bonus_unique_zeus")
		Ability:EndCooldown()
		Ability:StartCooldown(cd)
		print(cd)
		Caster:Stop()
	end
end

function Yakasa04_SwapAbilities(caster,is_ultimate)
	if is_ultimate then
		caster:SetModel("models/thd2/kanako/kanako_mmd_transform.vmdl")
		caster:SetOriginalModel("models/thd2/kanako/kanako_mmd_transform.vmdl")
		ReplaceAbilities(caster,"ability_thdots_yasaka01","ability_thdots_yasaka41")
		ReplaceAbilities(caster,"ability_thdots_yasaka02","ability_thdots_yasaka42")
		ReplaceAbilities(caster,"ability_thdots_yasaka03","ability_thdots_yasaka43")
	else
		caster:RemoveGesture(ACT_DOTA_IDLE)
		caster:SetModel("models/thd2/kanako/kanako_mmd.vmdl")
		caster:SetOriginalModel("models/thd2/kanako/kanako_mmd.vmdl")
		ReplaceAbilities(caster,"ability_thdots_yasaka41","ability_thdots_yasaka01")
		ReplaceAbilities(caster,"ability_thdots_yasaka42","ability_thdots_yasaka02")
		ReplaceAbilities(caster,"ability_thdots_yasaka43","ability_thdots_yasaka03")
	end
end

function Yakasa04_OnChannelSucceeded(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local AbilityEx=Caster:FindAbilityByName("ability_thdots_yasakaEx")

		print(keys.buff_name)
	if not Caster:HasModifier(keys.buff_name) then
		Ability:EndCooldown()
		Ability:ApplyDataDrivenModifier(Caster, Caster, keys.buff_name, {})
		Yakasa04_SwapAbilities(Caster, true)
		if AbilityEx then 
			AbilityEx:SetLevel(2) 
			AbilityEx:ApplyDataDrivenModifier(Caster, Caster, "modifier_thdots_yasakaEx_buff", {})
			local hBuff=Caster:FindModifierByName("modifier_thdots_yasakaEx_buff")
			local exbuff_max_stack=AbilityEx:GetSpecialValueFor("max_stack")
			if hBuff and exbuff_max_stack then
				hBuff:SetStackCount(exbuff_max_stack)
			end
		end

		local OnThinkEnd=function ()
			-- 
		end

		local pos=Caster:GetOrigin()
		Caster:SetContextThink(
			"yasaka04_hold_postion",
			function ()
				if GameRules:IsGamePaused() then return 0.03 end
				if Ability:IsNull() then 
					OnThinkEnd()
					return nil
				end
				if not Caster:HasModifier("modifier_thdots_yasakaEx_buff") then
					AbilityEx:ApplyDataDrivenModifier(Caster, Caster, "modifier_thdots_yasakaEx_buff", {})
				end
				
				if not Caster:IsPositionInRange(pos,1500) then
					pos=Caster:GetOrigin()
				else
					Caster:SetOrigin(pos)
				end

				if not Caster:HasModifier(keys.buff_name) then 
					Yakasa04_SwapAbilities(Caster, false)
					if AbilityEx then AbilityEx:SetLevel(1) end
					OnThinkEnd()
					return nil 
				end
				return 0.03
			end,0)
	else
		Caster:RemoveModifierByName(keys.buff_name)
		local cd=Ability:GetCooldown(Ability:GetLevel())+FindTelentValue(Caster,"special_bonus_unique_zeus")
		Ability:EndCooldown()
		Ability:StartCooldown(cd)
	end
end

function Yakasa04_OnUpgrade(keys)
	local Caster = keys.caster
	local AbilityEx = Caster:FindAbilityByName("ability_thdots_yasakaEx")
	if AbilityEx:GetLevel() == 0 then
		AbilityEx:SetLevel(1)
	end
end

function Yakasa04_OnPhaseStart(keys)
	local Caster=keys.caster
	--Caster:SetModel("models/thd2/kanako/kanako_mmd_transforming.vmdl")
	Caster:SetOriginalModel("models/thd2/kanako/kanako_mmd_transforming.vmdl")

	if not Caster:HasModifier("modifier_thdots_yasaka04_buff") then
		Caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
	else
		Caster:StartGesture(ACT_DOTA_IDLE)
	end
end

function Yakasa04_OnChannelInterrupted(keys)
	local Caster=keys.caster
	if not Caster:HasModifier("modifier_thdots_yasaka04_buff") then
		--Caster:SetModel("models/thd2/kanako/kanako_mmd.vmdl")
		Caster:SetOriginalModel("models/thd2/kanako/kanako_mmd.vmdl")
	else
		--Caster:SetModel("models/thd2/kanako/kanako_mmd_transforming.vmdl")
		Caster:SetOriginalModel("models/thd2/kanako/kanako_mmd_transforming.vmdl")
		keys.ability:EndCooldown()
		print("EndCooldown")
	end
end

function Yakasa04_OnChannelFinish(keys)
	local Caster=keys.caster
end

function Yasaka41_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local tick_interval=keys.tick_interval
	local rate_tick=keys.rate*keys.tick_interval
	local tick=0
	local last_down_tick=0

	damage_table={
		victim=nil, 
		attacker=Caster, 
		damage=Ability:GetAbilityDamage(),
		damage_type=Ability:GetAbilityDamageType(),
	}

	Ability:ApplyDataDrivenModifier(Caster, Caster, keys.icon_name, {})
	local origin=Caster:GetOrigin()

	local OnThinkEnd=function ()
		Caster:RemoveModifierByName(keys.icon_name)
	end

	Caster:SetContextThink(
		"yasaka41_main_loop",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if Ability:IsNull() then 
				OnThinkEnd()
				return nil
			end
			if last_down_tick~=math.floor(tick*rate_tick) then
				last_down_tick=math.floor(tick*rate_tick)
				local rdpos=origin+RandomVector(keys.radius)*RandomFloat(0,1)

				local enemies=FindUnitsInRadius(
					Caster:GetTeamNumber(),
					rdpos,
					nil,
					keys.damage_radius,
					Ability:GetAbilityTargetTeam(),
					Ability:GetAbilityTargetType(),
					Ability:GetAbilityTargetFlags(),
					FIND_ANY_ORDER,
					false)
				for _,v in pairs(enemies) do
					damage_table.victim=v
					UnitDamageTarget(damage_table)

					UtilStun:UnitStunTarget(Caster,v,keys.stun_duration)
				end
				local effectIndex = ParticleManager:CreateParticle("particles/heroes/kanako/ability_kanako_041.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControl(effectIndex, 0, rdpos)
				ParticleManager:SetParticleControl(effectIndex, 1, rdpos)
				ParticleManager:SetParticleControl(effectIndex, 3, rdpos)
				ParticleManager:DestroyParticleSystemTime(effectIndex,1.0)
				Caster:EmitSound("Visage_Familar.StoneForm.Cast")
				GridNav:DestroyTreesAroundPoint(rdpos, keys.damage_radius, true)
			end

			tick=tick+1
			if not Caster:HasModifier(keys.icon_name) then 
				OnThinkEnd()
				return nil 
			end
			return tick_interval
		end,0)
end

function Yasaka41_wanbaochui(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	if Caster:HasModifier("modifier_item_wanbaochui") then
		damage_table={
			victim=nil, 
			attacker=Caster, 
			damage=keys.ability:GetAbilityDamage(),
			damage_type=keys.ability:GetAbilityDamageType(),
		}
		local origin=Caster:GetOrigin()
		local rdpos=origin+RandomVector(keys.radius)*RandomFloat(0,1)

		local enemies=FindUnitsInRadius(
			Caster:GetTeamNumber(),
			rdpos,
			nil,
			keys.damage_radius,
			keys.ability:GetAbilityTargetTeam(),
			keys.ability:GetAbilityTargetType(),
			keys.ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER,
			false)
		for _,v in pairs(enemies) do
			damage_table.victim=v
			UnitDamageTarget(damage_table)
			UtilStun:UnitStunTarget(Caster,v,keys.stun_duration)
		end
		local effectIndex = ParticleManager:CreateParticle("particles/heroes/kanako/ability_kanako_041.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(effectIndex, 0, rdpos)
		ParticleManager:SetParticleControl(effectIndex, 1, rdpos)
		ParticleManager:SetParticleControl(effectIndex, 3, rdpos)
		ParticleManager:DestroyParticleSystemTime(effectIndex,1.0)
		Caster:EmitSound("Visage_Familar.StoneForm.Cast")
		GridNav:DestroyTreesAroundPoint(rdpos, keys.damage_radius, true)
	end
end



function Yasaka42_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local TargetPoint=keys.target_points[1]
	local tick_interval=keys.tick_interval
	local max_tick=keys.duration/tick_interval
	local tick=0

	local OnThinkEnd=function ()
		-- 
	end

	local effectIndex = ParticleManager:CreateParticle("particles/heroes/kanako/ability_kanako_042.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, TargetPoint)
	ParticleManager:SetParticleControl(effectIndex, 7, TargetPoint)
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.duration)

	Caster:SetContextThink(
		"yasaka42_main_loop",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if Ability:IsNull() then 
				OnThinkEnd()
				return nil
			end
			local enemies=FindUnitsInRadius(
				Caster:GetTeamNumber(),
				TargetPoint,
				nil,
				keys.effect_radius,
				Ability:GetAbilityTargetTeam(),
				Ability:GetAbilityTargetType(),
				Ability:GetAbilityTargetFlags(),
				FIND_ANY_ORDER,
				false)
			for _,v in pairs(enemies) do
				Ability:ApplyDataDrivenModifier(Caster, v, keys.debuff_name, {})
			end
			tick=tick+1
			if tick>=max_tick then 
				OnThinkEnd()
				return nil 
			end
			return tick_interval
		end,0)
end

function Yasaka43_OnSpellStart(keys)
	local Ability=keys.ability
	local Caster=keys.caster
	local Target=keys.target
	local tick_interval=keys.tick_interval
	local tick_mana_spend=keys.mana_spend*tick_interval
	

	Target:Purge(false, true, false, true, false)
	Ability:ApplyDataDrivenModifier(Caster, Caster, keys.aura_name, {})
	if Caster:HasModifier("modifier_item_wanbaochui") then
		Ability:ApplyDataDrivenModifier(Caster, Caster, keys.aura_name_2, {})
	end

	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_overgrowth_vine_glow_trail.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(effectIndex, 0, Target:GetOrigin())

	local OnThinkEnd=function ()
		Caster:StopSound("Hero_WitchDoctor.Voodoo_Restoration.Loop")
	end

	Caster:SetContextThink(
		"yasaka43_main_loop",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if Ability:IsNull() then 
				Caster:RemoveModifierByName(keys.aura_name)
				Caster:RemoveModifierByName(keys.aura_name_2)
				OnThinkEnd()
				return nil
			end
			Caster:SpendMana(tick_mana_spend, Ability)
			if Caster:GetMana()<tick_mana_spend then
				Caster:InterruptChannel()
			end
			if not Caster:IsChanneling() then 
				Caster:RemoveModifierByName(keys.aura_name)
				Caster:RemoveModifierByName(keys.aura_name_2)
				OnThinkEnd()
				return nil 
			end
			return tick_interval
		end,0)

end
