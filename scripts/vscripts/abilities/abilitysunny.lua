--------------------------------------------------------
--光精「交叉反射」
--------------------------------------------------------
ability_thdots_sunnyEx = {}

function ability_thdots_sunnyEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_sunnyEx_passive"
end

modifier_ability_thdots_sunnyEx_passive = {}
LinkLuaModifier("modifier_ability_thdots_sunnyEx_passive","scripts/vscripts/abilities/abilitysunny.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_sunnyEx_passive:IsHidden() 		return false end
function modifier_ability_thdots_sunnyEx_passive:IsPurgable()		return false end
function modifier_ability_thdots_sunnyEx_passive:RemoveOnDeath() 	return false end
function modifier_ability_thdots_sunnyEx_passive:IsDebuff()		return false end

function modifier_ability_thdots_sunnyEx_passive:OnCreated()
	self.caster 						= self:GetParent()
	self.int 							= self:GetAbility():GetSpecialValueFor("int")
	self.resistance 					= self:GetAbility():GetSpecialValueFor("resistance")
	self.regen_bonus 					= self:GetAbility():GetSpecialValueFor("regen_bonus")
	self.bonus 							= nil
	self:StartIntervalThink(0.03)
end

function modifier_ability_thdots_sunnyEx_passive:OnIntervalThink()
	self.caster_int 					= self.caster:GetIntellect()
	self.bonus = ( self.caster_int / self.int ) * self.resistance
	if IsServer() then
		if GameRules:IsDaytime() then
			self:SetStackCount(1)
		else
			self:SetStackCount(0)
		end
	end
end

function modifier_ability_thdots_sunnyEx_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
end

function modifier_ability_thdots_sunnyEx_passive:GetModifierConstantHealthRegen()
	if self:GetStackCount() ~= 0 then
		return self:GetParent():GetLevel() * self.regen_bonus
	else
		return 0
	end
end
function modifier_ability_thdots_sunnyEx_passive:GetModifierMagicalResistanceBonus()
	return self.bonus
end

--------------------------------------------------------
--光符「黄光偏斜」
--------------------------------------------------------
ability_thdots_sunny01 = {}

function ability_thdots_sunny01:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local duration  			= self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_ability_thdots_sunny01", {duration = duration})
	self.invis = caster:AddNewModifier(caster, self, "modifier_invisible", {duration = duration})

	EmitSoundOn("DOTA_Item.InvisibilitySword.Activate", caster)
end

modifier_ability_thdots_sunny01 = {}
LinkLuaModifier("modifier_ability_thdots_sunny01","scripts/vscripts/abilities/abilitysunny.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_sunny01:IsHidden() 		return false end
function modifier_ability_thdots_sunny01:IsPurgable()		return false end
function modifier_ability_thdots_sunny01:RemoveOnDeath() 	return true end
function modifier_ability_thdots_sunny01:IsDebuff()		return false end

function modifier_ability_thdots_sunny01:OnCreated()
	self.movement_speed = self:GetAbility():GetSpecialValueFor("movement_speed")
	if not IsServer() then return end
	self:StartIntervalThink(0.03)
end

function modifier_ability_thdots_sunny01:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_invisible") then
		self:Destroy()
	end
end
function modifier_ability_thdots_sunny01:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_ability_thdots_sunny01:GetModifierMoveSpeedBonus_Percentage()
	return self.movement_speed
end

--------------------------------------------------------
--日热「冰质分解」
--------------------------------------------------------
ability_thdots_sunny02 = {}

function ability_thdots_sunny02:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end

function ability_thdots_sunny02:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local radius  				= self:GetSpecialValueFor("radius")
	local damage  				= self:GetSpecialValueFor("damage")
	local stun_time  			= self:GetSpecialValueFor("stun_time")
	local int_bonus  			= self:GetSpecialValueFor("int_bonus")
	damage = damage + caster:GetIntellect() * int_bonus

	--特效音效
	sunny02_effect(caster,radius)
	caster:EmitSound("Hero_Tinker.LaserImpact")
	--伤害
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(),
									self:GetAbilityTargetType(),0,0,false)
	for _,v in pairs(targets) do
		local damage_table = {
				ability = self,
				victim = v,
				attacker = caster,
				damage = damage,
				damage_type = self:GetAbilityDamageType(), 
				damage_flags = 0
		}
		UtilStun:UnitStunTarget(caster,v,stun_time)
		UnitDamageTarget(damage_table)
	end
end

function sunny02_effect(caster,radius)
	local direct = math.acos(caster:GetForwardVector().x)

	local dummy = CreateUnitByName("npc_no_vision_dummy_unit", 
	    	                        caster:GetOrigin(), 
									false, 
								    caster, 
									caster, 
									caster:GetTeamNumber()
									)
	local top = dummy:GetOrigin()
	dummy:FindAbilityByName("ability_dummy_unit"):SetLevel(1)
	dummy:SetAbsOrigin(Vector(top.x,top.y,top.z+500))
	local time = 2
	dummy:SetContextThink("dummy_kill",
		function ( )
			time = time - 0.03
			if time > 0 then
				dummy:SetAbsOrigin(Vector(top.x,top.y,top.z+500))
				return 0.03
			else
				dummy:ForceKill(true)
				return nil
			end
		end, 
		0)
	
	for k=0,4 do
		local rad = Vector(math.cos(direct+math.pi/2.5*k),math.sin(direct+math.pi/2.5*k),0) --五个方向
		local dummy_kid = CreateUnitByName("npc_no_vision_dummy_unit", 
	    	                        caster:GetAbsOrigin()+ rad * radius, 
									false, 
								    caster, 
									caster, 
									caster:GetTeamNumber()
									)
		local time = 2
		dummy_kid:FindAbilityByName("ability_dummy_unit"):SetLevel(1)
		dummy_kid:SetContextThink("dummy_kill",
			function ( )
				time = time - 0.03
				if time > 0 then
					-- dummy_kid:SetAbsOrigin(Vector(top.x,top.y,top.z+500))
					return 0.03
				else
					dummy_kid:ForceKill(true)
					return nil
				end
			end, 
		0)
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_laser.vpcf", PATTACH_CUSTOMORIGIN,dummy)
		ParticleManager:SetParticleControlEnt(effectIndex , 0, dummy, 5, "attach_hitloc", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(effectIndex , 1, dummy_kid, 5, "attach_hitloc", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(effectIndex , 9, dummy, 5, "attach_hitloc", Vector(0,0,0), true)
	end
end

--------------------------------------------------------
--光符「蓝光反射」
--------------------------------------------------------
ability_thdots_sunny03 = {}

function ability_thdots_sunny03:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local target 				= self:GetCursorTarget()
	local damage  				= self:GetSpecialValueFor("damage")
	local damage_bonus  		= self:GetSpecialValueFor("damage_bonus") / 100
	local duration  			= self:GetSpecialValueFor("duration")
	local regen_reduce  		= self:GetSpecialValueFor("regen_reduce")
	local int_bonus  			= self:GetSpecialValueFor("int_bonus")
	local radius  				= self:GetSpecialValueFor("radius")
	damage = damage + caster:GetIntellect() * int_bonus
	--特效音效
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_laser.vpcf", PATTACH_CUSTOMORIGIN,caster)
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_attack2", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 1, target, 5, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effectIndex , 9, caster, 5, "attach_attack2", Vector(0,0,0), true)
	target:EmitSound("Hero_Tinker.LaserImpact")

	target:AddNewModifier(caster,self, "modifier_ability_thdots_sunny03_debuff", {duration = duration})
	local damage_table = {
				ability = self,
				victim = target,
				attacker = caster,
				damage = damage,
				damage_type = self:GetAbilityDamageType(), 
				damage_flags = 0
		}
	UnitDamageTarget(damage_table)

	local targets = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(),
									self:GetAbilityTargetType(),0,0,false)
	DeleteDummy(targets)
	for i,unit in pairs(targets) do
		if unit == target then
			table.remove(targets, i)
		end
	end
	if #targets == 0 then return end
	for _,v in pairs(targets) do
		--特效音效
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_laser.vpcf", PATTACH_CUSTOMORIGIN,target)
		ParticleManager:SetParticleControlEnt(effectIndex , 0, target, 5, "attach_hitloc", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(effectIndex , 1, v, 5, "attach_hitloc", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(effectIndex , 9, target, 5, "attach_hitloc", Vector(0,0,0), true)
		v:EmitSound("Hero_Tinker.LaserImpact")

		v:AddNewModifier(caster,self, "modifier_ability_thdots_sunny03_debuff", {duration = duration})
		local damage_table = {
				ability = self,
				victim = v,
				attacker = caster,
				damage = damage * damage_bonus,
				damage_type = self:GetAbilityDamageType(), 
				damage_flags = 0
		}
		UnitDamageTarget(damage_table)
		break
	end
end

modifier_ability_thdots_sunny03_debuff = {}
LinkLuaModifier("modifier_ability_thdots_sunny03_debuff","scripts/vscripts/abilities/abilitysunny.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_sunny03_debuff:IsHidden() 		return false end
function modifier_ability_thdots_sunny03_debuff:IsPurgable()		return true end
function modifier_ability_thdots_sunny03_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_sunny03_debuff:IsDebuff()		return true end

function modifier_ability_thdots_sunny03_debuff:OnCreated()	
	if not IsServer() then return end
	--特效
end

function modifier_ability_thdots_sunny03_debuff:OnDestroy()
	if not IsServer() then return end
end

function modifier_ability_thdots_sunny03_debuff:DeclareFunctions()	
	return {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_ability_thdots_sunny03_debuff:GetModifierHealAmplify_PercentageTarget()
	return self:GetAbility():GetSpecialValueFor("regen_reduce")
end

function modifier_ability_thdots_sunny03_debuff:GetModifierHPRegenAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("regen_reduce")
end

function modifier_ability_thdots_sunny03_debuff:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("regen_reduce")
end

--------------------------------------------------------
--激光「太阳爆发」
--------------------------------------------------------
ability_thdots_sunny04 = {}

function ability_thdots_sunny04:OnSpellStart()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.damage 						= self:GetSpecialValueFor("damage")
	self.int_bonus 						= self:GetSpecialValueFor("int_bonus")
	self.damage = self.damage + self.caster:GetIntellect() * self.int_bonus
	self.caster:AddNewModifier(self.caster, self,"modifier_ability_thdots_sunny04", {})
	--设置白天
end

modifier_ability_thdots_sunny04 = {}
LinkLuaModifier("modifier_ability_thdots_sunny04","scripts/vscripts/abilities/abilitysunny.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_sunny04:IsHidden() 		return false end
function modifier_ability_thdots_sunny04:IsPurgable()		return false end
function modifier_ability_thdots_sunny04:RemoveOnDeath() 	return true end
function modifier_ability_thdots_sunny04:IsDebuff()		return false end

function modifier_ability_thdots_sunny04:OnCreated()
	if not IsServer() then return end
	self.caster 						= self:GetParent()
	self.radius 						= self:GetAbility():GetSpecialValueFor("radius")
	self.constant 						= self:GetAbility():GetSpecialValueFor("constant")
	self.base_count 					= self:GetAbility():GetSpecialValueFor("base_count")
	self.length 						= self:GetAbility():GetSpecialValueFor("length")
	self.interval = 0.3
	self.count = self.base_count + math.floor(self.caster:GetMaxHealth()/self.constant)
	self.duration = self.count * self.interval
	if not self.orbs then
		self.orbs = {}
	end
	-- print("count is ",self.count)
	self:StartIntervalThink(self.interval)
	--特效音效
	-- local count  = math.floor(self.duration/4)
	self.sun = CreateUnitByName("npc_dummy_unit", 
    	                        Vector(99999,-99999,0), 
								false, 
							    self.caster, 
								self.caster, 
								self.caster:GetTeamNumber()
								)
	self.sun:SetOrigin(Vector(99999,-99999,0))
	self.sun:AddAbility("phoenix_supernova")
	local sunness = self.sun:FindAbilityByName("phoenix_supernova")
	sunness:SetLevel(4)
	self.sun:CastAbilityImmediately(sunness, self.caster:GetPlayerOwnerID())
	self.sun:SetContextThink("sunny04_kill", 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if self.caster:HasModifier("modifier_ability_thdots_sunny04") then
				if not self.sun:HasModifier("modifier_phoenix_supernova_hiding") then
					self.sun:CastAbilityImmediately(sunness, self.caster:GetPlayerOwnerID())
				end
				return 0.03
			else
				self.sun:ForceKill(true)
				return nil
			end
		end,
	0)
end

function modifier_ability_thdots_sunny04:OnIntervalThink()
	if not IsServer() then return end
	local caster = self.caster
	local ability = self:GetAbility()
	local width = self.radius
	local length = self.length

	local orb_thinker = CreateModifierThinker(
		self:GetCaster(),
		self,
		nil, -- Maybe add one later
		{},
		self:GetCaster():GetOrigin(),
		self:GetCaster():GetTeamNumber(),
		false		
	)
	
	orb_thinker:EmitSound("Voice_Thdots_Suika.AbilitySeija01_1")
	ProjectileManager:CreateLinearProjectile({
				Ability = ability,
				EffectName = "particles/econ/items/puck/puck_alliance_set/puck_illusory_orb_aproset.vpcf",
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
				vVelocity = (caster:GetForwardVector() * Vector(1, 1, 0)):Normalized() * 1200,
				bProvidesVision = true,	
				iVisionRadius 		= 250,
				iVisionTeamNumber 	= caster:GetTeamNumber(),
				ExtraData = {
					orb_thinker		= orb_thinker:entindex(),
				}
			})
	table.insert(self.orbs, orb_thinker:entindex())
	self.count = self.count - 1
	if self.count <= 0 then
		self:Destroy()
	end
end

function ability_thdots_sunny04:OnProjectileHit_ExtraData(target, location, data)
	if not IsServer() then return end
	if target then
		print(self.damage)
		target:EmitSound("Hero_Puck.IIllusory_Orb_Damage")
		local damage_table = {
					ability = self,
					victim = target,
					attacker = self.caster,
					damage = self.damage,
					damage_type = self:GetAbilityDamageType(), 
					damage_flags = 0
			}
		UnitDamageTarget(damage_table)
	else
		EntIndexToHScript(data.orb_thinker):StopSound("Hero_Puck.Illusory_Orb")
	end
end

function modifier_ability_thdots_sunny04:OnDestroy()
	if not IsServer() then return end
	--取消特效
end

--------------------------------------------------------
--虹光「棱镜闪光」
--------------------------------------------------------
ability_thdots_sunny05 = {}

function ability_thdots_sunny05:OnInventoryContentsChanged()
	if IsServer() then
		if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
			self:SetHidden(false)
		else
			local illusion = FindUnitsInRadius(self:GetCaster():GetTeam(),self:GetCaster():GetAbsOrigin(),nil,99999,DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_BASIC+ DOTA_UNIT_TARGET_HERO,0,0,false)
			for _,v in pairs(illusion) do
				self:GetCaster():SetContextThink("sunny05_delay",--延迟，不然对自己使用会瞬间消失
					function()
						if v:HasModifier("modifier_ability_thdots_sunny05") then
							v:ForceKill(true)
							print("2")
						end
					end,
				0.03)
			end
			self:SetHidden(true)
		end
	end
end

function ability_thdots_sunny05:OnHeroCalculateStatBonus()
	self:OnInventoryContentsChanged()
end

function ability_thdots_sunny05:OnSpellStart()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.target 						= self:GetCursorTarget()
	local duration  					= self:GetSpecialValueFor("duration")
	local illusion = FindUnitsInRadius(self.caster:GetTeam(),self.caster:GetAbsOrigin(),nil,99999,DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_BASIC+ DOTA_UNIT_TARGET_HERO,0,0,false)
	for _,v in pairs(illusion) do
		if v:HasModifier("modifier_ability_thdots_sunny05") then
			print("1")
			v:ForceKill(true)
		end
	end
	self.caster:SetContextThink("sunny05",
		function()
			self.illusion = create_illusion(self,self.target:GetAbsOrigin(),0,0,duration)
			self.illusion:AddNewModifier(self.caster, self, "modifier_ability_thdots_sunny05", {})	
		end,
	0.03)
end

modifier_ability_thdots_sunny05 = {}
LinkLuaModifier("modifier_ability_thdots_sunny05","scripts/vscripts/abilities/abilitysunny.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_sunny05:IsHidden() 		return false end
function modifier_ability_thdots_sunny05:IsPurgable()		return false end
function modifier_ability_thdots_sunny05:RemoveOnDeath() 	return true end
function modifier_ability_thdots_sunny05:IsDebuff()			return false end

function modifier_ability_thdots_sunny05:CheckState()
	return {
		[MODIFIER_STATE_ATTACK_IMMUNE]			= true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] 		= true,
		[MODIFIER_STATE_DISARMED]				= true
	}
end

function modifier_ability_thdots_sunny05:OnCreated()
	if not IsServer() then return end
	self.caster = self:GetParent()
	self.illusion = self:GetAbility().illusion
	self.illusion.hero = self:GetAbility().target
	self:StartIntervalThink(0.03)
end

function modifier_ability_thdots_sunny05:OnIntervalThink()
	if not IsServer() then return end
	self.health = self.illusion.hero:GetHealth()
	local percent = self.health/self.illusion.hero:GetMaxHealth()
	if self.illusion.hero:IsAlive() then
		self.illusion:SetHealth(self.illusion:GetMaxHealth()*percent)
	else
		print("3")
		self:GetParent():ForceKill(true)
		self:Destroy()
	end
end

function create_illusion(self, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)	
	local player_id = self.caster:GetPlayerID()
	local caster_team = self.caster:GetTeam()
	local tmp = self.caster
	if GetMapName() == "dota" then
		tmp = nil
	end
	
	local illusion = CreateUnitByName(self.target:GetUnitName(), illusion_origin, true, self.caster, tmp, caster_team)  --handle_UnitOwner needs to be nil, or else it will crash the game.
	illusion:SetPlayerID(player_id)
	illusion:SetControllableByPlayer(player_id, true)

	--Level up the illusion to the caster's level.
	local caster_level = self.caster:GetLevel()
	for i = 1, caster_level - 1 do
		illusion:HeroLevelUp(false)
	end

	--Set the illusion's available skill points to 0 and teach it the abilities the caster has.
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
