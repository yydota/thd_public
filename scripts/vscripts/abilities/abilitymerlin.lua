MERLINEX_BONUS_COUNT = nil --小号EX层数记录


function Merlin01( keys )
	local caster = keys.caster
	local target = keys.target
	if is_spell_blocked(keys.target) then return end
	target:SetForceAttackTarget(nil)

	target:Stop()


	if caster:IsAlive() then 
		local order = {
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = caster:entindex()
		}

		ExecuteOrderFromTable(order)
	else 
		target:Stop()
	end

	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/merlin/merlin01.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW,target)
	-- ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())		
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.duration)

	if target:IsHero() then
		local damage_table = {
			ability = keys.ability,
			victim = target,
			attacker = caster,
			damage = keys.ability:GetSpecialValueFor("spell_damage") + caster:GetIntellect()*1.5,
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = 0
			}
		UnitDamageTarget(damage_table) 
		target:SetForceAttackTarget(caster)
	else
		local damage_table = {
			ability = keys.ability,
			victim = target,
			attacker = caster,
			damage = keys.ability:GetSpecialValueFor("spell_damage") + caster:GetIntellect()*1.5 + keys.ability:GetSpecialValueFor("extra_damage"),
			damage_type = keys.ability:GetAbilityDamageType(), 
			damage_flags = 0
			}
		UnitDamageTarget(damage_table) 
		target:SetForceAttackTarget(caster)

		caster:SetMana(caster:GetMana() + 70)
	end

end


function Merlin01End( keys )
	local target = keys.target
	target:SetForceAttackTarget(nil)	
end


function Merlin02( keys )
	-- body
	local caster = keys.caster
	local target = keys.target
	if is_spell_blocked(target,caster) then return end
	target:EmitSound("Voice_Thdots_Merlin.AbilityMerlin02")
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_battle_hunger.vpcf", PATTACH_OVERHEAD_FOLLOW,target)
	-- ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())		
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.buff_time)
	if(FindTelentValue(caster,"special_bonus_unique_earth_spirit") == 1)then
		if(caster:GetTeam() ~= target:GetTeam()) then
			keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_merlin02_debuff_telent", {})
		else
			keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_merlin02_buff", {})
		end
	else
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_merlin02_debuff", {})
		--Purge(bool RemovePositiveBuffs, bool RemoveDebuffs, bool BuffsCreatedThisFrameOnly, bool RemoveStuns, bool RemoveExceptions)
		--target:Purge(false,true,false,true,false)
	end
end

function Merlin03 (keys)
	local caster = keys.caster
	local flag15_l = FindTelentValue(caster,"special_bonus_unique_earth_spirit_2")
	local flag20 = FindTelentValue(caster,"special_bonus_unique_earth_spirit_3")

	local currentHealth = caster:GetHealth()
	local maxHealth = caster:GetMaxHealth()
	local tmp1,tmp2 = math.modf( (1 - (currentHealth / maxHealth ) ) / keys.ability:GetSpecialValueFor("spell_rate") )
	local buffNum = tmp1 + 1

	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), self, keys.ability:GetSpecialValueFor("aura_range"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false)

	--光环回血
	if (flag15_l == 1) then
		for _,u in pairs (targets) do
			u:SetModifierStackCount("modifier_merlin03_buff", caster, buffNum*2)
		end
	else
		for _,u in pairs (targets) do
			u:SetModifierStackCount("modifier_merlin03_buff", caster, buffNum)
		end
	end
	
	--光环天赋双抗

	if( keys.caster:FindModifierByName("modifier_merlin03_telent") ) then
		--设置双抗层数
		for _,u in pairs (targets) do
			u:SetModifierStackCount("modifier_merlin03_buff_telent", caster, buffNum)
		end
	else
		--点天赋给护甲光环
		if (flag20 == 1)then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_merlin03_telent", {})
		end
	end
end

function Merlin03Telent (keys)
	local caster = keys.caster
	local ability = keys.ability
	local flag20 = FindTelentValue(caster,"special_bonus_unique_earth_spirit_3")
	local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), self, keys.ability:GetSpecialValueFor("aura_range"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false)


	--光环天赋双抗
	if (flag20 == 1) then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_merlin03_telent", {})
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_lunasa04", {})

		local currentHealth = caster:GetHealth()
		local maxHealth = caster:GetMaxHealth()
		local tmp1,tmp2 = math.modf( (1 - (currentHealth / maxHealth ) ) / keys.ability:GetSpecialValueFor("spell_rate") )
		local buffNum = tmp1 + 1
		for _,u in pairs (targets) do
			u:SetModifierStackCount("modifier_merlin03_buff_telent", caster, buffNum)
		end
	end
end


function Merlin04SpellStart( keys )
	-- body
	local caster = keys.caster
	local target = keys.target
	if is_spell_blocked(keys.target) then return end
	keys.ability:ApplyDataDrivenModifier(caster, caster, "OnMerlin04TakeDamage", {})
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_merlin04_enemy", {})
	merlin04target = target
	caster:EmitSound("Voice_Thdots_Merlin.AbilityMerlin04")
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_earth_spirit_4"))
--customorigin
	local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/merlin/merlin04_target.vpcf", PATTACH_OVERHEAD_FOLLOW,target)
	--ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin() + Vector(0,0,100))		
	ParticleManager:DestroyParticleSystemTime(effectIndex,keys.duration)

    local effectIndex1 = ParticleManager:CreateParticle("particles/thd2/heroes/merlin/merlin04_self.vpcf", PATTACH_OVERHEAD_FOLLOW,caster)
	--ParticleManager:SetParticleControl(effectIndex1, 0, caster:GetOrigin() + Vector(0,0,100))		
	ParticleManager:DestroyParticleSystemTime(effectIndex1,keys.duration)

end


function OnMerlin04TakeDamage( keys )
	local caster = keys.caster
	local target = merlin04target
	local attacker = keys.attacker
	local damage_to_deal = keys.TakenDamage * (keys.ability:GetSpecialValueFor("back_factor") + FindTelentValue(caster,"special_bonus_unique_earth_spirit_5"))


	if (attacker:IsBuilding()==false and attacker:IsRealHero()) and attacker ~= caster then
		if (damage_to_deal > 0) then

			local damage_table = {
				ability = keys.ability,
				victim = target,
				attacker = caster,
				damage = damage_to_deal,
				damage_type = keys.ability:GetAbilityDamageType(),
				damage_flags = 0
			}
			UnitDamageTarget(damage_table)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,target,damage_to_deal,nil)
			local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/merlin/merlin04_thin.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin()+Vector(0, 0, 100))
			ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin()+Vector(0, 0, 100))
		end
	end
end


function MerlinExOnCreated ( keys )
	-- 天生, 每击杀一个单位增加4的生命值, 250次击杀后收益减半。
	local caster = EntIndexToHScript(keys.caster_entindex)
	local MerlinExModifier = caster:FindModifierByName("modifier_MerlinEx_HealthBonus")
	if MerlinExModifier and not caster:IsIllusion() then
		if MERLINEX_BONUS_COUNT == nil then
			MERLINEX_BONUS_COUNT = caster:GetModifierStackCount("modifier_MerlinEx_HealthBonus", caster)
		end
		if MERLINEX_BONUS_COUNT >= 250 then
			MERLINEX_BONUS_COUNT = MERLINEX_BONUS_COUNT + 1
			--caster:SetMaxHealth(caster:GetMaxHealth() + 2)
		else
			MERLINEX_BONUS_COUNT = MERLINEX_BONUS_COUNT + 2
			--caster:SetMaxHealth(caster:GetMaxHealth() + 4)
		end
	end
end

function MerlinExOnIntervalThink( keys )
	-- body
		local caster = EntIndexToHScript(keys.caster_entindex)
		if MERLINEX_BONUS_COUNT ~= nil then
		caster:SetModifierStackCount("modifier_MerlinEx_HealthBonus", caster, MERLINEX_BONUS_COUNT)
		end
end


function MerlinExOnattackLanded( keys )
	-- 天生，第四次攻击附带法术伤害
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if not target:IsBuilding() then
		local MerlinExModifier = caster:FindModifierByName("modifier_MerlinEx_AttackBonus")
		local count = caster:GetModifierStackCount("modifier_MerlinEx_AttackBonus", caster)
		if count >= 3 then
			local effectIndex = ParticleManager:CreateParticle("particles/econ/items/timbersaw/timbersaw_ti9/timbersaw_ti9_chakram_hit.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			caster:SetModifierStackCount("modifier_MerlinEx_AttackBonus", keys.ability, 0)
			local damage_table = {
				ability = keys.ability,
				victim = target,
				attacker = caster,
				damage = caster:GetMaxHealth() * FindValueTHD("health_percent_bonus",keys.ability)/100,
				damage_type = keys.ability:GetAbilityDamageType()
			}
			UnitDamageTarget(damage_table)
		else
			caster:SetModifierStackCount("modifier_MerlinEx_AttackBonus", keys.ability, count + 1)
		end
	end
end
