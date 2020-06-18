-- 这个文件是RPG载入的时候，游戏的主程序最先载入的文件
-- 一般在这里载入各种我们所需要的各种lua文件
-- 除了addon_game_mode以外，其他的部分都需要去掉


GameRules:EnableCustomGameSetupAutoLaunch(true)
G_IsAIMode = false
G_IsFastCDMode = false
G_IsFastRespawnMode = false
Bot_Mode = false
-- look at precache, if map == "dota" then enable for default
cur_bot_dif = 1 -- easy
fast_respawn_val = 20 -- fast respawn mode's respawn time

G_Bot_Push_All_Time = {60,40,20,1}
G_Rune_Bounty_List = {1,1,1,1,1,1}
G_Rune_PowerUp_List = {1,1,1,1,1,1}
G_Rune_Bounty_Spwner_List = {}
G_Rune_PowerUp_Spwner_List = {}

-- 载入项目所有文件
require ( "util/damage" )
require ( "util/stun" )
require ( "util/pauseunit" )
require ( "util/silence" )
require ( "util/magic_immune" )
require ( "util/timers" )
require ( "util/util" )
require ( "util/disarmed" )
require ( "util/invulnerable" )
require ( "util/graveunit" )
require ( "util/collision" )
require ( "util/nodamage" )
require ( "util/CheckItemModifies")

--clothes
require ( "util/clothes")
require ( "util/eventregister")
require ( "util/observe")
require ( "util/rune_fixer")
require ( "util/rune_fixer")
require ( "util/webapi")
require ( "util/shuffle")


if THDOTSGameMode == nil then
	THDOTSGameMode = {}
end

function Precache( context )

	if GetMapName() == "dota" then 
		--bot enable for default at dota map
		Bot_Mode = true
	end
	
	--clothes add(extra clothes,default should add first)
	add_cloth(
			"npc_dota_hero_templar_assassin",
			"models/thd2/sakuya_cloth01/sakuya_mmd_cloth01.vmdl",
			1.0, --not necessary, 1.0 for default
			3    --not necessary, minimal id usable for default
	)
	
	add_cloth(
			"npc_dota_hero_lina",
			"models/thd2/hakurei_reimu/hakurei_reimu_mmd.vmdl"
	)
	
	PrecacheResource( "model", "models/thd2/point.vmdl", context )--真の点数
	PrecacheResource( "model", "models/thd2/power.vmdl", context )--真のP点
	PrecacheResource( "model", "models/development/invisiblebox.vmdl", context )
	PrecacheResource( "model", "models/thd2/iku/iku_lightning_drill.vmdl", context )
	PrecacheResource( "particle", "particles/items_fx/aegis_respawn_spotlight.vpcf",context )--真のP点
	PrecacheResource( "particle", "particles/units/heroes/hero_mirana/mirana_base_attack.vpcf",context )--永琳弹道
	PrecacheResource( "particle", "particles/items2_fx/hand_of_midas.vpcf",context )--真の点数
	PrecacheResource( "particle_folder", "particles/thd2/heroes/reimu", context )--灵梦and跳台
	PrecacheResource( "particle", "particles/thd2/environment/death/act_hero_die.vpcf",context )--死亡
	PrecacheResource( "particle", "particles/environment/thd_rain.vpcf",context )--雨
	PrecacheResource( "particle", "particles/econ/items/alchemist/alchemist_midas_knuckles/alch_knuckles_lasthit_coins.vpcf",context )--雨
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_visage.vsndevts", context )--灵梦and跳台
	PrecacheResource( "soundfile", "soundevents/game_sounds_custom.vsndevts", context )--背景音乐，BIU

	--PrecacheResource( "particle", "particles/thd2/chen_cast_4.vpcf", context )--激光
	

	PrecacheResource( "model", "models/thd2/yyy.vmdl", context )--灵梦D
	PrecacheResource( "model", "models/thd2/fantasy_seal.vmdl", context )--灵梦F

	PrecacheResource( "model", "models/thd2/youmu/youmu.vmdl", context )--妖梦R

	PrecacheResource( "model", "models/heroes/lycan/lycan_wolf.vmdl", context )--狗花D

	PrecacheResource( "particle", "particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_fallback_low_egset.vpcf", 
	context )--天子F
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context )--天子W
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_zuus", context )--天子W

	PrecacheResource( "model", "models/props_gameplay/rune_haste01.vmdl", context )--魔理沙R
	PrecacheResource( "model", "models/thd2/masterspark.vmdl", context )--魔理沙 魔炮
	
	PrecacheResource( "particle", "particles/dire_fx/tower_bad_face_end_shatter.vpcf", context )--幽幽子F
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_death_prophet", context )--幽幽子D
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_bane", context )--幽幽子F
	PrecacheResource( "model", "models/thd2/yuyuko_fan.vmdl", context )--幽幽子W

	PrecacheResource( "particle_folder", "particles/units/heroes/hero_phoenix", context )--妹红R	
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context )--妹红R
	PrecacheResource( "model", "models/thd2/firewing.vmdl", context )--妹红W	

	PrecacheResource( "particle", "particles/thd2/heroes/flandre/ability_flandre_04_buff.vpcf", context )--芙兰朵露	
	PrecacheResource( "particle", "particles/thd2/heroes/flandre/ability_flandre_04_effect.vpcf", context )--芙兰朵露

	PrecacheResource( "particle_folder", "particles/units/heroes/hero_brewmaster", context )--红三
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", context )--红三

	PrecacheResource( "particle_folder", "particles/units/heroes/hero_tiny", context )--西瓜
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_tiny.vsndevts", context )--西瓜

	PrecacheResource( "particle_folder", "particles/units/heroes/hero_night_stalker", context )--露米娅
	
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_disruptor", context )--永琳
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_disruptor.vsndevts", context )--永琳

	PrecacheResource( "particle_folder", "particles/units/heroes/hero_night_stalker", context )--NEET

	PrecacheResource( "particle_folder", "particles/units/heroes/hero_doom_bringer", context )--flandre04
	PrecacheResource( "particle_folder", "particles/units/heroes/hero_phantom_assassin", context )--flandre04

	PrecacheResource( "particle_folder", "particles/units/heroes/hero_tiny", context )--suika01
	-- PrecacheResource( "particle_folder", "particles/units/heroes/hero_dark_seer/dark_seer_surge_start_fallback_low.vpcf", context )-- 提琴


	PrecacheResource( "particle", "particles/thd2/items/item_ballon.vpcf", context )--幽灵气球
	PrecacheResource( "particle", "particles/thd2/items/item_bad_man_card.vpcf", context )--坏人卡
	PrecacheResource( "particle", "particles/thd2/items/item_good_man_card.vpcf", context )--好人卡
	PrecacheResource( "particle", "particles/thd2/items/item_love_man_card.vpcf", context )--爱人卡
	PrecacheResource( "particle", "particles/thd2/items/item_unlucky_man_card.vpcf", context )--衰人卡
	PrecacheResource( "particle", "particles/units/heroes/hero_lich/lich_ambient_frost_legs.vpcf", context )--冰青蛙减速
	PrecacheResource( "particle", "particles/thd2/items/item_kafziel.vpcf", context )--镰刀
	PrecacheResource( "particle", "particles/base_attacks/ranged_tower_good_launch.vpcf", context )--绿刀
	PrecacheResource( "particle", "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf", context )--绿坝
	PrecacheResource( "particle", "particles/units/heroes/hero_brewmaster/brewmaster_windwalk.vpcf", context )--碎骨笛
	PrecacheResource( "particle", "particles/units/heroes/hero_medusa/medusa_mana_shield_shell_mod.vpcf", context )--碎骨笛
	PrecacheResource( "particle", "particles/thd2/items/item_camera.vpcf", context )--相机
	PrecacheResource( "particle", "particles/thd2/items/item_tsundere.vpcf", context )--无敌
	PrecacheResource( "particle", "particles/thd2/items/item_rocket.vpcf",context )--火箭
	PrecacheResource( "particle", "particles/thd2/items/item_mr_yang.vpcf",context )--火箭
	PrecacheResource( "particle", "particles/thd2/items/item_donation_gem.vpcf",context )--钱玉
	PrecacheResource( "particle", "particles/thd2/items/item_donation_box.vpcf",context )--钱箱
	PrecacheResource( "particle", "particles/thd2/items/item_phoenix_wing.vpcf",context )--火凤凰之翼
	PrecacheResource( "particle", "particles/thd2/items/item_darkred_umbrella_fog_attach.vpcf",context )--深红的雨伞 单位依附
	PrecacheResource( "particle", "particles/econ/items/sniper/sniper_charlie/sniper_base_attack_explosion_charlie.vpcf",context )--风枪
	PrecacheResource( "particle", "particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf",context )--马王
	PrecacheResource( "particle", "particles/thd2/items/item_yatagarasu.vpcf",context )--八尺乌
	PrecacheResource( "particle", "particles/items2_fx/phase_boots.vpcf",context )--狐狸面具
	PrecacheResource( "particle", "particles/thd2/items/item_pocket_watch.vpcf",context )--秒表
	PrecacheResource( "particle", "particles/thd2/items/item_moon_bow.vpcf",context )--月弓
	PrecacheResource( "particle", "particles/items_fx/ethereal_blade.vpcf",context )--三次元
	PrecacheResource( "particle", "particles/items2_fx/mekanism.vpcf",context )--梅肯
	PrecacheResource( "particle", "particles/items3_fx/warmage_mana.vpcf",context )--秘法
	
	PrecacheResource( "model", "models/thd2/kaguya/kaguya.vmdl",context )

	--MMD

	PrecacheResource( "model", "models/thd2/reisen/reisen.vmdl",context )
	PrecacheResource( "model", "models/thd2/reisen/reisenUnit.vmdl",context )

	PrecacheResource( "model", "models/thd2/hakurei_reimu/hakurei_reimu_mmd.vmdl",context )
	PrecacheResource( "model", "models/thd2/marisa/marisa_mmd.vmdl",context )
	PrecacheResource( "model", "models/aya/aya_mmd.vmdl",context )
	PrecacheResource( "model", "models/thd2/tenshi/tenshi_mmd.vmdl",context )
	PrecacheResource( "model", "models/thd2/flandre/flandre_mmd.vmdl",context )

	PrecacheResource( "model", "models/thd2/hiziri_byakuren/hiziri_byakuren_mmd.vmdl",context )
	PrecacheResource( "model", "models/thd2/mokou/mokou_mmd.vmdl",context )
	PrecacheResource( "model", "models/thd2/yuugi/yuugi_mmd.vmdl",context )
	PrecacheResource( "model", "models/thd2/suika/suika_mmd.vmdl",context )
	PrecacheResource( "model", "models/thd2/rumia/rumia_mmd.vmdl",context )
	PrecacheResource( "model", "models/thd2/iku/iku_mmd.vmdl",context )

	PrecacheResource( "model", "models/thd2/youmu/youmu_mmd.vmdl",context )
	PrecacheResource( "model", "models/thd2/eirin/eirin_mmd.vmdl",context )
	PrecacheResource( "model", "models/thd2/yuyuko/yuyuko_mmd.vmdl",context )
	PrecacheResource( "model", "models/thd2/utsuho/utsuho_mmd.vmdl",context )
	PrecacheResource( "model", "models/thd2/sakuya/sakuya_mmd.vmdl",context )

	PrecacheResource( "model", "models/heroes/death_prophet/death_prophet_ghost.vmdl",context )

	PrecacheResource( "model", "models/thd2/yukkuri/yukkuri.vmdl",context )
	PrecacheResource( "model", "models/thd2/koishi/koishi_transform_mmd.vmdl",context )
	PrecacheResource( "model", "models/thd2/koishi/koishi_w_mmd.vmdl",context )
	PrecacheResource( "model", "models/thd2/yumemi/yumemi_idousen.vmdl",context )

	PrecacheResource( "model", "models/thd2/kanako/kanako_mmd_transform.vmdl",context )
	PrecacheResource( "model", "models/thd2/kanako/kanako_mmd_transforming.vmdl",context )
	PrecacheResource( "model", "models/satori/satori.vmdl",context )
	PrecacheResource( "model", "models/thd_hero/lunasa_prismriver/lunasa.vmdl",context )
	
end

-- Create the game mode when we activate
function Activate()
	GameRules.THDOTSGameMode = THDOTSGameMode
	GameRules.THDOTSGameMode:InitGameMode()
	_G["AddonTemplate"] = THDOTSGameMode
end

-- 这个函数是addon_game_mode里面所写的，会在vlua.cpp执行的时候所执行的内容
function THDOTSGameMode:InitGameMode()
  print('[THDOTS] Starting to load THDots gamemode...')

  InitLogFile( "log/dota2x.txt","")
  -- 初始化记录文件
  -- 这个记录文件的路径是 dota 2 beta/dota/log/dota2x.txt
  -- 在有必要的时候，你可以使用  AppendToLogFile("log/dota2x.txt","记录内容")
  -- 来记录一些数据，避免游戏的崩溃了，却无法看到控制台的报错，无法判断是哪里出了问题

  -- 游戏事件监听
  -- 监听的API规则是
  -- ListenToGameEvent(API定义的事件名称或者我们自己程序发出的事件名称,事件触发之后执行的函数,LUA所有者)
  -- 这里所使用的 Dynamic_Wrap(THDOTSGameMode, 'OnEntityKilled') 其实就相当于self:OnEntityKilled
  -- 使用Dynamic_Wrap的好处是可以在控制台输入 developer 1之后，控制台显示一些额外的信息
  
  ListenToGameEvent('entity_killed', Dynamic_Wrap(THDOTSGameMode, 'OnEntityKilled'), self)
  -- 监听单位被击杀的事件
  
  ListenToGameEvent('player_connect_full', Dynamic_Wrap(THDOTSGameMode, 'AutoAssignPlayer'), self)
  -- 监听玩家连接完成的事件，这里的函数 AutoAssignPlayer 是自动分配玩家英雄

  ListenToGameEvent('player_disconnect', Dynamic_Wrap(THDOTSGameMode, 'CleanupPlayer'), self)
  -- 监听玩家断开连接的事件，有时候当玩家断开连接，我们可能要为其清理英雄，储存相关数据，等他重连之后再重新赋给他

  ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(THDOTSGameMode, 'AbilityUsed'), self)

  ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(THDOTSGameMode, 'AbilityLearn'), self)

  ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(THDOTSGameMode, 'Levelup'), self)

  ListenToGameEvent('npc_spawned', Dynamic_Wrap( THDOTSGameMode, 'OnHeroSpawned' ), self )

  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(THDOTSGameMode, 'OnGameRulesStateChange'), self)

  ListenToGameEvent('player_chat', Dynamic_Wrap(THDOTSGameMode, 'OnPlayerSay'), self)
  
  --ListenToGameEvent('dota_hero_random', Dynamic_Wrap(THDOTSGameMode, 'OnPlayerRandomChoose'), self) -- not working
  
  --ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(THDOTSGameMode, 'OnPlayerRandomChoose'), self)

  -- ListenToGameEvent("dota_item_purchase", Dynamic_Wrap(THDOTSGameMode, 'On_dota_item_purchase'), self)

  -- ListenToGameEvent("dota_item_purchased", Dynamic_Wrap(THDOTSGameMode, 'On_dota_item_purchased'), self)

	
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(true)

	
end

--to ban some girls(which is not work done XD)
G_BOT_USED = 
{
	false ,
	false ,
	false ,
	false ,
	false ,
	
	true ,
	false ,
	false ,
	false ,
	false ,
	
	true ,
	false ,
	true ,
	true ,
	true ,
	
	true ,
	true ,
	true ,
	true ,
	false ,
	
	true ,
	true ,
	true ,
	true ,
	true ,
	
	true ,
	true ,
	true ,
	true ,
	true ,
	
	true ,
	true
}

G_Bot_Random_Hero = 
{	
	"npc_dota_hero_lina",					--红白
	"npc_dota_hero_juggernaut",				--妖梦
	"npc_dota_hero_slark",					--文文
	"npc_dota_hero_earthshaker",			--天子
	"npc_dota_hero_life_stealer",			--⑩
	
	"npc_dota_hero_crystal_maiden",			--黑白
	"npc_dota_hero_drow_ranger",			--恋
	"npc_dota_hero_mirana",					--兔子
	"npc_dota_hero_chaos_knight",			--妹红
	"npc_dota_hero_centaur",				--红三
	
	"npc_dota_hero_tidehunter",				--西瓜
	"npc_dota_hero_clinkz",					--虫子
	"npc_dota_hero_axe",					--⑨
	"npc_dota_hero_naga_siren",				--二妹
	"npc_dota_hero_storm_spirit",			--四季
	
	"npc_dota_hero_razor",					--衣玖
	"npc_dota_hero_dark_seer",				--白莲
	"npc_dota_hero_furion",					--辉夜
	"npc_dota_hero_kunkka",					--船长
	"npc_dota_hero_lion",					--早苗
	
	"npc_dota_hero_necrolyte",				--uuz
	"npc_dota_hero_puck",					--蓝
	"npc_dota_hero_sniper",					--空
	"npc_dota_hero_tinker",					--教授
	"npc_dota_hero_venomancer" ,			--花妈
	
	"npc_dota_hero_zuus",					--神妈
	"npc_dota_hero_warlock",				--大妹
	"npc_dota_hero_bounty_hunter",			--狗花
	"npc_dota_hero_silencer",				--永琳
	"npc_dota_hero_obsidian_destroyer",		--紫
	
	"npc_dota_hero_templar_assassin",		--16
	"npc_dota_hero_visage"					--小爱
}

G_Bots_Ability_Add = {
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16  },
	{2,1,2,1,2,  6,2,1,1,10,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17  },
	{1,2,1,2,1,  6,1,2,2,10,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17  },
	{1,2,3,2,2,  6,2,3,3,11,  3,6,1,1,13, 1,0,6,0,15,  0,0,0,0,16  },
	
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16  }, --marisa wait for fix
	{2,1,3,3,3,  2,3,2,2,10,  6,6,1,1,13, 1,0,6,0,14,  0,0,0,0,16  },
	{2,1,1,3,1,  6,1,3,3,10,  3,6,2,2,12, 2,0,6,0,14,  0,0,0,0,17  },
	{2,1,2,3,2,  6,2,3,3,10,  3,6,1,1,13, 1,0,6,0,15,  0,0,0,0,16  },
	{1,3,1,3,1,  6,1,3,3,10,  2,6,2,2,13, 2,0,6,0,14,  0,0,0,0,17  },
	
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16  }, -- suika wait for fix
	{2,1,2,3,2,  6,2,3,3,11,  3,6,1,1,13, 1,0,6,0,14,  0,0,0,0,17  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17  },
	{1,2,1,2,1,  6,1,2,2,10,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17  },
	{1,2,3,2,2,  6,2,3,3,11,  3,6,1,1,13, 1,0,6,0,15,  0,0,0,0,16  },
	
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,16  },
	{2,1,2,3,2,  6,2,3,3,11,  3,6,1,1,13, 1,0,6,0,14,  0,0,0,0,17  },
	{1,2,1,2,1,  6,1,2,2,11,  3,6,3,3,12, 3,0,6,0,15,  0,0,0,0,17  },
	{1,2,1,2,1,  6,1,2,2,10,  3,6,3,3,13, 3,0,6,0,14,  0,0,0,0,17  },
	{1,2,3,1,1,  6,1,3,3,11,  3,6,2,2,12, 2,0,6,0,15,  0,0,0,0,16  }  --sanae
	
}

G_Bot_List = {}
G_Bot_Buff_List = {}
G_Bot_Diff_Text = {"easy","normal","hard","lunatic"}

function Split(szFullString, szSeparator)  
	local nFindStartIndex = 1  
	local nSplitIndex = 1  
	local nSplitArray = {}  
	while true do  
		local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
		if not nFindLastIndex then  
			nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
			break  
		end  
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
		nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
		nSplitIndex = nSplitIndex + 1  
	end  
	return nSplitArray  
end

function GetCurrentTime()
	-- hour, minute, second
	return string.match(GetSystemTime(), '(%d+)[:](%d+)[:](%d+)')
end

function GetHostPlayer()  --获取当前主机(房主)玩家的句柄
	for i=0,63 do
		local plyhd = PlayerResource:GetPlayer(i)
		-- 验证玩家是否为主机
		local is_host = GameRules:PlayerHasCustomGameHostPrivileges(plyhd)
		if is_host then return plyhd end
	end
	return nil
end

-- 验证玩家是否为主机
function IsHost( key )
	local i = tonumber(key)
	if i ~= nil then -- number
		local plyhd = PlayerResource:GetPlayer(i)
		return GameRules:PlayerHasCustomGameHostPrivileges(plyhd)
	else 
		return GameRules:PlayerHasCustomGameHostPrivileges(key)
	end
end

function HostSay( text )  --由主机发送某条消息(当做日志, 提示等, 发送给所有人)
	Say(GetHostPlayer(),text,false)
end

function THDOTSGameMode:ChangeBotDifficulty( player, dif )
	
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_STRATEGY_TIME then -- can't change difficulty in game
		Say(player, "Can't change bot's difficulty after bot spawned!",false)
		print("THDOTSGameMode:ChangeBotDifficulty: Error: Can't Change difficulty after bot spawned")
		return
	end
	if dif <=0 or dif > 4 then --invalid difficulty
		Say(player, "invalid difficulty!",false)
		print("THDOTSGameMode:ChangeBotDifficulty: Error: invalid difficulty")
		return
	end
	cur_bot_dif = dif
	
	local text = G_Bot_Diff_Text[dif]
	Say(player, "Bot Difficulty set to " .. text, false)
	print("Bot Difficulty set to " .. text)
	
	-- not modify at here now, see state changes
	--[[
	for k,v in pairs(G_Bot_List) do
		local tHero = PlayerResource:GetPlayer(v):GetAssignedHero()
		tHero:SetBotDifficulty(dif)
	end
	
	for k,v in pairs(G_Bot_Buff_List) do
		v:SetLevel(dif)
	end
	]]--
end

--not working
--[[
G_Random_Player_List = {false,false,false,false,false,false,false,false,false,false,false}

function THDOTSGameMode:OnPlayerRandomChoose( keys )
	
	print("THDOTSGameMode:OnPlayerRandomChoose:")
	print(keys.playerid)
	G_Random_Player_List[keys.playerid] = true
	
end
]]--

boolstr = {
	[true] = "Yes",
	[false] = "No"
}

G_Player_Pause_Count = {0,0,0,0,0,0,0,0,0,0,0,0,0,0}
G_Player_Cloth = {1,1,1,1,1,1,1,1,1,1,1,1,1,1}
G_Player_IsCoach = {0,0,0,0,0,0,0,0,0,0,0,0,0,0}
MAX_Pause_Count = 6

function DisplayChampion( caster )
	local unit = CreateUnitByName(
		"npc_vision_dummy_unit"
		,caster:GetOrigin()
		,false
		,caster
		,caster
		,caster:GetTeam()
	)

	local effectIndex = ParticleManager:CreateParticle("particles/champion/champion.vpcf", PATTACH_CUSTOMORIGIN, caster) 
	ParticleManager:SetParticleControlEnt(effectIndex , 0, caster, 5, "attach_hitloc", Vector(0,0,0), true)

	Timer.Loop 'DisplayChampion' ( 0.1, 5 * 10,
			function(i)
				unit:SetOrigin(caster:GetOrigin())
				if i == 5 * 10 then
					unit:RemoveSelf()
					ParticleManager:DestroyParticleSystem(effectIndex,true)
					return true
				end
			end
	)
end



function THDOTSGameMode:OnPlayerSay( keys )
	local text = keys.text
	-- 获取玩家的id与handle
	local plyid = keys.playerid
	if plyid < 0 then return end --console
	local plyhd = PlayerResource:GetPlayer(plyid)
	-- 验证玩家是否为主机(影响接下来某些选项的设置权)
	local is_host = GameRules:PlayerHasCustomGameHostPrivileges(plyhd)
	-- is_host 的值就是发言的玩家是否为主机
	local tmp = "false"
	if is_host then tmp = "true" end
	print("player " .. plyid .. " says " .. text )
	print("player is host: " .. tmp )
	
	local ss = Split( text, " " )
	
	if is_host then  --主机限定的指令(所有图通用)
	
		
		if text == "-print_nearby_abilities" then
			local tmp = Entities:FindAllInSphere(PlayerResource:GetPlayer(plyid):GetAssignedHero():GetOrigin(),300)
			for _,v in pairs(tmp) do
				print('---------------')
				print(v:GetOrigin())
				print(v:GetClassname()..":")
				local cnt = v:GetAbilityCount()
				for i=0,cnt do
					if v:GetAbilityByIndex(i) ~= nil then
						print(v:GetAbilityByIndex(i):GetAbilityName())
					end
				end
				print('---------------')
			end
			return
		end
	
		if text == "-print_nearby_modifiers" then
			local tmp = Entities:FindAllInSphere(PlayerResource:GetPlayer(plyid):GetAssignedHero():GetOrigin(),300)
			for _,v in pairs(tmp) do
				print('---------------')
				print(v:GetOrigin())
				print(v:GetClassname()..":")
				local cnt = v:GetModifierCount()
				for i=0,cnt do
					print(v:GetModifierNameByIndex(i))
				end
				print('---------------')
			end
			return
		end
		
		if text == "-print_nearby_item" then
			local tmp = Entities:FindAllInSphere(PlayerResource:GetPlayer(plyid):GetAssignedHero():GetOrigin(),300)
			for _,v in pairs(tmp) do
				print('---------------')
				print(v:GetOrigin())
				print(v:GetClassname())
				print('---------------')
				--HostSay(v:GetClassname())
			end
			return
		elseif text == "-print_position" then
			local tmp = PlayerResource:GetPlayer(plyid):GetAssignedHero():GetOrigin()
			print(tmp)
			return
		elseif ss[1] == "-observeinit" then  --仅预处理观战模式
			if GameRules:State_Get() <= 2 then --只允许洗牌阶段用
				enable_observe( ss[2] ~= "0" )
				observerhd = PlayerResource:GetPlayer(plyid)
			end
		elseif ss[1] == "-observe" then  --make host observing
			if GameRules:State_Get() <= 2 then 
				enable_observe( ss[2] ~= "0" )
				enable_coach( plyid, true )
				observerhd = PlayerResource:GetPlayer(plyid)
			end
		elseif text == "-allowsame" then  --允许选择相同少女
			GameRules:SetSameHeroSelectionEnabled(true)
			Say(plyhd, "Allowsame Mode ON...",false)
		elseif text == "-unallowsame" then  --不再允许选择相同少女
			GameRules:SetSameHeroSelectionEnabled(false)
			Say(plyhd, "Allowsame Mode OFF...",false)
		end
		if GameRules:State_Get() < DOTA_GAMERULES_STATE_STRATEGY_TIME then --只能在决策阶段(所有人选完人)前使用,主要是为了防止恶意使用
			if text == "-fastrespawn" then  --快速复活
				G_IsFastRespawnMode = true
				Say(plyhd, "Fast Respawn Mode ON",false)
			elseif text == "-unfastrespawn" then
				G_IsFastRespawnMode = false
				Say(plyhd, "Fast Respawn Mode OFF",false)
			elseif text == "-fastcd" then  --快速CD(-80%冷却时间,类似wtf但蓝量非无限)
				G_IsFastCDMode = true
				Say(plyhd, "Fast CoolDown Mode ON",false)
			elseif text == "-unfastcd" then
				G_IsFastCDMode = false
				Say(plyhd, "Fast CoolDown Mode OFF",false)
			end
		else
			if text == "-fastrespawn" or text == "-unfastrespawn" or text == "-fastcd" or text == "-unfastcd" then
				HostSay("Can't Change it now,please do this earlier at shuffle state.")
			end
		end
	end
	
	--完全通用的公共指令
	if text=="-checkmap" then
		HostSay("mapname is: "..GetMapName())
		HostSay("FastCoolDown: "..boolstr[G_IsFastCDMode])
		HostSay("FastRespawn: "..boolstr[G_IsFastRespawnMode])
		if Bot_Mode then
			HostSay("BotDiff: "..G_Bot_Diff_Text[cur_bot_dif])
		end
	elseif ss[1] == "-debugtext" then
		DisplayChampion( PlayerResource:GetPlayer(plyid):GetAssignedHero() )
	elseif ss[1] == "-coach" then
		if GetMapName() == "4_thdots_with_coach" and GameRules:State_Get() <= 2 then
			enable_coach( plyid, ss[2] == "1" )
		end
	elseif ss[1] == "-keybind" then
		if PlayerResource:GetSelectedHeroName(plyid) == "npc_dota_hero_invoker" then
			CustomGameEventManager:Send_ServerToPlayer(plyhd, "custom_key_bind", {key_val = ss[2], event = "xianzhezhishi"} )
		end
	elseif text == "-pause" then
		if is_host or G_Player_Pause_Count[plyid+1] < MAX_Pause_Count then --host可以无限暂停
			G_Player_Pause_Count[plyid+1] = G_Player_Pause_Count[plyid+1] + 1
			PauseGame(not GameRules:IsGamePaused()) -- set as not
		else
			HostSay( string.format( "Player %d has Paused %d times!You can pause any more now.", plyid, MAX_Pause_Count ) )
		end
	elseif ss[1] == "-cloth" then
		update_cloth( G_Player_Cloth, plyid, tonumber(ss[2]) )
	-- do not need this anymore from now on
	-- just click button to random pick
	--[[
	elseif text == "-random" then
		if GameRules:State_Get() > 2 then -- after shuffle
			if PlayerResource:HasSelectedHero(plyid) == false then
				PlayerResource:GetPlayer(plyid):MakeRandomHeroSelection()
				--PlayerResource:ModifyGold(plyid,200,true,0); --200 extra gold
			end
		end
	]]
	elseif text == "ruozhitaidao" then --gtmdtd(这里是大鸽加的, 而且本来是空的)
		HostSay("gtmdtd")  --这个是我加的 XD
	end
	
	if text == "getnum" then
		local num = GetNum()
		HostSay("num is " .. tostring(num))
	end
	-- if text == "1" then
	-- 	HostSay("-createhero leg")
	-- end
	-- if text == "2" then
	-- 	HostSay("-createhero leg enemy")
	-- end
	--以上为所有玩家和地图可用的通用指令
	
	if GetMapName() ~= "dota" then return end
	-- 下面的指令就只能在dota(bot)地图中使用了
	
	if is_host then  --这些指令仍然是主机限定的
		if text == "-addbot" then --启用bot
			Bot_Mode = true
			HostSay("Bot Mode ON...")
			--具体改动到了state变动
			--必须在选人完成前使用才有效
		elseif text == "-removebot" then --取消bot
			Bot_Mode = false
			HostSay("Bot Mode OFF...")
			--必须在选人完成前使用才有效
		elseif text == "-startbot" then --运行bot脚本
			--开启sv_cheats (现在不需要了)
			--SendToServerConsole('sv_cheats 1')
			GameRules:GetGameModeEntity():SetBotThinkingEnabled(true)
			GameRules:GetGameModeEntity():SetBotsMaxPushTier(cur_bot_dif + 2)
			G_IsAIMode = true
			HostSay("Bot Start to Think...")
		elseif text == "-stopbot" then --停止bot脚本
			GameRules:GetGameModeEntity():SetBotThinkingEnabled(false)
			G_IsAIMode = false
			HostSay("Bot Stop to Think...")
		elseif text == "-easy" then --选择难度, 以下共4种
			self:ChangeBotDifficulty(plyhd,1)
			--Say(nil, "Bot Difficulty set to easy",false)
		elseif text == "-normal" then
			self:ChangeBotDifficulty(plyhd,2)
			--Say(nil, "Bot Difficulty set to normal",false)
		elseif text == "-hard" then 
			self:ChangeBotDifficulty(plyhd,3)
			--Say(nil, "Bot Difficulty set to hrad",false)
		elseif text == "-lunatic" then 
			self:ChangeBotDifficulty(plyhd,4)
			--Say(nil, "Bot Difficulty set to lunatic",false)
		end
	end

end

function THDOTSGameMode:CheckChoose( keys )
	--有玩家未选择少女则随机选择
	print("CheckChoose")
	for i=0,9 do
		if PlayerResource:HasSelectedHero(i) == false then
			PlayerResource:GetPlayer(i):MakeRandomHeroSelection()
			print(i)
		end
	end
end

-- 这个函数是在有玩家连接到游戏之后，调用的，请查看 THDOTSGameMode:AutoAssignPlayer里面调用这个函数的部分
-- 主要是设置属于游戏模式的相关规则，并且开启循环计时器
function THDOTSGameMode:CaptureGameMode()
	print("THDOTSGameMode:CaptureGameMode")
	 
	
  if GameMode == nil then
	  GameMode = GameRules:GetGameModeEntity()		

    -- 设定镜头距离的大小，默认为1134
    GameMode:SetCameraDistanceOverride( 1134.0 )
   end
end

-- 以下的这些函数，大多都是把传递的数值Print出来
-- PrintTable和print的东西，都会显示在控制台上
-- PrintTable会显示例如
-- caster:
--        table:0x00ff000
-- caster_entindex:195
-- target:
--        table:0x00ff000
-- 这样的内容，那么我们就可以通过keys.caster_entindex来获取这个caster的Entity序号
-- 再通过
-- EntIndexToHScript(keys.caster_entindex)
-- 就可以获取这个施法者相对应的hScript了

function THDOTSGameMode:AbilityUsed(keys)
	print("THDOTSGameMode:AbilityUsed")
	-- local caster = EntIndexToHScript(keys.caster_entindex)
	--  -- print_r(keys)
	-- 	for i=0,15 do 
	-- 		if caster:GetAbilityByIndex(i) ~= nil then
	-- 			print(caster:GetAbilityByIndex(i):GetName())
	-- 		end
	-- 	end
	-- 	print("------------------------------------")
	-- 	for i=0,8 do 
	-- 		if caster:GetModifierNameByIndex(i) ~= nil then
	-- 			-- print(caster:GetModifierNameByIndex(i))
	-- 		end
	-- 	end
		
	-- 	print("------------------------------------")
  local ply = EntIndexToHScript(keys.PlayerID+1)
  if(ply==nil)then
    return
  end
  local caster = ply:GetAssignedHero()
  if(caster==nil)then
    return
  end
end

function THDOTSGameMode:AbilityLearn(keys)
	print("THDOTSGameMode:AbilityLearn")
	local ply = EntIndexToHScript(keys.player)
    if(ply==nil)then
      return
    end
	local caster = ply:GetAssignedHero()
end

G_Bot_Level = {0,0,0,0,0,0,0,0,0,0,0}

function THDOTSGameMode:BotUpGradeAbility(hero)
	print("THDOTSGameMode:BotUpGradeAbility")
	
	local hName = hero:GetClassname()
	local hIndex = -1
	for i=0,233 do
		if G_Bot_Random_Hero[i] == hName then
			hIndex = i
			break
		end
	end
	
	if hIndex < 0 then
		print('THDOTSGameMode:BotUpGradeAbility: Error: invalid hero name: ' .. hName )
	else
		local v = hero:GetPlayerOwnerID()
		local lvl = hero:GetLevel()
		--print(lvl)
		if lvl == nil then
			lvl = 1
		end
		--print(lvl)
		for i=G_Bot_Level[v]+1,lvl do
			local j = G_Bots_Ability_Add[hIndex][i] - 1 --abilitys is 0~n-1, but vals set as 1~n
			local ability = hero:GetAbilityByIndex(j)
			if ability~=nil then
				local level = math.min((ability:GetLevel() + 1),ability:GetMaxLevel())
				ability:SetLevel(level)
			end
		end
		
		G_Bot_Level[v] = lvl
		
	end
	
	hero:SetAbilityPoints(0)
	
end

function THDOTSGameMode:Levelup(keys)
	print("THDOTSGameMode:Levelup")
	 
	
	if G_IsAIMode == true then
	    for k,v in pairs(G_Bot_List) do
	    	--if v == keys.player then
			-- just updata every bot is ok
    			local ply = PlayerResource:GetPlayer(v)
	    		local hero = ply:GetAssignedHero()
				self:BotUpGradeAbility(hero)
		 	--end
		end
	end
end

function THDOTSGameMode:BotUpGradeAbilityCommon(caster)
	print("THDOTSGameMode:BotUpGradeAbilityCommon")
	 
	
	-- local unitNameSlot = G_BOT_Ability_list[caster:GetUnitName()]
	-- local abilitySlot = nil
	-- if unitNameSlot~=nil then
	-- 	abilitySlot = unitNameSlot[caster:GetLevel()]
	-- end
	-- if abilitySlot ~= nil then
	-- 	local ability = caster:GetAbilityByIndex(abilitySlot)
	-- 	ability:UpgradeAbility(true)
	-- else
	-- 	for i=0,16 do
	-- 	 	local ability = caster:GetAbilityByIndex(i)
	-- 	 	if ability:CanAbilityBeUpgraded() then
	-- 			ability:UpgradeAbility(true)
	-- 			break
	-- 		end
	-- 	end 
	-- end
	--caster:SetAbilityPoints(0)
end

function THDOTSGameMode:AutoAssignPlayer(keys)
	--print("THDOTSGameMode:BotUpGradeAbilityCommon")
	 
	
	-- 这里调用CaptureGameMode这个函数，执行游戏模式初始化
	THDOTSGameMode:CaptureGameMode()
end


function THDOTSGameMode:getItemByName( hero, name )
  for i=0,11 do
    local item = hero:GetItemInSlot( i )
    if item ~= nil then
      local lname = item:GetAbilityName()
      if lname == name then
        return item
      end
    end
  end

  return nil
end

function THDOTSGameMode:OnEntityKilled( keys )
	-- 储存被击杀的单位
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	-- 储存杀手单位
	local killerEntity = EntIndexToHScript( keys.entindex_attacker )

	if killedUnit:IsHero() and not killedUnit.HasAegis and not killedUnit:IsIllusion() then --判断有无不朽盾，并BIU
 		killedUnit:EmitSound("THD_BIU")
	end

	for i=0,10 do --因幡帝，资本家
		if PlayerResource:GetPlayer(i) == nil then break end
		if killedUnit:FindAbilityByName("ability_dummy_unit") then return end
		local ply = PlayerResource:GetPlayer(i)
		local hero = ply:GetAssignedHero()
		if hero == nil then break end
		if hero:GetName() == "npc_dota_hero_gyrocopter" and FindTelentValue(hero,"special_bonus_unique_tei_4") == 1 then
			local gold = RandomInt(2, 6)
			hero:ModifyGold(gold, false, DOTA_ModifyGold_Unspecified)
		end
	end

	if(killedUnit:IsHero()==false and killedUnit:GetUnitName()~= "ability_yuuka_flower") then
		if killedUnit:FindAbilityByName("ability_dummy_unit") then return end --若被击杀的单位是马甲，则return
		local i = RandomInt(0,100)
		if(i<5)then
			local unit = CreateUnitByName(
				"npc_coin_up_unit"
				,killedUnit:GetOrigin()
				,false
				,killedUnit
				,killedUnit
				,DOTA_UNIT_TARGET_TEAM_NONE
				)
			unit:SetThink(
				function()
					unit:RemoveSelf()
					return nil
				end, 
				"ability_collection_power_remove",
			30.0)
		end
		i = RandomInt(0,100)
		if(i<5)then
			local unit = CreateUnitByName(
				"npc_power_up_unit"
				,killedUnit:GetOrigin()
				,false
				,killedUnit
				,killedUnit
				,DOTA_UNIT_TARGET_TEAM_NONE
				)
			unit:SetThink(
				function()
					unit:RemoveSelf()
					return nil
				end, 
				"ability_collection_power_remove",
			30.0)
		end
	end
	
	if(killedUnit:IsHero()==true)then
		if killedUnit:GetClassname() == "npc_dota_hero_kunkka" and killedUnit.IsDriving == true then
			--print('test_ship')
			--local murasaship = killedUnit.ability_minamitsu_ship
			--murasaship:CastAbilityOnPosition(murasaship:GetAbsOrigin(),murasaship:FindAbilityByName("ability_thdots_minamitsu04_unit_download"),-1)
			self:OnMinamitsu04ShipDownload(killedUnit)
		end
	end
	
	if(killedUnit:IsHero()==true)then
    local effectIndex = ParticleManager:CreateParticle("particles/thd2/environment/death/act_hero_die.vpcf", PATTACH_CUSTOMORIGIN, killedUnit)
    ParticleManager:SetParticleControl(effectIndex, 0, killedUnit:GetOrigin())
    ParticleManager:SetParticleControl(effectIndex, 1, killedUnit:GetOrigin())
    ParticleManager:DestroyParticleSystem(effectIndex,false)
		local powerStatValue = killedUnit:GetContext("hero_bouns_stat_power_count")
		if(powerStatValue==nil)then
			return
		end
		local powerDecrease = (powerStatValue - powerStatValue%2)/2
		killedUnit:SetContextNum("hero_bouns_stat_power_count",powerStatValue-powerDecrease,0)
		local ability = killedUnit:FindAbilityByName("ability_common_power_buff")
		if(killedUnit:GetPrimaryAttribute()==0)then
			killedUnit:SetModifierStackCount("common_thdots_power_str_buff",ability,powerStatValue-powerDecrease)
		elseif(killedUnit:GetPrimaryAttribute()==1)then
			killedUnit:SetModifierStackCount("common_thdots_power_agi_buff",ability,powerStatValue-powerDecrease)
		elseif(killedUnit:GetPrimaryAttribute()==2)then
			killedUnit:SetModifierStackCount("common_thdots_power_int_buff",ability,powerStatValue-powerDecrease)
		end
	end
  
  	if(killerEntity:IsHero()==true)then
    	local abilityNecAura = killerEntity:FindAbilityByName("necrolyte_heartstopper_aura")
	    if(abilityNecAura~=nil)then
	    	local abilityLevel = abilityNecAura:GetLevel()
	    	if(abilityLevel~=nil)then
	    		killerEntity:SetMana(killerEntity:GetMana()+(abilityLevel*5+5))
	    	end
	    end
 	end
 	
end

function THDOTSGameMode:OnHeroSpawned( keys )
	--print("THDOTSGameMode:OnHeroSpawned")
	--if GameRules:State_Get() < DOTA_GAMERULES_STATE_PRE_GAME then return end
	 
	
  local hero = EntIndexToHScript(keys.entindex)
  if(hero==nil)then
    return
  end

  if hero:IsHero() then
  
		--print('THDOTSGameMode:OnHeroSpawned:')
		--print(hero:GetClassname())
		--print('strated')
		
	 	if hero.isFirstSpawn == nil or hero.isFirstSpawn == true then
		    self:PrecacheHeroResource(hero)
			
			-- set bot's default ability level
		    if G_IsAIMode == true then
			    local plyID = hero:GetPlayerOwnerID()
			    for k,v in pairs(G_Bot_List) do
			    	if v == plyID then
						local bot_buff_ability = hero:AddAbility("ability_common_bot_buff") --bot mana buff
						if bot_buff_ability ~= nil then
							table.insert(G_Bot_Buff_List,bot_buff_ability)
							bot_buff_ability:SetLevel(cur_bot_dif) -- bot's default difficulty
						end
						hero:SetBotDifficulty(cur_bot_dif)
						self:BotUpGradeAbility(hero) -- init abilities
						--[[
						for i=0,16 do
						 	local ability = hero:GetAbilityByIndex(i)
							if ability~=nil then
								local level = 1 or ability:GetMaxLevel()
								ability:SetLevel(level)
							end
						end
						]]--
				 	end
				end
			end
			
			if G_IsFastCDMode then --Fast CoolDown
				local fastCDability = hero:AddAbility("ability_fast_cd_buff")
				if fastCDability ~= nil then
					fastCDability:SetLevel(1)
				end
			end
			
		    local ability = hero:AddAbility("ability_common_power_buff")
			if ability ~= nil then
				ability:SetLevel(1)
				if(hero:GetPrimaryAttribute()==0)then
					ability:ApplyDataDrivenModifier(hero,hero,"common_thdots_power_str_buff",{})
				elseif(hero:GetPrimaryAttribute()==1)then
					ability:ApplyDataDrivenModifier(hero,hero,"common_thdots_power_agi_buff",{})
				elseif(hero:GetPrimaryAttribute()==2)then
					ability:ApplyDataDrivenModifier(hero,hero,"common_thdots_power_int_buff",{})
				end
			end
			-- not working
			--[[
			if PlayerResource:HasRandomed(hero:GetPlayerOwnerID()) then --this player random picked
				print('Player' .. hero:GetPlayerOwnerID() .. 'gain 200 gold' )
				hero:ModifyGold( 200, true, 0 )
			end
			]]--
			
		    hero.isFirstSpawn = false
			
	  	end

		if hero:GetClassname() == "npc_dota_hero_drow_ranger" then
		    hero:SetModel("models/thd2/koishi/koishi_mmd.vmdl")
		    hero:SetOriginalModel("models/thd2/koishi/koishi_mmd.vmdl")
		    PlayerResource:SetCameraTarget(hero:GetPlayerOwnerID(), nil)
		    hero:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
		end
		
		local plyid = hero:GetPlayerOwnerID() + 1
		if plyid > 0 then
			local cloth_id = G_Player_Cloth[plyid]
			--print(plyid)
			--print(cloth_id)
			if Hero_Cloth[hero:GetClassname()] ~= nil then
				local cloth = Hero_Cloth[hero:GetClassname()][ cloth_id ]
				local cloth_size = Hero_Cloth[hero:GetClassname()..'_size'][ cloth_id ]
				if cloth ~= nil then
					hero:SetModel(cloth)
					hero:SetModelScale(cloth_size)
					hero:SetOriginalModel(cloth)
				end
			end
		end
		
		--print('THDOTSGameMode:OnHeroSpawned:')
		--print(hero:GetClassname())
		--print('ended')
		
  end
end

function THDOTSGameMode:PrecacheHeroResource(hero)
	local heroName = hero:GetClassname()
	local context

	local abilityEx
	local modifierRemove

	--DeepPrintTable()
	--motion:
	--motion:EnableMotion()
	print('THDOTSGameMode:PrecacheHeroResource:')
	print(heroName)

	if(heroName == "npc_dota_hero_zuus")then
		require( 'abilities/abilityYasaka' )
	elseif(heroName == "npc_dota_hero_slark")then
		require( 'abilities/abilityAya' )
	elseif(heroName == "npc_dota_hero_lina")then
		require( 'abilities/abilityReimu' )
		require( 'abilities/abilityReisen' )
	elseif(heroName == "npc_dota_hero_juggernaut")then
		require( 'abilities/abilityYoumu' )
		abilityEx = hero:FindAbilityByName("ability_thdots_youmuEx")
		abilityEx:SetLevel(1)
	elseif(heroName == "npc_dota_hero_drow_ranger")then
		require( 'abilities/abilityKoishi' )
	elseif(heroName == "npc_dota_hero_earthshaker")then
		require( 'abilities/abilityTensi' )
	elseif(heroName == "npc_dota_hero_dark_seer")then
		require( 'abilities/abilityByakuren' )
		abilityEx = hero:FindAbilityByName("ability_thdots_byakuren04")
		abilityEx:SetLevel(1)
	elseif(heroName == "npc_dota_hero_crystal_maiden")then
		require( 'abilities/abilityMarisa' )
	elseif(heroName == "npc_dota_hero_furion")then
		require( 'abilities/abilityKaguya' )	
		abilityEx = hero:FindAbilityByName("ability_thdots_kaguyaEx")
		abilityEx:SetLevel(1)		
	elseif(heroName == "npc_dota_hero_necrolyte")then
		require( 'abilities/abilityYuyuko' )
		hero:SetContextNum("ability_yuyuko_Ex_deadflag",FALSE,0)
		GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(THDOTSGameMode, 'OnTHDOTSDamageFilter'), self)
		abilityEx = hero:FindAbilityByName("ability_thdots_yuyukoEx")
		abilityEx:SetLevel(1)
	elseif(heroName == "npc_dota_hero_templar_assassin")then
		require( 'abilities/abilitySakuya' )
		abilityEx = hero:FindAbilityByName("ability_thdots_sakuyaEx")
		abilityEx:SetLevel(1)
	elseif(heroName == "npc_dota_hero_razor")then
		require( 'abilities/abilityIku' )
		abilityEx = hero:FindAbilityByName("ability_thdots_ikuEx")
		abilityEx:SetLevel(1)	
		abilityEx_2 = hero:FindAbilityByName("ability_thdots_iku_pose")
		abilityEx_2:SetLevel(1)
	elseif(heroName == "npc_dota_hero_naga_siren")then
		require( 'abilities/abilityFlandre' )
		abilityEx = hero:FindAbilityByName("ability_thdots_flandreEx")
		abilityEx:SetLevel(1)
	elseif(heroName == "npc_dota_hero_chaos_knight")then
		require( 'abilities/abilityMokou' )
		abilityEx = hero:FindAbilityByName("ability_thdots_mokouEx")
		abilityEx:SetLevel(1)
	elseif(heroName == "npc_dota_hero_sniper")then
		--hero:EnableMotion()
	elseif(heroName == "npc_dota_hero_mirana")then
		abilityEx = hero:FindAbilityByName("ability_thdots_reisenOldex")
		abilityEx:SetLevel(1)
		--hero:EnableMotion()
	elseif(heroName == "npc_dota_hero_silencer")then
		abilityEx = hero:FindAbilityByName("ability_thdots_eirinex")
		abilityEx:SetLevel(1)
		hero.ability_eirinEx_count = 0
		hero:SetContextThink(DoUniqueString("Thdots_eirinEx_passive"),
		  function()
		  	if GameRules:IsGamePaused() then return 0.03 end
		    hero.ability_eirinEx_count = hero.ability_eirinEx_count + 1
		    if(hero.ability_eirinEx_count >= 81)then
		      hero.ability_eirinEx_count = 0
		      hero:SetBaseIntellect(hero:GetBaseIntellect()+1)
		    end
		    if(hero:FindModifierByName("modifier_silencer_int_steal")~=nil)then
		      hero:RemoveModifierByName("modifier_silencer_int_steal")
		    end
		    return 1.0
		  end
		,1.0)
	elseif(heroName == "npc_dota_hero_bounty_hunter")then
		abilityEx = hero:FindAbilityByName("ability_system_criticalstrike")
		abilityEx:SetLevel(1)
	elseif(heroName == "npc_dota_hero_tinker")then
		abilityEx = hero:FindAbilityByName("ability_thdots_yumemiEx")
		abilityEx:SetLevel(1)
	elseif(heroName == "npc_dota_hero_axe")then
		hero:SetContextThink("ability_cirno_ex", 
		    function()
		    	if GameRules:IsGamePaused() then return 0.03 end
		      	if hero:GetIntellect()~=9 then
		        	hero:ModifyIntellect(9-hero:GetIntellect())
		      	end
		      return 0.1
		    end, 
		0.1)
	elseif(heroName == "npc_dota_hero_kunkka")then
		GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(THDOTSGameMode, 'OnMinamitsu04Order'), self)
	elseif(heroName == "npc_dota_hero_puck")then
		abilityEx = hero:FindAbilityByName("ability_thdots_RanEx")
		abilityEx:SetLevel(1)
	elseif(heroName == "npc_dota_hero_venomancer")then
		GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(THDOTSGameMode, 'OnTHDOTSDamageFilter'), self)
		abilityEx = hero:FindAbilityByName("ability_thdots_YuukaEx")
		abilityEx:SetLevel(1)
		abilityEx2 = hero:FindAbilityByName("ability_thdots_YuukaEx2")
		abilityEx2:SetLevel(1)
  	elseif(heroName == "npc_dota_hero_visage")then
	   	abilityEx = hero:FindAbilityByName("ability_thdots_MargatroidEx")
	    abilityEx:SetLevel(1)

	    local doll=CreateUnitByName(
					"ability_margatroidex_doll",
					hero:GetOrigin(),
					false,
					hero,
					hero,
					hero:GetTeam())
		doll:SetModel("models/alice/penglai.vmdl")
		doll:SetOriginalModel("models/alice/penglai.vmdl")
		doll:RemoveSelf()
	elseif(heroName == "npc_dota_hero_phantom_assassin")then
	   	abilityEx = hero:FindAbilityByName("ability_thdots_nueEx")
	    abilityEx:SetLevel(1)
	elseif(heroName == "npc_dota_hero_rubick")then
		hero:FindAbilityByName("rubick_empty2"):SetHidden(true)
	elseif(heroName == "npc_dota_hero_invoker")then		
		local ability = hero:FindAbilityByName("ability_thdots_patchouli_xianzhezhishi")
		ability:SetLevel(1)	
		ability = hero:FindAbilityByName("ability_thdots_patchouli_fire_fire")
		ability:SetLevel(1)
		ability:SetHidden(true)
		ability = hero:FindAbilityByName("ability_thdots_patchouli_fire_water")
		ability:SetLevel(1)
		ability:SetHidden(true)
		ability = hero:FindAbilityByName("ability_thdots_patchouli_fire_wood")
		ability:SetLevel(1)
		ability:SetHidden(true)
		ability = hero:FindAbilityByName("ability_thdots_patchouli_fire_metal")
		ability:SetLevel(1)
		ability:SetHidden(true)
		ability = hero:FindAbilityByName("ability_thdots_patchouli_fire_earth")
		ability:SetLevel(1)
		ability:SetHidden(true)
		ability = hero:FindAbilityByName("ability_thdots_patchouli_water_water")
		ability:SetLevel(1)
		ability:SetHidden(true)
		ability = hero:FindAbilityByName("ability_thdots_patchouli_water_wood")
		ability:SetLevel(1)
		ability:SetHidden(true)
		ability = hero:FindAbilityByName("ability_thdots_patchouli_water_metal")
		ability:SetLevel(1)
		ability:SetHidden(true)
		ability = hero:FindAbilityByName("ability_thdots_patchouli_water_earth")
		ability:SetLevel(1)
		ability:SetHidden(true)
		ability = hero:FindAbilityByName("ability_thdots_patchouli_wood_wood")
		ability:SetLevel(1)
		ability:SetHidden(true)		
		ability = hero:FindAbilityByName("ability_thdots_patchouli_wood_metal")
		ability:SetLevel(1)
		ability:SetHidden(true)
		ability = hero:FindAbilityByName("ability_thdots_patchouli_wood_earth")
		ability:SetLevel(1)
		ability:SetHidden(true)
		ability = hero:FindAbilityByName("ability_thdots_patchouli_metal_metal")
		ability:SetLevel(1)
		ability:SetHidden(true)
		ability = hero:FindAbilityByName("ability_thdots_patchouli_metal_earth")
		ability:SetLevel(1)
		ability:SetHidden(true)		
		ability = hero:FindAbilityByName("ability_thdots_patchouli_earth_earth")
		ability:SetLevel(1)
		ability:SetHidden(true)
	elseif (heroName == "npc_dota_hero_lich") then
	   	abilityEx = hero:FindAbilityByName("ability_thdots_koakumaex")
	    abilityEx:SetLevel(1)
	elseif (heroName == "npc_dota_hero_dazzle") then
		GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(THDOTSGameMode, 'OnTHDOTSDamageFilter'), self)
		abilityEx = hero:FindAbilityByName("ability_thdots_lunasaEx")
		abilityEx:SetLevel(1)
	elseif (heroName == "npc_dota_hero_dragon_knight") then
		abilityEx = hero:FindAbilityByName("ability_thdots_meirinex")
		abilityEx:SetLevel(1)
	elseif (heroName == "npc_dota_hero_weaver") then
		abilityEx = hero:FindAbilityByName("ability_thdots_lyricaEx")
		abilityEx:SetLevel(1)
	elseif (heroName == "npc_dota_hero_mars") then
		abilityEx = hero:FindAbilityByName("ability_thdots_shouEx")
		abilityEx:SetLevel(1)
	elseif (heroName == "npc_dota_hero_night_stalker") then
		abilityEx = hero:FindAbilityByName("ability_thdots_mystiaex")
		abilityEx:SetLevel(1)
	elseif (heroName == "npc_dota_hero_earth_spirit") then
		abilityEx = hero:FindAbilityByName("ability_thdots_MerlinEx")
		abilityEx:SetLevel(1)
	elseif (heroName == "npc_dota_hero_vengefulspirit") then
		abilityEx = hero:FindAbilityByName("ability_thdots_hatateEx")
		abilityEx:SetLevel(1)	
	elseif (heroName == "npc_dota_hero_riki") then
		abilityEx = hero:FindAbilityByName("ability_thdots_kogasaex")
		abilityEx:SetLevel(1)
	elseif (heroName == "npc_dota_hero_gyrocopter") then
		abilityEx = hero:FindAbilityByName("ability_thdots_teiex")
		abilityEx:SetLevel(1)
	elseif (heroName == "npc_dota_hero_spectre") then
		abilityEx = hero:FindAbilityByName("ability_thdots_nitoriEx")
		abilityEx:SetLevel(1)
	elseif (heroName == "npc_dota_hero_legion_commander") then
		abilityEx = hero:FindAbilityByName("ability_thdots_kokoroEx")
		abilityEx:SetLevel(1)
		abilityEx = hero:FindAbilityByName("ability_thdots_kokoroEx_2")
		abilityEx:SetLevel(1)
		abilityEx = hero:FindAbilityByName("ability_thdots_kokoro03_release")
		abilityEx:SetLevel(1)
	elseif (heroName == "npc_dota_hero_luna") then  --天生有BUG，暂时回收
		abilityEx = hero:FindAbilityByName("ability_thdots_childEx")
		abilityEx:SetLevel(1)
	end
end

G_Player_randomed = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

function THDOTSGameMode:OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()
	if newState == 2 then -- CUSTOM_GAME_SETUP / shuffle
		-- WebApi:SetTesting(true)
		WebApi:BeforeMatch(THD2_Rating_Catcher)
		if GetMapName() == "4_thdots_with_coach" then
			GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 6 )
			GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 6 )
		end
		if Bot_Mode then
			HostSay("You're in bot mode.")
			HostSay("You can choose difficulty now.")
			HostSay("Usage: -easy, -normal, -hard, -lunatic.")
			HostSay("Default Difficulty: easy.")
		end
	elseif newState == 3 then -- HERO_SELECTION
		
		--[[
		GameRules:GetGameModeEntity():SetContextThink(
			"msg delay",
			function()
				HostSay("Please input -random to pick randomly.")
				HostSay("input -random will get 200 extra gold.")
				HostSay("click random button won't get anything.")
				return nil
			end,
			0.2
		)
		]]--
		local num = GetNum()
		HostSay("num is " .. tostring(num))
		GameRules:GetGameModeEntity():SetContextThink(
			"random checker",
			function()
				for i=0,20 do
					if G_Player_randomed[i+1] == 0 and PlayerResource:HasRandomed(i) then
						G_Player_randomed[i+1] = 1
						PlayerResource:ModifyGold(i,200,true,0);
					end
				end
				if GameRules:State_Get() >= 4 then return nil end
				return 0.2
			end,
			0.2
		)
	elseif newState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		
		--如果有人没选英雄则自动暂停游戏
		local paused = false
		local has_patchouli = false
		for i =0,63 do
			if PlayerResource:GetPlayer(i) ~= nil then
				if PlayerResource:HasSelectedHero(i) == false and not paused then
					
					GameRules:GetGameModeEntity():SetContextThink(
						"delay game pause",
						function()
							local ok = true
							for i =0,63 do
								if PlayerResource:GetPlayer(i) ~= nil 
								and PlayerResource:HasSelectedHero(i) == false
								then
									ok = false
									break
								end
							end
							if not ok then
								PauseGame(true)
								HostSay(".检测到有玩家未选择人物, 游戏已暂停")
								HostSay(".当所有人准备好后请输入 -pause 解除暂停")
								HostSay(".如果进入游戏后仍然未选择, 游戏会为玩家随机一个人物, 但没有额外赏金")
							end
							return nil
						end,
						24.0
					)
					paused = true
				end
				--对帕秋莉玩家的提醒
				if PlayerResource:GetSelectedHeroName(i) == "npc_dota_hero_invoker" and not has_patchouli then
					HostSay(".预读七曜的魔法使的技能，将造成短暂延迟。")
					--HostSay(".由于快捷键限制, 图书需要用自定义按钮来合成技能。")
					--HostSay(".可以使用-keybind X指令来绑定按键(如-keybind d)。")
					--HostSay(".如果不小心绑错了, 请断开并重连然后重新绑定即可。")
					--HostSay(".帕秋莉每3级获得1个额外技能点，用于加满所有天赋和技能。")
					HostSay(".帕秋莉每施放一个合成魔法，可以维持一个贤者之石3秒。")
					HostSay(".当贤者之石达到5个之后，会立刻触发日/月符。")
					HostSay(".白天触发日符「皇家烈焰」，对800范围内敌方英雄造成25%血量魔法伤害。")
					HostSay(".晚上触发月符「沉静的月神」，1200范围内友方英雄施加隐身且根据帕秋莉魔法上限的10%恢复生命魔法值，并降低所受伤害25%，持续10秒。")
					HostSay(".帕秋莉享受日/月元素加成，白天提高技能增强10%，晚上受到伤害降低10%")		
					has_patchouli = true
				end
			end
		end
		
		if Bot_Mode == true then
		
			HostSay("You're in bot mode.")
			--HostSay("You can choose difficulty now.")
			--HostSay("Usage: -easy, -normal, -hard, -lunatic.")
			--HostSay("Default Difficulty: easy.")
			HostSay("Bot Difficulty: " .. G_Bot_Diff_Text[cur_bot_dif])
		
			print("changing to bot mod...")
			print(GameRules:IsCheatMode()) --debug
			
			--DOTA2 的bot加载机制十分弱智
			--如果你进游戏的时候是作弊模式, 那么你就可以控制机器人了
			--但如果不是作弊模式会创建不了机器人
			--所以唯一的办法就是先开作弊创建机器人, 然后进游戏前关掉作弊, 进游戏以后再打开作弊并开启机器人脚本
			--十分弱智不是嘛qwq ? 
			--    来自zdw1999
			
			--[[
			
			local ply = nil
			for i=0,9 do --检测机器人将要使用的位置
				ply = PlayerResource:GetPlayer(i)
				if ply==nil then
					table.insert(G_Bot_List,i)
				end
			end
			--用bot填充空位
			SendToServerConsole('dota_bot_populate')
			SendToServerConsole('dota_bot_set_difficulty 3') --难度为hard
			--设置AI活动
			--local GameMode = GameRules:GetGameModeEntity()
			--GameMode:SetBotThinkingEnabled(true) --不要在这里开启脚本
			--设置AI推塔的最高级别
			--GameMode:SetBotsMaxPushTier(5)
			
			--在这里先关闭cheats, 等进游戏后执行 -startbot
			SendToServerConsole('sv_cheats 0')
			
			--]]
			
			--old bot load style
			--SendToServerConsole('sv_cheats 1')
			--print(GameRules:IsCheatMode()) --debug
			--G_IsAIMode = true
			
			--为了能够方便控制机器人的技能点和属性, 这里使用旧方式加载bot
			
			local GameMode = GameRules:GetGameModeEntity()
			local ply = nil
			local goodcnt = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
			local badcnt = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
			
			--清除玩家选择的英雄
			
			for i=0,233 do
				ply = PlayerResource:GetPlayer(i)
				if ply ~= nil then
					local tHeroName = PlayerResource:GetSelectedHeroName(i)
					print( 'Player ' .. string.format("%d",i) .. ' picked ' .. tHeroName )
					if tHeroName ~= nil then
						for j=0,233 do
							if G_Bot_Random_Hero[j] == tHeroName then
								G_BOT_USED[j] = true
								break
							end
						end
					end
				end
			end
			
			-- 创建bot
			
			for i=0,233 do
				ply = PlayerResource:GetPlayer(i)
				if ply ~= nil then
					print(string.format("player %d is not nil",i))
				end
				
				if goodcnt >= 5 and badcnt >= 5 then
					break
				end
				
				if ply == nil then
					local int = RandomInt(1, 32)
					while(G_BOT_USED[int])
					do
						int = RandomInt(1, 32)
					end
					bot_team = true
					if goodcnt >= 5 then
						bot_team = false
					end
					if bot_team == true then
						goodcnt = goodcnt + 1
					else 
						badcnt = badcnt + 1
					end
					--table.insert(G_Bot_List,i)
					Tutorial:AddBot(G_Bot_Random_Hero[int],'','',bot_team)
					G_BOT_USED[int]=true
					
				end
			end
			
			for i=0,233 do
				if PlayerResource:GetPlayer(i) ~= nil and PlayerResource:GetConnectionState(i) == 1 then
					table.insert(G_Bot_List,i)
					print(i)
				end
			end
			--如果存在机器人则启动AI
			
			if #G_Bot_List > 0 then
				G_IsAIMode = true
				--设置AI活动
				GameRules:GetGameModeEntity():SetBotThinkingEnabled(true)
				--设置AI推塔的最高级别
				GameRules:GetGameModeEntity():SetBotsMaxPushTier(cur_bot_dif + 2)
				--for i=0,9 do
				--	if PlayerResource:GetConnectionState(i)==1 then
				--		plyhd = PlayerResource:GetPlayer(keys.userid-1)
				--		plyhd:
				--	end
				--end
			end
			
			--在这里先关闭cheats, 等进游戏后执行 -startbot
			--G_IsAIMode = false
			--SendToServerConsole('sv_cheats 0')
			--print(GameRules:IsCheatMode()) --debug
			
			--Say(nil, "Bot Spawned...",false)
			print("Bot Spawned...") --debug
			
        end
    elseif newState == 5 then  --显示人物的阶段(过场)
		--random hero for anyone which not choosed
		for i =0,63 do
			if PlayerResource:GetPlayer(i) ~= nil then
				if PlayerResource:HasSelectedHero(i) == false then
					PlayerResource:GetPlayer(i):MakeRandomHeroSelection()
					--PlayerResource:ModifyGold(i,200,true,0); --no more 200 fold for this guy
				end
			end
		end
    elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then -- 地图加载好了, 所有人准备出门
		if Bot_Mode == true and #G_Bot_List > 0 then
			Tutorial:StartTutorialMode()
			HostSay("Bot Difficulty: " .. G_Bot_Diff_Text[cur_bot_dif])
			if G_IsFastRespawnMode then -- fast respawn mode
				GameMode:SetFixedRespawnTime(fast_respawn_val)
				HostSay("Fast Respawn Mode ON")
			end
			if G_IsFastCDMode then
				HostSay("Fast CoolDown Mode ON")
			end
		end
	elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then  --游戏到达 00:00(第一次刷符)
	
		--开启神符修正机制
		rune_fixer_init()
		
		GameRules:GetGameModeEntity():SetContextThink(
			"Bot Push All",
			function()
				GameRules:GetGameModeEntity():SetBotsMaxPushTier(6)
				return nil
			end,
			G_Bot_Push_All_Time[cur_bot_dif] * 60.0
		)
		
    end
  
	print(newState)
	
	if newState == 7 then
		
		G_Player_sighted = {}
		
		GameRules:GetGameModeEntity():SetContextThink( "observe sight", function ( ... )
			for i = 0,63 do
				if G_Player_sighted[i] == nil and PlayerResource:GetPlayer(i) ~= nil then
					print(i)
					local playerhero = PlayerResource:GetPlayer(i):GetAssignedHero()
					if PlayerResource:GetSelectedHeroName(i) ~= "npc_dota_hero_monkey_king"
					and playerhero ~= nil then
						if PlayerResource:GetPlayerCountForTeam(6) > 0 then
							CreateObserveSightUnit(playerhero)
						end
						G_Player_sighted[i] = true
						
					end
				end
			end
			if GameRules:State_Get() == 7 then
				return 5.0
			end
		end , 5.0)
		
	end
	
	if newState == DOTA_GAMERULES_STATE_POST_GAME then
		-- WebApi:SetTesting(true)
		WebApi:AfterMatch()
	end
	--之前的信使加载
	--[[
	if newState == 7 then
		GameRules:GetGameModeEntity():SetContextThink( "thetime", function ( ... )
			for i = 0,63 do
				if G_Player_courier[i] == nil and PlayerResource:GetPlayer(i) ~= nil then
					print(i)
					local playerhero = PlayerResource:GetPlayer(i):GetAssignedHero()
					if PlayerResource:GetSelectedHeroName(i) ~= "npc_dota_hero_monkey_king"
					and playerhero ~= nil then
						local xinshi = CreateUnitByName(
						"npc_dota_courier", 
						playerhero:GetOrigin() + ( playerhero:GetForwardVector() * 100), 
						false, 
						playerhero, 
						playerhero, 
						playerhero:GetTeam()
						)
						xinshi:SetControllableByPlayer(i, true)
						xinshi:SetOriginalModel("models/items/courier/shibe_dog_cat/shibe_dog_cat_flying.vmdl")
						--local ID = Caster:GetPlayerOwnerID()
						--xinshi:SetControllableByPlayer(ID,true)	
						local ability = xinshi:AddAbility("ability_system_fly")
						ability:SetLevel(1)	
						ability = xinshi:FindAbilityByName("courier_burst")
						ability:SetLevel(1)	
						if PlayerResource:GetPlayerCountForTeam(6) > 0 then
							CreateObserveSightUnit(playerhero)
						end
						G_Player_courier[i] = xinshi
					end
				end
			end
			if GameRules:State_Get() == 7 then
				return 5.0
			end
		end , 5.0)
	end
	]]--
  
end

G_Player_courier = {}
	
function THDOTSGameMode:OnMinamitsu04Order(keys)
  if keys.units["0"] ~= nil then
    local orderUnit = EntIndexToHScript(keys.units["0"])
    if orderUnit ~= nil then
      if keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
        if orderUnit:GetClassname() == "npc_dota_hero_kunkka" then
          if keys.entindex_target == orderUnit.ability_minamitsu_ship_index then
            local ship = EntIndexToHScript(orderUnit.ability_minamitsu_ship_index)
            self:OnMinamitsuMoveToShip(orderUnit,ship)
          end
        elseif orderUnit:GetUnitName() == "ability_minamitsu_04_ship"  then
          if keys.entindex_target == orderUnit.ability_minamitsu_hero_index then
            local hero = EntIndexToHScript(orderUnit.ability_minamitsu_hero_index)
            self:OnMinamitsuMoveToShip(hero,orderUnit)
            return false
          end
        end
      elseif keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
        if orderUnit:GetClassname() == "npc_dota_hero_kunkka" then
          if orderUnit.IsDriving then
            local ship = orderUnit.ability_minamitsu_ship
            if ship ~= nil and ship:IsNull() == false then
              ship:MoveToPosition(Vector(keys.position_x,keys.position_y,keys.position_z))
            end
          end
        end
      end
    end
  end
  return true
end


function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

function THDOTSGameMode:OnTHDOTSDamageFilter(keys)
	if keys.entindex_attacker_const == nil or keys.entindex_victim_const == nil then
		return true
	end
	local unit = EntIndexToHScript(keys.entindex_attacker_const) --施加伤害者
	local target = EntIndexToHScript(keys.entindex_victim_const) --受伤害者
	target.damage = keys.damage
	if target:IsHero() and not target:IsIllusion() then
		if target:HasModifier("modifier_item_aegis") then
			target.HasAegis = true
			-- print(target.HasAegis)
		else
			target.HasAegis = false
			-- print(target.HasAegis)
		end
	end
	if unit ~= nil and unit:IsNull() == false and target ~= nil and target:IsNull() == false then
		--提琴伤害监听
		if unit:IsHero() and unit:GetName() == "npc_dota_hero_dazzle" and keys.entindex_inflictor_const ~= nil then --entindex_inflictor_const是伤害来源,普攻为nil
			local LUNASA_DAMAGE_BONUS_PERCENT = unit:GetModifierStackCount("modifier_lunasa03", unit)/100 --法术暴击几率
			local percent = RandomFloat(0, 1.00) --随机数, 若几率大于随机数则暴击
			if LUNASA_DAMAGE_BONUS_PERCENT >= percent then
			local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_surge_start_fallback_low.vpcf", PATTACH_POINT, unit)
			ParticleManager:DestroyParticleSystem(effectIndex,false)
				keys.damage = keys.damage * 2
			end
		end
		--因幡帝3技能伤害监听
		if target:GetName() == "npc_dota_hero_gyrocopter" and keys.entindex_inflictor_const == nil and target:HasModifier("modifier_ability_thdots_tei03") 
			and unit:IsRangedAttacker() then
			local damage_reduce = 1 -FindValueTHD("beattacked_reduce",target:FindAbilityByName("ability_thdots_tei03")) / 100
			keys.damage = keys.damage * damage_reduce
		end
		--幽香花伤害对塔伤害监听
		if unit:GetUnitName()=="ability_yuuka_flower" and target:IsBuilding() then
			keys.damage = keys.damage * 0.15
		end
		if unit:IsHero()==false then
			unit = unit:GetOwner()
		end
		--幽幽子死亡BUFF伤害监听
		if target:GetClassname()=="npc_dota_hero_necrolyte" and target:GetContext("ability_yuyuko_Ex_deadflag") == FALSE  and target:IsRealHero() then
			if keys.damage >= target:GetHealth() then
				local vecCaster = target:GetOrigin()
				local effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/yuyuko/ability_yuyuko_04_effect.vpcf", PATTACH_CUSTOMORIGIN, target)
				ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
				ParticleManager:DestroyParticleSystem(effectIndex,false)

				effectIndex = ParticleManager:CreateParticle("particles/thd2/heroes/yuyuko/ability_yuyuko_04_effect_a.vpcf", PATTACH_CUSTOMORIGIN, target)
				ParticleManager:SetParticleControl(effectIndex, 0, target:GetOrigin())
				ParticleManager:SetParticleControl(effectIndex, 5, target:GetOrigin())
				ParticleManager:DestroyParticleSystem(effectIndex,false)
				local ability = target:FindAbilityByName("ability_thdots_yuyukoEx")
				ability:ApplyDataDrivenModifier(target, target, "modifier_thdots_yuyukoEx", {})
				target:SetHealth(target:GetMaxHealth())
				UnitNoDamageTarget(target,target,10)
				if FindTelentValue(target,"special_bonus_unique_necrophos_3") == 0 then
					UnitDisarmedTarget(target,target,10)					
				end
				target:SetContextNum("ability_yuyuko_Ex_deadflag",TRUE,0)
				local gameTime = GameRules:GetGameTime()
				target:SetContextThink(DoUniqueString("abilityyuyuko_Ex_undead_timer"), 
					function()
						if GameRules:IsGamePaused() then return 0.03 end
						if GameRules:GetGameTime() - gameTime <= 10.1 then
							if target:IsAlive() == false then
								target:SetContextNum("ability_yuyuko_Ex_deadflag",FALSE,0)
								return nil
							end
							if(GetDistanceBetweenTwoVec2D(target:GetOrigin(),vecCaster)>300) and FindTelentValue(target,"special_bonus_unique_necrophos_3") == 0 then
								target:SetOrigin(vecCaster)
								SetTargetToTraversable(target)
							end
							return 0.03
						else
							if(target~=nil)then
								target:Kill(keys.ability, unit)
						    else
						    	target:Kill(keys.ability, nil)
						    end
						    target:SetContextNum("ability_yuyuko_Ex_deadflag",FALSE,0)
						    return nil
						end
					end, 
				0.03) 
				return false
			end
		end
	end
	return true
end

function THDOTSGameMode:OnMinamitsuMoveToShip(hero,ship)
  local ability = hero:FindAbilityByName("ability_thdots_minamitsu04")
  if ability ~= nil then
    hero:SetContextThink("ability_thdots_minamitsu_04_move_to_ship",
     	 function ()
     	 	if GameRules:IsGamePaused() then return 0.03 end
	        if hero ~= nil and ship ~= nil and ship:IsNull()==false and hero:IsNull() == false then
	          local shipAbility = ship:FindAbilityByName("ability_thdots_minamitsu04_unit_upload")
	          ship:CastAbilityOnTarget(hero,shipAbility, hero:GetPlayerOwnerID())
	        else
          return nil
        end
      end,
    0.03)
  end
end

function THDOTSGameMode:OnMinamitsu04ShipDownload(caster)
	caster.IsDriving = false
	caster:EmitSound("Voice_Thdots_Minamitsu.AbilityMinamitsu042")
	FindClearSpaceForUnit(caster, caster:GetOrigin(), false)
	caster:MoveToPositionAggressive(caster:GetOrigin())
	caster:RemoveNoDraw()
	caster:RemoveModifierByName("modifier_minamitsu04_Invincible")

	Timer.Wait 'ability_minamitsu_04_remove_speed' (2,
		function()
			if caster.IsDriving == false then
				if caster.ability_minamitsu_ship ~= nil and caster.ability_minamitsu_ship:IsNull() == false then
					caster.ability_minamitsu_ship:RemoveModifierByName("modifier_minamitsu04_speed")
				end
			end
		end
	)
end

function THDOTSGameMode:OnMinamitsu04ShipDownload(caster)
	caster.IsDriving = false
	caster:EmitSound("Voice_Thdots_Minamitsu.AbilityMinamitsu042")
	FindClearSpaceForUnit(caster, caster:GetOrigin(), false)
	caster:MoveToPositionAggressive(caster:GetOrigin())
	caster:RemoveNoDraw()
	caster:RemoveModifierByName("modifier_minamitsu04_Invincible")

	Timer.Wait 'ability_minamitsu_04_remove_speed' (2,
		function()
			if caster.IsDriving == false then
				if caster.ability_minamitsu_ship ~= nil and caster.ability_minamitsu_ship:IsNull() == false then
					caster.ability_minamitsu_ship:RemoveModifierByName("modifier_minamitsu04_speed")
				end
			end
		end
	)
end

Cast_xianzhezhishi = function (keys)
	print(keys.val)
	local val = keys.val
	local plyid = keys.PlayerID
	
	if PlayerResource:GetSelectedHeroName(plyid) == "npc_dota_hero_invoker" then
			
		local hero = PlayerResource:GetPlayer(plyid):GetAssignedHero()
		if hero == nil then return end
		local ability = nil 
		for i=0,29 do
			if hero:GetAbilityByIndex(i):GetAbilityName() ==
			"ability_thdots_patchouli_xianzhezhishi" then
				ability = hero:GetAbilityByIndex(i)
			end
		end
			
		if ability ~= nil then
			hero:CastAbilityNoTarget(ability, plyid)
		end
	
	end
	
end

RegisterCustomEventListener("Cast_xianzhezhishi", Cast_xianzhezhishi)

-- function THDOTSGameMode:On_dota_item_purchase(data)
--   print("[BAREBONES] dota_item_purchase")
--   -- print_r(data)
-- end

-- function THDOTSGameMode:On_dota_item_purchased(data)
--   print("[BAREBONES] dota_item_purchased")
--   -- print_r(data)
-- end



RegisterCustomEventListener("Shuffle_Pressed", Shuffle_Pressed)

