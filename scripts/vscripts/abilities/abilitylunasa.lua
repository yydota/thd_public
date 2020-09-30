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
		UnitDamageTarget(DamageTable)
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
	local ability = keys.ability
	local lunasa03_buff = caster:FindModifierByName("modifier_lunasa03")
	local LUNASA_DAMAGE_BONUS_PERCENT = (caster:GetMaxHealth() - caster:GetHealth())/caster:GetMaxHealth() * 10 / (keys.AbilityMulti - FindTelentValue(caster,"special_bonus_unique_dazzle_4"))
	caster:SetModifierStackCount("modifier_lunasa03", caster, LUNASA_DAMAGE_BONUS_PERCENT * 100 )
end

ability_thdots_lunasa_wanbaochui = {}

function ability_thdots_lunasa_wanbaochui:GetAbilityTextureName()
	if not IsClient() then return end
	if not self:GetCaster().arcana_style then return "wisp_overcharge" end
	return "custom/imba_wisp_overcharge_arcana"
end

function ability_thdots_lunasa_wanbaochui:OnInventoryContentsChanged()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
			self:SetHidden(false)
		else
			if self:GetCaster():HasModifier("modifier_ability_thdots_lunasa_wanbaochui") then
				self:GetCaster():RemoveModifierByName("modifier_ability_thdots_lunasa_wanbaochui")
				self:ToggleAbility()
			end
			self:SetHidden(true)
		end
	end
end

function ability_thdots_lunasa_wanbaochui:OnHeroCalculateStatBonus()
	self:OnInventoryContentsChanged()
end

function ability_thdots_lunasa_wanbaochui:OnToggle()
	if IsServer() then 
		local caster 			= self:GetCaster()
		local ability 			= self
		if ability:GetToggleState() then
			EmitSoundOn("Hero_Wisp.Overcharge", caster)
			caster:AddNewModifier( caster, ability, "modifier_ability_thdots_lunasa_wanbaochui", {})
			self.effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_overcharge.vpcf", PATTACH_ABSORIGIN_FOLLOW,caster)
			ParticleManager:SetParticleControlEnt(self.effectIndex , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)
		else
			caster:StopSound("Hero_Wisp.Overcharge")
			ParticleManager:DestroyParticleSystem(self.effectIndex,true)			
			caster:RemoveModifierByName("modifier_ability_thdots_lunasa_wanbaochui")
		end
	end
end

modifier_ability_thdots_lunasa_wanbaochui={}
LinkLuaModifier("modifier_ability_thdots_lunasa_wanbaochui","scripts/vscripts/abilities/abilitylunasa.lua",LUA_MODIFIER_MOTION_NONE)

--modifier 基础判定
function modifier_ability_thdots_lunasa_wanbaochui:IsHidden()      return false end
function modifier_ability_thdots_lunasa_wanbaochui:IsPurgable()        return false end
function modifier_ability_thdots_lunasa_wanbaochui:RemoveOnDeath()     return false end
function modifier_ability_thdots_lunasa_wanbaochui:IsDebuff()      return false end

function modifier_ability_thdots_lunasa_wanbaochui:OnCreated()
		self.caster 				= self:GetCaster()
		self.ability 				= self:GetAbility()
		self.drain_pct 				= self:GetAbility():GetSpecialValueFor("drain_pct")/100
		self.drain_interval 		= self:GetAbility():GetSpecialValueFor("drain_interval")
		self.deltaDrainPct			= self.drain_interval * self.drain_pct
		self.bonus_attack_speed 	= self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
		self.bonus_damage_pct 		= self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
	if IsServer() then

		self.overcharge_pfx 		= ParticleManager:CreateParticle(self:GetCaster().overcharge_effect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

		self:StartIntervalThink(self.drain_interval)
	end
end

function modifier_ability_thdots_lunasa_wanbaochui:OnIntervalThink()
	-- hp removal instead of self dmg... this wont break urn or salve
	local current_health 	= self.caster:GetHealth() 
	local health_drain 		= current_health * self.deltaDrainPct
	self.caster:ModifyHealth(current_health - health_drain, self.ability, true, 0)
end

function modifier_ability_thdots_lunasa_wanbaochui:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		-- MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
	return funcs
end
function modifier_ability_thdots_lunasa_wanbaochui:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.overcharge_pfx, false)
	end
end
function modifier_ability_thdots_lunasa_wanbaochui:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attack_speed
end

function modifier_ability_thdots_lunasa_wanbaochui:GetModifierIncomingDamage_Percentage()
	return self.bonus_damage_pct
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
	UnitDamageTarget(DamageTable)
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
	UnitDamageTarget(DamageTable)
end

function lunasaExOnCreated ( keys )
	-- 天生, 每击杀一个单位增加法术伤害,达到上限后层数减半
	local caster = EntIndexToHScript(keys.caster_entindex)
	local amplify_limit = math.ceil(keys.ability:GetSpecialValueFor("amplify_limit") / keys.ability:GetSpecialValueFor("amplify_bonus") * 2)
	print(amplify_limit)
	local lunasaExModifier = caster:FindModifierByName("modifier_lunasaEx")
	if lunasaExModifier and not caster:IsIllusion() then
		if LUNASAEX_BONUS_COUNT == nil then
			LUNASAEX_BONUS_COUNT = caster:GetModifierStackCount("modifier_lunasaEx", caster)
		end
		if LUNASAEX_BONUS_COUNT >= amplify_limit then
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


