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
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_item_shanbibu_passive:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_shanbibu_passive:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")	
end

function modifier_item_shanbibu_passive:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end


modifier_item_shanbibu_active = {}
LinkLuaModifier("modifier_item_shanbibu_active","items/item_shanbibu.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_item_shanbibu_active:IsDebuff() return false end
function modifier_item_shanbibu_active:IsHidden() return false end
function modifier_item_shanbibu_active:IsPurgable() return true end
function modifier_item_shanbibu_active:RemoveOnDeath() return true end

function modifier_item_shanbibu_active:OnCreated()
	if not IsServer() then return end
	self:StartIntervalThink(0.03)
end

function modifier_item_shanbibu_active:OnIntervalThink()
	if not IsServer() then return end
	if not self:GetParent():HasModifier("modifier_invisible") then
		self:Destroy()
	end
end

function modifier_item_shanbibu_active:CheckState()
	return {
		[MODIFIER_STATE_ATTACK_IMMUNE]			= true,
		[MODIFIER_STATE_DISARMED]				= true
	}
end

function modifier_item_shanbibu_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DECREPIFY_UNIQUE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
	}
end

function modifier_item_shanbibu_active:GetModifierMagicalResistanceDecrepifyUnique()
	return self:GetAbility():GetSpecialValueFor("debuff_mgical_resistance_decrepify")
end
function modifier_item_shanbibu_active:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("debuff_slowdown_movespeed_percent")
end
function modifier_item_shanbibu_active:GetAbsoluteNoDamagePhysical()
	return 1
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

