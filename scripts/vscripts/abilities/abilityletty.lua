--------------------------------------------------------
--冬符「蕾蒂之心」
--------------------------------------------------------
ability_thdots_lettyEx = {}

function ability_thdots_lettyEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_lettyEx"
end

modifier_ability_thdots_lettyEx = {}
LinkLuaModifier("modifier_ability_thdots_lettyEx","scripts/vscripts/abilities/abilityletty.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_lettyEx:IsHidden() 		return false end
function modifier_ability_thdots_lettyEx:IsPurgable()		return false end
function modifier_ability_thdots_lettyEx:RemoveOnDeath() 	return false end
function modifier_ability_thdots_lettyEx:IsDebuff()		return false end

function modifier_ability_thdots_lettyEx:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end

function modifier_ability_thdots_lettyEx:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("resistance_bonus") * self:GetStackCount()
end

function modifier_ability_thdots_lettyEx:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("armor_bonus") * self:GetStackCount()
end


function modifier_ability_thdots_lettyEx:GetModifierTotal_ConstantBlock(kv)
	if not IsServer() then return end
	if kv.attacker:IsHero() then
		return 0
	else
		print(kv.damage * self:GetAbility():GetSpecialValueFor("imcome_damage") / 100)
	end
end

function modifier_ability_thdots_lettyEx:OnCreated()
	if not IsServer() then return end
	self.caster 		= self:GetCaster()
	self.point 			= self:GetCaster():GetOrigin()
	self.active_time 	= self:GetAbility():GetSpecialValueFor("active_time")
	self.react_time		= 0
 	self:StartIntervalThink(1)
end

function modifier_ability_thdots_lettyEx:OnIntervalThink()
	if not IsServer() then return end
	-- print("--------------")
	self.count = self:GetAbility():GetSpecialValueFor("count") + FindTelentValue(self:GetCaster(),"special_bonus_unique_letty_3")
	if self.caster:GetOrigin() == self.point then
		-- print(self.react_time)
		-- print(self.active_time)
		-- print(self:GetStackCount())
		-- print(self.count)
		if self.react_time >= self.active_time and self:GetStackCount() < self.count then
			self:IncrementStackCount()
			self.react_time = 0
		end
		self.react_time = self.react_time + 1
	else
		self.point = self.caster:GetOrigin()
		self:SetStackCount(0)
		self.react_time = 0
	end

	if FindTelentValue(self:GetCaster(),"special_bonus_unique_letty_1") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_lettyEx_talent_1") then
		self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_lettyEx_talent_1",{})
	end

end


modifier_ability_thdots_lettyEx_talent_1 = {}
LinkLuaModifier("modifier_ability_thdots_lettyEx_talent_1","scripts/vscripts/abilities/abilityletty.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_lettyEx_talent_1:IsHidden() 		return false end
function modifier_ability_thdots_lettyEx_talent_1:IsPurgable()		return false end
function modifier_ability_thdots_lettyEx_talent_1:RemoveOnDeath() 	return false end
function modifier_ability_thdots_lettyEx_talent_1:IsDebuff()		return false end

--------------------------------------------------------
--冬符「花之凋零]
--------------------------------------------------------
ability_thdots_letty01 = {}


function ability_thdots_letty01:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_letty01:GetAOERadius()
	if self:GetCaster():HasModifier("modifier_ability_thdots_lettyEx_talent_1") then
		return self:GetSpecialValueFor("radius") + 200
	else
		return self:GetSpecialValueFor("radius")
	end
end

function ability_thdots_letty01:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	self.damage = self:GetSpecialValueFor("damage")
	self.caster = self:GetCaster()
	self.radius = self:GetSpecialValueFor("radius") + FindTelentValue(self:GetCaster(),"special_bonus_unique_letty_1")
	self.explosion_interval = 1
	self.frametime = 0
	self.point = self:GetCursorPosition()

	self.freezing_field_aura = CreateModifierThinker(caster, self, "modifier_ability_thdots_letty01", {duration = duration}, self.point, caster:GetTeamNumber(), false)
	self.freezing_field_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", PATTACH_CUSTOMORIGIN, self.freezing_field_aura)

	ParticleManager:SetParticleControl(self.freezing_field_particle, 0, self.point)
	ParticleManager:SetParticleControl(self.freezing_field_particle, 1, Vector (self.radius, 0, 0))
	ParticleManager:SetParticleControl(self.freezing_field_particle, 5, Vector (self.radius, 0, 0))
	caster:EmitSound("hero_Crystal.freezingField.wind")

end

function ability_thdots_letty01:OnChannelThink()
	if not IsServer() then return end
	self.frametime = self.frametime + FrameTime()
	if self.frametime >= self.explosion_interval then
		self.frametime = 0
		local caster = self.caster
		local damage = self.damage
		local point = self.point
		local radius = self.radius
		local targets = FindUnitsInRadius(caster:GetTeam(), point,nil,radius,self:GetAbilityTargetTeam(),
			self:GetAbilityTargetType(),0,0,false)
		--特效音效
		for i=0,math.floor(radius/50) do
			local random_point = Vector(point.x + RandomInt(-radius, radius),point.y + RandomInt(-radius/2, radius),0)
			local particle_name =  "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf"
			local fxIndex = ParticleManager:CreateParticle(particle_name, PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(fxIndex, 0, random_point)
			ParticleManager:SetParticleControl(fxIndex, 1, random_point)
			ParticleManager:ReleaseParticleIndex(fxIndex)
		end

		EmitSoundOnLocationWithCaster(point, "hero_Crystal.freezingField.explosion", self:GetCaster())

		self:SetContextThink("letty01",function ()
			-- body
			for _,v in pairs (targets) do
				local damage_tabel = {
						victim 			= v,
						damage 			= damage,
						damage_type		= self:GetAbilityDamageType(),
						attacker 		= caster,
						ability 		= self
					}
				UnitDamageTarget(damage_tabel)
			end
		end,0.4)
	end
end

function ability_thdots_letty01:OnChannelFinish()
	if not IsServer() then return end
	-- print(self.freezing_field_aura:GetRemainingTime())
	-- self.freezing_field_aura:Destroy()
	self:StopSound("hero_Crystal.freezingField.wind")
	ParticleManager:DestroyParticle(self.freezing_field_particle, false)
	ParticleManager:ReleaseParticleIndex(self.freezing_field_particle)
end


modifier_ability_thdots_letty01 = {}
LinkLuaModifier("modifier_ability_thdots_letty01","scripts/vscripts/abilities/abilityletty.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_letty01:IsHidden() 		return false end
function modifier_ability_thdots_letty01:IsPurgable()		return false end
function modifier_ability_thdots_letty01:RemoveOnDeath() 	return false end
function modifier_ability_thdots_letty01:IsDebuff()		return false end

-- function modifier_ability_thdots_letty01:OnCreated()
-- 	if not IsServer() then return end
-- 	self.caster = self:GetCaster()
-- 	self.radius = self:GetAbility():GetSpecialValueFor("radius")
-- 	self.damage = self:GetAbility():GetSpecialValueFor("damage")
-- 	local duration = self:GetAbility():GetSpecialValueFor("duration")
-- 	print(self.point)
-- 	-- self:StartIntervalThink(1)
-- end

-- function modifier_ability_thdots_letty01:OnDestroy()
-- 	if not IsServer() then return end
-- 	ParticleManager:DestroyParticle(self.freezing_field_particle, false)
-- 	ParticleManager:ReleaseParticleIndex(self.freezing_field_particle)
-- end

-- function modifier_ability_thdots_letty01:OnIntervalThink()
-- 	if not IsServer() then return end
-- 	local caster = self.caster
-- 	local ability = self:GetAbility()
-- 	local damage = self.damage
-- 	local point = self:GetAbility().point
-- 	local targets = FindUnitsInRadius(caster:GetTeam(), point,nil,self.radius,ability:GetAbilityTargetTeam(),
-- 		ability:GetAbilityTargetType(),0,0,false)
-- 	--特效音效
-- 	local particle_name =  "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf"
-- 	local fxIndex = ParticleManager:CreateParticle(particle_name, PATTACH_CUSTOMORIGIN, caster)
-- 	ParticleManager:SetParticleControl(fxIndex, 0, point)
-- 	ParticleManager:SetParticleControl(fxIndex, 1, point)
-- 	ParticleManager:ReleaseParticleIndex(fxIndex)

-- 	print("do it")
-- 	for _,v in pairs (targets) do
-- 		local damage_tabel = {
-- 				victim 			= v,
-- 				damage 			= damage,
-- 				damage_type		= ability:GetAbilityDamageType(),
-- 				damage_flags 	= ability:GetAbilityTargetFlags(),
-- 				attacker 		= caster,
-- 				ability 		= ability
-- 			}
-- 		UnitDamageTarget(damage_tabel)
-- 	end
-- end

--------------------------------------------------------
--白符「波光]
--------------------------------------------------------
ability_thdots_letty02 = {}


function ability_thdots_letty02:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_letty02:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local player = caster:GetPlayerID()
	local duration = self:GetSpecialValueFor("duration")
	local number = self:GetSpecialValueFor("number")
	local speed = self:GetSpecialValueFor("speed")
	local cast_range = self:GetSpecialValueFor("cast_range")

	local point = caster:GetOrigin() + caster:GetForwardVector() * cast_range
	local angle = 360/number
	local qangle = QAngle(0, angle, 0)
	point = RotatePosition(caster:GetAbsOrigin(), qangle, point)

	self.start_point = self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_attack1"))
	--音效
	caster:EmitSound("Hero_Lich.ChainFrost")
	
	for i=0,number do
		-- local dummy = CreateUnitByName("npc_dota_hero_winter_wyvern", 
		local dummy = CreateUnitByName("npc_dummy_unit", 
	    	                        self.start_point, 
									false, 
								    caster, 
									caster, 
									caster:GetTeamNumber()
									)
		-- dummy:SetPlayerID(caster:GetPlayerID())
		-- dummy:SetControllableByPlayer(player, true)
		dummy:AddNewModifier(caster, self, "modifier_ability_thdots_letty02_dummy",{duration = 5})
		dummy.letty02_point = point
		point = RotatePosition(caster:GetAbsOrigin(), qangle, point)
		qangle = QAngle(0, angle, 0)
	end
end


modifier_ability_thdots_letty02_dummy = {}
LinkLuaModifier("modifier_ability_thdots_letty02_dummy","scripts/vscripts/abilities/abilityletty.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_letty02_dummy:IsHidden() 		return false end
function modifier_ability_thdots_letty02_dummy:IsPurgable()		return false end
function modifier_ability_thdots_letty02_dummy:RemoveOnDeath() 	return false end
function modifier_ability_thdots_letty02_dummy:IsDebuff()		return false end
function modifier_ability_thdots_letty02_dummy:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_ability_thdots_letty02_dummy:OnCreated()
	if not IsServer() then return end
	-- body
	self.caster 				= self:GetCaster()
	self.start_point 			= self:GetAbility().start_point
	self.stun_duration 			= self:GetAbility():GetSpecialValueFor("stun_duration") + FindTelentValue(self:GetCaster(),"special_bonus_unique_letty_2")
	self.damage 				= self:GetAbility():GetSpecialValueFor("damage")
	self.limit 					= self:GetAbility():GetSpecialValueFor("limit")
	self.speed 					= self:GetAbility():GetSpecialValueFor("speed") * FrameTime()
	self.angle = 0
	local dummy = self:GetParent()
	local particle = "particles/units/heroes/hero_lich/lich_chain_frost.vpcf"
	self.fxIndex = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, dummy)
	-- ParticleManager:SetParticleControl(self.fxIndex, 0, dummy:GetOrigin())
	ParticleManager:SetParticleControlEnt(self.fxIndex , 0, dummy, 5, "attach_hitloc", Vector(0,0,0), true)
	-- ParticleManager:DestroyParticleSystemTime(effectIndex,keys.Duration)
	ParticleManager:SetParticleControl(self.fxIndex, 0, dummy:GetOrigin())
	ParticleManager:SetParticleControl(self.fxIndex, 1, dummy:GetOrigin())
	ParticleManager:SetParticleControl(self.fxIndex, 2, Vector(2000,0,0))
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_letty02_dummy:OnIntervalThink()
	if not IsServer() then return end
	local caster = self.caster
	local dummy = self:GetParent()
	local ability = self:GetAbility()
	local qangle = QAngle(0, 30, 0)
	local add_increase		= 1	--递增角度
	local max_angel			= 10--最大发射角度
	if self.angle <= max_angel then
		self.angle = self.angle + add_increase
	else
		self.angle = -self.angle
		self.angle = self.angle - add_increase
	end
	qangle = QAngle(0, self.angle, 0)
	local direct = (dummy.letty02_point - dummy:GetOrigin()):Normalized()
	dummy.letty02_point = RotatePosition(self.start_point, qangle, dummy.letty02_point)

	ParticleManager:SetParticleControl(self.fxIndex, 1, dummy:GetOrigin())
	-- ParticleManager:SetParticleControl(self.fxIndex, 0, dummy:GetOrigin())
	-- ParticleManager:SetParticleControl(self.fxIndex, 2, Vector(2000,0,0))


	--冰冻伤害
	local targets = FindUnitsInRadius(caster:GetTeam(), dummy:GetOrigin(),nil,128,ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),0,0,false)
	DeleteDummy(targets)
	for _,v in pairs(targets) do
		if not v:HasModifier("modifier_ability_thdots_letty02_debuff") and not IsTHDImmune(v) then
			v:AddNewModifier(caster, ability, "modifier_ability_thdots_letty02_debuff", {duration = self.stun_duration})
			self.limit = self.limit - 1
			if self.limit <= 0 then
				self:Destroy()
				return
			end
		end
	end

	--移动
	local next_point = dummy:GetOrigin() + direct * self.speed
	next_point.z = self.start_point.z
	dummy:SetOrigin(next_point)
	if ( dummy:GetOrigin() - self.start_point):Length2D() > 700 then
		self:Destroy()
	end
end

function modifier_ability_thdots_letty02_dummy:OnDestroy()
	if not IsServer() then return end
	local dummy = self:GetParent()
	dummy:EmitSound("Hero_Lich.ChainFrostImpact.Creep")
	dummy:RemoveSelf()
	-- ParticleManager:DestroyParticleSystem(self.fxIndex,true)
	ParticleManager:ReleaseParticleIndex(self.fxIndex)
end

modifier_ability_thdots_letty02_debuff = {}
LinkLuaModifier("modifier_ability_thdots_letty02_debuff","scripts/vscripts/abilities/abilityletty.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_letty02_debuff:IsHidden() 		return false end
function modifier_ability_thdots_letty02_debuff:IsPurgable()		return true end
function modifier_ability_thdots_letty02_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_letty02_debuff:IsDebuff()		return true end

function modifier_ability_thdots_letty02_debuff:GetEffectName() return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf" end
function modifier_ability_thdots_letty02_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end


function modifier_ability_thdots_letty02_debuff:CheckState() --冻结
	return {
		[MODIFIER_STATE_STUNNED] = true,
	}
end

function modifier_ability_thdots_letty02_debuff:OnRefresh(keys)
	if not IsServer() then return end
	self:OnCreated(keys)
end

function modifier_ability_thdots_letty02_debuff:OnCreated()
	if not IsServer() then return end
	-- body
	local caster 				= self:GetCaster()
	local target 				= self:GetParent()
	local ability 				= self:GetAbility()
	local damage 				= self:GetAbility():GetSpecialValueFor("damage")


	self:GetParent():EmitSound("Hero_Crystal.Frostbite")
	local damage_tabel = {
				victim 			= target,
				damage 			= damage,
				damage_type		= ability:GetAbilityDamageType(),
				attacker 		= caster,
				ability 		= ability
			}
	UnitDamageTarget(damage_tabel)
end

--------------------------------------------------------
--「霜心之大地」
--------------------------------------------------------
ability_thdots_letty03 = {}

function ability_thdots_letty03:GetIntrinsicModifierName()
	return "modifier_ability_thdots_letty03"
end

modifier_ability_thdots_letty03 = {}
LinkLuaModifier("modifier_ability_thdots_letty03","scripts/vscripts/abilities/abilityletty.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_letty03:IsHidden() 		return false end
function modifier_ability_thdots_letty03:IsPurgable()		return false end
function modifier_ability_thdots_letty03:RemoveOnDeath() 	return false end
function modifier_ability_thdots_letty03:IsDebuff()		return false end

function modifier_ability_thdots_letty03:GetEffectName() return "particles/generic_gameplay/generic_slowed_cold.vpcf" end
function modifier_ability_thdots_letty03:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_ability_thdots_letty03:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_ability_thdots_letty03:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("health_bonus")	
end


function modifier_ability_thdots_letty03:OnTakeDamage(keys)
	if not IsServer() then return end
	if keys.attacker:GetTeam() == keys.unit:GetTeam() then return end
	if keys.attacker == self:GetParent() and keys.damage_type == DAMAGE_TYPE_MAGICAL and self:GetStackCount() == 0 then
		local damage = self:GetAbility():GetSpecialValueFor("damage_perdamage")
		local duration = self:GetAbility():GetSpecialValueFor("duration")
		keys.unit:AddNewModifier(self:GetCaster(), self:GetAbility(),"modifier_ability_thdots_letty03_debuff", {duration = duration})
		if FindTelentValue(self:GetCaster(),"special_bonus_unique_letty_5") ~= 0 then
			damage = keys.unit:GetMaxHealth() * FindTelentValue(self:GetCaster(),"special_bonus_unique_letty_5") / 100
		end
		print(damage)
		--特效音效
		local damage_tabel = {
				victim 			= keys.unit,
				damage 			= damage,
				damage_type		= self:GetAbility():GetAbilityDamageType(),
				attacker 		= self:GetParent(),
				ability 		= self:GetAbility()
			}

		self:SetStackCount(1)
		UnitDamageTarget(damage_tabel)
		self:SetStackCount(0)
	end
end

modifier_ability_thdots_letty03_debuff = {}
LinkLuaModifier("modifier_ability_thdots_letty03_debuff","scripts/vscripts/abilities/abilityletty.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_letty03_debuff:IsHidden() 		return false end
function modifier_ability_thdots_letty03_debuff:IsPurgable()		return true end
function modifier_ability_thdots_letty03_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_letty03_debuff:IsDebuff()		return true end

function modifier_ability_thdots_letty03_debuff:GetEffectName() return "particles/generic_gameplay/generic_slowed_cold.vpcf" end
function modifier_ability_thdots_letty03_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_ability_thdots_letty03_debuff:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_ability_thdots_letty03_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("decrease_speed")
end

--------------------------------------------------------
--寒符「Cold Snap]
--------------------------------------------------------

ability_thdots_letty04 = {}

function ability_thdots_letty04:GetCastRange()
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_letty04:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local duration  			= self:GetSpecialValueFor("duration")
	self.radius  				= self:GetSpecialValueFor("radius")
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		self.radius = self.radius + 30000
	end
	-- caster:AddNewModifier(caster, self, "modifier_ability_thdots_letty04", {duration = duration})
	CreateModifierThinker(caster, self, "modifier_ability_thdots_letty04", {duration = duration}, caster:GetOrigin(), caster:GetTeamNumber(), false)

end

modifier_ability_thdots_letty04 = {}
LinkLuaModifier("modifier_ability_thdots_letty04","scripts/vscripts/abilities/abilityletty.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_letty04:IsHidden() 		return false end
function modifier_ability_thdots_letty04:IsPurgable()		return false end
function modifier_ability_thdots_letty04:RemoveOnDeath() 	return true end
function modifier_ability_thdots_letty04:IsDebuff()		return false end

function modifier_ability_thdots_letty04:GetAuraRadius() return self.radius end -- global
function modifier_ability_thdots_letty04:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_ability_thdots_letty04:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_ability_thdots_letty04:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
function modifier_ability_thdots_letty04:GetModifierAura() return "modifier_ability_thdots_letty04_debuff" end
function modifier_ability_thdots_letty04:IsAura() return true end

function modifier_ability_thdots_letty04:OnCreated()
	self.radius = self:GetAbility().radius
	if not IsServer() then return end
	local dummy = self:GetParent()
	local radius = self:GetAbility().radius
	local talent_effect_point = dummy:GetOrigin()
	--特效音效
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		talent_effect_point = Vector(0,0,0)
		EmitGlobalSound("hero_Crystal.freezingField.wind")
	end
	-- local particle = "particles/units/heroes/hero_lich/lich_chain_frost.vpcf"
	-- self.fxIndex = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN, dummy)
	-- -- ParticleManager:SetParticleControl(self.fxIndex, 0, dummy:GetOrigin())
	-- ParticleManager:SetParticleControlEnt(self.fxIndex , 0, dummy, 5, "attach_hitloc", Vector(0,0,0), true)
	-- -- ParticleManager:DestroyParticleSystemTime(effectIndex,keys.Duration)
	-- ParticleManager:SetParticleControl(self.fxIndex, 0, dummy:GetOrigin())
	
	self:GetParent():EmitSound("hero_Crystal.freezingField.wind")
	local particle_1 = "particles/units/heroes/hero_lich/lich_ice_spire.vpcf"
	local particle_2 = "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf"
	self.letty04_particle_1 = ParticleManager:CreateParticle(particle_1, PATTACH_CUSTOMORIGIN, dummy)
	self.letty04_particle_2 = ParticleManager:CreateParticle(particle_2, PATTACH_CUSTOMORIGIN, dummy)
	-- ParticleManager:SetParticleControl(self.fxIndex, 0, dummy:GetOrigin())
	ParticleManager:SetParticleControl(self.letty04_particle_1, 0, talent_effect_point)
	ParticleManager:SetParticleControl(self.letty04_particle_1, 1, talent_effect_point)
	ParticleManager:SetParticleControl(self.letty04_particle_1, 2, talent_effect_point)
	ParticleManager:SetParticleControl(self.letty04_particle_1, 3, talent_effect_point)
	ParticleManager:SetParticleControl(self.letty04_particle_1, 4, talent_effect_point)
	ParticleManager:SetParticleControl(self.letty04_particle_1, 5, Vector(radius,radius,radius))
	ParticleManager:SetParticleControl(self.letty04_particle_2, 0, talent_effect_point)
	ParticleManager:SetParticleControl(self.letty04_particle_2, 1, Vector(radius,0,0))
	ParticleManager:ReleaseParticleIndex(self.letty04_particle_1)
	ParticleManager:ReleaseParticleIndex(self.letty04_particle_2)
end

function modifier_ability_thdots_letty04:OnDestroy()
	if not IsServer() then return end
	self:GetParent():StopSound("hero_Crystal.freezingField.wind")
end

modifier_ability_thdots_letty04_debuff = {}
LinkLuaModifier("modifier_ability_thdots_letty04_debuff","scripts/vscripts/abilities/abilityletty.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_letty04_debuff:IsHidden() 		return false end
function modifier_ability_thdots_letty04_debuff:IsPurgable()		return true end
function modifier_ability_thdots_letty04_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_letty04_debuff:IsDebuff()		return true end

function modifier_ability_thdots_letty04_debuff:GetEffectName() return "particles/generic_gameplay/generic_slowed_cold.vpcf" end
function modifier_ability_thdots_letty04_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_ability_thdots_letty04_debuff:OnCreated()
	if not IsServer() then return end
	self.attak_speed = self:GetParent():GetDisplayAttackSpeed() * self:GetAbility():GetSpecialValueFor("decrease_aspeed") / 100
	--天赋禁疗
	if FindTelentValue(self:GetCaster(),"special_bonus_unique_letty_4") ~= 0 then
		self:SetStackCount(1)
	end
end


function modifier_ability_thdots_letty04_debuff:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_DISABLE_HEALING,
	}
end

function modifier_ability_thdots_letty04_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("decrease_mspeed")
end

function modifier_ability_thdots_letty04_debuff:GetDisableHealing()
	if self:GetStackCount() == 1 then
		return 1
	else
		return 0
	end
end

function modifier_ability_thdots_letty04_debuff:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		return self.attak_speed
	end
end