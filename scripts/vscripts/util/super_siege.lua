Super_Siege = Super_Siege or {}
START_TIME = 2400				--出兵时间
INTERVAL_TIME = 120				--出兵间隔
PATH = {
Vector(-4997.613770,-5483.517090,128.000000),
Vector(-2879.457031,-5381.724121,128.000000),
Vector(403.047760,-5450.785156,128.000000),
Vector(1833.770142,-2792.065430,128.000000),
Vector(1045.798950,-1009.788635,128.000000),
Vector(-2239.795410,2064.000000,128.000000),
Vector(-3031.070801,3913.613037,256.000000),
Vector(-1695.215820,5525.166992,256.000000),
Vector(2502.371094,5703.623047,256.000000),
Vector(5239.779785,5687.033691,256.000000),
}


modifier_ability_thdots_super_siege = {}  --标记BUFF，防止被钱箱之类的技能秒掉
LinkLuaModifier("modifier_ability_thdots_super_siege","scripts/vscripts/util/super_siege.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_super_siege:IsHidden() 		return true end
function modifier_ability_thdots_super_siege:IsPurgable()		return false end
function modifier_ability_thdots_super_siege:RemoveOnDeath() 	return false end
function modifier_ability_thdots_super_siege:IsDebuff()		return false end

function modifier_ability_thdots_super_siege:OnCreated()
	if not IsServer() then return end
	self.health = GameRules:GetDOTATime(false, false) - START_TIME
	print("health is :",self.health)
end


function modifier_ability_thdots_super_siege:DeclareFunctions()
	return {
		-- MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
	}
end


-- function modifier_ability_thdots_super_siege:GetModifierPhysicalArmorBonus()
-- 	return 10
-- end
function modifier_ability_thdots_super_siege:GetModifierExtraHealthBonus()
	return self.health
end

function siege_start_interval()
	if GetMapName() ~= "1_thdots_map" then return end
	local siege_time = 0
	local say = true
	GameRules:GetGameModeEntity():SetContextThink("siege_time", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if math.floor(GameRules:GetDOTATime(false, false)) >= START_TIME then
				START_TIME = START_TIME + INTERVAL_TIME
				if say then
					GameRules:SendCustomMessage("<font color='#00FFFF'>游戏已经超过40分钟，双方每过2分钟派出一个超级兵进攻</font>", 0, 0)
					GameRules:SendCustomMessage("<font color='#00FFFF'>杀死超级兵获得500经验，500金币</font>", 0, 0)
					say = false
				end
				CreateSiege_Hakurei()
				CreateSiege_Moriya()
			end
			siege_time = siege_time + 0.03
			return 0.03
		end
		,
		0)
end

function siege_print()
	-- print_r(PATH)
	print(PATH[1])
end

function CreateSiege_Hakurei()
	local siege_time = 0
	local forts=Entities:FindAllByClassname("npc_dota_fort")
	local super_siege = CreateUnitByName(
			"npc_thd_goodguys_super_siege",
			PATH[2],
			false,
			forts[1],
			forts[1],
			forts[1]:GetTeam())
	FindClearSpaceForUnit(super_siege,super_siege:GetOrigin(),true)
	super_siege:AddNewModifier(super_siege,nil,"modifier_ability_thdots_super_siege",{})
	super_siege.path_count = 2
	super_siege.point = PATH[super_siege.path_count]
	super_siege:SetContextThink("siege_Path",
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if super_siege ~= nil then
				if not super_siege:IsAlive() then return nil end
				super_siege:MoveToPositionAggressive(super_siege.point)
			end
			siege_time = siege_time + 3
			return 3
		end
		,
		0)
	super_siege:SetContextThink("siege_Next",
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if super_siege ~= nil then
				if not super_siege:IsAlive() then return nil end
				if (super_siege:GetOrigin() - super_siege.point):Length2D() <= 200 then
					super_siege.path_count = super_siege.path_count + 1
					if PATH[super_siege.path_count] ~= nil then
						super_siege.point = PATH[super_siege.path_count]
						super_siege:MoveToPositionAggressive(super_siege.point)
					end
				end
			end
			siege_time = siege_time + 0.03
			return 0.03
		end
		,
		0)
end

function CreateSiege_Moriya()
	local siege_time = 0
	local forts=Entities:FindAllByClassname("npc_dota_fort")
	local super_siege = CreateUnitByName(
			"npc_thd_badguys_super_siege",
			PATH[#PATH - 1],
			false,
			forts[2],
			forts[2],
			forts[2]:GetTeam())
	FindClearSpaceForUnit(super_siege,super_siege:GetOrigin(),true)
	super_siege:AddNewModifier(super_siege,nil,"modifier_ability_thdots_super_siege",{})
	super_siege.path_count = #PATH - 1
	super_siege.point = PATH[super_siege.path_count]
	super_siege:SetContextThink("siege_Path",
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if super_siege ~= nil then
				if not super_siege:IsAlive() then return nil end
				super_siege:MoveToPositionAggressive(super_siege.point)
			end
			siege_time = siege_time + 3
			return 3
		end
		,
		0)
	super_siege:SetContextThink("siege_Next",
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if super_siege ~= nil then
				if not super_siege:IsAlive() then return nil end
				if (super_siege:GetOrigin() - super_siege.point):Length2D() <= 200 then
					super_siege.path_count = super_siege.path_count - 1
					if PATH[super_siege.path_count] ~= nil then
						super_siege.point = PATH[super_siege.path_count]
						super_siege:MoveToPositionAggressive(super_siege.point)
					end
				end
			end
			siege_time = siege_time + 0.03
			return 0.03
		end
		,
		0)
end