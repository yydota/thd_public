item_harvest_cradle = {}

function item_harvest_cradle:GetIntrinsicModifierName()
	return "modifier_item_harvest_cradle_passive"
end

modifier_item_harvest_cradle_passive = {}
LinkLuaModifier("modifier_item_harvest_cradle_passive","items/item_harvest_cradle.lua", LUA_MODIFIER_MOTION_NONE)
function modifier_item_harvest_cradle_passive:IsHidden() return false end

function modifier_item_harvest_cradle_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end

function modifier_item_harvest_cradle_passive:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")	
end

function modifier_item_harvest_cradle_passive:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_harvest_cradle_passive:OnCreated()
	if not IsServer() then return end
	self.level 							= self:GetCaster():GetLevel()
	self.caster 						= self:GetCaster()
	self.ability						= self:GetAbility()
	self.regen_health					= self.ability:GetSpecialValueFor("regen_health")
	self.regen_mana						= self.ability:GetSpecialValueFor("regen_mana")
	self.regen_health_perlevel			= self.ability:GetSpecialValueFor("regen_health_perlevel")
	self.regen_mana_perlevel			= self.ability:GetSpecialValueFor("regen_mana_perlevel")
	self:StartIntervalThink(FrameTime())
end

function modifier_item_harvest_cradle_passive:OnIntervalThink()
	if not IsServer() then return end
	if self.level ~= self:GetCaster():GetLevel() then
		local health_regen = self.regen_health + self:GetCaster():GetLevel() * self.regen_health_perlevel
		local mana_regen = self.regen_mana + self:GetCaster():GetLevel() * self.regen_mana_perlevel
		self.caster:Heal(health_regen, self.caster)
		self.caster:SetMana(self.caster:GetMana() + mana_regen)
		print(health_regen)
		print(mana_regen)
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,self.caster,health_regen,nil)
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_ADD,self.caster,mana_regen,nil)
		self.level = self:GetCaster():GetLevel()
	end
end