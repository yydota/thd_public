
--自定义函数

--函数作用：计算距离
--函数输入：1. 施法者 2.目标
--函数输出：距离
function calDistanceHero(caster,target)
    local vCaster= caster:GetAbsOrigin()
    local vTarget= target:GetAbsOrigin()
    return math.sqrt(((vTarget.x-vCaster.x)*(vTarget.x-vCaster.x))+((vTarget.y-vCaster.y)*(vTarget.y-vCaster.y)))
end

--函数作用：计算距离
--函数输入：1. 坐标A 2.坐标B
--函数输出：距离
function calDistancePoint(v1,v2)
    return math.sqrt(((v2.x-v1.x)*(v2.x-v1.x))+((v2.y-v1.y)*(v2.y-v1.y)))
end

--自定义函数 end

ability_thdots_yorihime_01 = class({})
LinkLuaModifier( "modifier_ability_thdots_yorihime_01_debuff", "scripts/vscripts/abilities/abilityyorihime.lua",LUA_MODIFIER_MOTION_NONE )

--让技能有AOE显示
function ability_thdots_yorihime_01:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_yorihime_01:CastFilterResultTarget(hTarget)
	if hTarget == self:GetCaster() or hTarget:IsMagicImmune() then
		return UF_FAIL_CUSTOM
	end
end

function ability_thdots_yorihime_01:OnSpellStart()
    if not IsServer() then return end
    local caster=self:GetCaster()
	self.target = self:GetCursorTarget()
	-- print(self:GetEffectiveCooldown(self:GetLevel()-1))
	if is_spell_blocked(self.target,caster) then return end
	

	

	EmitSoundOn( "Hero_Sven.StormBolt", self:GetCaster() )
	
	if caster:HasModifier("modifier_ability_thdots_yorihime_01_move") then
        caster:RemoveModifierByName("modifier_ability_thdots_yorihime_01_move")
    end
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_yorihime_01_move", {})

 
end
--------------------------------------------------------------------------------
--移动修饰器
modifier_ability_thdots_yorihime_01_move=class({})
LinkLuaModifier( "modifier_ability_thdots_yorihime_01_move", "scripts/vscripts/abilities/abilityyorihime.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_ability_thdots_yorihime_01_move:IsHidden()        return false end
function modifier_ability_thdots_yorihime_01_move:IsPurgable()      return false end
function modifier_ability_thdots_yorihime_01_move:RemoveOnDeath()   return true end
function modifier_ability_thdots_yorihime_01_move:IsDebuff()        return false end
--Horizontal Motion Constant=0.033333335071802
--modifier 修改列表
-- function modifier_ability_thdots_yorihime_01_move:CheckState()
-- 	local state = {
-- 		[MODIFIER_STATE_STUNNED] = true,
-- 		[MODIFIER_STATE_OUT_OF_GAME] = true,
-- 		[MODIFIER_STATE_INVULNERABLE] = true,
-- 		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
-- 	}
-- 	return state
-- end



function modifier_ability_thdots_yorihime_01_move:OnCreated(params)
	if not IsServer() then return end
	self.caster=self:GetCaster()
    self.ability=self:GetAbility()
	self.target=self.ability:GetCursorTarget()
	self.cancel = false
	self.velocity = self.ability:GetSpecialValueFor("dash_speed") + FindTelentValue(self.caster,"special_bonus_movdspeed_1000")
	self.ability:SetActivated(false)
	-- self.caster=self:GetCaster()
    -- self.ability=self:GetAbility()
	-- self.target=self.ability:GetCursorTarget()
	-- self.velocity=self.ability:GetSpecialValueFor("dash_speed")

	self.particle_lightning= ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf", PATTACH_POINT_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(self.particle_lightning, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.particle_lightning, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)

	self.particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge_target.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber())
	self:AddParticle(self.particle, false, false, -1, false, true)

	self.direction=(self.target:GetAbsOrigin() - self.caster:GetAbsOrigin()):Normalized()
	self.distance=calDistanceHero(self.caster,self.target)

	print(self.caster:GetTeamNumber())
	print(self.target:GetTeamNumber())
	if self.caster:GetTeamNumber() ~= self.target:GetTeamNumber() then
		print("do it")
		self.target:AddNewModifier(self.caster, self.ability, "modifier_ability_thdots_yorihime_01_vision", {})
	end
	print("do it2")
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_yorihime_01_move:OnOrder(keys)
    if not IsServer() then return end

    local caster=self:GetParent()
    local ability=self:GetAbility()

	if keys.unit==caster and keys.order_type==DOTA_UNIT_ORDER_HOLD_POSITION  then
		self:StartIntervalThink(-1) 
		self.target:RemoveModifierByName("modifier_ability_thdots_yorihime_01_vision")
		FindClearSpaceForUnit(self.caster,self.caster:GetAbsOrigin(),false)
		self.cancel=true
		self.caster:SetForwardVector(self.caster:GetAbsOrigin():Normalized())
		self:Destroy()
		ParticleManager:DestroyParticle(self.particle_lightning,true)
		StopSoundOn("Hero_Sven.StormBoltImpact",caster)
	end
	
end

function modifier_ability_thdots_yorihime_01_move:OnIntervalThink()
	if not IsServer() then return end
	if not self.target:IsAlive() then
		local targets = FindUnitsInRadius(self.caster:GetTeam(), self.target:GetAbsOrigin(),nil,1000,
			self.ability:GetAbilityTargetTeam(),self.ability:GetAbilityTargetType(),0,0, false)
		if #targets > 0 then
			for _,unit in pairs (targets) do
				self.target:RemoveModifierByName("modifier_ability_thdots_yorihime_01_vision")
				self.target = unit
				self.target:AddNewModifier(self.caster, self.ability, "modifier_ability_thdots_yorihime_01_vision",{})
			end
		else
			self.target:RemoveModifierByName("modifier_ability_thdots_yorihime_01_vision")
			self:StartIntervalThink(-1) 
			FindClearSpaceForUnit(self.caster,self.caster:GetAbsOrigin(),false)
			self.cancel=true
			self.caster:SetForwardVector(self.caster:GetAbsOrigin():Normalized())
			self:Destroy()
			ParticleManager:DestroyParticle(self.particle_lightning,true)
			StopSoundOn("Hero_Sven.StormBoltImpact",self.caster)
		end
	end
	self.caster:SetForwardVector(self.direction)
	self.direction=(self.target:GetAbsOrigin() - self.caster:GetAbsOrigin()):Normalized()
	self.distance=calDistanceHero(self.caster,self.target)

	if self.caster:IsRooted() or self.caster:IsStunned() or self.caster:IsHexed() then
		FindClearSpaceForUnit(self.caster,self.caster:GetAbsOrigin(),false)
		self.cancel=true
		self.caster:SetForwardVector(self.caster:GetAbsOrigin():Normalized())
		self:Destroy()
	end

	if self.distance > 100 then
		self.caster:SetAbsOrigin(self.caster:GetAbsOrigin() + self.direction * self.velocity * 0.033333335071802)
		self.caster:SetAbsOrigin(Vector(self.caster:GetAbsOrigin().x, self.caster:GetAbsOrigin().y, GetGroundHeight(self.caster:GetAbsOrigin(), self.caster)))
	else 
		FindClearSpaceForUnit(self.caster,self.caster:GetAbsOrigin(),false)
		self.caster:SetForwardVector(self.caster:GetAbsOrigin():Normalized())
		self:Destroy()
	end
	
end

function modifier_ability_thdots_yorihime_01_move:OnDestroy()
	--结束时眩晕敌人
	if not IsServer() then return end
	local 	ability = self:GetAbility()
	local 	target 	= self.target
	local	caster  = ability:GetCaster()
	ability:SetActivated(true)
	-- print(self:GetEffectiveCooldown(self:GetLevel()-1))
	ability:StartCooldown(ability:GetEffectiveCooldown(ability:GetLevel()-1))
	-- ability:StartCooldown(13)
	ParticleManager:DestroyParticle(self.particle_lightning,true) 
	target:RemoveModifierByName("modifier_ability_thdots_yorihime_01_vision")


	local   radius 	= ability:GetSpecialValueFor("radius")
	local	stun_duration = ability:GetSpecialValueFor( "duration" ) + FindTelentValue(caster,"special_bonus_stun_time")
	local	heal_duration = ability:GetSpecialValueFor( "heal_duration" )
	if self.cancel then
		return
	end
	-- print(caster:GetTeam())
	local 	enemy 	= FindUnitsInRadius(caster:GetTeam(),
			target:GetAbsOrigin(),
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)



	if not caster:IsAlive() then return end

	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(effectIndex , 3, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effectIndex)
	for _,unit in pairs(enemy) do
		local damage_table=
			{
				victim=unit,
				attacker=caster,
				damage          = ability:GetSpecialValueFor("damage"),
				damage_type     = ability:GetAbilityDamageType(),
				damage_flags    = ability:GetAbilityTargetFlags(),
				ability= ability
			}
		UtilStun:UnitStunTarget(caster,unit,stun_duration)
		ApplyDamage(damage_table)	
	end

	local allies = FindUnitsInRadius(
				   caster:GetTeam(),		
				   target:GetOrigin(),		
				   nil,					
				   ability:GetSpecialValueFor("radius"),		
				   DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				   DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
					DOTA_UNIT_TARGET_FLAG_NONE,
					FIND_ANY_ORDER,
					false
	)
	for _,unit in pairs(allies) do
		unit:AddNewModifier(caster,ability,"modifier_ability_thdots_yorihime_01_buff",{duration = heal_duration})
	end

	EmitSoundOn( "Hero_Sven.StormBoltImpact", target )


end
--------------------------------------------------------------------------------
--视野buff
modifier_ability_thdots_yorihime_01_vision=class({})
LinkLuaModifier( "modifier_ability_thdots_yorihime_01_vision", "scripts/vscripts/abilities/abilityyorihime.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_ability_thdots_yorihime_01_vision:IsHidden()		return false end
function modifier_ability_thdots_yorihime_01_vision:IsPurgable()	return false end
function modifier_ability_thdots_yorihime_01_vision:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_ability_thdots_yorihime_01_vision:ShouldUseOverheadOffset() return true end -- I have no idea when this works but it might be particle-specific

function modifier_ability_thdots_yorihime_01_vision:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetCaster()
	self.particle = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge_target.vpcf", 
		PATTACH_OVERHEAD_FOLLOW, self:GetParent(), self:GetCaster():GetTeamNumber())
	self:StartIntervalThink(0.03)
end

function modifier_ability_thdots_yorihime_01_vision:OnIntervalThink()
	if not IsServer() then return end
	if not self.caster:HasModifier("modifier_ability_thdots_yorihime_01_move") then
		self:Destroy()
	end
end

function modifier_ability_thdots_yorihime_01_vision:CheckState()
	return {[MODIFIER_STATE_PROVIDES_VISION] = true}
end


function modifier_ability_thdots_yorihime_01_move:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ORDER,
    }
    return funcs
end

function modifier_ability_thdots_yorihime_01_vision:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticleSystem(self.particle,true)
end

--------------------------------------------------------------------------------

modifier_ability_thdots_yorihime_01_buff=class({})
LinkLuaModifier( "modifier_ability_thdots_yorihime_01_buff", "scripts/vscripts/abilities/abilityyorihime.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_ability_thdots_yorihime_01_buff:IsHidden()        return true end
function modifier_ability_thdots_yorihime_01_buff:IsPurgable()      return false end
function modifier_ability_thdots_yorihime_01_buff:RemoveOnDeath()   return true end
function modifier_ability_thdots_yorihime_01_buff:IsDebuff()        return false end

function modifier_ability_thdots_yorihime_01_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
	return funcs
end

function modifier_ability_thdots_yorihime_01_buff:OnCreated()
	if not IsServer() then return end
	local 	ability = self:GetAbility()
	local heal=ability:GetSpecialValueFor("buff_heal")
	self:GetParent():Heal(heal,caster)
end

function modifier_ability_thdots_yorihime_01_buff:GetModifierMagicalResistanceBonus() 
	return 100
end


function modifier_ability_thdots_yorihime_01_buff:GetModifierPhysicalArmorBonus() 
	return 9999
end


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
ability_thdots_yorihime_02 = class({})
LinkLuaModifier( "modifier_ability_thdots_yorihime_02", "scripts/vscripts/abilities/abilityyorihime.lua",LUA_MODIFIER_MOTION_NONE )


function ability_thdots_yorihime_02:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("02_duration")
	self.caster = caster
	self.target = target
	target:AddNewModifier(caster,self,"modifier_ability_thdots_yorihime_02",{duration = duration })
	EmitSoundOn("Hero_Abaddon.AphoticShield.Cast", target)
end

--------------------------------------------------------------------------------

modifier_ability_thdots_yorihime_02 = class ({})

function modifier_ability_thdots_yorihime_02:IsHidden() 		return false end
function modifier_ability_thdots_yorihime_02:IsPurgable()		return true end
function modifier_ability_thdots_yorihime_02:RemoveOnDeath() 	return true end
function modifier_ability_thdots_yorihime_02:IsDebuff()		return false end


function modifier_ability_thdots_yorihime_02:OnCreated()
	if not IsServer() then return end
	local ability = self:GetAbility()
	local caster = ability.caster
	local target = ability.target
	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_treant/treant_livingarmor.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_head", self:GetCaster():GetOrigin(), true )
	self:AddParticle( nFXIndex, false, false, -1, false, true )

	self.particle= ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_livingarmor.vpcf", PATTACH_ROOTBONE_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(self.particle, 0, target, PATTACH_ROOTBONE_FOLLOW, "follow_rootbone", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.particle, 1, target, PATTACH_ROOTBONE_FOLLOW, "follow_rootbone", target:GetAbsOrigin(), true)
end

function modifier_ability_thdots_yorihime_02:OnDestroy()
    if not IsServer() then return end
    local ability=self:GetAbility()


    ParticleManager:DestroyParticle(self.particle,true) 
    
end



function modifier_ability_thdots_yorihime_02:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
	return funcs
end


function modifier_ability_thdots_yorihime_02:GetModifierMagicalResistanceBonus() 
	return self:GetAbility():GetSpecialValueFor( "02_magical" ) 
end



function modifier_ability_thdots_yorihime_02:GetModifierPhysicalArmorBonus() 
	return self:GetAbility():GetSpecialValueFor( "02_armor" ) 
end


function modifier_ability_thdots_yorihime_02:GetModifierConstantManaRegen() 
	return self:GetAbility():GetSpecialValueFor( "02_manaregen" ) 
end


function modifier_ability_thdots_yorihime_02:GetModifierConstantHealthRegen() 
	return self:GetAbility():GetSpecialValueFor( "02_healregen" ) 
end



---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

ability_thdots_yorihime_03 = class({})

function ability_thdots_yorihime_03:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	self.caster 	= caster
	self.target 	= target
	local duration = self:GetSpecialValueFor("shield_duration")
	target:EmitSound("Hero_Omniknight.Purification")
	-- local MaxHealth = self:GetSpecialValueFor("shield_health")
	local MaxHealth = self:GetSpecialValueFor("shield_health")
	local strength = self.caster:GetStrength() * FindTelentValue(caster,"special_bonus_shield_strength")
	self.shield_remaining = MaxHealth + strength
	print("self.shield_remaining is :",self.shield_remaining)
	-- self.shield_remaining = MaxHealth
	if target:HasModifier("modifier_shield_buff") then
		target:RemoveModifierByName("modifier_shield_buff")
	end
	target:AddNewModifier(caster,self,"modifier_shield_buff",{duration = duration })
	
	


end

--------------------------------------------------------------------------------

modifier_shield_buff=class({})

LinkLuaModifier("modifier_shield_buff", "scripts/vscripts/abilities/abilityyorihime.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_shield_buff:IsHidden()        return false end
function modifier_shield_buff:IsPurgable()      return true end
function modifier_shield_buff:RemoveOnDeath()   return true end
function modifier_shield_buff:IsDebuff()        return false end

function modifier_shield_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
	return funcs
end
function modifier_shield_buff:OnCreated()
    if not IsServer() then return end
    local ability=self:GetAbility()
    local caster = ability.caster
    local target = ability.target

    self.particle= ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf", PATTACH_ROOTBONE_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(self.particle, 0, target, PATTACH_ROOTBONE_FOLLOW, "follow_rootbone", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.particle, 1, target, PATTACH_ROOTBONE_FOLLOW, "follow_rootbone", target:GetAbsOrigin(), true)
end

function modifier_shield_buff:OnDestroy()
    if not IsServer() then return end
    local ability=self:GetAbility()
    ParticleManager:DestroyParticle(self.particle,true) 
end

function modifier_shield_buff:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor( "buff_damage" )
end

function modifier_shield_buff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor( "buff_movespeed" )
end

function modifier_shield_buff:GetModifierTotal_ConstantBlock(kv)
	if not IsServer then return end
	local ability = self:GetAbility()
	-- print("print out damage:", kv.damage)
	
	if kv.damage < ability.shield_remaining then 
		ability.shield_remaining = ability.shield_remaining-kv.damage
		-- print("shield_health:", ability.shield_remaining )
		return kv.damage
	else
		self:Destroy()
		return ability.shield_remaining
	end

end


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------


ability_thdots_yorihime_Ex = class ({})

function ability_thdots_yorihime_Ex:IsHiddenWhenStolen() 		return false end
function ability_thdots_yorihime_Ex:IsRefreshable() 			return true end
function ability_thdots_yorihime_Ex:IsStealable() 			return false end

function ability_thdots_yorihime_Ex:GetIntrinsicModifierName()
    return "modifier_thdots_yorihime_ex"
end


--------------------------------------------------------------------------------


modifier_thdots_yorihime_ex = class({})

LinkLuaModifier("modifier_thdots_yorihime_ex", "scripts/vscripts/abilities/abilityyorihime.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_thdots_yorihime_ex:IsHidden()         return false end
function modifier_thdots_yorihime_ex:IsPurgable()       return false end
function modifier_thdots_yorihime_ex:RemoveOnDeath()    return true end
function modifier_thdots_yorihime_ex:IsDebuff()     return false end

function modifier_thdots_yorihime_ex:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		-- MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
	return funcs
end

function modifier_thdots_yorihime_ex:OnCreated()
	if not IsServer() then return end

	self:StartIntervalThink(0.1)
end

function modifier_thdots_yorihime_ex:OnIntervalThink()
	if not IsServer() then return end
	local caster 		= self:GetParent()
	local abilityName="special_bonus_radius_99999"
	
	if caster:HasAbility(abilityName) and caster:FindAbilityByName(abilityName):GetLevel()>0 then 
		self.radius = caster:FindAbilityByName(abilityName):GetSpecialValueFor("ex_talent_radius")
	else 
		self.radius	= self:GetAbility():GetSpecialValueFor("ex_radius")
	end 
	local radius = self.radius
	-- print("tianfu",radius)
	local ability = self:GetAbility()
	local allies = FindUnitsInRadius(
					self:GetParent():GetTeam(),		
					self:GetParent():GetOrigin(),		
				   nil,					
				   radius,		
				   DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				   DOTA_UNIT_TARGET_HERO,
				   0, FIND_CLOSEST,
				   false
	)
	local count = 0
	for k,v in pairs(allies) do
		if v:IsRealHero() then
			count = count + 1
		end
	end
	-- if count == 1 then
	-- 	count = 0
	-- end
	self:GetParent():SetModifierStackCount("modifier_thdots_yorihime_ex", self:GetAbility(), count)
end





function modifier_thdots_yorihime_ex:GetModifierMagicalResistanceBonus() 
	return self:GetAbility():GetSpecialValueFor( "ex_magical" ) * self:GetStackCount()
end




function modifier_thdots_yorihime_ex:GetModifierPhysicalArmorBonus() 
	return self:GetAbility():GetSpecialValueFor( "ex_armor" ) * self:GetStackCount()
end


-- function modifier_thdots_yorihime_ex:GetModifierConstantManaRegen() 
-- 	return self:GetAbility():GetSpecialValueFor( "ex_manaregen" ) * self:GetStackCount()
-- end


function modifier_thdots_yorihime_ex:GetModifierConstantHealthRegen() 
	return self:GetAbility():GetSpecialValueFor( "ex_healthregen" ) * self:GetStackCount()
end





ability_thdots_yorihime_ultimate = class({})
LinkLuaModifier("modifier_thdots_yorihime_ultimate", "scripts/vscripts/abilities/abilityyorihime.lua", LUA_MODIFIER_MOTION_NONE)



---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------


function ability_thdots_yorihime_ultimate:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ultimate_duration = self:GetSpecialValueFor( "ultimate_duration" ) + FindTelentValue(caster,"special_bonus_god_strength_duration")
	print(ultimate_duration)
	-- local ultimate_duration = self:GetSpecialValueFor( "ultimate_duration" )
	
	-- print(ultimate_duration)
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_thdots_yorihime_ultimate", { duration = ultimate_duration }  )

	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetCaster():GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	EmitSoundOn( "Hero_Sven.GodsStrength", self:GetCaster() )

end

--------------------------------------------------------------------------------

modifier_thdots_yorihime_ultimate = class({})

function modifier_thdots_yorihime_ultimate:IsHidden()        return false end
function modifier_thdots_yorihime_ultimate:IsPurgable()      return false end
function modifier_thdots_yorihime_ultimate:RemoveOnDeath()   return true end
function modifier_thdots_yorihime_ultimate:IsDebuff()        return false end


function modifier_thdots_yorihime_ultimate:GetStatusEffectName()
	return "particles/status_fx/status_effect_gods_strength.vpcf"
end



function modifier_thdots_yorihime_ultimate:GetHeroEffectName()
	return "particles/units/heroes/hero_sven/sven_gods_strength_hero_effect.vpcf"
end



function modifier_thdots_yorihime_ultimate:OnCreated( kv )
	self.gods_strength_damage = self:GetAbility():GetSpecialValueFor( "gods_strength_damage" )
	-- self.radius 		= self:GetAbility():GetSpecialValueFor("ult_radius")
	-- self.caster 		= self:GetParent()
	if not IsServer() then return end
	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_sven/sven_spell_gods_strength_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon" , self:GetParent():GetOrigin(), true )
		ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head" , self:GetParent():GetOrigin(), true )
		self:AddParticle( nFXIndex, false, false, -1, false, true )
		self:StartIntervalThink(0.1)
end



function modifier_thdots_yorihime_ultimate:OnIntervalThink()
	if not IsServer() then return end
	local caster 		= self:GetParent()
	self.radius	= self:GetAbility():GetSpecialValueFor("ult_radius") + FindTelentValue(caster,"special_bonus_radius_99999")

	local radius = self.radius
	-- print("ult",radius)
	local ability = self:GetAbility()
	local allies = FindUnitsInRadius(
					self:GetParent():GetTeam(),		
					self:GetParent():GetOrigin(),		
				   nil,					
				   radius,		
				   DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				   DOTA_UNIT_TARGET_HERO,
				   0, FIND_CLOSEST,
				   false
	)
	local count = 0
	for k,v in pairs(allies) do
		if v:IsIllusion()==false then
			count = count + 1
		end
	end
	self:GetParent():SetModifierStackCount("modifier_thdots_yorihime_ultimate", self:GetAbility(), count)
end


function modifier_thdots_yorihime_ultimate:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_thdots_yorihime_ultimate:GetModifierBaseDamageOutgoing_Percentage()
	return self.gods_strength_damage * self:GetStackCount()
end

function modifier_thdots_yorihime_ultimate:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor( "ult_strength" ) * self:GetStackCount()
end

--------------------------------------------------------------------------------
