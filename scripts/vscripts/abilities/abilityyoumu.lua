if AbilityYoumu == nil then
	AbilityYoumu = class({})
end

function OnYoumu01SpellStart(keys)
	AbilityYoumu:OnYoumu01Start(keys)
end

function OnYoumu01SpellMove(keys)
	AbilityYoumu:OnYoumu01Move(keys)
end

function OnYoumu02SpellStart(keys)
	AbilityYoumu:OnYoumu02Start(keys)
end

function OnYoumu02SpellStartDamage(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if target:IsBuilding() then return end
	local damage_table = {
				ability = keys.ability,
			    victim = target,
			    attacker = caster,
			    damage = keys.BounsDamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = keys.ability:GetAbilityTargetFlags()
	}
	if FindTelentValue(caster,"special_bonus_unique_youmu_2") ~= 0 then
		damage_table.damage = target:GetMaxHealth() * 0.06
		damage_table.damage_type = DAMAGE_TYPE_PURE
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,target,damage_table.damage,nil)
	end
	UnitDamageTarget(damage_table)
end

function OnYoumu02SpellStartUnit(keys)
	AbilityYoumu:OnYoumu02StartUnit(keys)
end
function OnYoumu03SpellStart(keys)
	AbilityYoumu:OnYoumu03Start(keys)
end

function OnYoumu03SpellOrderMoved(keys)
	AbilityYoumu:OnYoumu03OrderMoved(keys)
end

function OnYoumu03SpellOrderAttack(keys)
	AbilityYoumu:OnYoumu03OrderAttack(keys)
end


ability_thdots_youmu04 = class ({})  



function ability_thdots_youmu04:GetAOERadius()
	if ( self:GetCaster():HasScepter() ) then
		return self:GetSpecialValueFor( "wanbaochui_radius" )
	end
	return 0
end


--function ability_thdots_youmu04:GetCooldown( nLevel )
--	local ability = self:GetCaster():FindAbilityByName("special_bonus_unique_juggernaut")
--	local telent_val = 0
    --if ability~=nil then
    --    telent_val = ability:GetSpecialValueFor("value")
    --end
--	return self.BaseClass.GetCooldown( self, nLevel ) + telent_val -- + FindTelentValue(self:GetCaster(),"special_bonus_unique_juggernaut")
--end


function ability_thdots_youmu04:OnSpellStart()
  if not IsServer() then return end
  self.caster = self:GetCaster()
  local duration = self:GetSpecialValueFor("duration")
  self.caster:AddNewModifier(self.caster, self, "modifier_thdots_youmu04_states", {
  		duration = duration})
  self.caster:EmitSound("Voice_Thdots_Youmu.AbilityYoumu04")
end

modifier_thdots_youmu04_states = {}
LinkLuaModifier("modifier_thdots_youmu04_states","scripts/vscripts/abilities/abilitymystia.lua",LUA_MODIFIER_MOTION_NONE)




function modifier_thdots_youmu04_states:IsHidden()     return true end
function modifier_thdots_youmu04_states:IsPurgable()   return false end
function modifier_thdots_youmu04_states:RemoveOnDeath()  return true end
function modifier_thdots_youmu04_states:IsDebuff()   return false end
function modifier_thdots_youmu04_states:CheckState()
	local state = {
					[MODIFIER_STATE_ATTACK_IMMUNE] = true,
					[MODIFIER_STATE_MAGIC_IMMUNE] = true,
					[MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}

	return state
end
function modifier_thdots_youmu04_states:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return funcs
end
function modifier_thdots_youmu04_states:GetEffectName()
	return "particles/thd2/heroes/youmu/youmu_04_blossoms_effect.vpcf"
end
function modifier_thdots_youmu04_states:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_thdots_youmu04_states:GetModifierIncomingDamage_Percentage()   return -100 end


function modifier_thdots_youmu04_states:OnCreated()
  self.caster           = self:GetParent()
  self.ability          = self:GetAbility()
  self.target           = self.ability:GetCursorTarget()
  self.AbilityMulti     = self:GetAbility():GetSpecialValueFor("ability_multi")
  self.WanbaochuiStun   = self:GetAbility():GetSpecialValueFor("wanbaochui_stun")
  self.WanbaochuiRadius = self:GetAbility():GetSpecialValueFor("wanbaochui_radius")
  if not IsServer() then return end
  self:StartIntervalThink(0.1)

    local caster = self.caster
	local target = self.target

	THDReduceCooldown(self.ability,FindTelentValue(caster,"special_bonus_unique_juggernaut"))
	
	
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/youmu/youmu_04_circle.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)
end


function modifier_thdots_youmu04_states:OnIntervalThink()
  if not IsServer() then return end
  AbilityYoumu:OnYoumu04Think(self)
end



function OnYoumu04SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target

	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_juggernaut"))
	
	
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/youmu/youmu_04_circle.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)
end

function OnYoumu04SpellThink(keys)
	keys.caster =  EntIndexToHScript(keys.caster_entindex)
	AbilityYoumu:OnYoumu04Think(keys)
end

function AbilityYoumu:OnYoumu01Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_juggernaut_2"))
	local targetPoint = keys.target_points[1]
	local Youmu01rad = GetRadBetweenTwoVec2D(caster:GetOrigin(),targetPoint)
	local Youmu01MoveSpeed = GetDistanceBetweenTwoVec2D(caster:GetOrigin(),targetPoint)/2
	keys.ability:SetContextNum("ability_Youmu01_Rad",Youmu01rad,0)
	keys.ability:SetContextNum("ability_Youmu01_Move_Speed",Youmu01MoveSpeed,0)
	keys.ability:SetContextNum("ability_Youmu01_Count",0,0)
end

function AbilityYoumu:OnYoumu01Move(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	--绿字伤害
	local item
    local attack = 0
    local bonusAttack = 0 
    for i=0,5 do
        item = caster:GetItemInSlot(i)
        if(item~=nil)then
            bonusAttack = item:GetSpecialValueFor("bonus_damage")
            if(bonusAttack~=nil)then
                attack = bonusAttack + attack
            end
        end
    end 
	local Damage = caster:GetAttackDamage()+attack

	local count = keys.ability:GetContext("ability_Youmu01_Count")
	count = count + 0.2
	if(count == 0.2)then
	    -- Ñ­»µ¸÷¸öÄ¿±êµ¥Î»
		for _,v in pairs(targets) do
				local damage_table = {
					ability = keys.ability,
					victim = v,
					attacker = caster,
					damage = keys.ability:GetAbilityDamage()+Damage*0.8,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = keys.ability:GetAbilityTargetFlags()
				}
				UnitDamageTarget(damage_table)
		end
		keys.ability:SetContextNum("ability_Youmu01_Count",0,0)
		local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/youmu/youmu_01_blink_effect.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, caster:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 2, caster:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 5, caster:GetOrigin())

		ParticleManager:DestroyParticleSystem(effectIndex,false)
	end
	local Youmu01rad = keys.ability:GetContext("ability_Youmu01_Rad")
	local Youmu01MoveSpeed = keys.ability:GetContext("ability_Youmu01_Move_Speed")
	local vec = Vector(vecCaster.x+math.cos(Youmu01rad)*Youmu01MoveSpeed,vecCaster.y+math.sin(Youmu01rad)*Youmu01MoveSpeed,vecCaster.z)
	local unit = caster.Youmu03_Effect_Unit
	if unit ~= nil and unit:IsNull()==false then
		unit:SetOrigin(vec)
	end
	caster:SetOrigin(vec)
	if(count==0.2)then
		SetTargetToTraversable(caster)
	end
end

function AbilityYoumu:OnYoumu02Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if(target:IsBuilding()==true)then
		return
	end

	--[[if(target:IsBuilding()==true)then
		return
	end

	if(target:GetContext("ability_Youmu02_Armor_Decrease")==nil)then
		target:SetContextNum("ability_Youmu02_Armor_Decrease",0,0)
	end
	local decreaseArmor = target:GetContext("ability_Youmu02_Armor_Decrease")
	decreaseArmor = decreaseArmor + keys.DecreaseArmor
	if(decreaseArmor>=keys.DecreaseMaxArmor)then
		decreaseArmor = 48
	end
	target:SetContextNum("ability_Youmu02_Armor_Decrease",decreaseArmor,0)
	target:SetPhysicalArmorBaseValue(keys.target:GetPhysicalArmorBaseValue() - keys.DecreaseArmor)
	]]--
	--PrintTable(keys)
	if(target.ability_Youmu02_Armor_Decrease==nil)then
		target.ability_Youmu02_Armor_Decrease = 0
	end

	if(target.ability_Youmu02_Armor_Decrease_Unit==nil)then
		target.ability_Youmu02_Armor_Decrease_Unit = 0
	end

	if(target.ability_Youmu02_Armor_Decrease_Count==nil)then
		target.ability_Youmu02_Armor_Decrease_Count = 0
	end

	if( ((-target.ability_Youmu02_Armor_Decrease) + (-target.ability_Youmu02_Armor_Decrease_Unit)) <= keys.DecreaseMaxArmor)then
		target.ability_Youmu02_Armor_Decrease = target.ability_Youmu02_Armor_Decrease + keys.DecreaseArmor
		target.ability_Youmu02_Armor_Decrease_Count = target.ability_Youmu02_Armor_Decrease_Count + 1
		target:SetModifierStackCount("modifier_youmu02_armor_decrease", keys.ability, target.ability_Youmu02_Armor_Decrease_Count)
		decreaseArmor = ((-target.ability_Youmu02_Armor_Decrease_Unit) + (-target.ability_Youmu02_Armor_Decrease))
	else
		decreaseArmor = keys.DecreaseMaxArmor
	end
	local decreaseArmor = ((-target.ability_Youmu02_Armor_Decrease_Unit) + (-target.ability_Youmu02_Armor_Decrease))

	local effectIndex4 = ParticleManager:CreateParticle("particles/heroes/youmu/youmu_02_effect_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex4, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex4, 2, target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex4, 3, target:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex4,false)
		
	local effectIndex3 = ParticleManager:CreateParticle("particles/heroes/youmu/youmu_02_effect_number_c.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex3, 0, target:GetOrigin() + Vector(-15,0,256))
	ParticleManager:DestroyParticleSystemTime(effectIndex3,0.5)

	local effectIndex = ParticleManager:CreateParticle("particles/heroes/youmu/youmu_02_effect_number.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin() + Vector(0,0,256))
	if(decreaseArmor>=10)then
		ParticleManager:SetParticleControl(effectIndex, 1, Vector(0,(decreaseArmor - decreaseArmor%10)/10,0))
	else
		ParticleManager:SetParticleControl(effectIndex, 1, Vector(0,decreaseArmor+5,0))
	end
	ParticleManager:DestroyParticleSystemTime(effectIndex,0.5)

	if(decreaseArmor>=10)then
		local effectIndex2 = ParticleManager:CreateParticle("particles/heroes/youmu/youmu_02_effect_number.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex2, 0, target:GetOrigin() + Vector(15,0,256))
		ParticleManager:SetParticleControl(effectIndex2, 1, Vector(0,decreaseArmor%10,0))
		ParticleManager:DestroyParticleSystemTime(effectIndex2,0.5)
	end

	--[[target:SetThink(
		function()
			target:SetPhysicalArmorBaseValue(keys.target:GetPhysicalArmorBaseValue() + keys.DecreaseArmor)	
			local decreaseArmorNow = target:GetContext("ability_Youmu02_Armor_Decrease") + keys.DecreaseArmor
			target:SetContextNum("ability_Youmu02_Armor_Decrease",decreaseArmorNow,0)	
		end, 
		DoUniqueString("ability_Youmu02_Armor_Decrease_Duration"), 
		keys.Duration
	)	
	]]--

end

function OnYoumu02SpellRemove(keys)
	keys.target.ability_Youmu02_Armor_Decrease = 0
	keys.target.ability_Youmu02_Armor_Decrease_Count = 0
end

function OnYoumu02SpellRemoveUnit(keys)
	keys.target.ability_Youmu02_Armor_Decrease_Unit = 0
	keys.target.ability_Youmu02_Armor_Decrease_Count_Unit = 0
end

function AbilityYoumu:OnYoumu02StartUnit(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	if(target:IsBuilding()==true)then
		return
	end

	if(target.ability_Youmu02_Armor_Decrease==nil)then
		target.ability_Youmu02_Armor_Decrease = 0
	end

	if(target.ability_Youmu02_Armor_Decrease_Unit==nil)then
		target.ability_Youmu02_Armor_Decrease_Unit = 0
	end
	if(target.ability_Youmu02_Armor_Decrease_Count_Unit==nil)then
		target.ability_Youmu02_Armor_Decrease_Count_Unit = 0
	end

	local decreaseArmor
	if(((-target.ability_Youmu02_Armor_Decrease_Unit) + (-target.ability_Youmu02_Armor_Decrease)) <= keys.DecreaseMaxArmor)then
		target.ability_Youmu02_Armor_Decrease_Unit = target.ability_Youmu02_Armor_Decrease_Unit + keys.DecreaseArmor * (1+caster.telent) --天赋魂魄双倍减甲
		target.ability_Youmu02_Armor_Decrease_Count_Unit = target.ability_Youmu02_Armor_Decrease_Count_Unit + (1+caster.telent)
		target:SetModifierStackCount("modifier_youmu02_armor_decrease_unit", keys.ability, target.ability_Youmu02_Armor_Decrease_Count_Unit)
		decreaseArmor = ((-target.ability_Youmu02_Armor_Decrease_Unit) + (-target.ability_Youmu02_Armor_Decrease))
	else
		decreaseArmor = keys.DecreaseMaxArmor
	end
	local effectIndex4 = ParticleManager:CreateParticle("particles/heroes/youmu/youmu_02_effect_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex4, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex4, 2, target:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex4, 3, target:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex4,false)
		
	local effectIndex3 = ParticleManager:CreateParticle("particles/heroes/youmu/youmu_02_effect_number_c.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex3, 0, target:GetOrigin() + Vector(-15,0,256))
	ParticleManager:DestroyParticleSystemTime(effectIndex3,0.5)

	local effectIndex = ParticleManager:CreateParticle("particles/heroes/youmu/youmu_02_effect_number.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin() + Vector(0,0,256))
	if(decreaseArmor>=10)then
		ParticleManager:SetParticleControl(effectIndex, 1, Vector(0,(decreaseArmor - decreaseArmor%10)/10,0))
	else
		ParticleManager:SetParticleControl(effectIndex, 1, Vector(0,decreaseArmor,0))
	end
	ParticleManager:DestroyParticleSystemTime(effectIndex,0.5)

	if(decreaseArmor>=10)then
		local effectIndex2 = ParticleManager:CreateParticle("particles/heroes/youmu/youmu_02_effect_number.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(effectIndex2, 0, target:GetOrigin() + Vector(15,0,256))
		ParticleManager:SetParticleControl(effectIndex2, 1, Vector(0,decreaseArmor%10,0))
		ParticleManager:DestroyParticleSystemTime(effectIndex2,0.5)
	end
end

function AbilityYoumu:OnYoumu03Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local unit = CreateUnitByName(
		"npc_thdots_unit_youmu03_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)
	local bonusdamage = keys.BounsDamage
	if FindTelentValue(caster,"special_bonus_unique_youmu_1") == 1 then
		unit.telent = 1
		bonusdamage = bonusdamage * 2
	else
		unit.telent = 0
	end
	caster.Youmu03_Effect_Unit = unit
	local bounsDamage = caster:GetAttackDamage() * bonusdamage
	unit:SetBaseDamageMax(bounsDamage+1)
	unit:SetBaseDamageMin(bounsDamage-1)
	unit:SetBaseMoveSpeed(caster:GetBaseMoveSpeed())
	unit:SetBaseAttackTime(caster:GetBaseAttackTime() / caster:GetAttackSpeed() * unit:GetAttackSpeed())
	
	unit:AddAbility("ability_thdots_youmu02_unit")
	local ability_unit_youmu02 = unit:FindAbilityByName("ability_thdots_youmu02_unit")
	local ability_caster_youmu02_level = caster:FindAbilityByName("ability_thdots_youmu02"):GetLevel()
	ability_unit_youmu02:SetLevel(ability_caster_youmu02_level)
	GameRules:GetGameModeEntity():SetThink(
			function()
			    caster:RemoveModifierByName("modifier_thdots_youmu03_spawn")
				unit:RemoveSelf()
				print("remove")
			end, 
			DoUniqueString("ability_Youmu03_Unit_Duration"), 
			keys.Duration
			)	
end

function AbilityYoumu:OnYoumu03OrderMoved(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local unit = caster.Youmu03_Effect_Unit
	if unit ~= nil and unit:IsNull()==false then
		unit:MoveToPosition(caster:GetOrigin())
	end
end

function AbilityYoumu:OnYoumu03OrderAttack(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local unit = caster.Youmu03_Effect_Unit
	if unit ~= nil and unit:IsNull()==false then
		unit:MoveToTargetToAttack(target)
	end
end


function AbilityYoumu:OnYoumu04Think(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local vecCaster = caster:GetOrigin()
	local vecTarget = target:GetOrigin()
	local Youmu04Rad
	local count
	
	if(keys.ability:GetContext("ability_Youmu04_Count") == nil)then
	    keys.ability:SetContextNum("ability_Youmu04_Count",0,0)
	end

	if(keys.ability:GetContext("ability_Youmu04_Rad") == nil or keys.ability:GetContext("ability_Youmu04_Rad") == 0) then
		Youmu04Rad = GetRadBetweenTwoVec2D(vecTarget,vecCaster)
		keys.ability:SetContextNum("ability_Youmu04_Rad",Youmu04Rad,0)
	end
	Youmu04Rad = keys.ability:GetContext("ability_Youmu04_Rad")
	count = keys.ability:GetContext("ability_Youmu04_Count")
	
	if(count%2 == 0)then
		
		Youmu04Rad = Youmu04Rad + 210*math.pi/180
		keys.ability:SetContextNum("ability_Youmu04_Rad",Youmu04Rad,0)
		local deal_damage = keys.ability:GetAbilityDamage() + keys.AbilityMulti * caster:GetPrimaryStatValue()
		if caster:HasModifier("modifier_item_wanbaochui") then 
			local targets = FindUnitsInRadius(
						caster:GetTeam(),		
						target:GetOrigin(),	
						nil,					
						350,		
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
					damage = deal_damage/5,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = keys.ability:GetAbilityTargetFlags()
				}
				UnitDamageTarget(damage_table)
				-- UnitPauseTarget(caster,v,keys.WanbaochuiStun)
				UnitPauseTarget(caster,v,keys.ability:GetSpecialValueFor("wanbaochui_stun"))
			end
		else

			local damage_table = {
					ability = keys.ability,
					victim = keys.target,
					attacker = caster,
					damage = deal_damage/5,
					damage_type = keys.ability:GetAbilityDamageType(), 
					damage_flags = keys.ability:GetAbilityTargetFlags()
			}
			UnitDamageTarget(damage_table)
			UnitPauseTarget(caster,target,1.0)
		end
		local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/youmu/youmu_04_sword_effect.vpcf", PATTACH_CUSTOMORIGIN, caster)
		local effect2VecForward = Vector(vecTarget.x+math.cos(Youmu04Rad)*500,vecTarget.y+math.sin(Youmu04Rad)*500,vecCaster.z)
		ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin())
		ParticleManager:SetParticleControl(effectIndex, 1, effect2VecForward)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
	    target:EmitSound("Hero_Juggernaut.Attack")
		
		caster:SetForwardVector((keys.target:GetOrigin()-caster:GetOrigin()):Normalized())
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
	end
	local vec = Vector(vecTarget.x+math.cos(Youmu04Rad)*250,vecTarget.y+math.sin(Youmu04Rad)*250,vecCaster.z)
	caster:SetOrigin(vec)
	count = count +1
	keys.ability:SetContextNum("ability_Youmu04_Count",count,0)
	if(count>=10)then
		FindClearSpaceForUnit(caster, vecTarget, false)
		caster:SetForwardVector(Vector(caster:GetForwardVector().x,caster:GetForwardVector().y,0))
		local spellCard = ParticleManager:CreateParticle("particles/thd2/heroes/youmu/youmu_04_word.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(spellCard, 0, caster:GetOrigin())
		ParticleManager:DestroyParticleSystem(spellCard,false)
		keys.ability:SetContextNum("ability_Youmu04_Count",0,0)
		keys.ability:SetContextNum("ability_Youmu04_Rad",0,0)
		return
	end
end

function AbilityCreateEffect( keys )
        local caster = keys.caster
 
        --创建特效
        local particleID = ParticleManager:CreateParticle(keys.effect_name, PATTACH_OVERHEAD_FOLLOW,caster)
 
        --我们将施法者的所在的三维坐标传给了CP0
        ParticleManager:SetParticleControl(particleID,0,caster:GetOrigin())
end

function OnYoumuExAttacked(keys)
	local Caster = keys.caster	
	if keys.attacker:IsRealHero() == true then
		if Caster:HasModifier("modifier_thdots_youmuEx_start")==false then return end
		
		--绿字伤害
		local item
	    local attack = 0
	    local bonusAttack = 0 
	    for i=0,5 do
	        item = Caster:GetItemInSlot(i)
	        if(item~=nil)then
	            bonusAttack = item:GetSpecialValueFor("bonus_damage")
	            if(bonusAttack~=nil)then
	                attack = bonusAttack + attack
	            end
	        end
	    end 

		local Attacker = keys.attacker
		local Damage = Caster:GetAttackDamage()+attack+keys.BounsDamage
		local target = keys.attacker
		local caster = EntIndexToHScript(keys.caster_entindex)		
		
			if Caster:IsStunned() == false and Caster:HasModifier("modifier_item_yukkuri_stick_debuff") == false then

				keys.ability:ApplyDataDrivenModifier(caster, Attacker, "modifier_youmu02_armor_decrease", {Duration = keys.Duration})
				if(target.ability_Youmu02_Armor_Decrease_Count==nil)then
					target.ability_Youmu02_Armor_Decrease_Count = 0
				end
				target.ability_Youmu02_Armor_Decrease_Count = target.ability_Youmu02_Armor_Decrease_Count + 1
				target:SetModifierStackCount("modifier_youmu02_armor_decrease", keys.ability, target.ability_Youmu02_Armor_Decrease_Count)		
				local damage_table = {
							ability = keys.ability,
						    victim = Attacker,
						    attacker = Caster,
						    damage = Damage,
						    damage_type = keys.ability:GetAbilityDamageType(), 
				    	    damage_flags = keys.ability:GetAbilityTargetFlags()
				}
				UnitDamageTarget(damage_table)
								
			end
			EmitSoundOn("Hero_Centaur.DoubleEdge",keys.caster)	--播放声音
			local Position = caster:GetOrigin()
			local effectIndex = ParticleManager:CreateParticle("particles/dev/library/base_attack_swipe.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(effectIndex, 0, Position)
			ParticleManager:SetParticleControl(effectIndex, 1, Position)
			ParticleManager:SetParticleControl(effectIndex, 2, Position)
			ParticleManager:SetParticleControl(effectIndex, 3, Position)
			ParticleManager:SetParticleControl(effectIndex, 5, Position)
			ParticleManager:SetParticleControl(effectIndex, 6, Position)
			ParticleManager:DestroyParticleSystem(effectIndex,false)
			Caster:RemoveModifierByName("modifier_thdots_youmuEx_start")
	end
end

function OnYoumuExStartDamage(keys)
	local Caster = keys.caster
	if Caster:HasModifier("modifier_thdots_youmuEx_start")==false then return end	

	--绿字伤害
	local item
    local attack = 0
    local bonusAttack = 0 
    for i=0,5 do
        item = Caster:GetItemInSlot(i)
        if(item~=nil)then
            bonusAttack = item:GetSpecialValueFor("bonus_damage")
            if(bonusAttack~=nil)then
                attack = bonusAttack + attack
            end
        end
    end 

	local Attacker = keys.attacker
	local Damage = Caster:GetAttackDamage()+attack+keys.BounsDamage
	local target = keys.attacker
	local caster = EntIndexToHScript(keys.caster_entindex)
	
	if target:IsRealHero() == true then
		if Caster:IsStunned() == false and Caster:HasModifier("modifier_item_yukkuri_stick_debuff") == false then

			keys.ability:ApplyDataDrivenModifier(caster, Attacker, "modifier_youmu02_armor_decrease", {Duration = keys.Duration})
			if(target.ability_Youmu02_Armor_Decrease_Count==nil)then
				target.ability_Youmu02_Armor_Decrease_Count = 0
			end
			target.ability_Youmu02_Armor_Decrease_Count = target.ability_Youmu02_Armor_Decrease_Count + 1
			target:SetModifierStackCount("modifier_youmu02_armor_decrease", keys.ability, target.ability_Youmu02_Armor_Decrease_Count)		
			local damage_table = {
						ability = keys.ability,
					    victim = Attacker,
					    attacker = Caster,
					    damage = Damage,
					    damage_type = keys.ability:GetAbilityDamageType(), 
			    	    damage_flags = keys.ability:GetAbilityTargetFlags()
			}
			UnitDamageTarget(damage_table)
							
		end
		EmitSoundOn("Hero_Centaur.DoubleEdge",keys.caster)	--播放声音
		local Position = caster:GetOrigin()
		local effectIndex = ParticleManager:CreateParticle("particles/dev/library/base_attack_swipe.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(effectIndex, 0, Position)
		ParticleManager:SetParticleControl(effectIndex, 1, Position)
		ParticleManager:SetParticleControl(effectIndex, 2, Position)
		ParticleManager:SetParticleControl(effectIndex, 3, Position)
		ParticleManager:SetParticleControl(effectIndex, 5, Position)
		ParticleManager:SetParticleControl(effectIndex, 6, Position)
		ParticleManager:DestroyParticleSystem(effectIndex,false)
		Caster:RemoveModifierByName("modifier_thdots_youmuEx_start")		
	end
	Caster:RemoveModifierByName("modifier_thdots_youmuExHeal")
end