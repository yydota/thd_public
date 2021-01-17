--减卡数量函数
function ItemAbility_SpendItem(keys)
	local ItemAbility = keys
	local Caster = keys:GetCaster()
	
	if (ItemAbility:IsItem()) then
		local Charge = ItemAbility:GetCurrentCharges()
		if (Charge>1) then
			ItemAbility:SetCurrentCharges(Charge-1)
		else
			Caster:RemoveItem(ItemAbility)
		end
	end
end

item_card_eat_man = {}

function item_card_eat_man:GetAOERadius()
	if self:GetCaster():GetLevel() >= self:GetSpecialValueFor("level_limit") then
		return self:GetSpecialValueFor("radius")
	else
		return
	end
end

function item_card_eat_man:CastFilterResultTarget(target)
	if target:GetUnitName() == "npc_dota_dark_troll_warlord_skeleton_warrior" then return end
	if not target:IsNeutralUnitType() or target:GetTeamNumber() ~= 4 then
		return UF_FAIL_CUSTOM
	--吃远古判定
	-- elseif target:IsAncient() and self:GetCaster():GetLevel() < self:GetSpecialValueFor("level_limit") then
	-- 	return UF_FAIL_CUSTOM
	end
end

function item_card_eat_man:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local radius = self:GetSpecialValueFor("radius")
	local per_min = self:GetSpecialValueFor("per_min")
	local game_time = math.floor(GameRules:GetDOTATime(false, false) /60)
	print("game_time")
	print(game_time)
	local eat_num = math.floor(game_time/per_min)
	print(eat_num)
	--特效音效
	local particle_pact = "particles/units/heroes/hero_clinkz/clinkz_death_pact.vpcf"
	local particle_pact_fx = ParticleManager:CreateParticle(particle_pact, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle_pact_fx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_pact_fx, 1, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_pact_fx, 5, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_pact_fx)
	
	target:Kill(self,caster)


	local targets = FindUnitsInRadius(caster:GetTeam(),target:GetOrigin(), nil,radius,self:GetAbilityTargetTeam(),
							 DOTA_UNIT_TARGET_CREEP,0,0,false)
	DeleteCreep(targets)
	-- if caster:GetLevel() < self:GetSpecialValueFor("level_limit") then
	-- 	DeleteAncient(targets)
	-- end
	table.sort(targets, function(a, b) if a:GetLevel()>b:GetLevel() then return true end end ) --根据等级排序，优先吃最高级的

	caster:EmitSound("Hero_Clinkz.DeathPact.Cast")

	ItemAbility_SpendItem(self)

	for _,v in pairs (targets) do
		if eat_num <= 0 then
			break
		else

			--特效音效
			local particle_pact = "particles/units/heroes/hero_clinkz/clinkz_death_pact.vpcf"
			local particle_pact_fx = ParticleManager:CreateParticle(particle_pact, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle_pact_fx, 0, v:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle_pact_fx, 1, v:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle_pact_fx, 5, v:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle_pact_fx)

			v:Kill(self,caster)
			eat_num = eat_num - 1
		end
	end
end

function DeleteCreep(targets)--删除小兵单位
    for i=1,#targets do
    	if targets[i]:GetUnitName() == "npc_dota_dark_troll_warlord_skeleton_warrior" 
    		or targets[i]:GetUnitName() == "npc_dota_roshan"
    	then break end
        if not targets[i]:IsNeutralUnitType() or targets[i]:GetTeamNumber() ~= 4 then
            table.remove(targets, i)
            DeleteDummy(targets)
        end
    end
end

-- function DeleteAncient(targets)--删除远古单位
--     for i=1,#targets do
--     	if targets[i]:GetUnitName() == "npc_dota_dark_troll_warlord_skeleton_warrior" 
--     		or targets[i]:GetUnitName() == "npc_dota_roshan"
--     	then break end
--         if targets[i]:IsAncient() then
--             table.remove(targets, i)
--             DeleteDummy(targets)
--         end
--     end
-- end

item_card_kid_man = {}

function item_card_kid_man:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	caster:EmitSound("DOTA_Item.ForceStaff.Activate")
	caster:AddNewModifier(caster, self, "modifier_item_card_kid_man", {duration = self:GetSpecialValueFor("push_duration")})
	ItemAbility_SpendItem(self)
end

modifier_item_card_kid_man = {}
LinkLuaModifier("modifier_item_card_kid_man","scripts/vscripts/items/item_card",LUA_MODIFIER_MOTION_NONE)

function modifier_item_card_kid_man:IsDebuff() return false end
function modifier_item_card_kid_man:IsHidden() return true end
function modifier_item_card_kid_man:IsPurgable() return false end
function modifier_item_card_kid_man:IsStunDebuff() return false end
function modifier_item_card_kid_man:IsMotionController()  return true end
function modifier_item_card_kid_man:GetMotionControllerPriority()  return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_item_card_kid_man:IgnoreTenacity()	return true end

function modifier_item_card_kid_man:OnCreated()
	if not IsServer() then return end
	
	local particle_name = "particles/items_fx/force_staff.vpcf"
	self.push_speed = self:GetAbility():GetSpecialValueFor("push_speed")
	self.push_speed = 60
	print(self.push_speed)
	self.pfx = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:GetParent():StartGesture(ACT_DOTA_FLAIL)
	self.angle = self:GetParent():GetForwardVector()
	self:StartIntervalThink(FrameTime())
end

function modifier_item_card_kid_man:OnDestroy()
	if not IsServer() then return end
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetParent():FadeGesture(ACT_DOTA_FLAIL)
	-- FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetOrigin(),true)
	ResolveNPCPositions(self:GetParent():GetAbsOrigin(), 128)
end

function modifier_item_card_kid_man:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetParent()
	--不摧毁树木
	-- GridNav:DestroyTreesAroundPoint(caster:GetOrigin(), self:GetAbility():GetSpecialValueFor("tree_radius"), true)
	caster:SetOrigin(caster:GetOrigin() + self.angle * self.push_speed)
end

function modifier_item_card_kid_man:CheckState()
	return {
		[MODIFIER_STATE_ROOTED]		= true,
	}
end