item_fireflies_light = {}

function item_fireflies_light:GetIntrinsicModifierName()
	return "modifier_item_fireflies_light_passive"
end

modifier_item_fireflies_light_passive = {}
LinkLuaModifier("modifier_item_fireflies_light_passive","items/item_fireflies_light.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_fireflies_light_passive:IsHidden() return false end

function modifier_item_fireflies_light_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_item_fireflies_light_passive:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage") + self:GetAbility():GetSpecialValueFor("per_damage") * self:GetStackCount()
end

function modifier_item_fireflies_light_passive:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_fireflies_light_passive:OnDeath(keys)
	if not IsServer() then return end
	--击杀英雄，增加层数
	if keys.attacker == self:GetCaster() and keys.unit:IsRealHero() then
		keys.unit:SetContextThink("HasAegis",
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if keys.unit:GetTimeUntilRespawn() > 5 then
				local caster = self:GetCaster()
				local kill_limit = self:GetAbility():GetSpecialValueFor("kill_limit")
				if self:GetStackCount() < kill_limit then
					self:SetStackCount(self:GetStackCount() + 1)
				else
					self:SetStackCount(kill_limit)
				end
				-- local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_donation_box.vpcf", PATTACH_CUSTOMORIGIN, caster)
				-- ParticleManager:SetParticleControl(effectIndex, 0, caster:GetAbsOrigin())
				-- ParticleManager:SetParticleControl(effectIndex, 1, caster:GetAbsOrigin())
				-- ParticleManager:ReleaseParticleIndex(effectIndex)
				-- caster:EmitSound("DOTA_Item.Hand_Of_Midas")
			end
		end
		,
		FrameTime())
	--本体死亡，失去层数
	elseif keys.unit == self:GetCaster() then 
		keys.unit:SetContextThink("HasAegis",
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if keys.unit:GetTimeUntilRespawn() > 5 then
				local caster = self:GetCaster()
				local lost_ondeath = self:GetAbility():GetSpecialValueFor("lost_ondeath") / 100
				local lost_StackCount = math.floor(lost_ondeath * self:GetStackCount())
				if lost_StackCount == 0 then lost_StackCount = 1 end
				if self:GetStackCount() == 0 then lost_StackCount = 0 end
				print("lost_StackCount")
				print(lost_StackCount)
				self:SetStackCount(self:GetStackCount() - lost_StackCount)
				-- local effectIndex = ParticleManager:CreateParticle("particles/thd2/items/item_donation_box.vpcf", PATTACH_CUSTOMORIGIN, caster)
				-- ParticleManager:SetParticleControl(effectIndex, 0, caster:GetAbsOrigin())
				-- ParticleManager:SetParticleControl(effectIndex, 1, caster:GetAbsOrigin())
				-- ParticleManager:ReleaseParticleIndex(effectIndex)
				-- caster:EmitSound("DOTA_Item.Hand_Of_Midas")
			end
		end
		,
		FrameTime())
	end
end


function modifier_item_fireflies_light_passive:OnCreated()
	if not IsServer() then return end
	self.level 							= self:GetCaster():GetLevel()
	self.caster 						= self:GetCaster()
	self.ability						= self:GetAbility()
	self.debuff_decrease				= self.ability:GetSpecialValueFor("debuff_decrease")
	self:StartIntervalThink(FrameTime())
end


function modifier_item_fireflies_light_passive:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local debuff_decrease = ability:GetSpecialValueFor("debuff_decrease") / 100

	--设置自己的debuff时间缩短
    for i=0,15 do
         if caster:GetModifierNameByIndex(i) ~= "" then
         	local modifier = caster:FindModifierByName(caster:GetModifierNameByIndex(i))
         	if modifier ~= nil then
	            if modifier:IsDebuff() and modifier.fireflies_light ~= false then
	            	modifier.fireflies_light = false --只生效一次
	            	local modifier_time = modifier:GetRemainingTime()
	            	print(modifier:GetRemainingTime())
	            	local extra_time = 1 - debuff_decrease --debuff缩短时间百分比
	            	if IsNoBugModifier(modifier) then
	            		modifier:SetDuration(modifier_time * extra_time, true)
		            end
	            	print(extra_time)
	            	print(modifier:GetRemainingTime())
	            	print("--------------------")
	            end
	        end
         end
    end
end