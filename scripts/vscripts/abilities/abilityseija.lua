--------------------------------------------------------
--欺符「逆针击」
--------------------------------------------------------
ability_thdots_seija01 = {}

modifier_ability_thdots_seija01_point = {}
LinkLuaModifier("modifier_ability_thdots_seija01_point","scripts/vscripts/abilities/abilityseija.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seija01_point:IsHidden() 		return true end
function modifier_ability_thdots_seija01_point:IsPurgable()		return false end
function modifier_ability_thdots_seija01_point:RemoveOnDeath() 	return true end
function modifier_ability_thdots_seija01_point:IsDebuff()		return false end

modifier_ability_thdots_seija01_target = {}
LinkLuaModifier("modifier_ability_thdots_seija01_target","scripts/vscripts/abilities/abilityseija.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seija01_target:IsHidden() 		return true end
function modifier_ability_thdots_seija01_target:IsPurgable()		return false end
function modifier_ability_thdots_seija01_target:RemoveOnDeath() 	return true end
function modifier_ability_thdots_seija01_target:IsDebuff()		return false end

function ability_thdots_seija01:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_seija01:OnSpellStart()
	if not IsServer() then return end
	self.caster 			= self:GetCaster()
	self.target 			= self:GetCursorTarget()
	self.point 				= self:GetCursorPosition()
	self.damage 			= self:GetSpecialValueFor("damage")
	self.int_bonus 			= self:GetSpecialValueFor("int_bonus")
	self.cast_range 		= self:GetSpecialValueFor("cast_range")
	if self.caster:HasModifier("modifier_ability_thdots_seija03") then --是否对自己判定
		self.target = self.caster
		self.caster:AddNewModifier(self.caster, self, "modifier_ability_thdots_seija01_target",{})
		return
	end
	local targets = FindUnitsInRadius(self.caster:GetTeam(),self.caster:GetAbsOrigin(),nil,self.cast_range,self:GetAbilityTargetTeam(),
		self:GetAbilityTargetType(),0,0,false)
	if #targets > 0 then
		for _,v in pairs(targets) do
			if v:HasModifier("modifier_ability_thdots_seija03") then
				self.target = v
				self.caster:AddNewModifier(self.caster, self, "modifier_ability_thdots_seija01_target",{})
				return
			end
		end
		self.caster:AddNewModifier(self.caster, self, "modifier_ability_thdots_seija01_point",{})
	else
		self.caster:AddNewModifier(self.caster, self, "modifier_ability_thdots_seija01_point",{})
	end
end
function ability_thdots_seija01:OnChannelFinish(bInterrupted)
	if not IsServer() then return end
	if self.caster:HasModifier("modifier_ability_thdots_seija01_point") then
		self.caster:RemoveModifierByName("modifier_ability_thdots_seija01_point")
	end
	if self.caster:HasModifier("modifier_ability_thdots_seija01_target") then
		self.caster:RemoveModifierByName("modifier_ability_thdots_seija01_target")
	end
end

function ability_thdots_seija01:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle)
	if not IsServer() then return end
	local caster = self.caster
	local target = hTarget
	local ability = self
	local damage = self.damage + self.int_bonus * caster:GetIntellect()
	StartSoundEventFromPosition("Voice_Thdots_Suika.AbilitySeija01_4",vLocation)
	local damageTable = {victim = target,
						damage = damage,
						damage_type = ability:GetAbilityDamageType(),
						attacker = caster,
						ability = ability
						}
	local damage_dealt = ApplyDamage(damageTable)
	ProjectileManager:DestroyLinearProjectile(iProjectileHandle)
end

function modifier_ability_thdots_seija01_point:OnCreated()
	if not IsServer() then return end
	self.ability 			= self:GetAbility()
	self.caster 			= self:GetParent()
	self.cast_range 		= self.ability:GetSpecialValueFor("cast_range")
	self.extra_cost 		= self.ability:GetSpecialValueFor("extra_cost")
	self.casterForward 		= self.caster:GetForwardVector()
	self.angle 				= 0
	self.all_angle 			= 0
	local angle_first		= 30	--初始夹角
	self.line_position 		= RotatePosition(self.caster:GetAbsOrigin(),QAngle(0, angle_first, 0), self.ability.point)
	self.clone_line_position= RotatePosition(self.caster:GetAbsOrigin(),QAngle(0, -angle_first, 0), self.ability.point)
	self.think 				= 0

	self:StartIntervalThink(0.1)
end

function modifier_ability_thdots_seija01_point:OnIntervalThink()
	if not IsServer() then return end
	local caster  			= self.caster
	local ability 			= self.ability
	local add_angel 		= 9 --最大散射角度
	local add_increase		= 1	--递增角度
	local max_angel			= 40--最大发射角度

	local qangle = QAngle(0, 0, 0)
	local clone_qangle = QAngle(0, 0, 0)
	self.angle = self.angle + add_increase
	if self.angle >= add_angel then
		self.angle = add_angel
	end
	self.all_angle = self.all_angle + self.angle
	local even = math.floor(self.all_angle/max_angel%2)
	if self.angle >= 4 then
		qangle = QAngle(0, -self.angle, 0)
		clone_qangle = QAngle(0, self.angle, 0)
	end
	if not IsEven(even) then
		qangle = QAngle(0, self.angle, 0)
		clone_qangle = QAngle(0, -self.angle, 0)
	else
		qangle = QAngle(0, -self.angle, 0)
		clone_qangle = QAngle(0, self.angle, 0)
	end
	-- caster:EmitSound("Voice_Thdots_Suika.AbilitySeija01_1")
	self.line_position 			= RotatePosition(caster:GetAbsOrigin(), qangle, self.line_position)
	self.clone_line_position	= RotatePosition(caster:GetAbsOrigin(), clone_qangle, self.clone_line_position)
	Seija01CreateProjectile(caster,ability,caster:GetAbsOrigin(),self.line_position)
	Seija01CreateProjectile(caster,ability,caster:GetAbsOrigin(),self.clone_line_position)
	caster:SetMana(caster:GetMana()-self.extra_cost)
end

function modifier_ability_thdots_seija01_target:OnCreated() --附带3技能后自机狙
	if not IsServer() then return end
	self.ability 			= self:GetAbility()
	self.caster 			= self:GetParent()
	self.cast_range 		= self.ability:GetSpecialValueFor("cast_range")
	self.extra_cost 		= self.ability:GetSpecialValueFor("extra_cost")
	self.casterForward 		= self.caster:GetForwardVector()
	self.angle 				= 0
	self.all_angle 			= 0
	local angle_first		= 30	--初始夹角
	self.start_position	 	= self.caster:GetAbsOrigin() + self.caster:GetForwardVector() *(-1100)
	self.clone_line_position= self.start_position

	self:StartIntervalThink(0.1)
end

function modifier_ability_thdots_seija01_target:OnIntervalThink()
	if not IsServer() then return end
	local caster  			= self.caster
	local ability 			= self.ability
	local target 		  	= self.ability.target
	local add_angel 		= 8 --最大散射角度
	local add_increase		= 1	--递增角度
	local max_angel			= 40--最大发射角度

	local qangle = QAngle(0, 0, 0)
	local clone_qangle = QAngle(0, 0, 0)
	self.angle = self.angle + add_increase
	if self.angle >= add_angel then
		self.angle = add_angel
	end
	self.all_angle = self.all_angle + self.angle
	local even = math.floor(self.all_angle/max_angel%2)
	if self.angle >= 4 then
		qangle = QAngle(0, -self.angle, 0)
		clone_qangle = QAngle(0, self.angle, 0)
	end
	if not IsEven(even) then
		qangle = QAngle(0, self.angle, 0)
		clone_qangle = QAngle(0, -self.angle, 0)
	else
		qangle = QAngle(0, -self.angle, 0)
		clone_qangle = QAngle(0, self.angle, 0)
	end

	self.start_position 	= RotatePosition(self.caster:GetAbsOrigin(),qangle, self.start_position)
	self.clone_line_position= RotatePosition(self.caster:GetAbsOrigin(),clone_qangle,self.clone_line_position)
	Seija01CreateProjectile(caster,ability,self.start_position,target:GetAbsOrigin())
	Seija01CreateProjectile(caster,ability,self.clone_line_position,target:GetAbsOrigin())
	caster:SetMana(caster:GetMana()-self.extra_cost)
end

function Seija01CreateProjectile(caster,ability,start_position,end_position)
	local caster  			= caster
	local ability 			= ability
	-- local distance 			= ability:GetSpecialValueFor("cast_range")
	local distance 			= 1200
	if caster:HasModifier("modifier_ability_thdots_seija01_target") then
		distance = distance +1100
	end
	StartSoundEventFromPosition("Voice_Thdots_Suika.AbilitySeija01_1",start_position)
	local particle 			= "particles/heroes/seija/seija01.vpcf"
	local barrage = ProjectileManager:CreateLinearProjectile({
				Source = caster,
				Ability = ability,
				vSpawnOrigin = start_position,
				bDeleteOnHit = true,
			    iUnitTargetTeam	 	= ability:GetAbilityTargetTeam(),
	   			iUnitTargetType 	= ability:GetAbilityTargetType(),
				EffectName = particle,
				fDistance = distance,
				fStartRadius = 50,
				fEndRadius = 50,
				-- vVelocity = ((point - caster:GetAbsOrigin()) * Vector(1, 1, 0)):Normalized() * 1500,
				vVelocity = ((end_position - start_position) * Vector(1, 1, 0)):Normalized() * 1500,
				bReplaceExisting = false,
				bProvidesVision = false,	
				bHasFrontalCone = false,
				iUnitTargetTeam = ability:GetAbilityTargetTeam(),							
				iUnitTargetType = ability:GetAbilityTargetType(),							
			})
end

--------------------------------------------------------
--逆弓「天壤梦弓」
--------------------------------------------------------
ability_thdots_seija02 = {}

modifier_ability_thdots_seija02 = {}
LinkLuaModifier("modifier_ability_thdots_seija02","scripts/vscripts/abilities/abilityseija.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seija02:IsHidden() 		return true end
function modifier_ability_thdots_seija02:IsPurgable()		return false end
function modifier_ability_thdots_seija02:RemoveOnDeath() 	return falsez end
function modifier_ability_thdots_seija02:IsDebuff()			return false end
function modifier_ability_thdots_seija02:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function ability_thdots_seija02:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local ability 				= self
	self.caster 				= caster
	self.int_bonus 				= self:GetSpecialValueFor("int_bonus")
	self.damage 				= self:GetSpecialValueFor("damage")
	self.damage_reduce 			= self:GetSpecialValueFor("damage_reduce")
	self.damage_limit 			= self:GetSpecialValueFor("damage_limit")
	self.duration_slow 			= self:GetSpecialValueFor("duration_slow")
	self.radius 				= self:GetSpecialValueFor("radius")
	self.extra_cost 			= self:GetSpecialValueFor("extra_cost")
	local num 					= self:GetSpecialValueFor("num") + 1 + FindTelentValue(caster,"special_bonus_unique_seija_2")	--最大弹幕数量
	local direction 			= caster:GetForwardVector()
	local count 				= 1										--
	local times					= 1
	self.projectile_table  		= {}
	local qangle = QAngle(0, 0, 0)
	local angle = RotatePosition(Vector(0,0,0), qangle, direction)
	local excursion = RotatePosition(Vector(0,0,0),QAngle(0, 120, 0), direction) * 150
	caster:AddNewModifier(caster, ability, "modifier_ability_thdots_seija02", {duration = 30})
	caster:SetContextThink("seija02",
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			qangle = QAngle(0, RandomInt(-10,10), 0)
			angle = RotatePosition(Vector(0,0,0), qangle, caster:GetForwardVector())
			Seija02CreateProjectile(caster,ability,caster:GetAbsOrigin()-excursion,angle,self.damage_reduce,count,self.projectile_table,times)
			times = times + 1
			qangle = QAngle(0, -RandomInt(-10,10), 0)
			angle = RotatePosition(Vector(0,0,0), qangle, caster:GetForwardVector())
			Seija02CreateProjectile(caster,ability,caster:GetAbsOrigin()+excursion,angle,self.damage_reduce,count,self.projectile_table,times)
			times = times + 1
			caster:SetMana(caster:GetMana()-self.extra_cost) --额外耗蓝
			if times >= num then
				return nil
			end
			return 0.25
		end
		,
		0)
end

function modifier_ability_thdots_seija02:OnCreated()
	if not IsServer() then return end
	self.caster 				= self:GetCaster()
	self.ability 				= self:GetAbility()
	self.reappear 				= self.ability:GetSpecialValueFor("reappear")
	self.radius 				= self.ability:GetSpecialValueFor("radius")
	self.projectile_table 		= self.ability.projectile_table
	self:StartIntervalThink(0.1)
end

function modifier_ability_thdots_seija02:OnIntervalThink()
	if not IsServer() then return end
	local end_number = 0
	for i = 1,#self.projectile_table do
		if self.projectile_table[i].barrage ~= nil then
			local barrage 					= self.projectile_table[i].barrage
			local damage_reduce 			= self.projectile_table[i].damage_reduce
			local count 					= self.projectile_table[i].count
			local direction  				= self.projectile_table[i].direction 		
			local vec 						= ProjectileManager:GetLinearProjectileLocation(barrage)
			local distance  				= (vec - self.caster:GetAbsOrigin()):Length2D()
			local radius  					= self.ability:GetSpecialValueFor("radius")
			local start_position 			= self.caster:GetAbsOrigin() - direction * radius
			if distance >= radius then
				ProjectileManager:DestroyLinearProjectile(barrage)
				self.projectile_table[i].barrage = nil
				for i = 1,#self.projectile_table do --判定弹幕是否全部消除，若是则删除Modifier
					if self.projectile_table[i].count == 5 then
						end_number = end_number + 1
						if end_number >= #self.projectile_table then
							-- self:OnDestroy() --弹幕全部消除，删除本身modifier
						end
					end
				end
				if count <= self.reappear then
					count = count + 1
					Seija02CreateProjectile(self.caster,self.ability,start_position,direction,damage_reduce,count,self.projectile_table,i)
				else
				end
			end
		end
	end
end

function ability_thdots_seija02:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle)
	if not IsServer() then return end
	local caster = self.caster
	local target = hTarget
	local ability = self
	local damage_reduce = 0
	for i = 1,#self.projectile_table do
		if self.projectile_table[i].barrage == iProjectileHandle then
			sign = i
			damage_reduce = self.projectile_table[i].damage_reduce /100
		end
	end
	if FindTelentValue(caster,"special_bonus_unique_seija_1") ~= 0 then
		damage_reduce = 0
	end

	local damage = self.damage + self.int_bonus * caster:GetIntellect()
	damage = damage *(1 - damage_reduce)
	local damageTable = {victim = target,
						damage = damage,
						damage_type = ability:GetAbilityDamageType(),
						attacker = caster,
						ability = ability
						}
	target:EmitSound("Voice_Thdots_Suika.AbilitySeija02_2")
	target:AddNewModifier(caster,ability, "modifier_ability_thdots_seija02_debuff",{duration = self.duration_slow})
	local damage_dealt = ApplyDamage(damageTable)
	for i = 1,#self.projectile_table do
		if self.projectile_table[i].barrage == iProjectileHandle then
			self.projectile_table[i].damage_reduce = self.projectile_table[i].damage_reduce + self.damage_reduce
			if self.projectile_table[i].damage_reduce >= self.damage_limit then
				self.projectile_table[i].damage_reduce = self.damage_limit
			end
		end
	end
end

function Seija02CreateProjectile(caster,ability,start_position,direction,damage_reduce,count,projectile_table,i)
	local caster  				= caster
	local ability 				= ability
	-- local distance 				= ability:GetSpecialValueFor("cast_range")
	local distance 				= 99999
	local speed 				= 500 + count * 120
	local end_position  		= caster:GetOrigin() + direction * 20000
	local particle 				= "particles/heroes/seija/seija02"..count..".vpcf"
	-- local direction_wanbaochui  = direction

	if caster:HasModifier("modifier_item_wanbaochui") then --添加万宝槌效果
		speed = 1000 + count * 120 	--弹幕速度增加
		local targets = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(),nil,ability.radius,ability:GetAbilityTargetTeam(),
		ability:GetAbilityTargetType(),0,0,false)
		for _,v in pairs (targets) do
			if v:HasModifier("modifier_ability_thdots_seija03") then
				end_position = v:GetOrigin()		--弹幕射向目标
				direction = ((end_position - start_position) * Vector(1, 1, 0)):Normalized()
			end
		end
	end

	if count ~= 1 then
		direction = RotatePosition(Vector(0,0,0), QAngle(0, RandomInt(-5,5), 0), direction)
	end
	StartSoundEventFromPosition("Voice_Thdots_Suika.AbilitySeija02_1",start_position)
	local barrage = ProjectileManager:CreateLinearProjectile({
				Source = caster,
				Ability = ability,
				vSpawnOrigin = start_position,
				bDeleteOnHit = true,
			    iUnitTargetTeam	 	= ability:GetAbilityTargetTeam(),
	   			iUnitTargetType 	= ability:GetAbilityTargetType(),
				EffectName = particle,
				fDistance = distance,
				fStartRadius = 50,
				fEndRadius = 50,
				-- vVelocity = ((end_position - start_position) * Vector(1, 1, 0)):Normalized() * speed,
				vVelocity = direction * speed,
				bReplaceExisting = false,
				bProvidesVision = true,	
				bHasFrontalCone = false,
				iUnitTargetTeam = ability:GetAbilityTargetTeam(),							
				iUnitTargetType = ability:GetAbilityTargetType(),
				iVisionRadius 		= 250,
				iVisionTeamNumber 	= caster:GetTeamNumber(),
			})
	-- direction = direction_wanbaochui
	local projectile = {barrage = barrage,damage_reduce = damage_reduce,count = count,direction = direction}
	projectile_table[i] = projectile
	-- print_r(projectile_table)
end

modifier_ability_thdots_seija02_debuff = {}
LinkLuaModifier("modifier_ability_thdots_seija02_debuff","scripts/vscripts/abilities/abilityseija.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seija02_debuff:IsHidden() 			return false end
function modifier_ability_thdots_seija02_debuff:IsPurgable()			return true end
function modifier_ability_thdots_seija02_debuff:RemoveOnDeath() 		return true end
function modifier_ability_thdots_seija02_debuff:IsDebuff()			return true end

function modifier_ability_thdots_seija02_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_ability_thdots_seija02_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movement_slow")
end


--------------------------------------------------------
--逆符「Evil in the Mirror」
--------------------------------------------------------
ability_thdots_seija03 = {}

function ability_thdots_seija03:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_ability_thdots_seijaEx_talent_3") then
		return "custom/ability_thdots_seija03_1"
	else
		return "custom/ability_thdots_seija03"
	end
end

function ability_thdots_seija03:CastFilterResultTarget(hTarget)
	if self:GetCaster():GetTeamNumber() == hTarget:GetTeamNumber() and self:GetCaster() ~= hTarget then
		if self:GetCaster():HasModifier("modifier_ability_thdots_seijaEx_talent_3") then
			return
		else
			return UF_FAIL_CUSTOM
		end
	end
end

function ability_thdots_seija03:GetIntrinsicModifierName()
	return "modifier_ability_thdots_seija03_passive"
end

function ability_thdots_seija03:OnSpellStart()
	if not IsServer() then return end
	local caster 				= self:GetCaster()
	local target 				= self:GetCursorTarget()
	local duration 				= self:GetSpecialValueFor("duration")
	self.attack 				= target:GetAverageTrueAttackDamage(target)
	if is_spell_blocked(target,caster) then return end
	if target:IsHero() then
		self.intellect_all 			= target:GetIntellect()
		self.intellect 				= target:GetBaseIntellect()
		if self.intellect_all < self.attack then
			target:AddNewModifier(caster, self, "modifier_ability_thdots_seija03_sign",{duration = duration})
		end
	end
	target:AddNewModifier(caster, self, "modifier_ability_thdots_seija03",{duration = duration})
	target:EmitSound("Voice_Thdots_Suika.AbilitySeija03_1")
end

modifier_ability_thdots_seija03 = {}
LinkLuaModifier("modifier_ability_thdots_seija03","scripts/vscripts/abilities/abilityseija.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seija03:IsHidden() 		return false end
function modifier_ability_thdots_seija03:IsPurgable()		return true end
function modifier_ability_thdots_seija03:RemoveOnDeath() 	return true end
function modifier_ability_thdots_seija03:IsDebuff()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return false
	else
		return true
	end
end

function modifier_ability_thdots_seija03:GetStatusEffectName()
	return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end

function modifier_ability_thdots_seija03:OnCreated()
	if not IsServer() then return end
	self.parent 			= self:GetParent()
	if not self.parent:IsHero() then return end
	self.attack 			= self:GetAbility().attack
	self.intellect_all 		= self.parent:GetIntellect()
	self.intellect 			= self.parent:GetBaseIntellect()
	self.level 				= self.parent:GetLevel()
	self.parent:ModifyIntellect(self.attack - self.intellect_all)
	self.attack_stackcount 	= self.parent:GetAverageTrueAttackDamage(self.parent)
	local abs = math.abs(self.intellect_all - self.attack_stackcount)
	self:SetStackCount(abs)
	self.rage_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_rage.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(self.rage_particle, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:StartIntervalThink(0.03)
end

function modifier_ability_thdots_seija03:OnIntervalThink()
	--判定若在技能期间升级，提升智力
	if not IsServer() then return end
	local level = self.parent:GetLevel() - self.level
	if level > 0 then
		self.intellect = self.intellect + self.parent:GetIntellectGain() * level
		self.level = self.parent:GetLevel()
	end
end

function modifier_ability_thdots_seija03:OnDestroy()
	if not IsServer() then return end
	local parent = self.parent
	if not self.parent:IsHero() then return end
	parent:SetBaseIntellect(self.intellect)
	ParticleManager:DestroyParticleSystem(self.rage_particle, true)
end

function modifier_ability_thdots_seija03:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

modifier_ability_thdots_seija03_sign = {}
function modifier_ability_thdots_seija03:GetModifierPreAttack_BonusDamage()
	local caster = self:GetParent()
	local damage = self:GetStackCount()
	if caster:HasModifier("modifier_ability_thdots_seija03_sign") then
		damage = -damage
	end
	return damage
end

LinkLuaModifier("modifier_ability_thdots_seija03_sign","scripts/vscripts/abilities/abilityseija.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seija03_sign:IsHidden() 		return true end
function modifier_ability_thdots_seija03_sign:IsPurgable()		return false end
function modifier_ability_thdots_seija03_sign:RemoveOnDeath() 	return false end
function modifier_ability_thdots_seija03_sign:IsDebuff() 		return false end


--判断奇偶数
function IsEven(num)
	local v = num%2
	if v==0 then
		return true
	else
		return false
	end
end

modifier_ability_thdots_seija03_passive = {}
LinkLuaModifier("modifier_ability_thdots_seija03_passive","scripts/vscripts/abilities/abilityseija.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seija03_passive:IsHidden() 		return false end
function modifier_ability_thdots_seija03_passive:IsPurgable()		return false end
function modifier_ability_thdots_seija03_passive:RemoveOnDeath() 	return false  end
function modifier_ability_thdots_seija03_passive:IsDebuff()			return false end

function modifier_ability_thdots_seija03_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_ability_thdots_seija03_passive:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.03)
end

function modifier_ability_thdots_seija03_passive:OnIntervalThink()
	if not IsServer() then return end
	if FindTelentValue(self:GetParent(),"special_bonus_unique_seija_3") ~= 0 then
		self:SetStackCount(1)
	end
end

function modifier_ability_thdots_seija03_passive:OnAttackLanded(kv)
	if not IsServer() then return end
	local caster = self:GetParent()
	local target = kv.target
	if kv.attacker == caster and target:IsHero() then
		local ability  					= self:GetAbility()		
		local caster_int 				= caster:GetIntellect()
		local caster_attack 			= caster:GetAverageTrueAttackDamage(caster)
		local target_int 				= target:GetIntellect()
		local target_attack 			= target:GetAverageTrueAttackDamage(target)
		-- print("----------------")
		-- print(caster_int)
		-- print(caster_attack)
		-- print(target_int)
		-- print(target_attack)
		if caster_attack < target_attack then --造成攻击力差距的物理伤害
			local damage_tabel = ({
				victim 			= target,
				-- Damage starts ramping from when cast time starts, so just gonna simiulate the effects by adding the cast point
				damage 			= target_attack-caster_attack,
				damage_type		= DAMAGE_TYPE_PHYSICAL,
				damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
				attacker 		= caster,
				ability 		= ability
			})
			UnitDamageTarget(damage_tabel)
		end
		if caster_int < target_int and target:IsAlive() then --造成智力差距的魔法伤害
			local damage_tabel = ({
				victim 			= target,
				-- Damage starts ramping from when cast time starts, so just gonna simiulate the effects by adding the cast point
				damage 			= target_int-caster_int,
				damage_type		= DAMAGE_TYPE_MAGICAL,
				damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
				attacker 		= caster,
				ability 		= ability
			})
			UnitDamageTarget(damage_tabel)
		end
	end
end

--------------------------------------------------------
--逆转「Reverse Hierarchy」
--------------------------------------------------------

ability_thdots_seija04 = {}

modifier_ability_thdots_seija04 = {}
LinkLuaModifier("modifier_ability_thdots_seija04","scripts/vscripts/abilities/abilityseija.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seija04:IsHidden() 		return false end
function modifier_ability_thdots_seija04:IsPurgable()		return true end
function modifier_ability_thdots_seija04:RemoveOnDeath() 	return true end
function modifier_ability_thdots_seija04:IsDebuff()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return false
	else
		return true
	end
end

function ability_thdots_seija04:GetAOERadius()
	if self:GetCaster():HasModifier("modifier_ability_thdots_seijaEx_talent_4") then
		return self:GetSpecialValueFor("talent_radius")
	else
		return self:GetSpecialValueFor("radius")
	end
end

function ability_thdots_seija04:GetCastRange(location, target)
	if self:GetCaster():HasModifier("modifier_ability_thdots_seijaEx_talent_4") then
		return self:GetSpecialValueFor("talent_range")
	else
		return self.BaseClass.GetCastRange(self, location, target)
	end
end

function ability_thdots_seija04:OnSpellStart()
	if not IsServer() then return end
	self.caster 			= self:GetCaster()
	self.target 			= self:GetCursorTarget()
	self.point 				= self:GetCursorPosition()
	self.radius 			= self:GetSpecialValueFor("radius")
	if self:GetCaster():HasModifier("modifier_ability_thdots_seijaEx_talent_4") then
		self.radius = self:GetSpecialValueFor("talent_radius")
	end
	self.isReverse 			= true --true顺时针，false逆时针
	local dummy = CreateUnitByName(
			"npc_dummy_unit"
			,self.point
			,false
			,self.caster
			,self.caster
			,self.caster:GetTeam()
		)
	dummy:SetContextThink("remove", 
		function ()
			dummy:ForceKill(true)
		end, 
		0.03)
	local particle = ParticleManager:CreateParticle("particles/heroes/seija/seija04.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
    ParticleManager:SetParticleControl(particle, 2, Vector(self.radius, self.radius, self.radius))
    ParticleManager:ReleaseParticleIndex(particle)

	if self.target ~= nil then
		self.center 		= self.target:GetAbsOrigin()
		if self.target:HasModifier("modifier_ability_thdots_seijaEx") then
			if self.target:HasModifier("modifier_ability_thdots_seijaEx_passive") then
				self.isReverse = true
			else
				self.isReverse = false
			end
		elseif self.target:HasModifier("modifier_ability_thdots_seijaEx_passive") then
			self.isReverse = false
		end
	else
		self.center 		= self.point
	end
	self.cast_range 		= 0
	local targets  			= FindUnitsInRadius(self.caster:GetTeam(),self.center, nil, self.radius, 
												self:GetAbilityTargetTeam(),self:GetAbilityTargetType(),0,0,false)
	print(self.isReverse)
	for _,v in pairs(targets) do
		if self.isReverse == true then
			if v:HasModifier("modifier_ability_thdots_seijaEx") then
				v:AddNewModifier(self.caster, self, "modifier_ability_thdots_seija04", {duration = 10})
			elseif v:HasModifier("modifier_ability_thdots_seijaEx_passive")  then
				v:AddNewModifier(self.caster, self, "modifier_ability_thdots_seija04", {duration = 10})
			end
		else
			if v:HasModifier("modifier_ability_thdots_seijaEx") then
			else
				v:AddNewModifier(self.caster, self, "modifier_ability_thdots_seija04", {duration = 10})
			end
		end
		print(v:GetName())
	end
	if self.target ~= nil then
		self.target:RemoveModifierByName("modifier_ability_thdots_seija04")
	end
	StartSoundEventFromPosition("Voice_Thdots_Suika.AbilitySeija04_1",self.center)
end

function modifier_ability_thdots_seija04:OnCreated()
	if not IsServer() then return end
	self.ability 	= self:GetAbility()
	self.parent 	= self:GetParent()
	self.center 	= self.ability.center
	self.speed 		= 10
	if self.ability.isReverse == false then
		self.speed = -10
	end
	self.limit 		= 0
	if self.parent:HasModifier("modifier_thdots_yugi04_think_interval") then --判定红三大招
		self:Destroy()
		return
	end
	if self.parent:HasModifier("modifier_thdots_yasaka04_buff") then --判定神奈子大招
		self:Destroy()
		return
	end
	if self.parent:GetName() == "npc_dota_roshan" then --判定肉山
		self:Destroy()
		return
	end
	self:StartIntervalThink(0.03)
end

function modifier_ability_thdots_seija04:OnIntervalThink()
	if not IsServer() then return end
	local position = self.parent:GetAbsOrigin()
	local qangle = QAngle(0, self.speed, 0)
	local end_position = RotatePosition(self.center, qangle, position)

	self.limit = self.limit + self.speed
	self.parent:SetOrigin(end_position)
	if self.limit >= 180 then
		self:Destroy()
	elseif self.limit <= -180 then
		self:Destroy()
	end
end

function modifier_ability_thdots_seija04:CheckState() --添加相位状态，防止卡地形
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
end

--------------------------------------------------------
--逆转「Reverse Hierarchy」
--------------------------------------------------------

ability_thdots_seijaEx = {}

function ability_thdots_seijaEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_seijaEx_passive"
end

function ability_thdots_seijaEx:OnSpellStart()
	if not IsServer() then return end
	self.caster 			= self:GetCaster()
	self.target 			= self:GetCursorTarget()
	self.duration 			= self:GetSpecialValueFor("duration")
	if is_spell_blocked(self.target,self.caster) then return end
	self.target:AddNewModifier(self.caster, self, "modifier_ability_thdots_seijaEx", {duration = self.duration})
end

modifier_ability_thdots_seijaEx = {}
LinkLuaModifier("modifier_ability_thdots_seijaEx","scripts/vscripts/abilities/abilityseija.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seijaEx:IsHidden() 		return false end
function modifier_ability_thdots_seijaEx:IsPurgable()		return true end
function modifier_ability_thdots_seijaEx:RemoveOnDeath() 	return true end
function modifier_ability_thdots_seijaEx:IsDebuff()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return false
	else
		return true
	end
end


function modifier_ability_thdots_seijaEx:OnCreated()
	if not IsServer() then return end
	self.parent 			= self:GetParent()
	if self.parent:HasModifier("modifier_ability_thdots_seijaEx_passive") then
		set_camera_yaw(self.parent,0)
	else
		set_camera_yaw(self.parent,180)
	end
end

function modifier_ability_thdots_seijaEx:OnDestroy()
	if not IsServer() then return end
	self.parent 			= self:GetParent()
	if self.parent:HasModifier("modifier_ability_thdots_seijaEx_passive") then
		set_camera_yaw(self.parent,180)
	else
		set_camera_yaw(self.parent,0)
	end
end

function set_camera_yaw(caster,sense) --sense为180度或者0度
	local plyid 		= caster:GetPlayerID()
	local plyhd 		= PlayerResource:GetPlayer(plyid)
	local angle 		= 0	--初始视角
	local num 			= 3 --旋转速率
	if sense == 180 then
		angle = 0
		num = 3
	elseif sense == 0 then
		angle = 180
		num = -3
	end
	caster:SetContextThink("yaw", 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			angle = angle + num
			CustomGameEventManager:Send_ServerToPlayer(plyhd, "set_camera_yaw", {key_val = angle} )
			if angle == sense then
				return nil
			else
				return 0.03
			end
		end, 
		0)
end

function set_camera_yaw_seija(caster,sense) --sense为180度或者0度
	local plyid 		= caster:GetPlayerID()
	local plyhd 		= PlayerResource:GetPlayer(plyid)
	CustomGameEventManager:Send_ServerToPlayer(plyhd, "set_camera_yaw", {key_val = sense} )
end

modifier_ability_thdots_seijaEx_passive = {}
LinkLuaModifier("modifier_ability_thdots_seijaEx_passive","scripts/vscripts/abilities/abilityseija.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seijaEx_passive:IsHidden() 			return false end
function modifier_ability_thdots_seijaEx_passive:IsPurgable()			return false end
function modifier_ability_thdots_seijaEx_passive:RemoveOnDeath() 		return false end
function modifier_ability_thdots_seijaEx_passive:IsDebuff()				return false end

function modifier_ability_thdots_seijaEx_passive:OnCreated()
	if not IsServer() then return end
	self.parent = self:GetParent()
	self.yaw 	= 180
	self.angle 	= 0
	self.num 	= 3
	self.parent:SetContextThink("delay", 
		function ()
		self:StartIntervalThink(0.03)
		end, 
		3)
end

function modifier_ability_thdots_seijaEx_passive:OnIntervalThink()
	if not IsServer() then return end
	if self.angle < self.yaw then
		self.angle = self.angle + self.num
		if self.angle == self.yaw then
			self.angle = self.yaw
		end
	end
	if self.angle > self.yaw then
		self.angle = self.angle - self.num
		if self.angle == self.yaw then
			self.angle = self.yaw
		end
	end
	if self.parent:HasModifier("modifier_ability_thdots_seijaEx") then
		self.yaw = 0
	else
		self.yaw = 180
	end
	set_camera_yaw_seija(self.parent,self.angle)
	if FindTelentValue(self:GetParent(),"special_bonus_unique_seija_4") ~= 0 and not self:GetParent():HasModifier("modifier_ability_thdots_seijaEx_talent_4") then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ability_thdots_seijaEx_talent_4", {})
	end
	if FindTelentValue(self:GetParent(),"special_bonus_unique_seija_3") ~= 0 and not self:GetParent():HasModifier("modifier_ability_thdots_seijaEx_talent_3") then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ability_thdots_seijaEx_talent_3", {})
	end
	if FindTelentValue(self:GetParent(),"special_bonus_unique_seija_5") ~= 0 and not self:GetParent():HasModifier("modifier_ability_thdots_seijaEx_talent_5") then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ability_thdots_seijaEx_talent_5", {})
	end
end

modifier_ability_thdots_seijaEx_talent_3 = {}
LinkLuaModifier("modifier_ability_thdots_seijaEx_talent_3","scripts/vscripts/abilities/abilityseija.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seijaEx_talent_3:IsHidden() 			return true end
function modifier_ability_thdots_seijaEx_talent_3:IsPurgable()			return false end
function modifier_ability_thdots_seijaEx_talent_3:RemoveOnDeath() 		return false end
function modifier_ability_thdots_seijaEx_talent_3:IsDebuff()			return false end

modifier_ability_thdots_seijaEx_talent_4 = {}
LinkLuaModifier("modifier_ability_thdots_seijaEx_talent_4","scripts/vscripts/abilities/abilityseija.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seijaEx_talent_4:IsHidden() 			return true end
function modifier_ability_thdots_seijaEx_talent_4:IsPurgable()			return false end
function modifier_ability_thdots_seijaEx_talent_4:RemoveOnDeath() 		return false end
function modifier_ability_thdots_seijaEx_talent_4:IsDebuff()			return false end

modifier_ability_thdots_seijaEx_talent_5 = {}
LinkLuaModifier("modifier_ability_thdots_seijaEx_talent_5","scripts/vscripts/abilities/abilityseija.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_seijaEx_talent_5:IsHidden() 			return true end
function modifier_ability_thdots_seijaEx_talent_5:IsPurgable()			return false end
function modifier_ability_thdots_seijaEx_talent_5:RemoveOnDeath() 		return false end
function modifier_ability_thdots_seijaEx_talent_5:IsDebuff()			return false end

function modifier_ability_thdots_seijaEx_talent_5:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_ability_thdots_seijaEx_talent_5:GetModifierSpellAmplify_Percentage()
	return 50
end