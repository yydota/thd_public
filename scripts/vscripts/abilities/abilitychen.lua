--------------------------------------------------------
--方符「奇门遁甲」
--------------------------------------------------------
ability_thdots_chenEx = {}

function ability_thdots_chenEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_chenEx"
end

modifier_ability_thdots_chenEx = {}
LinkLuaModifier("modifier_ability_thdots_chenEx","scripts/vscripts/abilities/abilitychen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_chenEx:IsHidden() 		return false end
function modifier_ability_thdots_chenEx:IsPurgable()		return false end
function modifier_ability_thdots_chenEx:RemoveOnDeath() 	return false end
function modifier_ability_thdots_chenEx:IsDebuff()		return false end

function modifier_ability_thdots_chenEx:DeclareFunctions()
	return
	{
		-- MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
	}
end

function modifier_ability_thdots_chenEx:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.03)
end
function modifier_ability_thdots_chenEx:OnIntervalThink()
	if not IsServer() then return end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_cheng_1") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_chenEx_telent_1") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_chenEx_telent_1",{})
	end
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_cheng_2") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_chenEx_telent_2") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_chenEx_telent_2",{})
	end
end

-- function modifier_ability_thdots_chenEx:GetModifierTotal_ConstantBlock(kv)
function modifier_ability_thdots_chenEx:GetModifierPhysical_ConstantBlock(kv)
	if not IsServer() then return end
	if kv.attacker == nil then return end
	local defence = kv.damage * self:GetAbility():GetSpecialValueFor("reduce") / 100
	if FindTelentValue(self:GetParent(),"special_bonus_unique_cheng_4") ~= 0 then
		-- print("0")
		return defence
	else
		if kv.attacker:IsHero() then
			-- print("1")
			return 0
		elseif kv.attacker:IsCreep() then
			if kv.attacker:IsNeutralUnitType() or kv.attacker:IsBuilding() then
			-- print("2")
				return defence
			else
			-- print("3")
				return 0
			end
		else
			-- print("4")
			return defence
		end
	end
end

modifier_ability_thdots_chenEx_telent_1 = modifier_ability_thdots_chenEx_telent_1 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_chenEx_telent_1","scripts/vscripts/abilities/abilitychen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_chenEx_telent_1:IsHidden() 		return true end
function modifier_ability_thdots_chenEx_telent_1:IsPurgable()		return false end
function modifier_ability_thdots_chenEx_telent_1:RemoveOnDeath() 	return false end
function modifier_ability_thdots_chenEx_telent_1:IsDebuff()		return false end

modifier_ability_thdots_chenEx_telent_2 = modifier_ability_thdots_chenEx_telent_2 or {}  --天赋监听
LinkLuaModifier("modifier_ability_thdots_chenEx_telent_2","scripts/vscripts/abilities/abilitychen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_chenEx_telent_2:IsHidden() 		return true end
function modifier_ability_thdots_chenEx_telent_2:IsPurgable()		return false end
function modifier_ability_thdots_chenEx_telent_2:RemoveOnDeath() 	return false end
function modifier_ability_thdots_chenEx_telent_2:IsDebuff()		return false end

--------------------------------------------------------
--滚符「滚球」
--------------------------------------------------------
ability_thdots_chen01 = {}

function ability_thdots_chen01:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_ability_thdots_chenEx_telent_1") then
		return self.BaseClass.GetCooldown(self, level) - 3
	else
		return self.BaseClass.GetCooldown(self, level)
	end
end


function ability_thdots_chen01:OnSpellStart()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.cast_range 					= self:GetSpecialValueFor("cast_range")
	self.point = self:GetCursorPosition()
	self.point = DecideMaxRange(self.caster,self.point,self.cast_range)
	self.caster:AddNewModifier(self.caster, self, "modifier_ability_thdots_chen01", {duration = 1})
end

modifier_ability_thdots_chen01 = {}
LinkLuaModifier("modifier_ability_thdots_chen01","scripts/vscripts/abilities/abilitychen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_chen01:IsHidden() 		return true end
function modifier_ability_thdots_chen01:IsPurgable()		return false end
function modifier_ability_thdots_chen01:RemoveOnDeath() 	return true end
function modifier_ability_thdots_chen01:IsDebuff()		return false end

function modifier_ability_thdots_chen01:OnCreated()
	if not IsServer() then return end
	self.caster 						= self:GetParent()
	self.attackspeed_bonus 				= self:GetAbility():GetSpecialValueFor("attackspeed_bonus")
	self.duration 						= self:GetAbility():GetSpecialValueFor("duration")
	self.point 							= self:GetAbility().point
	if self.caster:GetName() == "npc_dota_hero_terrorblade" then
		self.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1,2)
	end
	self:SetStackCount(1)
	self:StartIntervalThink(0.03)
end
function modifier_ability_thdots_chen01:OnIntervalThink()
	if not IsServer() then return end
	local vec = (self.point - self.caster:GetAbsOrigin()):Normalized()
	local velocity = 40 -- 速度
	if (self.caster:GetOrigin() - self.point):Length2D() <= 21 then
		FindClearSpaceForUnit(self.caster,self.caster:GetOrigin(),true)
		self:Destroy()
	else
		self.caster:SetAbsOrigin(self.caster:GetAbsOrigin() + vec * velocity) 
	end
end

function modifier_ability_thdots_chen01:OnDestroy()
	if not IsServer() then return end
	if self.caster:GetName() == "npc_dota_hero_terrorblade" then
		self.caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
	end
	self.caster:AddNewModifier(self.caster, self:GetAbility(), "modifier_ability_thdots_chen01_buff",{duration = self.duration})
	FindClearSpaceForUnit(self.caster,self.caster:GetAbsOrigin(),true)
	if self.caster:HasModifier("modifier_ability_thdots_chen03") then
		local ability 						= self.caster:FindAbilityByName("ability_thdots_chen03")
		local damage 						= ability:GetSpecialValueFor("damage")
		local radius 						= ability:GetSpecialValueFor("radius")
		local duration 						= ability:GetSpecialValueFor("duration")
		local int_bonus 					= ability:GetSpecialValueFor("int_bonus")
		OnChen03PassiveStart(self.caster,ability,damage,radius,int_bonus,duration)
	end
end

function modifier_ability_thdots_chen01:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] 	= true,
		[MODIFIER_STATE_ROOTED]		= true,
	}
end


modifier_ability_thdots_chen01_buff = {}
LinkLuaModifier("modifier_ability_thdots_chen01_buff","scripts/vscripts/abilities/abilitychen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_chen01_buff:IsHidden() 		return false end
function modifier_ability_thdots_chen01_buff:IsPurgable()		return false end
function modifier_ability_thdots_chen01_buff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_chen01_buff:IsDebuff()		return false end

function modifier_ability_thdots_chen01_buff:DeclareFunctions()
	return{
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_ability_thdots_chen01_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attackspeed_bonus")
end

--------------------------------------------------------
--阴阳「晴明大纹」
--------------------------------------------------------
ability_thdots_chen02 = {}

function ability_thdots_chen02:GetCastRange(location, target)
	if self:GetCaster():HasModifier("modifier_ability_thdots_chenEx_telent_2") then
		return self:GetSpecialValueFor("talent_range")
	else
		return self.BaseClass.GetCastRange(self, location, target)
	end
end

function ability_thdots_chen02:OnSpellStart()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.target 						= self:GetCursorTarget()
	self.wait_time 						= self:GetSpecialValueFor("wait_time")
	if is_spell_blocked(self.target) then return end
	self.target:EmitSound("Hero_Silencer.LastWord.Target")
	self.target:AddNewModifier(self.caster, self, "modifier_ability_thdots_chen02_target", {duration = self.wait_time})
	local chen02 = self.caster:AddNewModifier(self.caster, self, "modifier_ability_thdots_chen02", {duration = self.wait_time + 1})
	chen02.target = self.target 
end

modifier_ability_thdots_chen02_target = {}
LinkLuaModifier("modifier_ability_thdots_chen02_target","scripts/vscripts/abilities/abilitychen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_chen02_target:IsHidden() 		return false end
function modifier_ability_thdots_chen02_target:IsPurgable()		return true end
function modifier_ability_thdots_chen02_target:RemoveOnDeath() 	return false end
function modifier_ability_thdots_chen02_target:IsDebuff()		return true end

function modifier_ability_thdots_chen02_target:GetEffectName()
	return "particles/units/heroes/hero_silencer/silencer_last_word_status.vpcf"
end

function modifier_ability_thdots_chen02_target:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ability_thdots_chen02_target:OnCreated()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.target 						= self:GetParent()
	self.damage 						= self:GetAbility():GetSpecialValueFor("damage")
	self.wait_time 						= self:GetAbility():GetSpecialValueFor("wait_time")
	self.duration 						= self:GetAbility():GetSpecialValueFor("duration")
	self.duration_stun 					= self:GetAbility():GetSpecialValueFor("duration_stun")
	local damage_tabel = {
					victim 			= self.target,
					-- Damage starts ramping from when cast time starts, so just gonna simiulate the effects by adding the cast point
					damage 			= self.damage,
					damage_type		= self:GetAbility():GetAbilityDamageType(),
					damage_flags 	= self:GetAbility():GetAbilityTargetFlags(),
					attacker 		= self.caster,
					ability 		= self:GetAbility()
				}
	UnitDamageTarget(damage_tabel)
	self:StartIntervalThink(0.03)
end

function modifier_ability_thdots_chen02_target:OnIntervalThink()
	if not IsServer() then return end
	print(self.wait_time)
	self.wait_time = self.wait_time - 0.03
	if self.wait_time <= 0.03 or not self.target:IsAlive() then
		if self:GetStackCount() == 1 then
			--眩晕
			UtilStun:UnitStunTarget(self.caster,self.target,self.duration_stun)
		else
			--沉默
			self.target:AddNewModifier(self.caster, self:GetAbility(), "modifier_ability_thdots_chen02_debuff",{duration = self.duration})
		end
		self.target:EmitSound("Hero_Silencer.LastWord.Damage")
		local damage = self.damage
		local damage_tabel = {
						victim 			= self.target,
						-- Damage starts ramping from when cast time starts, so just gonna simiulate the effects by adding the cast point
						damage 			= damage,
						damage_type		= self:GetAbility():GetAbilityDamageType(),
						damage_flags 	= self:GetAbility():GetAbilityTargetFlags(),
						attacker 		= self.caster,
						ability 		= self:GetAbility()
					}
		UnitDamageTarget(damage_tabel)
		if self.caster:HasModifier("modifier_ability_thdots_chen03") then
			local ability 						= self.caster:FindAbilityByName("ability_thdots_chen03")
			local damage 						= ability:GetSpecialValueFor("damage")
			local radius 						= ability:GetSpecialValueFor("radius")
			local duration 						= ability:GetSpecialValueFor("duration")
			local int_bonus 					= ability:GetSpecialValueFor("int_bonus")
			OnChen03PassiveStart(self.caster,ability,damage,radius,int_bonus,duration)
		end
		self:Destroy()
	end
end

function modifier_ability_thdots_chen02_target:DeclareFunctions()
	return{
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
end

function modifier_ability_thdots_chen02_target:OnAbilityExecuted(keys)
	if not IsServer() then return end
	if keys.unit ~= self.target or keys.ability:IsItem() or keys.ability:IsToggle() then
		return
	end
	self:SetStackCount(1)
end


modifier_ability_thdots_chen02_debuff = {}
LinkLuaModifier("modifier_ability_thdots_chen02_debuff","scripts/vscripts/abilities/abilitychen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_chen02_debuff:IsHidden() 		return false end
function modifier_ability_thdots_chen02_debuff:IsPurgable()		return true end
function modifier_ability_thdots_chen02_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_chen02_debuff:IsDebuff()		return true end

function modifier_ability_thdots_chen02_debuff:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
	}
end

modifier_ability_thdots_chen02 = {}
LinkLuaModifier("modifier_ability_thdots_chen02","scripts/vscripts/abilities/abilitychen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_chen02:IsHidden() 		return true end
function modifier_ability_thdots_chen02:IsPurgable()		return false end
function modifier_ability_thdots_chen02:RemoveOnDeath() 	return false end
function modifier_ability_thdots_chen02:IsDebuff()		return false end
--------------------------------------------------------
--天符「天仙鸣动」
--------------------------------------------------------
ability_thdots_chen03 = {}

function ability_thdots_chen03:GetIntrinsicModifierName()
	return "modifier_ability_thdots_chen03"
end

modifier_ability_thdots_chen03 = {}
LinkLuaModifier("modifier_ability_thdots_chen03","scripts/vscripts/abilities/abilitychen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_chen03:IsHidden() 		return false end
function modifier_ability_thdots_chen03:IsPurgable()		return false end
function modifier_ability_thdots_chen03:RemoveOnDeath() 	return false end
function modifier_ability_thdots_chen03:IsDebuff()		return false end

function modifier_ability_thdots_chen03:OnCreated()
	if not IsServer() then return end
end

function modifier_ability_thdots_chen03:DeclareFunctions()
	return{
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
end

function modifier_ability_thdots_chen03:OnAbilityExecuted(keys)
	if not IsServer() then return end
	if keys.ability:GetName() == "ability_thdots_chen01" or 
		keys.ability:GetName() == "ability_thdots_chen02" or
		keys.ability:GetName() == "ability_thdots_chen04"
		then return
	end
	self.caster 						= self:GetParent()
	self.damage 						= self:GetAbility():GetSpecialValueFor("damage")
	self.radius 						= self:GetAbility():GetSpecialValueFor("radius")
	self.duration 						= self:GetAbility():GetSpecialValueFor("duration")
	-- self.int_bonus 						= self:GetAbility():GetSpecialValueFor("int_bonus")
	self.ability 						= self:GetAbility()
	if keys.unit ~= self.caster or keys.ability:IsItem() then
		return
	end
	--主动触发3技能
	if keys.ability:GetName() == "ability_thdots_chen03" then
		self.damage = self.damage * 2
		self.radius = self.radius * 2
	end
	OnChen03PassiveStart(self.caster,self.ability,self.damage,self.radius,self.int_bonus,self.duration)
end

function OnChen03PassiveStart(caster,ability,damage,radius,int_bonus,duration)
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius,
					ability:GetAbilityTargetTeam(),ability:GetAbilityTargetType(),0,0,false)
	local damage = damage + FindTelentValue(caster,"special_bonus_unique_cheng_3")
	local earthshock_particle = "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf"
	local earthshock_particle_fx = ParticleManager:CreateParticle(earthshock_particle, PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl(earthshock_particle_fx, 0,caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(earthshock_particle_fx, 1, Vector(radius+200,radius/2+100,1))
	ParticleManager:ReleaseParticleIndex(earthshock_particle_fx)
	caster:EmitSound("Hero_MonkeyKing.Spring.Target")
	for _,v in pairs(targets) do
		v:AddNewModifier(caster, ability, "modifier_ability_thdots_chen03_debuff",{duration = duration})
		local damage_tabel = {
					victim 			= v,
					-- Damage starts ramping from when cast time starts, so just gonna simiulate the effects by adding the cast point
					damage 			= damage,
					damage_type		= ability:GetAbilityDamageType(),
					damage_flags 	= ability:GetAbilityTargetFlags(),
					attacker 		= caster,
					ability 		= ability
				}
		UnitDamageTarget(damage_tabel)
	end
end

function ability_thdots_chen03:OnSpellStart()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
end

modifier_ability_thdots_chen03_debuff = {}
LinkLuaModifier("modifier_ability_thdots_chen03_debuff","scripts/vscripts/abilities/abilitychen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_chen03_debuff:IsHidden() 		return false end
function modifier_ability_thdots_chen03_debuff:IsPurgable()		return true end
function modifier_ability_thdots_chen03_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_chen03_debuff:IsDebuff()		return true end
function modifier_ability_thdots_chen03_debuff:GetAttributes() 	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_ability_thdots_chen03_debuff:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_earthshock_modifier.vpcf"
end

function modifier_ability_thdots_chen03_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ability_thdots_chen03_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_ability_thdots_chen03_debuff:GetModifierDamageOutgoing_Percentage()
	return -self:GetAbility():GetSpecialValueFor("damage_reduce")
end

function modifier_ability_thdots_chen03_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("movespeed_reduce")
end

--------------------------------------------------------
--仙符「尸解永远」
--------------------------------------------------------
ability_thdots_chen04 = {}

function ability_thdots_chen04:OnSpellStart()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.duration 						= self:GetSpecialValueFor("duration")
	self.caster:AddNewModifier(self.caster, self, "modifier_ability_thdots_chen04", {duration = self.duration})
end

modifier_ability_thdots_chen04 = {}
LinkLuaModifier("modifier_ability_thdots_chen04","scripts/vscripts/abilities/abilitychen.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_chen04:IsHidden() 		return false end
function modifier_ability_thdots_chen04:IsPurgable()		return false end
function modifier_ability_thdots_chen04:RemoveOnDeath() 	return true end
function modifier_ability_thdots_chen04:IsDebuff()		return false end

function modifier_ability_thdots_chen04:OnRefresh()
	if not IsServer() then return end
	self.caster 						= self:GetParent()
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf",PATTACH_ROOTBONE_FOLLOW,self.caster)
	ParticleManager:ReleaseParticleIndex(particle)
	self.caster:EmitSound("Voice_Thdots_Chen.AbilityChen04_1")
	self.caster:EmitSound("Voice_Thdots_Chen.AbilityChen04_2")
end
function modifier_ability_thdots_chen04:OnCreated()
	if not IsServer() then return end
	self.caster 						= self:GetParent()
	self.attack_bonus 					= self:GetAbility():GetSpecialValueFor("attack_bonus")
	self.duration 						= self:GetAbility():GetSpecialValueFor("duration")

	self.caster:EmitSound("Voice_Thdots_Chen.AbilityChen04_1")
	self.caster:EmitSound("Voice_Thdots_Chen.AbilityChen04_2")

	--特效
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf",PATTACH_ROOTBONE_FOLLOW,self.caster)
	ParticleManager:ReleaseParticleIndex(particle)

	local particle_cast = 	"particles/econ/items/lycan/blood_moon/lycan_blood_moon_weapon_ambient.vpcf"
	local effect_cast_1 = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self:GetParent())
	-- local effect_cast_2 = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self:GetParent())
	local attach_1 = "attach_attack1"
	local attach_2 = "attach_attack2"
	ParticleManager:SetParticleControlEnt(effect_cast_1,1,self.caster,PATTACH_POINT_FOLLOW,attach_2,Vector(0,0,0),true)
	ParticleManager:SetParticleControlEnt(effect_cast_1,2,self.caster,PATTACH_POINT_FOLLOW,attach_2,Vector(0,0,0),true)
	ParticleManager:SetParticleControlEnt(effect_cast_1,3,self.caster,PATTACH_POINT_FOLLOW,attach_2,Vector(0,0,0),true)
	ParticleManager:SetParticleControlEnt(effect_cast_1,4,self.caster,PATTACH_POINT_FOLLOW,attach_1,Vector(0,0,0),true)
	ParticleManager:SetParticleControlEnt(effect_cast_1,5,self.caster,PATTACH_POINT_FOLLOW,attach_1,Vector(0,0,0),true)
	ParticleManager:SetParticleControlEnt(effect_cast_1,6,self.caster,PATTACH_POINT_FOLLOW,attach_1,Vector(0,0,0),true)
	-- ParticleManager:SetParticleControlEnt(effect_cast_1,10,self.caster,PATTACH_POINT_FOLLOW,attach_1,Vector(0,0,0),true)
	-- ParticleManager:SetParticleControlEnt(effect_cast_2,1,self.caster,PATTACH_POINT_FOLLOW,attach_2,Vector(0,0,0),true)
	self:AddParticle(
		effect_cast_1,
		false,
		false,
		-1,
		false,
		false
	)
	-- self:AddParticle(
	-- 	effect_cast_2,
	-- 	false,
	-- 	false,
	-- 	-1,
	-- 	false,
	-- 	false
	-- )
	-- local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_totem_cast.vpcf", PATTACH_ABSORIGIN, self.caster)
	-- ParticleManager:ReleaseParticleIndex(effect_cast)
end

function modifier_ability_thdots_chen04:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_ability_thdots_chen04:OnAttackLanded(keys)
	if not IsServer() then return end
	if not (keys.attacker == self:GetParent()) then return end
	if keys.target:IsHero() then
		-- EmitSoundOn("Hero_Riki.Backstab",self:GetParent())
		EmitSoundOn("Hero_Riki.Invisibility",self:GetParent())
		self:SetDuration(self.duration,true)
		self:IncrementStackCount()
	end
end

function modifier_ability_thdots_chen04:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("attack_bonus") * self:GetStackCount()
end

function modifier_ability_thdots_chen04:OnDestroy()
	if not IsServer() then return end
	if self:GetParent():HasModifier("modifier_ability_thdots_chen03") then
		local ability 						= self:GetParent():FindAbilityByName("ability_thdots_chen03")
		local damage 						= ability:GetSpecialValueFor("damage")
		local radius 						= ability:GetSpecialValueFor("radius")
		local duration 						= ability:GetSpecialValueFor("duration")
		local int_bonus 					= ability:GetSpecialValueFor("int_bonus")
		OnChen03PassiveStart(self:GetParent(),ability,damage,radius,int_bonus,duration)
	end
end



