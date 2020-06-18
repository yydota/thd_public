ability_thdots_koishi01 = {}

modifier_ability_thdots_koishi01 = {} --被动计算
LinkLuaModifier("modifier_ability_thdots_koishi01","scripts/vscripts/abilities/abilitykoishi.lua",LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_koishi01_open = {} --主动开启buff
LinkLuaModifier("modifier_ability_thdots_koishi01_open","scripts/vscripts/abilities/abilitykoishi.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_koishi01:IsHidden()
	if self:GetAbility().SpellOpen == true then
		return true
	end
	return false
end
function modifier_ability_thdots_koishi01:IsPurgable()		return false end
function modifier_ability_thdots_koishi01:RemoveOnDeath() 	return false end
function modifier_ability_thdots_koishi01:IsDebuff()		return false end

function modifier_ability_thdots_koishi01_open:IsHidden() 		return false end
function modifier_ability_thdots_koishi01_open:IsPurgable()		return false end
function modifier_ability_thdots_koishi01_open:RemoveOnDeath() 	return false end
function modifier_ability_thdots_koishi01_open:IsDebuff()		return false end

function ability_thdots_koishi01:GetIntrinsicModifierName()
	return  "modifier_ability_thdots_koishi01"
end

function ability_thdots_koishi01:OnSpellStart()
	self.caster 		= self:GetCaster()
	if not IsServer() then return end
	self.caster:AddNewModifier(self.caster, self,"modifier_ability_thdots_koishi01_open",{duration = self:GetSpecialValueFor("duration")})
	self.SpellOpen = true
	self.caster:EmitSound("Hero_DarkWillow.Brambles.CastTarget")
end

function modifier_ability_thdots_koishi01:OnCreated()
	self.radius 		= self:GetAbility():GetSpecialValueFor("radius")
	self.duration 		= self:GetAbility():GetSpecialValueFor("duration")
	self.caster 		= self:GetParent()
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
	self:GetAbility().SpellOpen = false
end

function modifier_ability_thdots_koishi01:OnIntervalThink()
	if not IsServer() then return end
	local caster = self.caster
	local targets = FindUnitsInRadius(
				   caster:GetTeam(),		
				   caster:GetOrigin(),		
				   nil,					
				   self.radius + FindTelentValue(caster,"special_bonus_unique_drow_ranger_4"),		
				   DOTA_UNIT_TARGET_TEAM_BOTH,
				   DOTA_UNIT_TARGET_HERO,
				   0, FIND_CLOSEST,
				   false
	)
	local count = 0
	for k,v in pairs(targets) do
		if v:IsIllusion()==false then
			count = count + 1
		end
	end
	if self:GetAbility().SpellOpen == true then 
		count = 12 - count
	end
	count = count * (1 + FindTelentValue(caster,"special_bonus_unique_drow_ranger_2"))
	caster:SetModifierStackCount("modifier_ability_thdots_koishi01", self:GetAbility(), count)
	if caster:FindModifierByName("modifier_ability_thdots_koishi01_open") ~= nil then
		caster:SetModifierStackCount("modifier_ability_thdots_koishi01_open",self:GetAbility(),count)
	end
end

function modifier_ability_thdots_koishi01:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_ability_thdots_koishi01:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage") * self:GetStackCount()
end
function modifier_ability_thdots_koishi01_open:GetEffectName()
	return "particles/units/heroes/hero_arc_warden/arc_warden_tempest_buff.vpcf"
end

function modifier_ability_thdots_koishi01_open:OnDestroy()
	if not IsServer() then return end
	self:GetAbility().SpellOpen = false
	self:GetParent():EmitSound("Hero_DarkWillow.Bramble.Destroy")
end

function OnKoishi01Think(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targets = FindUnitsInRadius(
				   caster:GetTeam(),		
				   caster:GetOrigin(),		
				   nil,					
				   keys.Radius+FindTelentValue(caster,"special_bonus_unique_drow_ranger_4"),		
				   DOTA_UNIT_TARGET_TEAM_BOTH,
				   DOTA_UNIT_TARGET_HERO,
				   0, FIND_CLOSEST,
				   false
	)
	local count = 0
	for k,v in pairs(targets) do
		if v:IsIllusion()==false then
			count = count + 1
		end
	end
	local countTelent = FindTelentValue(caster,"special_bonus_unique_drow_ranger_2")
	if countTelent > 0 then
		caster:SetModifierStackCount("passive_koishi01_bonus_attack", keys.ability, count * countTelent)
	else
		caster:SetModifierStackCount("passive_koishi01_bonus_attack", keys.ability, count)
	end
end

function OnKoishi02AttackLanded(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local manadecrease = keys.DamagePercent * keys.DamageTaken / 100 + keys.BaseDamage
	

	if target:GetMana() >= manadecrease then
		target:ReduceMana(manadecrease)
	end
	local damage_table = {
		ability = keys.ability,
		victim = target,
		attacker = caster,
		damage = manadecrease,
		damage_type = keys.ability:GetAbilityDamageType(), 
	    damage_flags = keys.ability:GetAbilityTargetFlags()
	}
	UnitDamageTarget(damage_table) 
	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/am_manaburn_basher_ti_5.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
end

function OnKoishi02wanbaochui(keys)
	local caster = keys.caster
	local target = keys.target
	if caster:HasModifier("modifier_item_wanbaochui") then
		if is_spell_blocked(keys.target) then return end
		local deal_damage = (target:GetMaxMana()-target:GetMana())*1.4
		local targets = FindUnitsInRadius(
							caster:GetTeam(),		
							target:GetOrigin(),	
							nil,					
							500,		
							DOTA_UNIT_TARGET_TEAM_ENEMY,
							keys.ability:GetAbilityTargetType(),
							0,
							FIND_CLOSEST,
							false
						)
				for k,v in pairs(targets) do
					local damage_table = {
						ability = keys.ability,
						victim = v,
						attacker = caster,
						damage = deal_damage,
						damage_type = keys.ability:GetAbilityDamageType(), 
						damage_flags = keys.ability:GetAbilityTargetFlags()
					}
					UnitDamageTarget(damage_table)
				end
				target:EmitSound("Hero_Antimage.ManaVoid")
				local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_manavoid.vpcf", PATTACH_CUSTOMORIGIN, caster)
				local effectIndex2 = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_manavoid_ti_5_gold.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
				ParticleManager:SetParticleControl(effectIndex2, 0, target:GetOrigin())
				ParticleManager:DestroyParticleSystem(effectIndex,false)
				ParticleManager:DestroyParticleSystem(effectIndex2,false)
				UtilStun:UnitStunTarget( caster,target,0.5)
	else
		keys.ability:EndCooldown()
		keys.ability:RefundManaCost()
		return
	end
end

function Koishi_wanbaochui_check(keys)
	local caster = keys.caster
	local casterName = caster:GetClassname()
	local abilityEx=nil
	if casterName == "npc_dota_hero_drow_ranger" and caster:HasModifier("modifier_item_wanbaochui") then
		abilityEx = caster:FindAbilityByName("phantom_assassin_blur")
		abilityEx:SetLevel(1)
	else
		abilityEx = caster:FindAbilityByName("phantom_assassin_blur")
		abilityEx:SetLevel(0)
	end
end


function OnKoishiKill(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if caster:HasModifier("modifier_item_wanbaochui") then
		local ability = caster:FindAbilityByName("phantom_assassin_blur")
		ability:EndCooldown()
	end	
end





function OnKoishi04PhaseStart(keys)
 	local caster = EntIndexToHScript(keys.caster_entindex)
 	keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))
 	if FindTelentValue(caster,"special_bonus_unique_drow_ranger_3") ~= 0 then
 		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_koishi04_telent_bonus", {})
	 end
	if FindTelentValue(caster,"special_bonus_unique_drow_ranger_1") ~= 0 then
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_koishi04_telent_movespeed", {})
	end
end

function OnKoishi04Destroy(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_koishi04_bonus_action_end", nil)
end

function OnKoishi04ActionStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:SetModel("models/thd2/koishi/koishi_w_mmd.vmdl")
	caster:SetOriginalModel("models/thd2/koishi/koishi_w_mmd.vmdl")
end

function OnKoishi04ActionDestroy(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:SetModel("models/thd2/koishi/koishi_transform_mmd.vmdl")
	caster:SetOriginalModel("models/thd2/koishi/koishi_transform_mmd.vmdl")
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_koishi04_bonus", nil)
 	PlayerResource:SetCameraTarget(caster:GetPlayerOwnerID(), caster)
	caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	caster:MoveToPosition(caster:GetOrigin())
end

function OnKoishi04ActionEndStart(keys)	
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:SetModel("models/thd2/koishi/koishi_w_mmd.vmdl")
	caster:SetOriginalModel("models/thd2/koishi/koishi_w_mmd.vmdl")
end

function OnKoishi04ActionEndDestroy(keys)
	local caster = keys.caster
	caster:SetModel("models/thd2/koishi/koishi_mmd.vmdl")
	caster:SetOriginalModel("models/thd2/koishi/koishi_mmd.vmdl")
	PlayerResource:SetCameraTarget(caster:GetPlayerOwnerID(), nil)
	caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
	caster:MoveToPosition(caster:GetOrigin())
end

function OnKoishi04Think(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local targets
	if caster:HasModifier("modifier_thdots_medicine04_debuff") then
		targets = FindUnitsInRadius(
				caster:GetTeam(),	
				caster:GetOrigin(),	
				nil,
				1000,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO,
				0, 
				FIND_CLOSEST,
				false
			)
		if targets[1] == nil then
			targets = FindUnitsInRadius(
					caster:GetTeam(),	
					caster:GetOrigin(),	
					nil,
					1000,
					DOTA_UNIT_TARGET_TEAM_ENEMY,
					DOTA_UNIT_TARGET_BASIC,
					0, 
					FIND_CLOSEST,
					false
				)
		end
	else
		targets = FindUnitsInRadius(
			caster:GetTeam(),	
			caster:GetOrigin(),	
			nil,	
			1000,		
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			keys.ability:GetAbilityTargetType(),
			0, 
			FIND_CLOSEST,
			false
		)
	end	
	for i=1,#targets do 
		if targets[i]~=nil and targets[i]:IsInvisible()==false and targets[i]:GetUnitName()~="npc_reimu_04_dummy_unit" and targets[i]:GetUnitName()~="ability_yuuka_flower" and targets[i]:GetUnitName()~="npc_dota_watch_tower" then
			caster:MoveToTargetToAttack(targets[i])
			break
		end
	end
end

function OnKoishi04Kill(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vec = keys.unit:GetOrigin()
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, vec)
	ParticleManager:SetParticleControl(effectIndex, 1, vec)
	ParticleManager:SetParticleControl(effectIndex, 2, vec)
	ParticleManager:SetParticleControl(effectIndex, 3, vec)
	ParticleManager:SetParticleControl(effectIndex, 4, vec)
	ParticleManager:SetParticleControl(effectIndex, 8, vec)
end