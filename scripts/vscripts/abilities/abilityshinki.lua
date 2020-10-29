ability_thdots_shinki_01 = class({})
LinkLuaModifier( "modifiery_thdots_shinki_01_debuff", "scripts/vscripts/abilities/abilityshinki.lua",LUA_MODIFIER_MOTION_NONE )


function ability_thdots_shinki_01:GetAOERadius()		
	return self:GetSpecialValueFor("radius") 
end


function ability_thdots_shinki_01:OnSpellStart()
    if not IsServer() then return end
	local	caster  = self:GetCaster()
	local   radius 	= self:GetSpecialValueFor("radius")
	local	duration = self:GetSpecialValueFor("duration")
	local	int_bonus = self:GetSpecialValueFor("int_bonus")
	local 	enemy 	= FindUnitsInRadius(caster:GetTeam(),
			caster:GetAbsOrigin(),
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)

	for _,unit in pairs(enemy) do
		if  caster:HasModifier("modifiery_thdots_shinki_02_buff")		then
		local damage_table=
		{
			victim=unit,
			attacker=caster,
			damage          = self:GetSpecialValueFor("damage") + (caster:GetIntellect()*int_bonus) +(caster:GetMaxHealth() * (self:GetSpecialValueFor("percentage")/100)) ,
			damage_type     = self:GetAbilityDamageType(),
			damage_flags    = self:GetAbilityTargetFlags(),
			ability= ability
		}
		UnitDamageTarget(damage_table)	
		unit:AddNewModifier(caster, self, "modifiery_thdots_shinki_01_debuff", {duration = duration})
	else
		local damage_table=
		{
			victim=unit,
			attacker=caster,
			damage          = self:GetSpecialValueFor("damage") + (caster:GetIntellect()*int_bonus),
			damage_type     = self:GetAbilityDamageType(),
			damage_flags    = self:GetAbilityTargetFlags(),
			ability= ability
		}
		UnitDamageTarget(damage_table)	
		unit:AddNewModifier(caster, self, "modifiery_thdots_shinki_01_debuff", {duration = duration})
		end
	end
end



modifiery_thdots_shinki_01_debuff=class({})

function modifiery_thdots_shinki_01_debuff:IsHidden()        return false end
function modifiery_thdots_shinki_01_debuff:IsPurgable()      return true end
function modifiery_thdots_shinki_01_debuff:RemoveOnDeath()   return true end
function modifiery_thdots_shinki_01_debuff:IsDebuff()        return true end

function modifiery_thdots_shinki_01_debuff:OnRefresh()
	if not IsServer() then return end
	self:OnCreated()
end

function modifiery_thdots_shinki_01_debuff:OnCreated()
	if not IsServer() then return end
	local 	ability = self:GetAbility()
	local 	target 	= self:GetParent()
	target:EmitSound("Hero_Leshrac.Lightning_Storm")
	self.Lightning_Storm= ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(self.Lightning_Storm, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.Lightning_Storm, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.Lightning_Storm, 0, target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	self:AddParticle(self.Lightning_Storm, false, false, -1, false, true)
end

function modifiery_thdots_shinki_01_debuff:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_earthshock_modifier.vpcf"
end

function modifiery_thdots_shinki_01_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifiery_thdots_shinki_01_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("slow_amount")
end


ability_thdots_shinki_02 = class({})
LinkLuaModifier( "modifiery_thdots_shinki_02_debuff", "scripts/vscripts/abilities/abilityshinki.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifiery_thdots_shinki_02_buff", "scripts/vscripts/abilities/abilityshinki.lua",LUA_MODIFIER_MOTION_NONE )

function ability_thdots_shinki_02:GetAOERadius()		
	return self:GetSpecialValueFor("02_radius") 
end


function ability_thdots_shinki_02:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	-- caster:EmitSound("Hero_Nevermore.ROS.Arcana.Cast")
	caster:EmitSound("Hero_Terrorblade.Metamorphosis")
	local duration = self:GetSpecialValueFor("02_duration")
	if not caster:HasModifier("modifiery_thdots_shinki_02_buff")	then
		caster:AddNewModifier(caster, self, "modifiery_thdots_shinki_02_buff", {duration = duration})
	end
	self.particle= ParticleManager:CreateParticle("particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_sunder_ti8.vpcf", PATTACH_ROOTBONE_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(self.particle, 0, caster, PATTACH_ROOTBONE_FOLLOW, "follow_rootbone", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.particle, 1, caster, PATTACH_ROOTBONE_FOLLOW, "follow_rootbone", caster:GetAbsOrigin(), true)
end




modifiery_thdots_shinki_02_buff = class({})


function modifiery_thdots_shinki_02_buff:IsHidden()        return false end
function modifiery_thdots_shinki_02_buff:IsPurgable()      return false end
function modifiery_thdots_shinki_02_buff:RemoveOnDeath()   return true end
function modifiery_thdots_shinki_02_buff:IsDebuff()        return false end

-- function modifiery_thdots_shinki_02_buff:OnCreated(kv)
-- 	-- local ability=self:GetAbility()
--     -- local caster = ability.caster
--     -- local target = ability.target
-- 	-- caster:EmitSound("Hero_Terrorblade.Metamorphosis")
--     -- self.particle= ParticleManager:CreateParticle("particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_sunder_ti8.vpcf", PATTACH_ROOTBONE_FOLLOW, caster)
-- 	-- ParticleManager:SetParticleControlEnt(self.particle, 0, caster, PATTACH_ROOTBONE_FOLLOW, "follow_rootbone", caster:GetAbsOrigin(), true)
-- 	-- ParticleManager:SetParticleControlEnt(self.particle, 1, caster, PATTACH_ROOTBONE_FOLLOW, "follow_rootbone", caster:GetAbsOrigin(), true)
-- end

function modifiery_thdots_shinki_02_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifiery_thdots_shinki_02_buff:GetModifierHealthBonus () 	
	return self:GetAbility():GetSpecialValueFor( "02_healthbonus" )
end

function modifiery_thdots_shinki_02_buff:GetModifierMoveSpeedBonus_Constant () 	
	return self:GetAbility():GetSpecialValueFor( "02_movespeed" )
end

function modifiery_thdots_shinki_02_buff:OnCreated(keys)
	if not IsServer() then return end
	local 	ability = self:GetAbility()
	local	caster  = ability:GetCaster()
	
	-- self.Metamorphosis= ParticleManager:CreateParticle("particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_back_ambient_ti8.vpcf", PATTACH_ROOTBONE_FOLLOW, caster)
	-- ParticleManager:SetParticleControlEnt(self.Metamorphosis, 0, caster, PATTACH_ROOTBONE_FOLLOW, "follow_rootbone", caster:GetAbsOrigin(), true)
	-- ParticleManager:SetParticleControlEnt(self.Metamorphosis, 1, caster, PATTACH_ROOTBONE_FOLLOW, "follow_rootbone", caster:GetAbsOrigin(), true)


	local pfx_caster = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(pfx_caster, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(pfx_caster, 1, Vector(0, 0, 0))
	self:AddParticle(pfx_caster, false, false, 15, false, false)

	self:StartIntervalThink(0.03)
end

function modifiery_thdots_shinki_02_buff:OnIntervalThink()
	if not IsServer() then return end

	local 	ability = self:GetAbility()
	local	caster  = ability:GetCaster()
	local   radius 	= ability:GetSpecialValueFor("02_radius")
	local	duration = ability:GetSpecialValueFor( "02_debuff_duration" )
	local 	enemy 	= FindUnitsInRadius(caster:GetTeam(),
			caster:GetAbsOrigin(),
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)
		
	for _,unit in pairs(enemy) do
		if not unit:HasModifier("modifiery_thdots_shinki_02_debuff")	then
		unit:AddNewModifier(caster,ability,"modifiery_thdots_shinki_02_debuff",{duration = duration})
		
		end
	end
	-- self.Metamorphosis= ParticleManager:CreateParticle("particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_back_ambient_ti8.vpcf", PATTACH_ROOTBONE_FOLLOW, caster)
	-- ParticleManager:SetParticleControlEnt(self.Metamorphosis, 0, caster, PATTACH_ROOTBONE_FOLLOW, "follow_rootbone", caster:GetAbsOrigin(), true)
	-- ParticleManager:SetParticleControlEnt(self.Metamorphosis, 1, caster, PATTACH_ROOTBONE_FOLLOW, "follow_rootbone", caster:GetAbsOrigin(), true)
end

function modifiery_thdots_shinki_02_buff:OnDestroy()
    if not IsServer() then return end

	-- ParticleManager:DestroyParticle(self.Metamorphosis,true) 
	
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:ReleaseParticleIndex(pfx)
end


modifiery_thdots_shinki_02_debuff = class({})


function modifiery_thdots_shinki_02_debuff:IsHidden()        return false end
function modifiery_thdots_shinki_02_debuff:IsPurgable()      return true end
function modifiery_thdots_shinki_02_debuff:RemoveOnDeath()   return true end
function modifiery_thdots_shinki_02_debuff:IsDebuff()        return true end


function modifiery_thdots_shinki_02_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
	return funcs
end

function modifiery_thdots_shinki_02_debuff:GetModifierMagicalResistanceBonus() 	
	return self:GetAbility():GetSpecialValueFor( "02_debuff_magicial" )
end


function modifiery_thdots_shinki_02_debuff:GetModifierPhysicalArmorBonus() 
	return self:GetAbility():GetSpecialValueFor( "02_debuff_armor" )
end





ability_thdots_shinki_03 = class({})

LinkLuaModifier("modifier_thdots_shinki_thinker", "scripts/vscripts/abilities/abilityshinki.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_thdots_shinki_attackslow", "scripts/vscripts/abilities/abilityshinki.lua", LUA_MODIFIER_MOTION_NONE)
function ability_thdots_shinki_03:GetAOERadius()			return self:GetSpecialValueFor("03_radius") end

function ability_thdots_shinki_03:OnAbilityPhaseStart()
	local pos = self:GetCursorPosition()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_AbyssalUnderlord.Firestorm.Start")
	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/underlord_firestorm_pre.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.pfx, 0, pos)
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(self:GetSpecialValueFor("03_radius"), 1, 1))
	return true
end

function ability_thdots_shinki_03:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("Hero_AbyssalUnderlord.Firestorm.Start")
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, true)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
	end
end

function ability_thdots_shinki_03:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	caster:EmitSound("Hero_AbyssalUnderlord.Firestorm.Cast")
	CreateModifierThinker(caster, self, "modifier_thdots_shinki_thinker", {}, pos, caster:GetTeamNumber(), false)
end

modifier_thdots_shinki_thinker = class({})

function modifier_thdots_shinki_thinker:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("wave_count"))
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("wave_interval"))
		self:OnIntervalThink()
	end
end

function modifier_thdots_shinki_thinker:OnIntervalThink()
	if not IsServer() then return end
	if self:GetStackCount() <= 0 then
		self:Destroy()
		return
	else
		self:SetStackCount(self:GetStackCount() - 1)
	end
	local caster = self:GetCaster()
	local thinker = self:GetParent()
	local ability = self:GetAbility()
	thinker:EmitSound("Hero_AbyssalUnderlord.Firestorm")
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, thinker:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 4, Vector(ability:GetSpecialValueFor("03_radius"), 1, 1))
	ParticleManager:SetParticleControl(pfx, 5, Vector(0, 0, 0))
	ParticleManager:ReleaseParticleIndex(pfx)
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), thinker:GetAbsOrigin(), nil, ability:GetSpecialValueFor("03_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local dmg = ability:GetSpecialValueFor("wave_damage")
	for i=1, #enemy do
		enemy[i]:EmitSound("Hero_AbyssalUnderlord.Firestorm.Target")
			local damage_table = {victim = enemy[i], attacker = caster, damage = dmg, damage_type = ability:GetAbilityDamageType()}
			if enemy[i]:IsBuilding() then 
				damage_table.damage = damage_table.damage / 2 
			end
			UnitDamageTarget(damage_table)
		if caster:HasModifier("modifiery_thdots_shinki_02_buff") and not enemy[i]:IsBuilding() then
			enemy[i]:AddNewModifier(caster, ability, "modifier_thdots_shinki_attackslow", {duration = ability:GetSpecialValueFor("slow_duration")})
		end
	end
end

modifier_thdots_shinki_attackslow = class ({})

function modifier_thdots_shinki_attackslow:IsHidden() 		return false end
function modifier_thdots_shinki_attackslow:IsPurgable()		return true end
function modifier_thdots_shinki_attackslow:RemoveOnDeath() 	return true end
function modifier_thdots_shinki_attackslow:IsDebuff()			return true end

function modifier_thdots_shinki_attackslow:GetEffectName() 
	return 
	"particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave_burn.vpcf" 
end

function modifier_thdots_shinki_attackslow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_thdots_shinki_attackslow:GetModifierAttackSpeedBonus_Constant() 	
	return self:GetAbility():GetSpecialValueFor( "attackslow" )
end



ability_thdots_shinki_ultimate = class ({})
LinkLuaModifier("modifier_ability_thdots_shinki_ultimate","scripts/vscripts/abilities/abilityshinki.lua",LUA_MODIFIER_MOTION_NONE)


function ability_thdots_shinki_ultimate:OnSpellStart()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.target 						= self:GetCursorTarget()
	if is_spell_blocked(self.target,self.caster) then return end
	local duration  					= self:GetSpecialValueFor("duration")
	local show_incoming  				= self:GetSpecialValueFor("show_incoming")
	local show_outgoing  				= self:GetSpecialValueFor("show_outgoing")
	local incoming_damage  				= self:GetSpecialValueFor("incoming_damage")
	local outgoing_damage  				= self:GetSpecialValueFor("outgoing_damage")

	self.target:EmitSound("Hero_Terrorblade.ConjureImage")

	self.caster:SetContextThink("shinki4",
		function()
			self.illusion = create_illusion(self,self.target:GetAbsOrigin(),incoming_damage,outgoing_damage,duration)
			self.illusion:AddNewModifier(self.caster, self, "modifier_ability_thdots_shinki_ultimate", {})	
			FindClearSpaceForUnit(self.illusion,self.illusion:GetOrigin(),true)
		end,
	0.03)
end

modifier_ability_thdots_shinki_ultimate = class({})

function modifier_ability_thdots_shinki_ultimate:IsHidden() 		return false end
function modifier_ability_thdots_shinki_ultimate:IsPurgable()		return false end
function modifier_ability_thdots_shinki_ultimate:RemoveOnDeath() 	return true end
function modifier_ability_thdots_shinki_ultimate:IsDebuff()			return false end

-- function modifier_ability_thdots_shinki_ultimate:GetEffectName()
-- 	return "particles/units/heroes/hero_terrorblade/terrorblade_reflection_slow.vpcf"
-- end

function modifier_ability_thdots_shinki_ultimate:GetStatusEffectName()
	return "particles/status_fx/status_effect_terrorblade_reflection.vpcf"
end

function modifier_ability_thdots_shinki_ultimate:DeclareFunctions()
	return{
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		-- MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end

-- function modifier_ability_thdots_shinki_ultimate:GetModifierAttackRangeBonus()
-- 	if self:GetParent():HasModifier("modifier_ability_thdots_shinki_talent_1") then
-- 		return 300
-- 	else
-- 		return 0
-- 	end
-- end

function modifier_ability_thdots_shinki_ultimate:OnTakeDamage(keys)
	if not IsServer() then return end
	local illusion = keys.unit
	local unit = keys.attacker
	local building_damage = self:GetAbility():GetSpecialValueFor("building_damage") - 1
	if self:GetStackCount() == 1 then return end
	if unit:IsBuilding() and illusion == self:GetParent() then
		self:SetStackCount(1)
		local damageTable = {victim = illusion,
						damage = keys.damage * building_damage,
						damage_type = keys.damage_type,
						attacker = unit,
						ability = nil
					}
		UnitDamageTarget(damageTable)
		self:SetStackCount(0)
	end
end

function modifier_ability_thdots_shinki_ultimate:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetParent()
	self.illusion = self:GetAbility().illusion
	self.illusion.hero = self:GetAbility().target
	self:StartIntervalThink(0.04)
	self.effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_reflection_slow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
end

function modifier_ability_thdots_shinki_ultimate:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if caster:IsAlive() then return end
	caster:SetContextThink("HasAegis",
	function()
		if caster:GetTimeUntilRespawn() > 5 then
			ParticleManager:DestroyParticleSystem(self.effectIndex,true)
			self:GetParent():ForceKill(true)
		end
	end,
	0.03)
	-- if FindTelentValue(self:GetCaster(),"special_bonus_unique_shinki_1") ~= 0 and not self:GetCaster():HasModifier("modifier_ability_thdots_shinki_talent_1") then
	-- 	self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_shinki_talent_1",{})
	-- end
end

function create_illusion(self, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)	
	local player_id = self.caster:GetPlayerID()
	local caster_team = self.caster:GetTeam()
	local tmp = self.caster

	local	illusion_incoming_damage = self:GetSpecialValueFor( "incoming_damage" )
	local	illusion_outgoing_damage = self:GetSpecialValueFor( "outgoing_damage" )
	-- local	illusion_duration = self:GetAbility():GetSpecialValueFor( "illusion_incoming_damage" )
	print(illusion_incoming_damage)
	print(illusion_outgoing_damage)
	print(illusion_duration)


	local illusion = CreateUnitByName(self.target:GetUnitName(), illusion_origin, true, self.caster, tmp, caster_team)  --handle_UnitOwner needs to be nil, or else it will crash the game.
	illusion:SetPlayerID(player_id)
	illusion:SetControllableByPlayer(player_id, true)

	local caster_level = self.caster:GetLevel()
	for i = 1, caster_level - 1 do
		illusion:HeroLevelUp(false)
	end

	illusion:SetAbilityPoints(0)
	for ability_slot = 0, 15 do
		local individual_ability = self.target:GetAbilityByIndex(ability_slot)
		if individual_ability ~= nil then 
			local illusion_ability = illusion:FindAbilityByName(individual_ability:GetAbilityName())
			if illusion_ability ~= nil then
				illusion_ability:SetLevel(individual_ability:GetLevel())
			end
		end
	end

	--Recreate the caster's items for the illusion.
	for item_slot = 0, 5 do
		local individual_item = self.target:GetItemInSlot(item_slot)
		if individual_item ~= nil then
			local illusion_duplicate_item = CreateItem(individual_item:GetName(), illusion, illusion)
			illusion:AddItem(illusion_duplicate_item)
			illusion_duplicate_item:SetPurchaser(nil)
		end
	end
		-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
		illusion:AddNewModifier(self.caster, self, "modifier_illusion", {duration = illusion_duration, outgoing_damage = illusion_outgoing_damage, incoming_damage = illusion_incoming_damage})
		illusion:MakeIllusion()  --Without MakeIllusion(), the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.  Without it, IsIllusion() returns false and IsRealHero() returns true.
		return illusion
end

-- modifier_ability_thdots_shinki_talent_1 = modifier_ability_thdots_shinki_talent_1 or {}  --天赋监听
-- LinkLuaModifier("modifier_ability_thdots_shinki_talent_1","scripts/vscripts/abilities/abilityshinki.lua",LUA_MODIFIER_MOTION_NONE)
-- function modifier_ability_thdots_shinki_talent_1:IsHidden() 		return true end
-- function modifier_ability_thdots_shinki_talent_1:IsPurgable()		return false end
-- function modifier_ability_thdots_shinki_talent_1:RemoveOnDeath() 	return false end
-- function modifier_ability_thdots_shinki_talent_1:IsDebuff()		return false end