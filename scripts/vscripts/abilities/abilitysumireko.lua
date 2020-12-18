-- --------------------------------------------------------
-- --「Teleportation」
-- --------------------------------------------------------
-- ability_thdots_sumirekoEx = {}

-- function ability_thdots_sumirekoEx:GetIntrinsicModifierName()
-- 	return "modifier_ability_thdots_sumirekoEx"
-- end
-- --天赋判定modifier
-- modifier_ability_thdots_sumirekoEx = {}
-- LinkLuaModifier("modifier_ability_thdots_sumirekoEx","scripts/vscripts/abilities/abilitysumireko.lua",LUA_MODIFIER_MOTION_NONE)
-- function modifier_ability_thdots_sumirekoEx:IsHidden() 			return true end
-- function modifier_ability_thdots_sumirekoEx:IsPurgable()			return false end
-- function modifier_ability_thdots_sumirekoEx:RemoveOnDeath() 		return false end
-- function modifier_ability_thdots_sumirekoEx:IsDebuff()				return false end

-- function modifier_ability_thdots_sumirekoEx:OnCreated()
-- 	if not IsServer() then return end
-- 	self:StartIntervalThink(FrameTime())
-- end

-- function modifier_ability_thdots_sumirekoEx:OnIntervalThink()
-- 	if not IsServer() then return end
-- 	if FindTelentValue(self:GetParent(),"special_bonus_unique_sumireko_1") ~= 0 and not self:GetParent():HasModifier("modifier_ability_thdots_sumirekoEx_talent_1") then
-- 		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ability_thdots_sumirekoEx_talent_1", {})
-- 	end
-- 	if FindTelentValue(self:GetParent(),"special_bonus_unique_sumireko_4") ~= 0 and not self:GetParent():HasModifier("modifier_ability_thdots_sumirekoEx_talent_2") then
-- 		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ability_thdots_sumirekoEx_talent_2", {})
-- 	end
-- end

-- modifier_ability_thdots_sumirekoEx_talent_1 = {}
-- LinkLuaModifier("modifier_ability_thdots_sumirekoEx_talent_1","scripts/vscripts/abilities/abilitysumireko.lua",LUA_MODIFIER_MOTION_NONE)
-- function modifier_ability_thdots_sumirekoEx_talent_1:IsHidden() 			return true end
-- function modifier_ability_thdots_sumirekoEx_talent_1:IsPurgable()			return false end
-- function modifier_ability_thdots_sumirekoEx_talent_1:RemoveOnDeath() 		return false end
-- function modifier_ability_thdots_sumirekoEx_talent_1:IsDebuff()				return false end

-- modifier_ability_thdots_sumirekoEx_talent_2 = {}
-- LinkLuaModifier("modifier_ability_thdots_sumirekoEx_talent_2","scripts/vscripts/abilities/abilitysumireko.lua",LUA_MODIFIER_MOTION_NONE)
-- function modifier_ability_thdots_sumirekoEx_talent_2:IsHidden() 			return true end
-- function modifier_ability_thdots_sumirekoEx_talent_2:IsPurgable()			return false end
-- function modifier_ability_thdots_sumirekoEx_talent_2:RemoveOnDeath() 		return false end
-- function modifier_ability_thdots_sumirekoEx_talent_2:IsDebuff()				return false end


-- --相位移动
-- function ability_thdots_sumirekoEx:OnSpellStart()
-- 	if not IsServer() then return end
-- 	self.caster 						= self:GetCaster()
-- 	self.range 							= self:GetSpecialValueFor("range") + self.caster:GetCastRangeBonus()
-- 	local caster = self.caster
-- 	local range  = self.range
-- 	local min_range = 125
-- 	local true_range = RandomInt(min_range, range)
-- 	local blinkVector = caster:GetOrigin() + caster:GetForwardVector() * true_range
-- 	FindClearSpaceForUnit(caster,blinkVector,true)
-- 	ProjectileManager:ProjectileDodge(caster)
-- 	--特效音效
-- 	local effectIndex = ParticleManager:CreateParticle("particles/econ/events/ti9/blink_dagger_ti9_start.vpcf", PATTACH_POINT, caster)
-- 	ParticleManager:SetParticleControl(effectIndex, 0, caster:GetAbsOrigin())
-- 	ParticleManager:DestroyParticleSystem(effectIndex, false)
-- 	caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
-- end

--------------------------------------------------------
--紙符「ＥＳＰカード手裏剣」
--------------------------------------------------------
ability_thdots_sumireko01 = {}

function ability_thdots_sumireko01:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_sumireko01:OnSpellStart()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.damage 						= self:GetSpecialValueFor("damage")
	self.speed 							= self:GetSpecialValueFor("speed")
	self.radius 						= self:GetSpecialValueFor("radius")
	self.range 							= self:GetSpecialValueFor("range")
	self.num 							= self:GetSpecialValueFor("num")

	self.caster:EmitSound("Hero_Mars.Spear.Cast")
	local angle = -10
	if FindTelentValue(self.caster,"special_bonus_unique_sumireko_5") ~= 0 then
		self.num = self.num * 2
		angle = -5
	end
	print(self.num)
	self.low_speed = 500
	self.projectile_table = {}
	local caster = self.caster
	caster.sumireko01 = false
	local start_position = caster:GetOrigin() + caster:GetForwardVector() * 50
	local qangle = QAngle(0, 0, 0)
	local end_position 			=self.caster:GetOrigin() + (self:GetCursorPosition() - self.caster:GetOrigin()):Normalized() * self.range
	end_position 			= RotatePosition(caster:GetAbsOrigin(), qangle, end_position)
	Sumireko01CreateProjectile(caster,self,start_position,end_position,self.low_speed,1)
	for i=2,self.num do
		qangle = QAngle(0, angle, 0)
		end_position 			= RotatePosition(caster:GetAbsOrigin(), qangle, end_position)
		Sumireko01CreateProjectile(caster,self,start_position,end_position,self.low_speed,i)
	end
end

function Sumireko01CreateProjectile(caster,ability,start_position,end_position,speed,i)
	local caster  			= caster
	local ability 			= ability
	-- local distance 			= ability:GetSpecialValueFor("cast_range")
	local distance 			= (end_position - start_position):Length2D()
	local DeleteOnHit = ture
	local particle 			= "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf"
	if speed == ability.low_speed then
		particle 			= "particles/heroes/seija/seija01.vpcf"
		distance = 200
	end
	local barrage = ProjectileManager:CreateLinearProjectile({
				Source = caster,
				Ability = ability,
				vSpawnOrigin = start_position,
				bDeleteOnHit = DeleteOnHit,
			    iUnitTargetTeam	 	= ability:GetAbilityTargetTeam(),
	   			iUnitTargetType 	= ability:GetAbilityTargetType(),
				EffectName = particle,
				fDistance = distance,
				fStartRadius = ability.radius,
				fEndRadius = ability.radius,
				-- vVelocity = ((point - caster:GetAbsOrigin()) * Vector(1, 1, 0)):Normalized() * 1500,
				vVelocity = ((end_position - start_position) * Vector(1, 1, 0)):Normalized() * speed,
				bReplaceExisting = false,
				bProvidesVision = false,	
				bHasFrontalCone = false,
				iUnitTargetTeam = ability:GetAbilityTargetTeam(),							
				iUnitTargetType = ability:GetAbilityTargetType(),							
			})
	local projectile = {barrage = barrage,end_position = end_position}
	ability.projectile_table[i] = projectile
end

function ability_thdots_sumireko01:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle)
	if not IsServer() then return end
	local caster = self.caster
	local target = hTarget
	local ability = self
	local damage = self.damage

	if target == nil and caster.sumireko01 == false then
					
		for i = 1,#self.projectile_table do
			if self.projectile_table[i].barrage == iProjectileHandle then
				Sumireko01CreateProjectile(caster,self,vLocation,self.projectile_table[i].end_position,ability.speed,i)
			end
		end

		caster:SetContextThink("sumireko01",
			function ()
				caster.sumireko01 = true
			end,
		0.08)
	end
	if target ~= nil and caster.sumireko01 == true then
		target:EmitSound("Hero_Mars.Spear.Knockback")
		local damageTable = {victim = target,
							damage = damage,
							damage_type = ability:GetAbilityDamageType(),
							attacker = caster,
							ability = ability
							}
		if FindTelentValue(caster,"special_bonus_unique_sumireko_5") ~= 0 then
			target:AddNewModifier(caster, self, "modifier_ability_thdots_sumireko01_debuff", {duration = FindTelentValue(caster,"special_bonus_unique_sumireko_5")})
		end
		local damage_dealt = UnitDamageTarget(damageTable)
		ProjectileManager:DestroyLinearProjectile(iProjectileHandle)
	end
end

modifier_ability_thdots_sumireko01_debuff = {} --锁闭状态
LinkLuaModifier("modifier_ability_thdots_sumireko01_debuff","scripts/vscripts/abilities/abilitysumireko.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_sumireko01_debuff:IsHidden() 		return false end
function modifier_ability_thdots_sumireko01_debuff:IsPurgable()		return true end
function modifier_ability_thdots_sumireko01_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_sumireko01_debuff:IsDebuff()		return true end

function modifier_ability_thdots_sumireko01_debuff:CheckState()
	return {
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_SILENCED] = true,
	}
end

--------------------------------------------------------
--铳符「3D Printer Gun」
--------------------------------------------------------
ability_thdots_sumireko02 = {}

function ability_thdots_sumireko01:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_sumireko02:OnSpellStart()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.damage 						= self:GetSpecialValueFor("damage") + self.caster:GetIntellect()*FindTelentValue(self.caster,"special_bonus_unique_sumireko_2")

	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local target = self:GetCursorTarget()
	local width = 50
	local length = 1500
	local travel_speed = 1500

	local particle_projectile = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf"
	local sound_assassinate = "Ability.Assassinate"
	local sound_assassinate_launch = "Hero_Sniper.AssassinateProjectile"

	-- Play assassinate sound
	EmitSoundOn(sound_assassinate, caster)

	-- Play assassinate projectile sound
	EmitSoundOn(sound_assassinate_launch, caster)
	local assassinate_projectile = {Target = target,
				Source = caster,
				Ability = self,
				EffectName = particle_projectile,
				iMoveSpeed = travel_speed,
				bDodgeable = true,
				bVisibleToEnemies = true,
				bReplaceExisting = false,
				bProvidesVision = false,
				ExtraData = {
					target_entindex		= target:entindex(),
					projectile_num		= projectile_num,
					total_projectiles	= total_projectiles,
					bAutoCast			= bAutoCast
				}
			}
	ProjectileManager:CreateTrackingProjectile(assassinate_projectile)
end

function ability_thdots_sumireko02:OnProjectileHit(target, location)
	if not IsServer() then return end
	if target == nil then return end
	if is_spell_blocked(target) then return end
	local caster = self:GetCaster()
	local ability = self
	local duration 			= self:GetSpecialValueFor("stun_duration")
	local knockback_duration = 0.2
 	local knockback_distance = 100
 	local knockback_height 	= 100
 	local damage = self.damage
	local knockback_properties = {
			 center_x 			= caster:GetOrigin().x,
			 center_y 			= caster:GetOrigin().y,
			 center_z 			= caster:GetOrigin().z,
			 duration 			= duration ,
			 knockback_duration = knockback_duration,
			 knockback_distance = knockback_distance,
			 knockback_height 	= knockback_height,
		}
	target:AddNewModifier(caster, self, "modifier_knockback", knockback_properties)
	--特效音效
	target:EmitSound("Hero_Sniper.Boom_Headshot")
	local damageTable = {victim = target,
						damage = damage,
						damage_type = ability:GetAbilityDamageType(),
						attacker = caster,
						ability = ability
						}
	local damage_dealt = UnitDamageTarget(damageTable)
end

--------------------------------------------------------
--电线杆「Telekinesis」
--------------------------------------------------------
ability_thdots_sumireko03 = {}

function ability_thdots_sumireko03:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_sumireko03:GetAssociatedSecondaryAbilities()	return "ability_thdots_sumireko03_release" end

function ability_thdots_sumireko03:OnUpgrade()
	if not self.release_ability then
		self.release_ability = self:GetCaster():FindAbilityByName("ability_thdots_sumireko03_release")
	end
	
	if self.release_ability and not self.release_ability:IsTrained() then
		self.release_ability:SetLevel(1)
	end
end

function ability_thdots_sumireko03:OnSpellStart()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.delay_time 					= self:GetSpecialValueFor("delay_time")
	self.length 						= self:GetSpecialValueFor("length")
	local position = self:GetCursorPosition()
	self.telekinesis = CreateUnitByName("npc_ability_sumireko03_telekinesis", 
			position,
			false,
			self.caster,
			self.caster,
			self.caster:GetTeam()
		)
	if self.telekinesis:FindAbilityByName("ability_dummy_unit") ~= nil then
		self.telekinesis:FindAbilityByName("ability_dummy_unit"):SetLevel(1)
	end
	--获取砸的方向
	self.telekinesis:SetForwardVector((self:GetCursorPosition() - self.caster:GetOrigin()):Normalized())
	self.sumireko03_position = self.telekinesis:GetOrigin() + (self.telekinesis:GetOrigin() - self.caster:GetOrigin()):Normalized() * self.length
	print("1")
	if not self.release_ability then
		self.release_ability = self:GetCaster():FindAbilityByName("ability_thdots_sumireko03_release")
		print("2")
	end	
	if self.release_ability then
		print("3")
		self:GetCaster():SwapAbilities(self:GetName(), self.release_ability:GetName(), false,true)
		self:GetCaster().IsSumireko03ChangeBack = false
	end
	self.caster:AddNewModifier(self.caster, self,"modifier_ability_thdots_sumireko03_release",{duration = 2})
end
--交换技能modifier
modifier_ability_thdots_sumireko03_release = {}
LinkLuaModifier("modifier_ability_thdots_sumireko03_release","scripts/vscripts/abilities/abilitysumireko.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_sumireko03_release:IsHidden() 		return true end
function modifier_ability_thdots_sumireko03_release:IsPurgable()		return false end
function modifier_ability_thdots_sumireko03_release:RemoveOnDeath() 	return false end
function modifier_ability_thdots_sumireko03_release:IsDebuff()		return false end

function modifier_ability_thdots_sumireko03_release:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if not self:GetAbility().release_ability then
		self:GetAbility().release_ability	= self:GetParent():FindAbilityByName("ability_thdots_sumireko03_release")
	end
	if not self:GetParent().IsSumireko03ChangeBack and self:GetAbility().release_ability ~= nil then
		self:GetParent():SwapAbilities(self:GetAbility():GetName(), self:GetAbility().release_ability:GetName(), true,false)
		self:GetParent().IsSumireko03ChangeBack = true
	end
	if caster:IsAlive() then
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_ability_thdots_sumireko03", {duration = self:GetAbility().delay_time})--倒下的时间
	else
		self:GetAbility().telekinesis:AddNewModifier(caster, self:GetAbility(), "modifier_ability_thdots_sumireko03", {duration = self:GetAbility().delay_time})--倒下的时间
	end
end

--砸下modifier
modifier_ability_thdots_sumireko03 = {}
LinkLuaModifier("modifier_ability_thdots_sumireko03","scripts/vscripts/abilities/abilitysumireko.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_sumireko03:IsHidden() 		return true end
function modifier_ability_thdots_sumireko03:IsPurgable()		return false end
function modifier_ability_thdots_sumireko03:RemoveOnDeath() 	return false end
function modifier_ability_thdots_sumireko03:IsDebuff()		return false end

function modifier_ability_thdots_sumireko03:OnCreated()
	if not IsServer() then return end
	--调方向
	local telekinesis = self:GetAbility().telekinesis
	if self:GetAbility().sumireko03_position ~= telekinesis:GetOrigin() then
		telekinesis:SetForwardVector((self:GetAbility().sumireko03_position- telekinesis:GetOrigin()):Normalized())
		local effectIndex = ParticleManager:CreateParticle("particles/econ/events/ti9/blink_dagger_ti9_start_lvl2.vpcf", PATTACH_POINT, telekinesis)
		ParticleManager:SetParticleControl(effectIndex, 0, telekinesis:GetAbsOrigin())
		ParticleManager:DestroyParticleSystem(effectIndex, false)
	end
	telekinesis:SetContextThink("telekinesis_donghua", 
		function ()
			telekinesis:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1,0.6)
			telekinesis:EmitSound("Voice_Thdots_Sumireko.AbilitySumireko02_1")
			-- telekinesis:StartGesture(ACT_DOTA_CAST_ABILITY_1)
		-- print("do it")
		end,
	0.2)
end

function modifier_ability_thdots_sumireko03:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetCaster()
	self.ability 						= self:GetAbility()
	self.damage 						= self.ability:GetSpecialValueFor("damage")
	self.stun_duration 					= self.ability:GetSpecialValueFor("stun_duration") + FindTelentValue(caster,"special_bonus_unique_sumireko_3")
	self.length 						= self.ability:GetSpecialValueFor("length")
	self.width 							= self.ability:GetSpecialValueFor("width")
	local unit = self.ability.telekinesis
	--position是砸下的落点
	local position = unit:GetOrigin() + (self.ability.sumireko03_position - unit:GetOrigin()):Normalized() * self.ability.length --长度
	local targets = FindUnitsInLine(caster:GetTeam(), unit:GetOrigin(), position, nil,100,self.ability:GetAbilityTargetTeam(),self.ability:GetAbilityTargetType(),0)
	--特效音效
	for i=0,5 do
		CreateModifierThinker(caster,self.ability, "modifier_thdots_sumireko03_thinker", {duration = 10},
		 unit:GetOrigin() + (self.ability.sumireko03_position - unit:GetOrigin()):Normalized() * self.ability.length/5*i, 
		 caster:GetTeamNumber(), false)
	end
	unit:EmitSound("Voice_Thdots_Sumireko.AbilitySumireko02_2")
	for _,v in pairs(targets) do
		local damage_tabel = {
				victim 			= v,
				-- Damage starts ramping from when cast time starts, so just gonna simiulate the effects by adding the cast point
				damage 			= self.damage,
				damage_type		= self.ability:GetAbilityDamageType(),
				damage_flags 	= self.ability:GetAbilityTargetFlags(),
				attacker 		= caster,
				ability 		= self.ability
			}
		UtilStun:UnitStunTarget(caster,v,self.stun_duration)
		UnitDamageTarget(damage_tabel)
	end
	unit:SetContextThink("telekinesis_remove", 
		function ()
		unit:RemoveSelf()
		end,
	0.4)
end
modifier_thdots_sumireko03_thinker = {}
LinkLuaModifier("modifier_thdots_sumireko03_thinker", "scripts/vscripts/abilities/abilitysumireko.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_thdots_sumireko03_thinker:OnCreated()
	if IsServer() then
		self.ability = self:GetAbility()
		local thinker = self:GetParent()
		local position = thinker:GetOrigin() + (self.ability.sumireko03_position - thinker:GetOrigin()):Normalized() * self.ability.length --长度
		-- local particle = "particles/econ/items/monkey_king/ti7_weapon/mk_ti7_crimson_strike.vpcf"
		-- local sumireko03_particle = ParticleManager:CreateParticle(particle, PATTACH_CUSTOMORIGIN_FOLLOW,thinker)
		-- ParticleManager:SetParticleControl(sumireko03_particle, 0 , position)
		-- ParticleManager:SetParticleControl(sumireko03_particle, 1 , position)
		-- ParticleManager:SetParticleControl(sumireko03_particle, 2 , position)
		-- ParticleManager:SetParticleControl(sumireko03_particle, 6 , position)
		-- ParticleManager:ReleaseParticleIndex(sumireko03_particle)
		local earthshock_particle = "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf"
		local earthshock_particle_fx = ParticleManager:CreateParticle(earthshock_particle, PATTACH_ABSORIGIN,thinker)
		ParticleManager:SetParticleControl(earthshock_particle_fx, 0,thinker:GetAbsOrigin())
		ParticleManager:SetParticleControl(earthshock_particle_fx, 1, Vector(250,250,1))
		ParticleManager:ReleaseParticleIndex(earthshock_particle_fx)
	end
end


--电线杆释放
ability_thdots_sumireko03_release = {}

function ability_thdots_sumireko03_release:GetAssociatedPrimaryAbilities()	return "ability_thdots_kokoro03" end

function ability_thdots_sumireko03_release:OnSpellStart()
	if not IsServer() then return end
	if not self.sumireko03_ability then
		self.sumireko03_ability	= self:GetCaster():FindAbilityByName("ability_thdots_sumireko03")
	end
	if self.sumireko03_ability then
		self.sumireko03_ability.sumireko03_position	= self:GetCursorPosition()
	end
	-- self:GetCaster():SwapAbilities(self:GetName(), self.sumireko03_ability:GetName(), false, true)
	-- self:GetCaster().IsSumireko03ChangeBack = true
	self:GetCaster():RemoveModifierByName("modifier_ability_thdots_sumireko03_release")
end

--------------------------------------------------------
--＊幻视吧！目睹异世界的狂气＊
--------------------------------------------------------
ability_thdots_sumireko04 = {}

function ability_thdots_sumireko04:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function ability_thdots_sumireko04:GetCooldown(level)
	if self:GetCaster():HasModifier("modifier_ability_thdots_sumirekoEx_talent_2") then
		return self.BaseClass.GetCooldown(self, level) - 50
	else
		return self.BaseClass.GetCooldown(self, level)
	end
end

function ability_thdots_sumireko04:GetCastAnimation()
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		return ACT_DOTA_CAST_ABILITY_5
	else
		return ACT_DOTA_CAST_ABILITY_4
	end
end

function ability_thdots_sumireko04:GetBehavior()
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		return DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	else
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	end
end

function ability_thdots_sumireko04:GetChannelTime()
	if self:GetCaster():HasModifier("modifier_item_wanbaochui") then
		return 5
	else
		return 0
	end
end

function ability_thdots_sumireko04:GetAOERadius()
	if self:GetCaster():HasModifier("modifier_ability_thdots_sumirekoEx_talent_1") then
		return self:GetSpecialValueFor("radius_talent")
	else
		return self:GetSpecialValueFor("radius")
	end
end

function ability_thdots_sumireko04:OnSpellStart()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	self.duration 						= self:GetSpecialValueFor("duration")
	self.position = self:GetCursorPosition()
	local modifier = self.caster:AddNewModifier(self.caster, self, "modifier_ability_thdots_sumireko04",{duration = self.duration})
	--每释放一次技能，position都要传递给modifier，不然会被覆盖
	modifier.position = self.position

	if not self.caster:HasModifier("modifier_item_wanbaochui") then
		self.caster:EmitSound("Voice_Thdots_Sumireko.AbilitySumireko04")
	end
end

function ability_thdots_sumireko04:OnChannelFinish(bInterrupted)
	if not IsServer() then return end
	self.caster:RemoveModifierByName("modifier_ability_thdots_sumireko04")
end

modifier_ability_thdots_sumireko04 = {}
LinkLuaModifier("modifier_ability_thdots_sumireko04","scripts/vscripts/abilities/abilitysumireko.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_sumireko04:IsHidden() 		return false end
function modifier_ability_thdots_sumireko04:IsPurgable()		return false end
function modifier_ability_thdots_sumireko04:RemoveOnDeath() 	return false end
function modifier_ability_thdots_sumireko04:IsDebuff()		return false end
function modifier_ability_thdots_sumireko04:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

modifier_ability_thdots_sumireko04_debuff = {}
LinkLuaModifier("modifier_ability_thdots_sumireko04_debuff","scripts/vscripts/abilities/abilitysumireko.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_sumireko04_debuff:IsHidden() 		return false end
function modifier_ability_thdots_sumireko04_debuff:IsPurgable()		return true end
function modifier_ability_thdots_sumireko04_debuff:RemoveOnDeath() 	return true end
function modifier_ability_thdots_sumireko04_debuff:IsDebuff()		return true end

function modifier_ability_thdots_sumireko04_debuff:DeclareFunctions()
	return{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
	}
end

function modifier_ability_thdots_sumireko04_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_ability_thdots_sumireko04_debuff:GetModifierMiss_Percentage()
	return self:GetAbility():GetSpecialValueFor("miss")
end

function modifier_ability_thdots_sumireko04:OnCreated()
	if not IsServer() then return end
	self.caster 						= self:GetCaster()
	--延迟获取position
	self.caster:SetContextThink("sumireko04_delay", 
		function ()
			self.ability						= self:GetAbility()
			self.damage							= self.ability:GetSpecialValueFor("damage")
			self.illusion_damage				= self.ability:GetSpecialValueFor("illusion_damage")
			self.mana_damage					= self.ability:GetSpecialValueFor("mana_damage")
			self.mana_limit						= self.ability:GetSpecialValueFor("mana_limit")
			self.slow							= self.ability:GetSpecialValueFor("slow")
			self.miss							= self.ability:GetSpecialValueFor("miss")
			self.radius							= self.ability:GetSpecialValueFor("radius") + FindTelentValue(self.caster,"special_bonus_unique_sumireko_1")
			self.int_bonus						= self.ability:GetSpecialValueFor("int_bonus")

			self.wanbaochui = false
			if self.caster:HasModifier("modifier_item_wanbaochui") then
				self.wanbaochui = true
			end
		
			self.core_particle = "particles/econ/items/rubick/rubick_arcana/rbck_arc_skywrath_mage_mystic_flare_ambient.vpcf"
			local sound_cast = "Hero_SkywrathMage.MysticFlare.Cast"
			EmitSoundOnLocationWithCaster(self.ability.position, sound_cast, self:GetCaster()) 
		
			-- self.time = 0
			-- self.damage_tabel = {}
			self:StartIntervalThink(FrameTime())
		end,
	FrameTime())
end

function modifier_ability_thdots_sumireko04:OnIntervalThink()
	if not IsServer() then return end
	-- self.time = self.time + FrameTime()

	local targets = FindUnitsInRadius(self.caster:GetTeam(), self.position,nil,self.radius,self.ability:GetAbilityTargetTeam()
		,self.ability:GetAbilityTargetType(),0,0,false)
	DeleteDummy(targets)
	local num = #targets
	--特效音效
	local core_particle_fx = ParticleManager:CreateParticle(self.core_particle, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(core_particle_fx, 0 , self.position)
	ParticleManager:SetParticleControl(core_particle_fx, 1, Vector(self.radius, self.damage_duration, 1))            
	ParticleManager:ReleaseParticleIndex(core_particle_fx)
	if RollPercentage(20) then
		EmitSoundOnLocationWithCaster(self.ability.position, "Hero_SkywrathMage.MysticFlare", self:GetCaster()) 
	end
	--伤害
	if self.caster:GetMana() <= 20 then
		print("------------")
		self.wanbaochui = false
	end
	if self.caster:HasModifier("modifier_item_wanbaochui") and self.wanbaochui then
		print(self.wanbaochui)
		self.caster:ReduceMana(self.mana_limit*FrameTime())
	end
	if num == 0 then return end
	local damage = (self.damage + self.caster:GetIntellect() * self.int_bonus)/ num / (1/FrameTime())
	for _,v in pairs(targets) do
		--本来的伤害
		if not v:IsRealHero() and v:GetUnitName() ~= "npc_dota_roshan" then
			damage = damage * self.illusion_damage
		end
		local damage_tabel = {
				victim 			= v,
				damage 			= damage,
				damage_type		= self.ability:GetAbilityDamageType(),
				damage_flags 	= self.ability:GetAbilityTargetFlags(),
				attacker 		= self.caster,
				ability 		= self.ability
			}
		if self.caster:HasModifier("modifier_item_wanbaochui") and self.wanbaochui then
			if not IsTHDImmune(v) then
				UtilStun:UnitStunTarget(self.caster,v,0.5)
			end
		end
		UnitDamageTarget(damage_tabel)

		-- if self.ability:GetLevel() >= 2 then--2级大招增加烧蓝
		-- 	for i=0,#self.damage_tabel do 	--存储单位的耗蓝上限
		-- 		if self.damage_tabel[i] == v then
		-- 			break
		-- 		elseif i == #self.damage_tabel then
		-- 			table.insert(self.damage_tabel,v)
		-- 		end
		-- 	end
		-- 	-- print(#self.damage_tabel)
		-- 	print(v.sumireko04_extra)
		-- 	if v.sumireko04_extra == nil then
		-- 		v.sumireko04_extra = 0
		-- 	end
		-- 	v.sumireko04_extra = v.sumireko04_extra + self.mana_damage
		-- 	local manatoburn = v:GetMaxMana() * self.mana_damage / 100

		-- 	if v.sumireko04_extra <= self.mana_limit then
		-- 		local damage_tabel = {
		-- 			victim 			= v,
		-- 			damage 			= manatoburn,
		-- 			damage_type		= DAMAGE_TYPE_PHYSICAL,
		-- 			damage_flags 	= self.ability:GetAbilityTargetFlags(),
		-- 			attacker 		= self.caster,
		-- 			ability 		= self.ability
		-- 			}
		-- 		if v:IsAlive() then
		-- 			v:ReduceMana(manatoburn)
		-- 			UnitDamageTarget(damage_tabel)
		-- 		end
		-- 	end
		-- end

		if self.ability:GetLevel() >= 2 then--2级大招增加致盲,3级大招显形
			v:AddNewModifier(self.caster,self.ability,"modifier_ability_thdots_sumireko04_debuff",{duration = 0.5})
		end
	end
end

-- function modifier_ability_thdots_sumireko04:OnDestroy()
-- 	if not IsServer() then return end
-- 	if #self.damage_tabel == 0 then return end
-- 	for i=1,#self.damage_tabel do 	--清空蓝上限
-- 		self.damage_tabel[i].sumireko04_extra = 0 
-- 	end
-- 	if self.time >= self.ability:GetSpecialValueFor("duration") then 
-- 		for i=0,6 do 
-- 			if self.caster:GetAbilityByIndex(i) ~= nil then
-- 				print(self.caster:GetAbilityByIndex(i):GetName())
-- 				print(self.caster:GetAbilityByIndex(i):GetAbilityType())
-- 				print("DOTA_LOADOUT_TYPE_ABILITY_ULTIMATE Is :",DOTA_LOADOUT_TYPE_ABILITY_ULTIMATE)
-- 				if self.caster:GetAbilityByIndex(i):GetAbilityType() ~= DOTA_LOADOUT_TYPE_ABILITY_ULTIMATE then
-- 					self.caster:GetAbilityByIndex(i):EndCooldown()
-- 				end
-- 			end
-- 		end
-- 	end
-- end

--------------------------------------------------------
--「Teleportation」
--------------------------------------------------------

ability_thdots_sumirekoEx = {}

modifier_ability_thdots_sumirekoEx = {}
modifier_ability_thdots_sumirekoEx_handler = {}
LinkLuaModifier("modifier_ability_thdots_sumirekoEx", "scripts/vscripts/abilities/abilitysumireko.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_thdots_sumirekoEx_handler","scripts/vscripts/abilities/abilitysumireko.lua",LUA_MODIFIER_MOTION_NONE)

function ability_thdots_sumirekoEx:GetChannelTime()
	return self:GetSpecialValueFor("duration")
end

function ability_thdots_sumirekoEx:GetIntrinsicModifierName()
	return "modifier_ability_thdots_sumirekoEx_handler"
end

function ability_thdots_sumirekoEx:OnSpellStart()
	self:GetCaster():EmitSound("Hero_Puck.Phase_Shift")
	
	if self:GetAutoCastState() then
		-- IMBAfication: Sinusoid
		if self:GetCursorPosition() and not self:GetCursorTarget() then
			FindClearSpaceForUnit(self:GetCaster(), self:GetCursorPosition(), true)
		elseif self:GetCursorTarget() then	
			if self:GetCursorTarget() ~= self:GetCaster() then
				self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_sumirekoEx", {duration = self:GetSpecialValueFor("duration") + FrameTime()})
			end
			
			-- Kinda hacky way to allow Puck to self-cast channel (cause I don't think there's any existing ability that actually lets you do that normally)
			self:GetCaster():SetCursorCastTarget(nil)
			self:GetCaster():SetCursorPosition(self:GetCaster():GetAbsOrigin())
			self:OnSpellStart()
		end
	end
	
	-- "The buff lingers for one server tick once the channeling ends or is interrupted, which allows using items while still invulnerable and hidden."
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ability_thdots_sumirekoEx", {duration = self:GetSpecialValueFor("duration") + FrameTime()})
end

function ability_thdots_sumirekoEx:OnChannelFinish(interrupted)
	self:GetCaster():StopSound("Hero_Puck.Phase_Shift")

	local phase_modifier = self:GetCaster():FindModifierByNameAndCaster("modifier_ability_thdots_sumirekoEx", self:GetCaster())
	
	-- "The buff lingers for one server tick once the channeling ends or is interrupted, which allows using items while still invulnerable and hidden."
	if phase_modifier then
		phase_modifier:StartIntervalThink(FrameTime())
	end
end



-- Turns Puck green or something a frame before disappearing? This probably isn't actually used
function modifier_ability_thdots_sumirekoEx:GetStatusEffectName()
	return "particles/status_fx/status_effect_phase_shift.vpcf"
end

function modifier_ability_thdots_sumirekoEx:OnCreated()
	if not IsServer() then return end
	
	ProjectileManager:ProjectileDodge(self:GetParent())
	
	local phase_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_phase_shift.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	-- This doesn't seem to match the vanilla particle affect properly...the standard is more diffused, but "particles/units/heroes/hero_puck/puck_phase_shift.vpcf" leaves a focused dot which kinda overlaps with the space
	ParticleManager:SetParticleControl(phase_particle, 0, self:GetParent():GetAbsOrigin())
	self:AddParticle(phase_particle, false, false, -1, false, false)
	
	self:GetParent():AddNoDraw()
	
	if self:GetParent() ~= self:GetCaster() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_ability_thdots_sumirekoEx:OnRefresh()
	self:OnCreated()
end

function modifier_ability_thdots_sumirekoEx:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetAbility() or not self:GetAbility():IsChanneling() then
		self:Destroy()
	end
end

function modifier_ability_thdots_sumirekoEx:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveNoDraw()
end

function modifier_ability_thdots_sumirekoEx:CheckState()
	local state =
	{
		[MODIFIER_STATE_INVULNERABLE] 	= true,
		[MODIFIER_STATE_OUT_OF_GAME]	= true,
		[MODIFIER_STATE_UNSELECTABLE]	= true,
	}
	return state
end

--天赋判定modifier

function modifier_ability_thdots_sumirekoEx_handler:IsHidden() 			return true end
function modifier_ability_thdots_sumirekoEx_handler:IsPurgable()			return false end
function modifier_ability_thdots_sumirekoEx_handler:RemoveOnDeath() 		return false end
function modifier_ability_thdots_sumirekoEx_handler:IsDebuff()				return false end

function modifier_ability_thdots_sumirekoEx_handler:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(FrameTime())
end

function modifier_ability_thdots_sumirekoEx_handler:OnIntervalThink()
	if not IsServer() then return end
	if FindTelentValue(self:GetParent(),"special_bonus_unique_sumireko_1") ~= 0 and not self:GetParent():HasModifier("modifier_ability_thdots_sumirekoEx_talent_1") then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ability_thdots_sumirekoEx_talent_1", {})
	end
	if FindTelentValue(self:GetParent(),"special_bonus_unique_sumireko_4") ~= 0 and not self:GetParent():HasModifier("modifier_ability_thdots_sumirekoEx_talent_2") then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_ability_thdots_sumirekoEx_talent_2", {})
	end
end

modifier_ability_thdots_sumirekoEx_talent_1 = {}
LinkLuaModifier("modifier_ability_thdots_sumirekoEx_talent_1","scripts/vscripts/abilities/abilitysumireko.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_sumirekoEx_talent_1:IsHidden() 			return true end
function modifier_ability_thdots_sumirekoEx_talent_1:IsPurgable()			return false end
function modifier_ability_thdots_sumirekoEx_talent_1:RemoveOnDeath() 		return false end
function modifier_ability_thdots_sumirekoEx_talent_1:IsDebuff()				return false end

modifier_ability_thdots_sumirekoEx_talent_2 = {}
LinkLuaModifier("modifier_ability_thdots_sumirekoEx_talent_2","scripts/vscripts/abilities/abilitysumireko.lua",LUA_MODIFIER_MOTION_NONE)
function modifier_ability_thdots_sumirekoEx_talent_2:IsHidden() 			return true end
function modifier_ability_thdots_sumirekoEx_talent_2:IsPurgable()			return false end
function modifier_ability_thdots_sumirekoEx_talent_2:RemoveOnDeath() 		return false end
function modifier_ability_thdots_sumirekoEx_talent_2:IsDebuff()				return false end