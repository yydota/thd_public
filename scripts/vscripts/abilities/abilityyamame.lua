--------------------------------------------------------
--病符「瘴气场」
--------------------------------------------------------
ability_thdots_yamameEx = {}

function ability_thdots_yamameEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_yamameEx"
end

modifier_ability_thdots_yamameEx = {}
LinkLuaModifier("modifier_ability_thdots_yamameEx","scripts/vscripts/abilities/abilityyamame.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_yamameEx:IsHidden() 		return false end
function modifier_ability_thdots_yamameEx:IsPurgable()		return false end
function modifier_ability_thdots_yamameEx:RemoveOnDeath() 	return false end
function modifier_ability_thdots_yamameEx:IsDebuff()		return false end

function modifier_ability_thdots_yamameEx:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end
function modifier_ability_thdots_yamameEx:OnIntervalThink()
	if not IsServer() then return end
	if FindTelentValue(self:GetParent(),"special_bonus_unique_yamame_4") ~= 0 and not self:GetParent():HasModifier("modifier_ability_thdots_yamameEx_talent_1") then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ability_thdots_yamameEx_talent_1", {})
	end
end

function modifier_ability_thdots_yamameEx:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_thdots_yamameEx:OnAttackLanded(keys)
	if not IsServer() then return end
	if keys.attacker:GetTeam() == keys.target:GetTeam() or keys.target:IsBuilding() then return end
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	if keys.attacker == self:GetParent() then
		keys.target:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_yamameEx_debuff",{duration = duration})
		if keys.attacker:HasModifier("modifier_item_wanbaochui") and keys.attacker:HasModifier("modifier_broodmother_spin_web") then
			keys.target:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_ability_thdots_yamameEx_debuff_wanbaochui",{duration = duration})
		end
	end
end

modifier_ability_thdots_yamameEx_debuff = {}
LinkLuaModifier("modifier_ability_thdots_yamameEx_debuff","scripts/vscripts/abilities/abilityyamame.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_yamameEx_debuff:IsHidden() 		return false end
function modifier_ability_thdots_yamameEx_debuff:IsPurgable()		return true end
function modifier_ability_thdots_yamameEx_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_yamameEx_debuff:IsDebuff()			return true end

function modifier_ability_thdots_yamameEx_debuff:GetEffectName()
	return "particles/units/heroes/hero_broodmother/broodmother_poison_debuff_c.vpcf"
end

function modifier_ability_thdots_yamameEx_debuff:OnCreated()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.ability						= self:GetAbility()
	self.damage							= self.ability:GetSpecialValueFor("damage")
	self.level_bonus					= self.ability:GetSpecialValueFor("level_bonus")
	self:StartIntervalThink(1)
	--音效
end

function modifier_ability_thdots_yamameEx_debuff:OnIntervalThink()
	if not IsServer() then return end
	local damage = self.damage + self.caster:GetLevel() * self.level_bonus
	local damage_tabel = {
				victim 			= self:GetParent(),
				damage 			= damage,
				damage_type		= self.ability:GetAbilityDamageType(),
				damage_flags 	= self.ability:GetAbilityTargetFlags(),
				attacker 		= self.caster,
				ability 		= self.ability
			}
	UnitDamageTarget(damage_tabel)
end

modifier_ability_thdots_yamameEx_debuff_wanbaochui = {}
LinkLuaModifier("modifier_ability_thdots_yamameEx_debuff_wanbaochui","scripts/vscripts/abilities/abilityyamame.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_yamameEx_debuff_wanbaochui:IsHidden() 		return false end
function modifier_ability_thdots_yamameEx_debuff_wanbaochui:IsPurgable()		return true end
function modifier_ability_thdots_yamameEx_debuff_wanbaochui:RemoveOnDeath() 	return true end
function modifier_ability_thdots_yamameEx_debuff_wanbaochui:IsDebuff()			return true end

function modifier_ability_thdots_yamameEx_debuff_wanbaochui:GetEffectName()
	return "particles/units/heroes/hero_broodmother/broodmother_incapacitatingbite_debuff.vpcf"
end

function modifier_ability_thdots_yamameEx_debuff_wanbaochui:OnCreated()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.ability						= self:GetAbility()
	self.damage							= self.ability:GetSpecialValueFor("damage")
	self.level_bonus					= self.ability:GetSpecialValueFor("level_bonus")
	self.wanbaochui_count				= self.ability:GetSpecialValueFor("wanbaochui_count")
	self.wanbaochui_duration			= self.ability:GetSpecialValueFor("wanbaochui_duration")
end


function modifier_ability_thdots_yamameEx_debuff_wanbaochui:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_ability_thdots_yamameEx_debuff_wanbaochui:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("wanbaochui_slow") * self:GetStackCount()
end

function modifier_ability_thdots_yamameEx_debuff_wanbaochui:OnAttacked(keys)
	if not IsServer() then return end
	if keys.attacker == self:GetCaster() and keys.target == self:GetParent() then
		if self:GetStackCount() < self.wanbaochui_count then
			self:IncrementStackCount()
		else
			self:GetParent():AddNewModifier(self.caster, self.ability, "modifier_ability_thdots_yamameEx_debuff_wanbaochui_rooted", {duration = self.wanbaochui_duration})
			keys.target:EmitSound("DOTA_Item.RodOfAtos.Target")
			self:Destroy()
		end
	end
end

modifier_ability_thdots_yamameEx_debuff_wanbaochui_rooted = {}
LinkLuaModifier("modifier_ability_thdots_yamameEx_debuff_wanbaochui_rooted","scripts/vscripts/abilities/abilityyamame.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_yamameEx_debuff_wanbaochui_rooted:IsHidden() 		return false end
function modifier_ability_thdots_yamameEx_debuff_wanbaochui_rooted:IsPurgable()		return true end
function modifier_ability_thdots_yamameEx_debuff_wanbaochui_rooted:RemoveOnDeath() 	return true end
function modifier_ability_thdots_yamameEx_debuff_wanbaochui_rooted:IsDebuff()		return true end

function modifier_ability_thdots_yamameEx_debuff_wanbaochui_rooted:GetEffectName()
	return "particles/units/heroes/hero_broodmother/broodmother_incapacitatingbite_debuff.vpcf"
end
function modifier_ability_thdots_yamameEx_debuff_wanbaochui_rooted:CheckState() --缠绕
	return {
		[MODIFIER_STATE_ROOTED] = true,
	}
end

modifier_ability_thdots_yamameEx_talent_1 = {}
LinkLuaModifier("modifier_ability_thdots_yamameEx_talent_1","scripts/vscripts/abilities/abilityyamame.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_yamameEx_talent_1:IsHidden() 			return false end
function modifier_ability_thdots_yamameEx_talent_1:IsPurgable()			return false end
function modifier_ability_thdots_yamameEx_talent_1:RemoveOnDeath() 		return false end
function modifier_ability_thdots_yamameEx_talent_1:IsDebuff()			return false end
--------------------------------------------------------
--毒符「桦黄小町」
--------------------------------------------------------

ability_thdots_yamame02 = {}

function ability_thdots_yamame02:GetCastRange()
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_yamame02:GetIntrinsicModifierName()
	return "modifier_ability_thdots_yamame02_passive"
end

modifier_ability_thdots_yamame02_passive = {}
LinkLuaModifier("modifier_ability_thdots_yamame02_passive","scripts/vscripts/abilities/abilityyamame.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_yamame02_passive:IsHidden() 		return false end
function modifier_ability_thdots_yamame02_passive:IsPurgable()		return false end
function modifier_ability_thdots_yamame02_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_yamame02_passive:IsDebuff()		return false end

function modifier_ability_thdots_yamame02_passive:OnCreated()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.ability						= self:GetAbility()
	self.damage							= self.ability:GetSpecialValueFor("damage")
	self.passive_damage					= self.ability:GetSpecialValueFor("passive_damage")
end


function modifier_ability_thdots_yamame02_passive:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_ability_thdots_yamame02_passive:OnTakeDamage(keys)
	if not IsServer() then return end
	if keys.attacker:GetTeam() == keys.unit:GetTeam() then return end
	if keys.attacker == self:GetParent() and keys.damage_type == DAMAGE_TYPE_PHYSICAL then
		local damage = keys.damage * self.passive_damage / 100
		local damage_tabel = {
				victim 			= keys.unit,
				damage 			= damage,
				damage_type		= DAMAGE_TYPE_MAGICAL,
				damage_flags 	= self.ability:GetAbilityTargetFlags(),
				attacker 		= self.caster,
				ability 		= self.ability
			}
		UnitDamageTarget(damage_tabel)
	end
end

function ability_thdots_yamame02:OnSpellStart()
	if not IsServer() then return end
	self.caster 				= self:GetCaster()
	self.radius  				= self:GetSpecialValueFor("radius")
	self.duration  				= self:GetSpecialValueFor("duration")
	self.damage  				= self:GetSpecialValueFor("damage") + FindTelentValue(self.caster,"special_bonus_unique_yamame_1")
	print("do iti ew qwe")
	self:GetCaster():EmitSound("Voice_Thdots_Yamame.AbilityYamame02_1")
	local targets = FindUnitsInRadius(self.caster:GetTeam(), self.caster:GetOrigin(),nil,self.radius,self:GetAbilityTargetTeam(),
		self:GetAbilityTargetType(),0,0,false)
	DeleteDummy(targets)
	for _,v in pairs(targets) do
		local info = {
			Source = self:GetCaster(),
			Target = v,
			Ability = self,
			bDodgeable = true,
			EffectName = "particles/econ/items/broodmother/bm_lycosidaes/bm_lycosidaes_web_cast.vpcf",
			iMoveSpeed = 1200--self:GetSpecialValueFor("projectile_speed"),
		}
		if v:HasModifier("modifier_ability_thdots_yamame03_debuff") or v:HasModifier("modifier_ability_thdots_yamameEx_debuff") then
			ProjectileManager:CreateTrackingProjectile(info)
		end
	end
end

function ability_thdots_yamame02:OnProjectileHit(hTarget, vLocation)
	if not hTarget then return end
	local caster = self:GetCaster()
	local ability = self
	local modifier_spawn = "modifier_ability_thdots_yamame02_debuff"

	hTarget:AddNewModifier(caster, self, modifier_spawn, {duration = self.duration})

	local damage_tabel = {
				victim 			= hTarget,
				damage 			= self.damage,
				damage_type		= self:GetAbilityDamageType(),
				damage_flags 	= self:GetAbilityTargetFlags(),
				attacker 		= self.caster,
				ability 		= self
			}
	UnitDamageTarget(damage_tabel)
	hTarget:EmitSound("Hero_Broodmother.SpawnSpiderlingsImpact")
end

modifier_ability_thdots_yamame02_debuff = {}
LinkLuaModifier("modifier_ability_thdots_yamame02_debuff","scripts/vscripts/abilities/abilityyamame.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_yamame02_debuff:IsHidden() 		return false end
function modifier_ability_thdots_yamame02_debuff:IsPurgable()		return true end
function modifier_ability_thdots_yamame02_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_yamame02_debuff:IsDebuff()			return true end

function modifier_ability_thdots_yamame02_debuff:GetEffectName() return "particles/econ/items/broodmother/bm_lycosidaes/bm_lycosidaes_spiderlings_debuff.vpcf" end
function modifier_ability_thdots_yamame02_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_ability_thdots_yamame02_debuff:OnCreated()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.ability						= self:GetAbility()
	self.damage							= self.ability:GetSpecialValueFor("damage") 
end

function modifier_ability_thdots_yamame02_debuff:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_ATTACKED,
	}
end

function modifier_ability_thdots_yamame02_debuff:OnAttacked(keys)
	if not IsServer() then return end
	if keys.attacker == self:GetCaster() and keys.target == self:GetParent() then
		local damage_tabel = {
				victim 			= self:GetParent(),
				damage 			= self.damage,
				damage_type		= DAMAGE_TYPE_PHYSICAL,
				damage_flags 	= self.ability:GetAbilityTargetFlags(),
				attacker 		= self.caster,
				ability 		= self.ability
			}
		UnitDamageTarget(damage_tabel)
		self:Destroy()
	end
end

--------------------------------------------------------
--瘴气「原因不明之热病」
--------------------------------------------------------
ability_thdots_yamame03 = {}

function ability_thdots_yamame03:GetCastRange()
	return self:GetSpecialValueFor("cast_range") + self:GetCaster():GetCastRangeBonus()
end

function ability_thdots_yamame03:OnSpellStart()
	self.caster 						= self:GetCaster()
	if is_spell_blocked(self:GetCursorTarget(),self.caster) then return end
	local info = {
			Source = self:GetCaster(),
			Target = self:GetCursorTarget(),
			Ability = self,
			bDodgeable = true,
			EffectName = "particles/units/heroes/hero_broodmother/broodmother_web_cast.vpcf",
			iMoveSpeed = 1200--self:GetSpecialValueFor("projectile_speed"),
		}

		ProjectileManager:CreateTrackingProjectile(info)

	self:GetCaster():EmitSound("Hero_Broodmother.SpawnSpiderlingsCast")
	-- local radius = 500
	-- local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_web_strand_parent_b.vpcf",
	--  PATTACH_POINT_FOLLOW, self:GetCaster())
    -- ParticleManager:SetParticleControl(particle, 0, Vector(radius, radius, radius))
    -- ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, radius))
    -- ParticleManager:SetParticleControl(particle, 2, Vector(radius, radius, radius))
    -- ParticleManager:SetParticleControl(particle, 3, Vector(radius, radius, radius))
    -- ParticleManager:ReleaseParticleIndex(particle)
end

function ability_thdots_yamame03:OnProjectileHit(hTarget, vLocation)
	if not hTarget then return end
	local caster = self:GetCaster()
	local ability = self
	local modifier_spawn = "modifier_ability_thdots_yamame03_debuff"

	-- Ability specials
	local buff_duration = ability:GetSpecialValueFor("buff_duration")	
	local damage = ability:GetSpecialValueFor("damage")
		
	hTarget:AddNewModifier(caster, self, modifier_spawn, {duration = self:GetSpecialValueFor("duration")})

	hTarget:EmitSound("Hero_Broodmother.SpawnSpiderlingsImpact")
end

modifier_ability_thdots_yamame03_debuff = {}
LinkLuaModifier("modifier_ability_thdots_yamame03_debuff","scripts/vscripts/abilities/abilityyamame.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_yamame03_debuff:IsHidden() 		return false end
function modifier_ability_thdots_yamame03_debuff:IsPurgable()		return true end
function modifier_ability_thdots_yamame03_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_yamame03_debuff:IsDebuff()			return true end
function modifier_ability_thdots_yamame03_debuff:GetAttributes() 	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_ability_thdots_yamame03_debuff:GetEffectName() return "particles/units/heroes/hero_broodmother/broodmother_spiderlings_debuff.vpcf" end
function modifier_ability_thdots_yamame03_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_ability_thdots_yamame03_debuff:OnCreated()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.ability						= self:GetAbility()
	self.damage							= self.ability:GetSpecialValueFor("damage") + FindTelentValue(self.caster,"special_bonus_unique_yamame_3")
	self.duration						= self.ability:GetSpecialValueFor("duration")
	self.radius							= self.ability:GetSpecialValueFor("radius")
	self.num							= self.ability:GetSpecialValueFor("num")
	self:GetParent().Yamame04_IsDoneUnit = false
	self:StartIntervalThink(1)
	--音效
end

-- function modifier_ability_thdots_yamame03_debuff:OnRefresh()
-- 	self:OnCreated()
-- end

function modifier_ability_thdots_yamame03_debuff:OnIntervalThink()
	if not IsServer() then return end
	local damage = self.damage
	local damage_tabel = {
				victim 			= self:GetParent(),
				damage 			= damage,
				damage_type		= self.ability:GetAbilityDamageType(),
				damage_flags 	= self.ability:GetAbilityTargetFlags(),
				attacker 		= self.caster,
				ability 		= self.ability
			}
	UnitDamageTarget(damage_tabel)
end

function modifier_ability_thdots_yamame03_debuff:OnDeath(keys)
	if not IsServer() then return end
	-- if keys.unit == self:GetParent() and self:GetParent().Yamame04_IsDoneUnit == false then
	if keys.unit == self:GetParent() and keys.attacker:GetTeam() ~= keys.unit:GetTeam() then
		print(keys.attacker:GetName())
		self:GetParent().Yamame04_IsDoneUnit = true
		local targets = FindUnitsInRadius(self.caster:GetTeam(), self:GetParent():GetOrigin(),nil,self.radius,self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),0,0,false)
		DeleteDummy(targets)
		local HasDebuff_table = {}
		local num = self.num
		print("---------")
		print("1")
		print("num is ",num)
		for _,v in pairs(targets) do
			if v == self:GetParent() or v:HasModifier("modifier_ability_thdots_yamame03_debuff") then break end
			local info = {
				Source = keys.unit,
				Target = v,
				Ability = self.ability,
				bDodgeable = true,
				EffectName = "particles/units/heroes/hero_broodmother/broodmother_web_cast.vpcf",
				iMoveSpeed = 1200,
			}
			ProjectileManager:CreateTrackingProjectile(info)
		print("2")
		print("num is ",num)
			num = num - 1
			table.insert(HasDebuff_table,v)
			if num <= 0 then return end
		end
		if num > 0 then
				print("3")
				print("num is ",num)
			for _,v in pairs(targets) do
				if v == self:GetParent() or Yamame04_IsDoneUnit(v,HasDebuff_table) then 
					print("false")
					break
					 end
				local info = {
					Source = keys.unit,
					Target = v,
					Ability = self.ability,
					bDodgeable = true,
					EffectName = "particles/units/heroes/hero_broodmother/broodmother_web_cast.vpcf",
					iMoveSpeed = 1200,
				}
				ProjectileManager:CreateTrackingProjectile(info)
				print("4")
				print("num is ",num)
				num = num - 1
				if num <= 0 then return end
			end
		end
	end
end

function Yamame04_IsDoneUnit(unit,targets)
	for _,target in pairs(targets) do
		if unit == target then
			return true
		end
	end
	return false
end
function modifier_ability_thdots_yamame03_debuff:CheckState()
	if self:GetParent():GetHealthPercent() <= 30 then
		return {
			[MODIFIER_STATE_SPECIALLY_DENIABLE] = true,
		}
	end
end	

function modifier_ability_thdots_yamame03_debuff:DeclareFunctions()	
	return {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_ability_thdots_yamame03_debuff:GetModifierHealAmplify_PercentageTarget()
	return self:GetAbility():GetSpecialValueFor("regen_reduce")
end

function modifier_ability_thdots_yamame03_debuff:GetModifierHPRegenAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("regen_reduce")
end

function modifier_ability_thdots_yamame03_debuff:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("regen_reduce")
end


--------------------------------------------------------
--细网「犍陀多绳索」
--------------------------------------------------------

ability_thdots_yamame04 = {}

function ability_thdots_yamame04:GetCastRange()
	if self:GetCaster():HasModifier("modifier_ability_thdots_yamameEx_talent_1") then
		return self:GetSpecialValueFor("talent_range") + self:GetCaster():GetCastRangeBonus()
	else
		return self:GetSpecialValueFor("cast_range") + self:GetCaster():GetCastRangeBonus()
	end
end

function ability_thdots_yamame04:CastFilterResultTarget(target)
	if target == self:GetCaster() then
		self:ToggleAutoCast()
		return UF_FAIL_CUSTOM
	end
end

function ability_thdots_yamame04:OnSpellStart()
	if not IsServer() then return end
	self.caster 				= self:GetCaster()
	self.damage					= self:GetSpecialValueFor("damage")
	self.speed					= self:GetSpecialValueFor("speed")
	self.cast_range				= self:GetSpecialValueFor("cast_range") + FindTelentValue(self.caster,"special_bonus_unique_yamame_4")
	self.hook_speed				= self:GetSpecialValueFor("hook_speed")
	self.caster:EmitSound("Voice_Thdots_Yamame.AbilityYamame04_1")
	if FindTelentValue(self.caster,"special_bonus_unique_yamame_4") ~= 0 then
		self.hook_speed = self.hook_speed + self.speed
		self:RefreshCharges()
	end
	self.direction = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized()
	self.direction.z = 0
	self.point = self:GetCursorPosition()
	-- self:SetActivated(false)

	local hookshot_duration	= ((self.cast_range + self:GetCaster():GetCastRangeBonus()) / self.hook_speed)
	local hookshot_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_hookshot.vpcf", PATTACH_CUSTOMORIGIN, nil)
	-- CP0 is the hook's starting point
	ParticleManager:SetParticleControlEnt(hookshot_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	-- CP1 is the farthest point the hook will travel
	ParticleManager:SetParticleControl(hookshot_particle, 1, self:GetCaster():GetAbsOrigin() + self.direction * (self.cast_range + self:GetCaster():GetCastRangeBonus()))
	-- CP2 is the speed at which the hook travels
	ParticleManager:SetParticleControl(hookshot_particle, 2, Vector(self.hook_speed, 0, 0))
	-- CP3 is the duration at which the hook will last for
	ParticleManager:SetParticleControl(hookshot_particle, 3, Vector(hookshot_duration, 0, 0))
	local linear_projectile = {
		Ability				= self,
		-- EffectName			= "particles/units/heroes/hero_rattletrap/rattletrap_hookshot.vpcf", -- Doesn't do anything
		vSpawnOrigin		= self:GetCaster():GetAbsOrigin(),
		fDistance			= self.cast_range + self:GetCaster():GetCastRangeBonus(),
		fStartRadius		= self:GetSpecialValueFor("latch_radius"),
		fEndRadius			= self:GetSpecialValueFor("latch_radius"),
		Source				= self:GetCaster(),
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_TREE,
		fExpireTime 		= GameRules:GetGameTime() + 10.0,
		bDeleteOnHit		= true,
		vVelocity			= (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * self.hook_speed * Vector(1, 1, 0),
		bProvidesVision		= false,
		
		ExtraData			= {hookshot_particle = hookshot_particle}
	}
	self.projectile = ProjectileManager:CreateLinearProjectile(linear_projectile)

end

function ability_thdots_yamame04:OnProjectileThink_ExtraData(vLocation, ExtraData)
	if not IsServer() then return end
	--天赋对树木生效
	if self:GetAutoCastState() then
		local trees = GridNav:GetAllTreesAroundPoint(vLocation, 75, false)
		for _,tree in pairs(trees) do
			if #trees >=1 then
				if #trees > 1 then
					ClosestTree(trees,tree,vLocation)
				end
				StartSoundEventFromPosition("Voice_Thdots_Yamame.AbilityYamame04_2",vLocation)
				self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_yamame04_move", 
				{
					duration 		= 2,
					ent_index		= tree:GetEntityIndex()
				})
				if ExtraData.hookshot_particle then
					ParticleManager:DestroyParticle(ExtraData.hookshot_particle, true)
					ParticleManager:ReleaseParticleIndex(ExtraData.hookshot_particle)
					ProjectileManager:DestroyLinearProjectile(self.projectile)
				end
				return
			end
		end
	end
end

function ClosestTree(trees,tree,vLocation)
	local distance = (tree:GetOrigin() - vLocation):Length2D()
	for i=1,#trees do
        if (trees[i]:GetOrigin() - vLocation):Length2D() < distance then
            distance = (trees[i]:GetOrigin() - vLocation):Length2D()
            tree = trees[i]
        end
    end
end

function ability_thdots_yamame04:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if not IsServer() then return end
	if hTarget then
		if hTarget ~= self:GetCaster() and string.find(hTarget:GetName(),"trigger_thd_teleport") ~= 1 
			and hTarget:GetName()~= "thd_blue_entity" and not hTarget:HasModifier("dummy_unit") then
			hTarget:EmitSound("Voice_Thdots_Yamame.AbilityYamame04_2")
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_yamame04_move", 
			{
				duration 		= 10,
				ent_index		= hTarget:GetEntityIndex()
			})
			if ExtraData.hookshot_particle then
				ParticleManager:DestroyParticle(ExtraData.hookshot_particle, true)
				ParticleManager:ReleaseParticleIndex(ExtraData.hookshot_particle)
				ProjectileManager:DestroyLinearProjectile(self.projectile)
			end
		end
	else
		-- self:SetActivated(true)
	end
end


modifier_ability_thdots_yamame04_move = {}
LinkLuaModifier("modifier_ability_thdots_yamame04_move","scripts/vscripts/abilities/abilityyamame.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_yamame04_move:IsHidden() 		return true end
function modifier_ability_thdots_yamame04_move:IsPurgable()		return true end
function modifier_ability_thdots_yamame04_move:RemoveOnDeath() 	return true end
function modifier_ability_thdots_yamame04_move:IsDebuff()		return false end


function modifier_ability_thdots_yamame04_move:OnCreated(params)
	if not IsServer() then return end
	self.caster 		= self:GetCaster()
	self.ability 		= self:GetAbility()
	self.damage			= self.ability:GetSpecialValueFor("damage")
	self.duration		= self.ability:GetSpecialValueFor("duration") + FindTelentValue(self.caster,"special_bonus_unique_yamame_2")
	self.target			= EntIndexToHScript(params.ent_index)
	self.true_speed 	= 40
	--特效
	self.effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_lily.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
		ParticleManager:SetParticleControlEnt(self.effectIndex , 0, self.caster, 5, "attach_hitloc", Vector(0,0,0), true)
	if self.target:GetName() == "" then
		self.dummy = CreateUnitByName("npc_no_vision_dummy_unit", 
	    	                        self.target:GetOrigin(), 
									false, 
								    self.caster, 
									self.caster, 
									self.caster:GetTeamNumber()
									)
		ParticleManager:SetParticleControlEnt(self.effectIndex , 1, self.dummy, 5, "attach_hitloc", Vector(0,0,0), true)
	else
		ParticleManager:SetParticleControlEnt(self.effectIndex , 1, self.target, 5, "attach_hitloc", Vector(0,0,0), true)
	end

	if FindTelentValue(self.caster,"special_bonus_unique_yamame_4") ~= 0 then
		self.true_speed = self.true_speed + 100
	end
	if self.target:GetTeam() ~= self:GetCaster():GetTeam() and self.target:GetName() ~= "" then
	print(self.target:GetName())
		local damage = self.damage
		local damage_tabel = {
			victim 			= self.target,
			damage 			= damage,
			damage_type		= DAMAGE_TYPE_PHYSICAL,
			damage_flags 	= self.ability:GetAbilityTargetFlags(),
			attacker 		= self.caster,
			ability 		= self.ability
		}
		if FindTelentValue(self.caster,"special_bonus_unique_yamame_2") ~= 0 then
			self.target:AddNewModifier(self.caster, self.ability, "modifier_ability_thdots_yamame04_rooted",{duration = self.duration})
		end
		UnitDamageTarget(damage_tabel)
		damage_tabel.damage_type = DAMAGE_TYPE_MAGICAL
		UnitDamageTarget(damage_tabel)
	end
	self:StartIntervalThink(FrameTime())
end
function modifier_ability_thdots_yamame04_move:OnIntervalThink()
	if not IsServer() then return end
	local vec = (self.target:GetOrigin() - self.caster:GetAbsOrigin()):Normalized()
	if (self.caster:GetOrigin() - self.target:GetOrigin()):Length2D() > 150 then
		self.true_speed = self.true_speed + 5 -- 速度
	else
		self.true_speed = 40
	end
	if (self.caster:GetOrigin() - self.target:GetOrigin()):Length2D() <= 50 then
		ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
		-- self.target:CutDown(self.caster:GetTeamNumber()) --砍树
		self:Destroy()
	else
		self.caster:SetAbsOrigin(self.caster:GetAbsOrigin() + vec * self.true_speed)
	end
end

function modifier_ability_thdots_yamame04_move:OnDestroy()
	if not IsServer() then return end
	-- self.ability:SetActivated(true)
	ParticleManager:DestroyParticleSystem(self.effectIndex,true)
	if self.dummy ~= nil then
		self.dummy:RemoveSelf()
	end
end

modifier_ability_thdots_yamame04_rooted = {}
LinkLuaModifier("modifier_ability_thdots_yamame04_rooted","scripts/vscripts/abilities/abilityyamame.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_yamame04_rooted:IsHidden() 		return false end
function modifier_ability_thdots_yamame04_rooted:IsPurgable()		return true end
function modifier_ability_thdots_yamame04_rooted:RemoveOnDeath() 	return true end
function modifier_ability_thdots_yamame04_rooted:IsDebuff()		return true end

function modifier_ability_thdots_yamame04_rooted:GetEffectName()
	return "particles/units/heroes/hero_broodmother/broodmother_incapacitatingbite_debuff.vpcf"
end
function modifier_ability_thdots_yamame04_rooted:CheckState() --缠绕
	return {
		[MODIFIER_STATE_ROOTED] = true,
	}
end