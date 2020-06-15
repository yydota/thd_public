abilitylyrica = class({})

LYRICA_BONUS_COUNT = nil --天生击杀计数
LYRICA03TALENT_FLAG = 1 --给一次加25级天赋的次数

function OnLyrica01SpellStart( keys )
	-- body
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local vecCaster = caster:GetOrigin()
	local maxRange = 500 + FindTelentValue(caster,"special_bonus_cast_range_300") + caster:GetCastRangeBonus()
	local pointRad = GetRadBetweenTwoVec2D(vecCaster,targetPoint)
	if(GetDistanceBetweenTwoVec2D(vecCaster,targetPoint)<=maxRange)then
		FindClearSpaceForUnit(caster,targetPoint,true)
	else
		local blinkVector = Vector(math.cos(pointRad)*maxRange,math.sin(pointRad)*maxRange,0) + vecCaster
		FindClearSpaceForUnit(caster,blinkVector,true)
	end


	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_pur_ti6_immortal_hampart_b.vpcf", PATTACH_POINT, caster)
	ParticleManager:DestroyParticleSystem(effectIndex, false)
	if FindTelentValue(caster,"special_bonus_unique_weaver_3") then
		local effectIndex3 = ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_pur_ti6_immortal_beams.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:DestroyParticleSystem(effectIndex3, false)
	end
end

function OnLyrica01Heal( keys )
	-- 这里的施法坐标是已经传送完之后的坐标
	local caster = keys.caster
	local vecCaster = caster:GetOrigin()
	local targets = FindUnitsInRadius(caster:GetTeam(), 
									 vecCaster, 
									 nil, 
									 keys.heal_radius + FindTelentValue(caster,"special_bonus_unique_weaver_3"), 
									 DOTA_UNIT_TARGET_TEAM_BOTH, 
									 keys.ability:GetAbilityTargetType(), 
									 DOTA_UNIT_TARGET_NONE, 
									 FIND_ANY_ORDER, 
									 false
									)
	for _,v in pairs (targets) do
		if v:GetTeam() == caster:GetTeam() then
			local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_POINT, v)
			ParticleManager:DestroyParticleSystem(effectIndex, false)
			v:Heal(keys.heal + caster:GetIntellect()*1.9, caster)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,v,keys.heal + caster:GetIntellect()*1.9,nil)
		elseif FindTelentValue(caster,"special_bonus_unique_weaver_4") == 1 and not v:IsBuilding() then
				local damage_table = {
				ability = keys.ability,
				victim = v,
				attacker = caster,
				damage = keys.heal + caster:GetIntellect()*1.9,
				damage_type = keys.ability:GetAbilityDamageType()
				}
			UnitDamageTarget(damage_table)
			local effectIndex1 = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_guardian_angel_buff_n.vpcf", PATTACH_POINT, v)
			ParticleManager:DestroyParticleSystem(effectIndex1, false)
		end
	end
end


function OnLyrica02SpellStart( keys )
	-- body
	local caster = keys.caster
	local target = keys.target
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_ability_thdots_lyrica02_attack", {Duration = keys.duration })
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_ability_thdots_lyrica02_beattack", {Duration = keys.duration })
	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8_sphere.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
	effectIndex1 = ParticleManager:CreateParticle("particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8_swoosh.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
	effectIndex2 = ParticleManager:CreateParticle("particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8_glyph.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
	ParticleManager:DestroyParticleSystemTime(effectIndex, keys.duration)
	ParticleManager:DestroyParticleSystemTime(effectIndex1, keys.duration)
	ParticleManager:DestroyParticleSystemTime(effectIndex2, keys.duration)
end

function OnLyrica02Attack( keys )
	-- body
	local caster = keys.attacker
	local target = keys.target
	if not target:IsBuilding() then
		ParticleManager:DestroyParticle(effectIndex1,true)
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_ability_thdots_lyrica02_debuff", {Duration = keys.debuff_duration})
		caster:RemoveModifierByName("modifier_ability_thdots_lyrica02_attack")
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_degen_aura_debuff.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
		ParticleManager:DestroyParticleSystemTime(effectIndex, keys.debuff_duration)
		local damage_table = {
				ability = keys.ability,
				victim = target,
				attacker = caster,
				damage = keys.damage + caster:GetIntellect() * keys.bonus_int,
				damage_type = keys.ability:GetAbilityDamageType()
				}
		UnitDamageTarget(damage_table)
		if not target:IsAlive() then
			ParticleManager:DestroyParticleSystem(effectIndex,true)
		end
	end
end

function OnLyrica02Beattack( keys )
	-- body
	local caster = keys.target
	local target = keys.attacker
	if target:IsHero() then
		ParticleManager:DestroyParticle(effectIndex2,true)
		caster:RemoveModifierByName("modifier_ability_thdots_lyrica02_beattack")
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_ability_thdots_lyrica04", {Duration = keys.debuff_duration})
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_degen_aura_debuff.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
		ParticleManager:DestroyParticleSystemTime(effectIndex, keys.debuff_duration)
		local damage_table = {
				ability = keys.ability,
				victim = target,
				attacker = caster,
				damage = keys.damage + caster:GetIntellect() * keys.bonus_int,
				damage_type = keys.ability:GetAbilityDamageType()
				}
		UnitDamageTarget(damage_table)
		if not target:IsAlive() then
			ParticleManager:DestroyParticleSystem(effectIndex,true)
		end
	end
end

function OnLyrica04SpellStart( keys )
	-- body
	local caster = keys.caster
	local target = keys.target
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_ability_thdots_lyrica04", {Duration = keys.duration})
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_heavenly_grace_buff.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
	ParticleManager:DestroyParticleSystemTime(effectIndex, keys.duration)
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
	ParticleManager:DestroyParticleSystemTime(effectIndex, keys.duration)
end

function OnLyricaExAttackLanded ( keys )
	--每第四次攻击附加法术伤害
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local lunasaExModifier = caster:FindModifierByName("modifier_ability_thdots_lyricaEx_bonus")
	local count = caster:GetModifierStackCount("modifier_ability_thdots_lyricaEx_bonus", caster)
	if count >= 3 then
		caster:SetModifierStackCount("modifier_ability_thdots_lyricaEx_bonus", keys.ability, 0)
		local targets = FindUnitsInRadius(caster:GetTeam(), 
									 target:GetOrigin(), 
									 nil, 
									 300, 
									 DOTA_UNIT_TARGET_TEAM_ENEMY, 
									 keys.ability:GetAbilityTargetType(), 
									 DOTA_UNIT_TARGET_NONE, 
									 FIND_ANY_ORDER, 
									 false
									)
		for _,v in pairs(targets) do
			if not v:IsBuilding() then
				local damage_table = {
							ability = keys.ability,
							victim = v,
							attacker = caster,
							damage = 45 + caster:GetLevel(),
							damage_type = keys.ability:GetAbilityDamageType()
							}
				UnitDamageTarget(damage_table)
				local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_repel_buff_e.vpcf", PATTACH_ABSORIGIN, v)
				ParticleManager:DestroyParticleSystem(effectIndex,false)
			end
		end
	else
		caster:SetModifierStackCount("modifier_ability_thdots_lyricaEx_bonus", keys.ability, count + 1)
	end
end

function OnLyricaExOnkill ( keys )
	-- 天生, 每击杀一个单位增加0.2%冷却时间, 击杀200个单位后层数减半,上限75%
	local caster = EntIndexToHScript(keys.caster_entindex)
	local lunasaExModifier = caster:FindModifierByName("modifier_ability_thdots_lyricaEx")
	if lunasaExModifier and not caster:IsIllusion() then
		if LYRICA_BONUS_COUNT == nil then
			LYRICA_BONUS_COUNT = caster:GetModifierStackCount("modifier_ability_thdots_lyricaEx", caster)
		end
		if LYRICA_BONUS_COUNT >= 750 then
			LYRICA_BONUS_COUNT = 750
		elseif LYRICA_BONUS_COUNT >= 400 then
			LYRICA_BONUS_COUNT = LYRICA_BONUS_COUNT +1
		else
			LYRICA_BONUS_COUNT = LYRICA_BONUS_COUNT +2
		end
	end
end

function OnLyricaExIntervalThink ( keys )
	local caster = EntIndexToHScript(keys.caster_entindex)
	local ability = caster:FindAbilityByName("ability_thdots_lyrica03talent")
	local flag = FindTelentValue(caster,"special_bonus_unique_weaver_2")
	if LYRICA_BONUS_COUNT ~= nil then
	caster:SetModifierStackCount("modifier_ability_thdots_lyricaEx", caster, LYRICA_BONUS_COUNT)
	end
	if flag == 1 and LYRICA03TALENT_FLAG == 1 then 
		ability:SetLevel(1)
		flag = 0
		LYRICA03TALENT_FLAG = 0
	end

end

