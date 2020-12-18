item_shanbibu = {}

function item_shanbibu:GetIntrinsicModifierName()
	return "modifier_item_shanbibu_passive"
end

function item_shanbibu:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	duration = self:GetSpecialValueFor("duration")
	target:EmitSound("Item.GlimmerCape.Activate")
	target:RemoveModifierByName("modifier_item_shanbibu_active_delay")
	target:AddNewModifier(caster,self,"modifier_item_shanbibu_active_delay",{duration = duration+0.6})
end

modifier_item_shanbibu_passive = {}
LinkLuaModifier("modifier_item_shanbibu_passive","items/item_shanbibu.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_shanbibu_passive:IsHidden() return true end

function modifier_item_shanbibu_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end

function modifier_item_shanbibu_passive:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")	
end

function modifier_item_shanbibu_passive:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("mgical_resistance")
end

-- function modifier_item_shanbibu_passive:GetModifierBonusStats_Agility()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
-- end

-- function modifier_item_shanbibu_passive:GetModifierBonusStats_Intellect()
-- 	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
-- end


modifier_item_shanbibu_active = {}
LinkLuaModifier("modifier_item_shanbibu_active","items/item_shanbibu.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_item_shanbibu_active:IsDebuff() return false end
function modifier_item_shanbibu_active:IsHidden() return false end
function modifier_item_shanbibu_active:IsPurgable() return true end
function modifier_item_shanbibu_active:RemoveOnDeath() return true end

function modifier_item_shanbibu_active:OnCreated()
	if not IsServer() then return end
	self.time = 0
	self.react_time = self:GetAbility():GetSpecialValueFor("react_time")
	self:StartIntervalThink(FrameTime())
end

function modifier_item_shanbibu_active:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_invisible") and self.time >= self.react_time then
		self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_invisible", {duration = self:GetRemainingTime()})
		self.time = 0
	else
		self.time = self.time + FrameTime()
	end
end


function modifier_item_shanbibu_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end

function modifier_item_shanbibu_active:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("active_mgical_resistance")
end

function modifier_item_shanbibu_active:OnAbilityFullyCast(keys)
	if not IsServer() then return end
	if keys.unit == self:GetParent() then
		self.time = 0
	end
end

function modifier_item_shanbibu_active:OnAttack(keys)
	if not IsServer() then return end
	if keys.attacker == self:GetParent() then
		self.time = 0
	end
end

modifier_item_shanbibu_active_delay = {}
LinkLuaModifier("modifier_item_shanbibu_active_delay","items/item_shanbibu.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_item_shanbibu_active_delay:IsDebuff() return false end
function modifier_item_shanbibu_active_delay:IsHidden() return true end
function modifier_item_shanbibu_active_delay:IsPurgable() return true end
function modifier_item_shanbibu_active_delay:RemoveOnDeath() return true end

function modifier_item_shanbibu_active_delay:GetEffectName()
	return "particles/items3_fx/glimmer_cape_initial.vpcf"
end

function modifier_item_shanbibu_active_delay:OnCreated()
	if not IsServer() then return end
	local duration = self:GetAbility():GetSpecialValueFor("duration")
	self:GetParent():SetContextThink("shanbibu_delay", 
		function()
			if self:GetParent():HasModifier("modifier_item_shanbibu_active_delay") then 
				self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_item_shanbibu_active", {duration = duration})
				self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_invisible", {duration = duration})
			end
		end,
	0.6)
end

function modifier_item_shanbibu_active_delay:OnRefresh()
	if not IsServer() then return end
	self:OnCreated()
end
