

function OnLilyInnateToggleon(keys)
	
	
	local caster = keys.caster
	local model = keys.model	
	local ability = keys.ability
	
	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end	
	keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))	
	caster:SetOriginalModel(model)	
	
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lily_black", {})	
	


end


function OnLilyInnateToggleoff(keys)
	local caster = keys.caster
	

	local ability = keys.ability
	local model2 = keys.model2
	--ability:start
	keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))
	caster:SetOriginalModel(caster.caster_model)
	caster:RemoveModifierByName("modifier_lily_black")
	
end


function LilyInnatetogglecheck (keys)

	local caster = keys.caster
	local ability = keys.ability
	--local lilycd = ability:GetCooldownTimeRemaining()	
	
	if ability:IsCooldownReady() == false then
	
		ability:SetActivated(false)
		else
		ability:SetActivated(true)
	end




end

function LilyInnatetogglecheck2 (keys)

	local caster = keys.caster
	local ability = keys.ability
	local lilycd = ability:GetCooldownTimeRemaining()	
	
	if lilycd > 0 then
	
		ability:SetActivated(false)
		else
		ability:SetActivated(true)
	end




end




function lily01costcheck (keys)
	local caster = keys.caster
	local spellcost = keys.spellcost
	
	local ability = keys.ability
	
	if caster:HasModifier("modifier_lily_black") == false then
		if caster:GetMana() < spellcost then
			ability:SetActivated(false)
		else
			ability:SetActivated(true)
		end
		
	end	

	if caster:HasModifier("modifier_lily_black") == true then
		if caster:GetHealth() < spellcost then
			ability:SetActivated(false)
		else
			ability:SetActivated(true)
		end
		
	end	

end


function OnLily01SpellStart (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local spellcost = keys.spellcost
	
	if caster:HasModifier("modifier_lily_black") == false then
--	caster:SpendMana(spellcost,ability)
	caster:ReduceMana(spellcost)
	target:EmitSound("lily01healcast")	
	
	if 	target:GetTeam() ~= caster:GetTeam()  then
	
		if is_spell_blocked(target) then return end
	
	
	end
	ability:ApplyDataDrivenModifier(caster, target, "modifier_lily01buff", {})		

		
	end		
	
	if caster:HasModifier("modifier_lily_black") == true then
		
	target:EmitSound("lily01cursecast")	
		local damage_table = {
				ability = keys.ability,
			    victim = caster,
			    attacker = caster,
			    damage = spellcost,
			    damage_type = DAMAGE_TYPE_PURE, 
	    	    damage_flags = 0
		}	
		UnitDamageTarget(damage_table)		
		
	if 	target:GetTeam() ~= caster:GetTeam()  then
	
		if is_spell_blocked(target) then return end
	
	
	end
	ability:ApplyDataDrivenModifier(caster, target, "modifier_lily01debuff", {})	
		
	end	



end


function lily01buffhealing(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local baseheal = keys.effective
	local statscale = keys.scale * caster:GetIntellect()
	local healingdone = statscale+baseheal

--	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,target,healingdone,nil)	
	target:EmitSound("lily01heal")	
	
--	target:Heal(healingdone,caster)	
	THDHealTargetLily(caster,target,healingdone)


end


function lily01debuffdamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local basedmg = keys.effective
	local statscale = keys.scale * caster:GetIntellect()
	local dmgdone = statscale + basedmg
	target:EmitSound("lily01damage")	
		local damage_table = {
				ability = keys.ability,
			    victim = target,
			    attacker = caster,
			    damage = dmgdone,
			    damage_type = ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}	
		
	--	SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, target, dmgdone, nil)
		THDDealdamageMsgPoison(damage_table)
	--	UnitDamageTarget(damage_table)



end



function lily02costcheck (keys)
	local caster = keys.caster
	local spellcost = keys.spellcost
	
	local ability = keys.ability
	
	if caster:HasModifier("modifier_lily_black") == false then
		if caster:GetMana() < spellcost then
			ability:SetActivated(false)
		else
			ability:SetActivated(true)
		end
		
	end	

	if caster:HasModifier("modifier_lily_black") == true then
		if caster:GetHealth() < spellcost then
			ability:SetActivated(false)
		else
			ability:SetActivated(true)
		end
		
	end	

end



function OnLily02SpellStart (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local spellcost = keys.spellcost
	local maxheal = target:GetMaxHealth()
	
	
	
	
	if caster:HasModifier("modifier_lily_black") == false then
	
	--	caster:SpendMana(spellcost,ability)
		caster:ReduceMana(spellcost)		
--		SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,target,maxheal,nil)	
--		target:Heal(maxheal,caster)
	
		THDHealTargetLily(caster,target,maxheal)
	
		ability:ApplyDataDrivenModifier(caster, target, "modifier_lily02buff", {})		

		
	end		
	
	if caster:HasModifier("modifier_lily_black") == true then
	
		local enemies = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	
		for _,v in pairs(enemies) do	
			ability:ApplyDataDrivenModifier(caster, v, "modifier_lily02debuff_penalty", {})
		end
	
		if target:GetUnitName() == "ability_minamitsu_04_ship" or target:GetUnitName() == "ability_margatroid03_doll" or target:GetUnitName() == "npc_dota_mutation_pocket_roshan" or target:GetUnitName() == "npc_dota_roshan" then
			return
		end	
--		if target:GetClassname() ~= "npc_dota_roshan" then
		target:Kill(caster, caster)
--		end	
		
	
		local damage_table = {
				ability = keys.ability,
			    victim = caster,
			    attacker = caster,
			    damage = spellcost,
			    damage_type = DAMAGE_TYPE_PURE, 
	    	    damage_flags = 0
		}	
		UnitDamageTarget(damage_table)	
		
		
		

		
	end	



end





function lily03costcheck (keys)
	local caster = keys.caster
	local spellcost = keys.spellcost
	
	if caster:GetName() ~= "npc_dota_hero_leshrac" then return end
	local ability = keys.ability
	if caster:HasModifier("modifier_lily_black") == false then
		if caster:GetMana() < spellcost then
			ability:SetActivated(false)
		else
			ability:SetActivated(true)
		end
		
	end	

	if caster:HasModifier("modifier_lily_black") == true then
		if caster:GetHealth() < spellcost then
			ability:SetActivated(false)
		else
			ability:SetActivated(true)
		end
		
	end	

end


function OnLily03SpellStart(keys)

	local caster = keys.caster
	local ability = keys.ability
	local spellcost = keys.spellcost
	local targetpoint = keys.target_points[1]
	local lilyblack03modifierduration = FindValueTHD("duration",ability)	
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_lily03_caster_check", {duration = lilyblack03modifierduration})

	if caster:HasModifier("modifier_lily_black") == false then
	--	caster:SpendMana(spellcost,ability)
		caster:ReduceMana(spellcost)	
		ability:ApplyDataDrivenThinker(caster, targetpoint, "modifier_lily_white03_area", {})		

		
	end		
	
	if caster:HasModifier("modifier_lily_black") == true then
		ability:ApplyDataDrivenThinker(caster, targetpoint, "modifier_lily_black03_area", {})		
	
		local damage_table = {
				ability = keys.ability,
			    victim = caster,
			    attacker = caster,
			    damage = spellcost,
			    damage_type = DAMAGE_TYPE_PURE, 
	    	    damage_flags = 0
		}	
		UnitDamageTarget(damage_table)	

		
	end	



end



function lilywhite03bufftick (keys)

	local ability = keys.ability

	local caster = keys.caster
	local target = keys.target
	local baseheal = keys.effective
	local statscale = keys.scale * caster:GetIntellect()
	local healingdone = statscale+baseheal 
--	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,target,healingdone,nil)	
	target:EmitSound("lily03heal")	
--	target:Heal(healingdone,caster)	

	THDHealTargetLily(caster,target,healingdone)	
	if target:HasModifier("modifier_lily_white03_immunity_check") == true then
	
		local stackcount = target:GetModifierStackCount("modifier_lily_white03_immunity_check", caster)
	
		target:SetModifierStackCount("modifier_lily_white03_immunity_check", ability, stackcount+1)
	
	
	
	end	
	
	if target:HasModifier("modifier_lily_white03_immunity_check") == false then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_lily_white03_immunity_check", {})	
		target:SetModifierStackCount("modifier_lily_white03_immunity_check", ability, 1)	
	
	end
	
	if target:HasModifier("modifier_lily_white03_immunity_check") == true and target:GetModifierStackCount("modifier_lily_white03_immunity_check", caster) >= 3 then	
	

		

		if caster:HasModifier("modifier_lily03_caster_check") then	
			local immuneduration = FindValueTHD("immune_duration",ability)
		
			local lily03remainingtime = caster:FindModifierByName("modifier_lily03_caster_check"):GetRemainingTime()
		
			local totalduration = immuneduration + lily03remainingtime
		
			ability:ApplyDataDrivenModifier(caster, target, "modifier_lily_white03_immunity", {duration = totalduration})
			print(totalduration)
		
		else
			local immuneduration = FindValueTHD("immune_duration",ability)				
			ability:ApplyDataDrivenModifier(caster, target, "modifier_lily_white03_immunity", {duration = immuneduration})			
			print(immuneduration)		
		end			
		target:RemoveModifierByName("modifier_lily_white03_immunity_check")			
		

	end

end




function lilyblack03debufftick (keys)

	local ability = keys.ability

	local caster = keys.caster
	local target = keys.target
	local basedamage = keys.effective
	local statscale = keys.scale * caster:GetIntellect()
	local dmgdone = statscale+basedamage
	
	

	
	
	
	if target:HasModifier("modifier_lily_black03_stun_check") == true then
	
		local stackcount = target:GetModifierStackCount("modifier_lily_black03_stun_check", caster)
	
		target:SetModifierStackCount("modifier_lily_black03_stun_check", ability, stackcount+1)
	
	
	
	end	
	
	if target:HasModifier("modifier_lily_black03_stun_check") == false then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_lily_black03_stun_check", {})		
		target:SetModifierStackCount("modifier_lily_black03_stun_check", ability, 1)	
	end
	
	if target:HasModifier("modifier_lily_black03_stun_check") == true and target:GetModifierStackCount("modifier_lily_black03_stun_check", caster) >= 3 then	
		if caster:HasModifier("modifier_lily03_caster_check") then	
			local stunduration = FindValueTHD("immune_duration",ability)
		
			local lily03remainingtime = caster:FindModifierByName("modifier_lily03_caster_check"):GetRemainingTime()
		
			local totalduration = stunduration + lily03remainingtime
		
			ability:ApplyDataDrivenModifier(caster, target, "modifier_lily_black03_stun", {duration = totalduration})
		
		else
			local stunduration = FindValueTHD("immune_duration",ability)				
			ability:ApplyDataDrivenModifier(caster, target, "modifier_lily_black03_stun", {duration = stunduration})		
		
		end	
		target:RemoveModifierByName("modifier_lily_black03_stun_check")

	end
	target:EmitSound("lily03damage")
	--SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, target, dmgdone, nil)	
	
		local damage_table = {
				ability = keys.ability,
			    victim = target,
			    attacker = caster,
			    damage = dmgdone,
			    damage_type = DAMAGE_TYPE_MAGICAL, 
	    	    damage_flags = 0
		}
		THDDealdamageMsgPoison(damage_table)		
	--	UnitDamageTarget(damage_table)	
end



function lily04costcheck (keys)
	local caster = keys.caster
	local spellcost = keys.spellcost
	
	if caster:GetName() ~= "npc_dota_hero_leshrac" then return end
	local ability = keys.ability
	if caster:HasModifier("modifier_lily_black") == false then
		if caster:GetMana() < spellcost then
			ability:SetActivated(false)
		else
			ability:SetActivated(true)
		end
		
	end	

	if caster:HasModifier("modifier_lily_black") == true then
		if caster:GetHealth() < spellcost then
			ability:SetActivated(false)
		else
			ability:SetActivated(true)
		end
		
	end	

end



function OnLily04SpellStart(keys)

	local caster = keys.caster
	local ability = keys.ability
	local spellcost = keys.spellcost
	local targetpoint = keys.target_points[1]
	local Radius = keys.Radius
	local Duration = keys.Duration
	
	THDReduceCooldown(ability,FindTelentValue(caster,"special_bonus_unique_lily_2"))	
	
	

	if caster:HasModifier("modifier_lily_black") == false then
		--caster:SpendMana(spellcost,ability)	
		caster:ReduceMana(spellcost)		
		ability:ApplyDataDrivenThinker(caster, targetpoint, "modifier_lily_white04_area", {})		

		
	end		
	
	if caster:HasModifier("modifier_lily_black") == true then
	
		ability:ApplyDataDrivenThinker(caster, targetpoint, "modifier_lily_black04_area", {})	
	
		local damage_table = {
				ability = keys.ability,
			    victim = caster,
			    attacker = caster,
			    damage = spellcost,
			    damage_type = DAMAGE_TYPE_PURE, 
	    	    damage_flags = 0
		}	
		UnitDamageTarget(damage_table)	

		
	end	
	
	local dummy = CreateUnitByName(
		"npc_dummy_unit"
		,caster:GetCursorPosition()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)	
	dummy:AddAbility("night_stalker_darkness") 
	local selfAuraBorderFx = ParticleManager:CreateParticleForTeam("particles/heroes/lily/04ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy, 2)
    ParticleManager:SetParticleControl(selfAuraBorderFx, 0, Vector(Radius,0,0))
    ParticleManager:SetParticleControl(selfAuraBorderFx, 1, Vector(Radius,0,0))
	
	local selfAuraBorderFx2 = ParticleManager:CreateParticleForTeam("particles/heroes/lily/04ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy, 3)
    ParticleManager:SetParticleControl(selfAuraBorderFx2, 0, Vector(Radius,0,0))
    ParticleManager:SetParticleControl(selfAuraBorderFx2, 1, Vector(Radius,0,0))		
		
	caster:SetContextThink("dummy_remove", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			dummy:RemoveSelf()
		end
		,Duration)
		
		

end


function lilywhite04bufftick (keys)

	local ability = keys.ability

	local caster = keys.caster
	local target = keys.target
	local baseheal = keys.effective
	local statscale = keys.scale * caster:GetIntellect()
	local healingdone = statscale+baseheal 
	
--	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,target,healingdone,nil)	
	
--	target:Heal(healingdone,caster)	

	THDHealTargetLily(caster,target,healingdone)
	


end

function lilyblack04debufftick (keys)

	local ability = keys.ability

	local caster = keys.caster
	local target = keys.target
	local basedamage = keys.effective
	local statscale = keys.scale * caster:GetIntellect()
	local dmgdone = statscale+basedamage


	--SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, target, dmgdone, nil)	
	
		local damage_table = {
				ability = keys.ability,
			    victim = target,
			    attacker = caster,
			    damage = dmgdone,
			    damage_type = DAMAGE_TYPE_MAGICAL, 
	    	    damage_flags = 0
		}
		THDDealdamageMsgPoison(damage_table)		
	--	UnitDamageTarget(damage_table)	
end

function lilywhite04startsound (keys)
	local target = keys.target
	
	target:EmitSound("lily04heal")	


end


function lilywhite04stopsound (keys)
	local target = keys.target
	
	target:StopSound("lily04heal")	


end


function lilyblack04startsound (keys)
	local target = keys.target
	
	target:EmitSound("lily04damage")	


end


function lilyblack04stopsound (keys)
	local target = keys.target
	
	target:StopSound("lily04damage")	


end


ability_thdots_lily01_lua  = class({})


function ability_thdots_lily01_lua:CastFilterResultTarget( hTarget )
	if IsServer() then
		local caster = self:GetCaster()
		if hTarget:IsBuilding() then
			return UF_FAIL_OTHER
		end
		
		if caster:HasModifier("modifier_lily_black") then
			
			if caster:GetTeam() == hTarget:GetTeam() then
				if hTarget ~= caster then
					if hTarget:GetHealthPercent() > 30 then
						return UF_FAIL_FRIENDLY
					end
				end
			end
			
			
		else
			if caster:GetTeam() ~= hTarget:GetTeam() then
				
				return UF_FAIL_ENEMY
				
			end
		end
		

		return UF_SUCCESS
	end

--	return UnitFilter(hTarget, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), self:GetCaster():GetTeamNumber() )
end

LinkLuaModifier( "modifier_ability_thdots_lily01_lua_buff","scripts/vscripts/abilities/abilitylily.lua", LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_ability_thdots_lily01_lua_debuff","scripts/vscripts/abilities/abilitylily.lua", LUA_MODIFIER_MOTION_NONE )

function ability_thdots_lily01_lua:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local spell_cost = self:GetSpecialValueFor("spell_cost")
		local ability = self
		local spell_duration = self:GetSpecialValueFor("duration")
		if is_spell_blocked(target,caster) then return end
		if caster:HasModifier("modifier_lily_black") ~= true then
			target:EmitSound("lily01healcast")
			caster:ReduceMana(spell_cost)
			target:AddNewModifier(caster,self, "modifier_ability_thdots_lily01_lua_buff",  {duration = spell_duration} )
		end
		
		if caster:HasModifier("modifier_lily_black") then
			caster:ModifyHealth(caster:GetHealth()-spell_cost,self,false,0)
			target:EmitSound("lily01cursecast")
			target:AddNewModifier(caster,self, "modifier_ability_thdots_lily01_lua_debuff",  {duration = spell_duration} )
		end
	end
end

function ability_thdots_lily01_lua:GetIntrinsicModifierName()
	return "modifier_ability_thdots_lily01_lua_passive"
end

modifier_ability_thdots_lily01_lua_passive = class({})
LinkLuaModifier( "modifier_ability_thdots_lily01_lua_passive", "scripts/vscripts/abilities/abilitylily.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_ability_thdots_lily01_lua_passive:OnCreated(keys) 
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_ability_thdots_lily01_lua_passive:OnRefresh(keys) 
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_ability_thdots_lily01_lua_passive:IsPurgable() 
	return false 
end

function modifier_ability_thdots_lily01_lua_passive:RemoveOnDeath() 
	return false 
end

function modifier_ability_thdots_lily01_lua_passive:IsHidden() 
	return true 
end

function modifier_ability_thdots_lily01_lua_passive:OnIntervalThink( keys )

	if IsServer() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local spell_cost = ability:GetSpecialValueFor("spell_cost")
		if caster:HasModifier("modifier_lily_black") then
			if caster:GetHealth() < spell_cost then
			
				ability:SetActivated(false)
			else
				ability:SetActivated(true)
			end
		else
			if caster:GetMana() < spell_cost then
			
				ability:SetActivated(false)
			else
				ability:SetActivated(true)
			end
		end
	end
end

modifier_ability_thdots_lily01_lua_buff = class({})


function modifier_ability_thdots_lily01_lua_buff:OnCreated(keys) 
	if IsServer() then
	
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.target = self:GetParent()
		self.tickrate = self.ability:GetSpecialValueFor("tick_rate")
		local base_tick_effect =  self.ability:GetSpecialValueFor("healanddamage")
		local bonus_tick_effect = self.ability:GetSpecialValueFor("statscale")
		self.tickeffects = base_tick_effect + (self.caster:GetIntellect()*bonus_tick_effect)
		self:StartIntervalThink(self.tickrate)
	
	end
end

function modifier_ability_thdots_lily01_lua_buff:OnRefresh(keys) 
	if IsServer() then
	
	
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.target = self:GetParent()
		self.tickrate = self.ability:GetSpecialValueFor("tick_rate")
		local base_tick_effect =  self.ability:GetSpecialValueFor("healanddamage")
		local bonus_tick_effect = self.ability:GetSpecialValueFor("statscale")
		self.tickeffects = base_tick_effect + (self.caster:GetIntellect()*bonus_tick_effect)
		self:StartIntervalThink(self.tickrate)
	
	end
end

function modifier_ability_thdots_lily01_lua_buff:OnIntervalThink( keys )
	if IsServer() then
		self.target:EmitSound("lily01heal")
		THDHealTargetLily(self.caster,self.target,self.tickeffects)
	end
end

function modifier_ability_thdots_lily01_lua_buff:IsPurgable() 
	return true 
end

function modifier_ability_thdots_lily01_lua_buff:RemoveOnDeath() 
	return true 
end

function modifier_ability_thdots_lily01_lua_buff:IsHidden() 
	return false 
end

function modifier_ability_thdots_lily01_lua_buff:IsDebuff() 
	return false 
end

function modifier_ability_thdots_lily01_lua_buff:GetEffectName() 
	return "particles/units/heroes/hero_warlock/warlock_shadow_word_buff.vpcf" 
end

function modifier_ability_thdots_lily01_lua_buff:GetEffectAttachType() 
	return "PATTACH_ABSORIGIN_FOLLOW"	 
end

------------------------------------------------------------------------------





modifier_ability_thdots_lily01_lua_debuff = class({})



function modifier_ability_thdots_lily01_lua_debuff:OnCreated(keys) 
	if IsServer() then
	
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.target = self:GetParent()
		self.tickrate = self.ability:GetSpecialValueFor("tick_rate")
		local base_tick_effect =  self.ability:GetSpecialValueFor("healanddamage")
		local bonus_tick_effect = self.ability:GetSpecialValueFor("statscale")
		self.tickeffects = base_tick_effect + (self.caster:GetIntellect()*bonus_tick_effect)
		self:StartIntervalThink(self.tickrate)
	
	end
end

function modifier_ability_thdots_lily01_lua_debuff:OnRefresh(keys) 
	if IsServer() then
	
	
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.target = self:GetParent()
		self.tickrate = self.ability:GetSpecialValueFor("tick_rate")
		local base_tick_effect =  self.ability:GetSpecialValueFor("healanddamage")
		local bonus_tick_effect = self.ability:GetSpecialValueFor("statscale")
		self.tickeffects = base_tick_effect + (self.caster:GetIntellect()*bonus_tick_effect)
		self:StartIntervalThink(self.tickrate)
	
	end
end

function modifier_ability_thdots_lily01_lua_debuff:OnIntervalThink( keys )
	if IsServer() then
		local target = self.target
		local caster = self.caster
		local ability = self.ability
		target:EmitSound("lily01damage")
		local damage_table = {
				ability = ability,
			    victim = target,
			    attacker = caster,
			    damage = self.tickeffects,
			    damage_type = ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		THDDealdamageMsgPoison(damage_table)
	end



end

function THDDealdamageMsgPoison(damagetable)


	local thdfinaldamage = UnitDamageTarget(damagetable)
	

	if IsValidEntity(damagetable.victim) and damagetable.victim:IsNull() == false then
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,damagetable.victim,thdfinaldamage, nil)
	
	end

end

function modifier_ability_thdots_lily01_lua_debuff:IsPurgable() 
	return true 
end

function modifier_ability_thdots_lily01_lua_debuff:RemoveOnDeath() 
	return true 
end

function modifier_ability_thdots_lily01_lua_debuff:IsHidden() 
	return false 
end

function modifier_ability_thdots_lily01_lua_debuff:IsDebuff() 
	return true 
end

function modifier_ability_thdots_lily01_lua_debuff:GetEffectName() 
	return "particles/econ/items/witch_doctor/wd_ti8_immortal_head/wd_ti8_immortal_maledict.vpcf" 
end

function modifier_ability_thdots_lily01_lua_debuff:GetEffectAttachType() 
	return "PATTACH_ABSORIGIN_FOLLOW"	 
end

function THDHealTargetLily(caster,target,healamount)
	if caster:GetName() == "npc_dota_hero_leshrac" and caster:FindAbilityByName("special_bonus_unique_lily_1"):GetLevel() > 0  then
		healamount = healamount*1.5
	end
	target:Heal(healamount,caster)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,target,healamount,nil)	
end