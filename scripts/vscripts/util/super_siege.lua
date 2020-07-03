Super_Siege = Super_Siege or {}
START_TIME = 2400				--出兵时间
INTERVAL_TIME = 120			--出兵间隔
PATH = {
Vector(-4997.613770,-5483.517090,128.000000),
Vector(803.132751,-5676.043457,128.000000),
Vector(1833.770142,-2792.065430,128.000000),
Vector(1045.798950,-1009.788635,128.000000),
Vector(-2239.795410,2064.000000,128.000000),
Vector(-3407.669922,4059.369141,256.000000),
Vector(-1909.512817,5774.858887,256.000000),
Vector(5239.779785,5687.033691,256.000000),
}


modifier_ability_thdots_super_siege = {}  --标记BUFF，防止被钱箱之类的技能秒掉
LinkLuaModifier("modifier_ability_thdots_super_siege","scripts/vscripts/util/super_siege.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_ability_thdots_super_siege:IsHidden() 		return true end
function modifier_ability_thdots_super_siege:IsPurgable()		return false end
function modifier_ability_thdots_super_siege:RemoveOnDeath() 	return false end
function modifier_ability_thdots_super_siege:IsDebuff()		return false end

function siege_start_interval()
	if GetMapName() ~= "1_thdots_map" then return end
	local siege_time = 0
	GameRules:GetGameModeEntity():SetContextThink("siege_time", 
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if GameRules:GetDOTATime(false, false) >= START_TIME then
				START_TIME = START_TIME + INTERVAL_TIME
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
			PATH[1],
			false,
			forts[1],
			forts[1],
			forts[1]:GetTeam())
	super_siege:AddNewModifier(super_siege,nil,"modifier_ability_thdots_super_siege",{})
	super_siege.path_count = 1
	super_siege.point = PATH[super_siege.path_count]
	super_siege:SetContextThink("siege_Path",
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if super_siege ~= nil then
				super_siege:MoveToPositionAggressive(super_siege.point)
				if (super_siege:GetOrigin() - super_siege.point):Length2D() <= 200 then
					super_siege.path_count = super_siege.path_count + 1
					if PATH[super_siege.path_count] ~= nil then
						super_siege.point = PATH[super_siege.path_count]
					end
				end
			end
			siege_time = siege_time + 3
			return 3
		end
		,
		0)
end

function CreateSiege_Moriya()
	local siege_time = 0
	local forts=Entities:FindAllByClassname("npc_dota_fort")
	local super_siege = CreateUnitByName(
			"npc_thd_badguys_super_siege",
			PATH[#PATH],
			false,
			forts[2],
			forts[2],
			forts[2]:GetTeam())
	super_siege:AddNewModifier(super_siege,nil,"modifier_ability_thdots_super_siege",{})
	super_siege.path_count = #PATH
	super_siege.point = PATH[super_siege.path_count]
	super_siege:SetContextThink("siege_Path",
		function()
			if GameRules:IsGamePaused() then return 0.03 end
			if super_siege ~= nil then
				super_siege:MoveToPositionAggressive(super_siege.point)
				if (super_siege:GetOrigin() - super_siege.point):Length2D() <= 200 then
					super_siege.path_count = super_siege.path_count - 1
					if PATH[super_siege.path_count] ~= nil then
						super_siege.point = PATH[super_siege.path_count]
					end
				end
			end
			siege_time = siege_time + 3
			return 3
		end
		,
		0)
end