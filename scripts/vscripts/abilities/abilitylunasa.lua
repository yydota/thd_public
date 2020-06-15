abilitylunasa = class({})

LUNASAEX_BONUS_COUNT = nil --提琴EX层数记录

function lunasa01OnSpellStart(keys)
	-- body
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targetPoint = caster:GetOrigin()
	local vec = caster:GetForwardVector()
	local distance = keys.range

	--制作一条爆炸特效, 并附带伤害
	for i =1, distance/100 do
		targetPoint = targetPoint + vec*100
		local effectIndex = ParticleManager:CreateParticle("particles/heroes/lunasa/lunasa01.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(effectIndex, 1, targetPoint)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
	end
	local targetPoint = caster:GetOrigin()
 	local targets = FindUnitsInLine(
	      	caster:GetTeam(),
	      	targetPoint,
	      	targetPoint + vec*distance,
	      	nil,
	      	100,
	      	DOTA_UNIT_TARGET_TEAM_ENEMY,
	      	keys.ability:GetAbilityTargetType(),
	      	0)
 	for _,v in pairs(targets) do
 		local DamageTable = {
				   			ability = keys.ability,
			                victim = v, 
			                attacker = caster, 
			                damage = keys.damage + caster:GetIntellect(), 
			                damage_type = keys.ability:GetAbilityDamageType()
		           }
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_death_prophet/death_prophet_base_attack_explosion.vpcf", PATTACH_POINT, v)
		ParticleManager:DestroyParticleSystem(effectIndex, false)
		ApplyDamage(DamageTable)
		keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_lunasa01", {Duration = keys.Duration})
 	end
 	--添加声效
end

function lunasa02OnspellStart(keys)
	-- 普通攻击附带可叠加减魔抗debuff,并附带法术伤害
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if not target:IsBuilding() and caster:GetTeam() ~= target:GetTeam() then 
		local duration = keys.Duration
		local max_StackCount = keys.max_StackCount
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_surge_g.vpcf", PATTACH_POINT, target)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		local lunasaModifier = target:FindModifierByName("modifier_lunasa02_debuff")
		if not lunasaModifier then
			local lunasaModifier = keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_lunasa02_debuff", {Duration = duration})
			target:SetModifierStackCount("modifier_lunasa02_debuff", keys.ability,1 + FindTelentValue(caster,"special_bonus_unique_dazzle_2"))
		else
			local count = target:GetModifierStackCount("modifier_lunasa02_debuff", nil)
			lunasaModifier:SetDuration(duration, true)
			target:SetModifierStackCount("modifier_lunasa02_debuff", keys.ability, count + 1 + FindTelentValue(caster,"special_bonus_unique_dazzle_2"))
			if count >= 16 then 
				target:SetModifierStackCount("modifier_lunasa02_debuff", keys.ability, max_StackCount )
			end
		end
		local damage_table = {
		ability = keys.ability,
		victim = target,
		attacker = caster,
		damage = keys.damage,
		damage_type = keys.ability:GetAbilityDamageType()
		}
		UnitDamageTarget(damage_table)
	end
end

function lunasa03OnCreated (keys)
	-- 随着生命值减少,法术暴击提升
	local caster = EntIndexToHScript(keys.caster_entindex)
	local lunasa03_buff = caster:FindModifierByName("modifier_lunasa03")
	local LUNASA_DAMAGE_BONUS_PERCENT = (caster:GetMaxHealth() - caster:GetHealth())/caster:GetMaxHealth() * 10 / (keys.AbilityMulti - FindTelentValue(caster,"special_bonus_unique_dazzle_4"))
	caster:SetModifierStackCount("modifier_lunasa03", caster, LUNASA_DAMAGE_BONUS_PERCENT * 100 )
end


function lunasa04OnSpellStart ( keys )
	-- 大招,造成一次法术伤害并沉默6秒,完了再结算第一次伤害
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if is_spell_blocked(target) then return end
	caster:EmitSound("Voice_Thdots_Cirno.AbilityLunasa04")
	local DamageTable = {
			   			ability = keys.ability,
		                victim = target, 
		                attacker = caster, 
		                damage = keys.damage + caster:GetIntellect()*0.6, 
		                damage_type = keys.ability:GetAbilityDamageType()
	           }
	ApplyDamage(DamageTable)
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_lunasa04", {})
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, target, 5, "follow_origin", Vector(0,0,0), true)
	ParticleManager:DestroyParticleSystemTime(effectIndex,6)
end

function lunasa04End( keys )
	-- 施法结束,第二次结算伤害
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf", PATTACH_POINT, target)
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	effectIndex = nil
	local DamageTable  = {
			   			ability = keys.ability,
		                victim = target, 
		                attacker = caster, 
		                damage = keys.damage + caster:GetIntellect()*0.6, 
		                damage_type = keys.ability:GetAbilityDamageType()
	           }
	ApplyDamage(DamageTable)
end

function lunasaExOnCreated ( keys )
	-- 天生, 每击杀一个单位增加0.25%法术伤害, 击杀180个单位后层数减半
	local caster = EntIndexToHScript(keys.caster_entindex)
	local lunasaExModifier = caster:FindModifierByName("modifier_lunasaEx")
	if lunasaExModifier and not caster:IsIllusion() then
		if LUNASAEX_BONUS_COUNT == nil then
			LUNASAEX_BONUS_COUNT = caster:GetModifierStackCount("modifier_lunasaEx", caster)
		end
		if LUNASAEX_BONUS_COUNT >= 100 then
			LUNASAEX_BONUS_COUNT = LUNASAEX_BONUS_COUNT +1
		else
			LUNASAEX_BONUS_COUNT = LUNASAEX_BONUS_COUNT +2
		end
	end
end

function lunasaExOnIntervalThink( keys )
	-- body
		local caster = EntIndexToHScript(keys.caster_entindex)
		if LUNASAEX_BONUS_COUNT ~= nil then
		caster:SetModifierStackCount("modifier_lunasaEx", caster, LUNASAEX_BONUS_COUNT)
		end
end

function lunasaExOnattactLanded (keys)
	--每第四次攻击附加法术伤害
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if not target:IsBuilding() then
		local lunasaExModifier = caster:FindModifierByName("modifier_lunasaEx_magicBonus")
		local count = caster:GetModifierStackCount("modifier_lunasaEx_magicBonus", caster)
		if count >= 3 then
			caster:SetModifierStackCount("modifier_lunasaEx_magicBonus", keys.ability, 0)
				local damage_table = {
					ability = keys.ability,
					victim = target,
					attacker = caster,
					damage = keys.damage + caster:GetLevel()*3,
					damage_type = keys.ability:GetAbilityDamageType()
				}
				UnitDamageTarget(damage_table)	
		else
			caster:SetModifierStackCount("modifier_lunasaEx_magicBonus", keys.ability, count + 1)
		end
	end
end


