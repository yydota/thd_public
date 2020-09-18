--------------------------------------------------------
--动力「幻想推进器」
--------------------------------------------------------
ability_thdots_nitori01 = ability_thdots_nitori01 or class({})

function ability_thdots_nitori01:GetCooldown(level)
	if  self:GetCaster():HasModifier("modifier_ability_thdots_nitoriEx_talent1") then
		return self.BaseClass.GetCooldown(self, level) - 6
	else
		return self.BaseClass.GetCooldown(self, level)
	end
end
function ability_thdots_nitori01:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration") + FindTelentValue(self:GetCaster(),"special_bonus_unique_nitori_3")
		-- if FindTelentValue(self:GetCaster(),"special_bonus_unique_nitori_4") ~= 0 then
		-- 	caster:AddNewModifier(caster, self, "modifier_ability_thdots_nitori01_talent", {duration = duration})
		-- end
		caster:AddNewModifier(caster, self, "modifier_ability_thdots_nitori01", {duration = duration})
		if caster:GetName() == "npc_dota_hero_spectre" then
			-- caster:SetModel("models/nitori_cast1/nitori.vmdl")
			caster:SetOriginalModel("models/nitori_cast1/nitori.vmdl")
		end
		if not caster:HasModifier("modifier_bloodseeker_thirst") then
			caster:AddNewModifier(caster, self, "modifier_bloodseeker_thirst", {duration = duration})
		end
		caster:EmitSound("Hero_Phoenix.SolarForge.Layer")
		StartSoundEvent("Hero_Phoenix.SunRay.Loop",caster)
	end
end

LinkLuaModifier("modifier_ability_thdots_nitori01","scripts/vscripts/abilities/abilitynitori.lua",LUA_MODIFIER_MOTION_NONE)
modifier_ability_thdots_nitori01 = class({})

function modifier_ability_thdots_nitori01:IsHidden() return false end
function modifier_ability_thdots_nitori01:IsPurgable() return false end
function modifier_ability_thdots_nitori01:RemoveOnDeath() return true end


function modifier_ability_thdots_nitori01:GetEffectName()
	return "particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge.vpcf"
end

function modifier_ability_thdots_nitori01:OnCreated()
	self.movement_bonus = self:GetAbility():GetSpecialValueFor("movement_bonus")
	self.critical_bonus = self:GetAbility():GetSpecialValueFor("critical_bonus") + 1
	self.attack_bonus   = self:GetAbility():GetSpecialValueFor("attack_bonus")
	if IsServer() then
	-- self.attackrange_bonus = 0-- FindTelentValue(self:GetCaster(),"special_bonus_unique_nitori_1") 加攻击距离
	-- self:SetStackCount(self.attackrange_bonus)
		if self:GetAbility()then
			self.caster = self:GetParent()
			self.forward = self.caster:GetForwardVector()
			self:StartIntervalThink(0.03)
			-- self.pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_icarus_dive.vpcf", PATTACH_WORLDORIGIN, nil )
		else
			self:Destroy()
			return
		end
	end
end

function modifier_ability_thdots_nitori01:OnDestroy()
	if IsServer() then
		if self:GetParent():GetName() == "npc_dota_hero_spectre" then
			self:GetParent():SetModel("models/nitori/nitori.vmdl")
			self:GetParent():SetOriginalModel("models/nitori/nitori.vmdl")
		end
		StartSoundEvent("Hero_Phoenix.SunRay.Stop",self:GetParent())
		StopSoundEvent("Hero_Phoenix.SunRay.Loop",self:GetParent())
		self:SetStackCount(0)
	end
end

function modifier_ability_thdots_nitori01:OnIntervalThink()
	if self.caster:IsAlive() then
		if self.caster:IsStunned() or self.caster:IsFrozen() or self.caster:IsRooted() then
			return
		end
		self.caster:SetOrigin(self.caster:GetAbsOrigin() + self.forward*10)
		self.forward = self.caster:GetForwardVector()
		AddFOWViewer(self.caster:GetTeamNumber(), self.caster:GetAbsOrigin(), self.caster:GetCurrentVisionRange(), 0.051, false)
		-- ParticleManager:SetParticleControl(self.pfx, 0, self.caster:GetAbsOrigin() + self.caster:GetRightVector() * 32 )
	else
		self:Destroy()
	end
end

function modifier_ability_thdots_nitori01:CheckState()
	-- return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	return {
		[MODIFIER_STATE_FLYING]					= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] 		= true
	}
end

function modifier_ability_thdots_nitori01:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		-- MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		-- MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		-- MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
	}
end
-- function modifier_ability_thdots_nitori01:GetModifierDamageOutgoing_Percentage()
-- 	return self.attack_bonus
-- end
function modifier_ability_thdots_nitori01:GetModifierMoveSpeedBonus_Constant()
	return self.movement_bonus
end
function modifier_ability_thdots_nitori01:GetModifierPreAttack_BonusDamage()
	return self.attack_bonus
end
-- function modifier_ability_thdots_nitori01:GetModifierAttackRangeBonus()
-- 	return self:GetStackCount()
-- end
-- function modifier_ability_thdots_nitori01:GetOverrideAnimation()
-- 	print("do it")
-- 	return ACT_MP_RUN_MELEE
-- end
-- function modifier_ability_thdots_nitori01:GetModifierTurnRate_Percentage()
-- 	return -70
-- end

-- modifier_ability_thdots_nitori01_talent = {}
-- LinkLuaModifier("modifier_ability_thdots_nitori01_talent","scripts/vscripts/abilities/abilitynitori.lua",LUA_MODIFIER_MOTION_NONE)

-- function modifier_ability_thdots_nitori01_talent:IsHidden() return true end
-- function modifier_ability_thdots_nitori01_talent:IsPurgable() return false end
-- function modifier_ability_thdots_nitori01_talent:RemoveOnDeath() return false end

-- function modifier_ability_thdots_nitori01_talent:OnCreated()
-- 	if IsServer() then
-- 		self:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_nitori_4"))
-- 	end
-- end

-- function modifier_ability_thdots_nitori01_talent:DeclareFunctions()
-- 	return {
-- 		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
-- 	}
-- end
-- function modifier_ability_thdots_nitori01_talent:GetModifierDamageOutgoing_Percentage()
-- 	return self:GetStackCount()
-- end


--------------------------------------------------------
--电子「阳电子炮Cucumber. II」
--------------------------------------------------------
ability_thdots_nitori02 = {}

function ability_thdots_nitori02:CastFilterResultLocation(vLocation)
	if self:GetCaster():HasModifier("modifier_ability_thdots_nitori01") then
		return UF_FAIL_CUSTOM
	end
end

-- function ability_thdots_nitori02:GetOverrideAnimation()
-- 	return ACT_DOTA_CAST_ABILITY_2
-- end

function ability_thdots_nitori02:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self
		local width = self:GetSpecialValueFor("width")
		local length = self:GetSpecialValueFor("length")
		self.point = self:GetCursorPosition()
		self.num = 1.1
		caster:EmitSound("Ability.MKG_AssassinateLoad")
		caster:AddNewModifier(caster, self, "modifier_ability_thdots_nitori02", {duration = 1.0})
		-- caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2,0.65)
		self.weapon_particle = ParticleManager:CreateParticle("particles/heroes/nitori/nitori1_1.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(self.weapon_particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_weapon", caster:GetAbsOrigin(), true)
	end
end
function ability_thdots_nitori02:OnProjectileHit(target, location)
			-- local effectIndex = ParticleManager:CreateParticle("particles/heroes/nitori/ability_nitori02.vpcf", PATTACH_CUSTOMORIGIN, caster)
			-- ParticleManager:SetParticleControlEnt(effectIndex , 0, self:GetCaster(), 5, "attach_weapon", Vector(0,0,0), true)
			-- ParticleManager:SetParticleControlEnt(effectIndex , 1, target, 5, "attach_hitloc", Vector(0,0,0), true)
			-- ParticleManager:DestroyParticleSystem(effectIndex, true)
	if IsServer() then
		if target then
			self.num = self.num - 0.1
			if self.num <= 0 then 
				self.num = 0 
			end
			if FindTelentValue(self:GetCaster(),"special_bonus_unique_nitori_2") ~= 0 then self.num = 1 end
			self.duration = self:GetSpecialValueFor("duration")
			self.intellect_bonus = self:GetSpecialValueFor("intellect_bonus")
			self.damage = self:GetSpecialValueFor("damage") + (self:GetCaster():GetIntellect() * self.intellect_bonus) * self.num
			if target:IsBuilding() then 
				self.damage = self.damage * self:GetSpecialValueFor("building_reduce") / 100
			end
			target:AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_nitori02_debuff", {duration = self.duration})
			local damage_tabel = ({
				victim 			= target,
				-- Damage starts ramping from when cast time starts, so just gonna simiulate the effects by adding the cast point
				damage 			= self.damage,
				damage_type		= self:GetAbilityDamageType(),
				damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
				attacker 		= self:GetCaster(),
				ability 		= self
			})
			UnitDamageTarget(damage_tabel)
			self.wraith_particle = ParticleManager:CreateParticle("particles/heroes/nitori/ability_nitori02_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			-- ParticleManager:SetParticleControl(self.wraith_particle, 1, Vector(100, 1, 1))
			ParticleManager:DestroyParticleSystemTime(self.wraith_particle,self.duration)
		end
	end
end

modifier_ability_thdots_nitori02 = class({})
LinkLuaModifier("modifier_ability_thdots_nitori02","scripts/vscripts/abilities/abilitynitori.lua",LUA_MODIFIER_MOTION_NONE)

-- function modifier_ability_thdots_nitori02:IsHidden() return true end

function modifier_ability_thdots_nitori02:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true
	}
end

function modifier_ability_thdots_nitori02:OnCreated()
	if IsServer() then
		self.caster = self:GetParent()
		self.point = self:GetAbility().point
		local vec = self:GetAbility().point - self.caster:GetOrigin()
		vec.z = 0
		self.caster:SetForwardVector(vec:Normalized())
	end
end

function modifier_ability_thdots_nitori02:OnDestroy()
	if IsServer() then
		if self.caster:IsAlive() then
			local caster = self:GetAbility():GetCaster()
			local ability = self:GetAbility()
			local width = self:GetAbility():GetSpecialValueFor("width")
			local length = self:GetAbility():GetSpecialValueFor("length")
			ability.point = self:GetAbility().point
			ProjectileManager:CreateLinearProjectile({
				Ability = ability,
				EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
				vSpawnOrigin = caster:GetAbsOrigin(),
				fDistance = length,
				fStartRadius = width,
				fEndRadius = width,
				Source = caster,
				bHasFrontalCone = false,
				bReplaceExisting = false,
				iUnitTargetTeam = ability:GetAbilityTargetTeam(),							
				iUnitTargetType = ability:GetAbilityTargetType(),							
				bDeleteOnHit = false,
				vVelocity = ((ability.point - caster:GetAbsOrigin()) * Vector(1, 1, 0)):Normalized() * 7500,
				bProvidesVision = false,	
			})
			caster:EmitSound("Hero_Tinker.LaserImpact")
			caster:EmitSound("Hero_Tinker.Laser")
		end
	end
end

modifier_ability_thdots_nitori02_debuff = {}
LinkLuaModifier("modifier_ability_thdots_nitori02_debuff","scripts/vscripts/abilities/abilitynitori.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_nitori02_debuff:IsHidden() 		return false end
function modifier_ability_thdots_nitori02_debuff:IsPurgable()		return true end
function modifier_ability_thdots_nitori02_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_nitori02_debuff:IsDebuff()			return true end 

function modifier_ability_thdots_nitori02_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_ability_thdots_nitori02_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movement_slow")
end

--------------------------------------------------------
--化学「光東剑充能反应」
--------------------------------------------------------

ability_thdots_nitori03 = {}

function ability_thdots_nitori03:OnSpellStart()
	if IsServer() then 
		local caster = self:GetCaster()
		-- print(self:GetCaster().telent6)
		local radius = self:GetSpecialValueFor("radius")
		local damage = caster:GetAverageTrueAttackDamage(caster) * self:GetSpecialValueFor("attack_bonus") + (caster:GetIntellect() + caster:GetIntellectGain()) * self:GetSpecialValueFor("intellect_bonus") + self:GetSpecialValueFor("magical_bonus")
		caster:EmitSound("Hero_Mars.Spear")
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4,2.0)
		local effectIndex = ParticleManager:CreateParticle("particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser_b.vpcf", PATTACH_ABSORIGIN_FOLLOW,caster)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, radius,self:GetAbilityTargetTeam(),self:GetAbilityTargetType(),
		0, 0,false)
		if #targets > 0 then
			for _,target in pairs(targets) do
				local damage_tabel = {
					victim 			= target,
					-- Damage starts ramping from when cast time starts, so just gonna simiulate the effects by adding the cast point
					damage 			= damage,
					damage_type		= self:GetAbilityDamageType(),
					damage_flags 	= self:GetAbilityTargetFlags(),
					attacker 		= caster,
					ability 		= self
				}
				UnitDamageTarget(damage_tabel)
				-- SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, target, damage, nil)
			end
		end
	end
end
function ability_thdots_nitori03:GetCooldown(level)
	if  self:GetCaster():HasModifier("modifier_ability_thdots_nitoriEx_talent6") then
		return self.BaseClass.GetCooldown(self, level) - 2
	else
		return self.BaseClass.GetCooldown(self, level)
	end
end

function ability_thdots_nitori03:OnUpgrade()
	if IsServer() then
		self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_ability_thdots_nitori03",{})
	end
end

modifier_ability_thdots_nitori03 = {}
LinkLuaModifier("modifier_ability_thdots_nitori03","scripts/vscripts/abilities/abilitynitori.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_nitori03:IsHidden() 		return true end
function modifier_ability_thdots_nitori03:IsPurgable()		return false end
function modifier_ability_thdots_nitori03:RemoveOnDeath() 	return false end
function modifier_ability_thdots_nitori03:IsDebuff()		return false end

function modifier_ability_thdots_nitori03:DeclareFunctions()
	return{
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end

function modifier_ability_thdots_nitori03:OnAbilityFullyCast(params)
	if IsServer() then
		if params.unit ~= self:GetParent() or params.ability:IsItem() then return end
		self.talent4 = FindTelentValue(self:GetCaster(),"special_bonus_unique_nitori_4")
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ability_thdots_nitori03_passive",{})
		if FindTelentValue(self:GetCaster(),"special_bonus_unique_nitori_4") ~= 0 and self:GetCaster():HasModifier("modifier_ability_thdots_nitori03_passive") then
			self:GetCaster():FindModifierByName("modifier_ability_thdots_nitori03_passive"):SetStackCount(1)
		end
	end
end


modifier_ability_thdots_nitori03_passive = {}
LinkLuaModifier("modifier_ability_thdots_nitori03_passive","scripts/vscripts/abilities/abilitynitori.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_nitori03_passive:GetEffectName()
	return "particles/units/heroes/hero_leshrac/leshrac_pulse_nova_ambient.vpcf"
end

function modifier_ability_thdots_nitori03_passive:OnCreated()
	self.damage_bonus = self:GetAbility():GetSpecialValueFor("damage_bonus")
	local talent4 = 0
	if self:GetStackCount() ~= 0 then
		talent4 = 20
	end
	self.outdamage_bonus = self:GetAbility():GetSpecialValueFor("outdamage_bonus") + talent4
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	if IsServer() then
		self:SetStackCount(FindTelentValue(self:GetCaster(),"special_bonus_unique_nitori_6"))
	end
end

function modifier_ability_thdots_nitori03_passive:OnRefresh()
	self.damage_bonus = self:GetAbility():GetSpecialValueFor("damage_bonus")
	local talent4 = 0
	if self:GetStackCount() ~= 0 then
		talent4 = 20
	end
	self.outdamage_bonus = self:GetAbility():GetSpecialValueFor("outdamage_bonus") + talent4
end

function modifier_ability_thdots_nitori03_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_ability_thdots_nitori03_passive:OnAttackLanded(keys)
	if not IsServer() then return end
	-- if keys.attacker:GetTeam() == keys.target:GetTeam() then return end  --反补不触发
	if keys.attacker == self:GetParent() then
		if not self:GetParent():HasModifier("modifier_ability_thdots_nitori03_passive") then return end
		-- print(keys.attacker:GetName())
		local deal_damage = keys.damage  * (self:GetAbility():GetSpecialValueFor("damage_percent")/100) * (1 + FindTelentValue(self:GetCaster(),"special_bonus_unique_nitori_7")) -- + self:GetAbility():GetSpecialValueFor("damage_bonus")
		DoCleaveAttack(keys.attacker,keys.target,self:GetAbility(),deal_damage,150,450,650,"particles/econ/items/kunkka/divine_anchor/hero_kunkka_dafx_weapon/kunkka_spell_tidebringer_fxset.vpcf")
		self:Destroy()
	end
end
function modifier_ability_thdots_nitori03_passive:GetModifierDamageOutgoing_Percentage()
	return self.outdamage_bonus
end
-- function modifier_ability_thdots_nitori03_passive:GetModifierPreAttack_BonusDamage()
-- 	return self.damage_bonus + self:GetStackCount()
-- end

--------------------------------------------------------
--「河童之幻想大瀑布浮游炮」
--------------------------------------------------------
ability_thdots_nitori04 = {}

function ability_thdots_nitori04:CreateFunnels(num)
	self.tNitori04Funnel = {}
	self.tNitori04Funnel[num] = {
		Funnel = nil,
		Target = nil,
	}
end

function ability_thdots_nitori04:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if is_spell_blocked(target) then return end
	local number = self:GetSpecialValueFor("number") + FindTelentValue(self:GetCaster(),"special_bonus_unique_nitori_5")
	self.target = target
	local point = caster:GetOrigin()
	local back_point = point + caster:GetForwardVector()*Vector(-1,-1,0)
	local vec = math.acos(caster:GetForwardVector().x)
	for i = 1,number do
		ability_thdots_nitori04:CreateFunnels(i)
		self.tNitori04Funnel[i].Funnel = CreateUnitByName("ability_nitori04_funnel", 
			caster:GetOrigin(),
			false,
			caster,
			caster,
			caster:GetTeam()
		)
		self.tNitori04Funnel[i].Funnel:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
		self.tNitori04Funnel[i].Funnel:AddNewModifier(caster, self, "modifier_bloodseeker_thirst", {}) --self:GetSpecialValueFor("duration")
		self.tNitori04Funnel[i].Funnel:AddNewModifier(caster, self, "modifier_ability_thdots_nitori04_funnel", {duration = self:GetSpecialValueFor("duration")})
		-- caster:CastAbilityOnTarget(target,self,self.caster:GetPlayerID())
		self.tNitori04Funnel[i].Funnel:SetOrigin(back_point + Vector(math.cos(vec+math.pi/3*i) * 250,math.sin(vec+math.pi/3*i) * 250,point.z))
	end
end

modifier_ability_thdots_nitori04_funnel = {}
LinkLuaModifier("modifier_ability_thdots_nitori04_funnel","scripts/vscripts/abilities/abilitynitori.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_nitori04_funnel:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.target = self:GetAbility().target
	self:StartIntervalThink(0.03)
	self:GetParent():MoveToPosition(self.target:GetAbsOrigin() + RandomVector(250))
	self.ability = self.parent:GetAbilityByIndex(0)
	self.parent:MoveToPosition(self.target:GetAbsOrigin() + RandomVector(250))
	-- self.parent:SetOrigin(self.parent:GetOrigin().x,self.parent:GetOrigin().y,self.target:GetOrigin().z)
end

function modifier_ability_thdots_nitori04_funnel:OnIntervalThink()
	if not IsServer() then return end	
	self.parent = self:GetParent()
	local distance = (self.parent:GetAbsOrigin() - self:GetAbility().target:GetAbsOrigin()):Length2D()
	if distance <= 100 and not self.parent:HasModifier("modifier_ability_thdots_nitori04_funnel_cast") then 
		self.parent:AddNewModifier(self.caster, self:GetAbility(),"modifier_ability_thdots_nitori04_funnel_cast",{duration = 0.8 + RandomFloat(0.1,0.4) * RandomInt(-1,1)})
	end
	-- print(self:GetAbility().target:GetName())
	self.parent:MoveToTargetToAttack(self:GetAbility().target)
end

function modifier_ability_thdots_nitori04_funnel:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveSelf()
end

modifier_ability_thdots_nitori04_funnel_cast = {}
LinkLuaModifier("modifier_ability_thdots_nitori04_funnel_cast","scripts/vscripts/abilities/abilitynitori.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_nitori04_funnel_cast:OnCreated()
	if not IsServer() then return end
	if RollPercentage(50) then
		self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_2)
	else
		self:GetParent():StartGesture(ACT_DOTA_ATTACK)
	end

end
function modifier_ability_thdots_nitori04_funnel_cast:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetParent()
	local target = self:GetAbility().target
	local distance = (target:GetOrigin() - caster:GetOrigin()):Length2D()
	if distance > 450 then return end
	if not target or not target:IsAlive() then 
		local next_target = FindUnitsInRadius(self:GetCaster():GetTeam(),caster:GetOrigin(), nil,600,
			self:GetAbility():GetAbilityTargetTeam(),self:GetAbility():GetAbilityTargetType(),0	,FIND_CLOSEST,false)
		if #next_target > 0 then
			-- print(next_target[1]:GetName())
			self:GetAbility().target = next_target[1]
			target = self:GetAbility().target
			return
		else
			return
		end
	end
	local range = self:GetAbility():GetSpecialValueFor("range")
	local disintegration = self:GetAbility():GetSpecialValueFor("disintegration")
	local damage = self:GetAbility():GetSpecialValueFor("damage") + self:GetCaster():GetIntellect()*self:GetAbility():GetSpecialValueFor("int_bonus") --智力加成
	damage = damage * (1 + self:GetCaster():GetSpellAmplification(false))
	if not IsServer() then return end
	local point = caster:GetAbsOrigin() + caster:GetForwardVector() * 150
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_laser.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_weapon", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 1, target, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 9, caster, 5, "attach_weapon", Vector(0,0,0), true)
	-- local laser_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_laser.vpcf", PATTACH_CUSTOMORIGIN, caster)
	local targets = FindUnitsInRadius(self:GetCaster():GetTeam(),target:GetOrigin(),nil,range,self:GetAbility():GetAbilityTargetTeam(),self:GetAbility():GetAbilityTargetType(),
	0,0,false)
	for _,v in pairs(targets) do
		local damage_tabel = {
			victim 			= v,
			-- Damage starts ramping from when cast time starts, so just gonna simiulate the effects by adding the cast point
			damage 			= damage,
			damage_type		= self:GetAbility():GetAbilityDamageType(),
			damage_flags 	= self:GetAbility():GetAbilityTargetFlags(),
			attacker 		= caster,
			ability 		= self:GetAbility()
		}
		if v ~= target then
			damage_tabel.damage = damage_tabel.damage * disintegration
		end
		UnitDamageTarget(damage_tabel)
		caster:EmitSound("Hero_Tinker.LaserImpact")
	end
end

--------------------------------------------------------
--能源「 超负荷瓜装甲」
--------------------------------------------------------

ability_thdots_nitoriEx = {}



modifier_ability_thdots_nitoriEx = {}
modifier_ability_thdots_nitoriEx_talent6 = {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_nitoriEx","scripts/vscripts/abilities/abilitynitori.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_nitoriEx_talent6","scripts/vscripts/abilities/abilitynitori.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_nitoriEx_talent6:IsHidden() 		return true end
function modifier_ability_thdots_nitoriEx_talent6:IsPurgable()		return false end
function modifier_ability_thdots_nitoriEx_talent6:RemoveOnDeath() 	return false end
function modifier_ability_thdots_nitoriEx_talent6:IsDebuff()		return false end

modifier_ability_thdots_nitoriEx_talent1 = {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_nitoriEx_talent1","scripts/vscripts/abilities/abilitynitori.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_nitoriEx_talent1:IsHidden() 		return true end
function modifier_ability_thdots_nitoriEx_talent1:IsPurgable()		return false end
function modifier_ability_thdots_nitoriEx_talent1:RemoveOnDeath() 	return false end
function modifier_ability_thdots_nitoriEx_talent1:IsDebuff()		return false end



function modifier_ability_thdots_nitoriEx:IsHidden() 		return true end
function modifier_ability_thdots_nitoriEx:IsPurgable()		return false end
function modifier_ability_thdots_nitoriEx:RemoveOnDeath() 	return false end
function modifier_ability_thdots_nitoriEx:IsDebuff()		return false end

function ability_thdots_nitoriEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_nitoriEx"
end

function modifier_ability_thdots_nitoriEx:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_ability_thdots_nitoriEx:OnCreated()
	if IsServer() then
		-- local damage = self:GetCaster():GetAverageTrueAttackDamage(self:GetCaster()) * self:GetAbility():GetSpecialValueFor("spell_bonus")
		-- print(damage)
		self:StartIntervalThink(0.5)
	end
end

function modifier_ability_thdots_nitoriEx:OnIntervalThink()
	if not IsServer() then return end
	self:SetStackCount(self:GetCaster():GetAverageTrueAttackDamage(self:GetCaster()) * self:GetAbility():GetSpecialValueFor("spell_bonus"))
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_nitori_6") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_nitoriEx_talent6") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_nitoriEx_talent6",{})
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_nitori_1") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_nitoriEx_talent1") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_nitoriEx_talent1",{})
	end
end

function modifier_ability_thdots_nitoriEx:GetModifierBaseAttack_BonusDamage()
	return self:GetParent():GetIntellect() * self:GetAbility():GetSpecialValueFor("damage_bonus")
end

function modifier_ability_thdots_nitoriEx:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount()
end