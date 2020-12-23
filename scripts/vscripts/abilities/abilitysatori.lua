ability={}
abilityname={}
pet={}
-- AbilityStolenName = nil
-- require ( "script/new_thd/spells/heroes/npc_abilities_kogasa")
function OnSatori01SpellStart(keys)	
	local caster = keys.caster
	local target = keys.target
	local TargetName = target:GetClassname()
	local RandomNumber
	local AbilityLevel
	local SwapAbilityName
	caster:EmitSound("Voice_Thdots_Satori.AbilitySatori01")
	caster:FindAbilityByName("rubick_empty2"):SetAbilityIndex(-1)
	caster:FindAbilityByName("rubick_empty2"):SetHidden(true)
	if caster:HasModifier("modifier_item_wanbaochui") then
		THDReduceCooldown(keys.ability,-16)
	end
	if target:IsRealHero()==false then 
		keys.ability:RefundManaCost()
		keys.ability:EndCooldown()
		return end
	if(caster.sakuya04_cooldown_reset==TRUE)then
		keys.ability:EndCooldown()
		local usedCount = caster.sakuya04_ability_01_used_count + 1
		caster:SetMana(caster:GetMana() - usedCount * 0.25 * keys.ability:GetManaCost(keys.ability:GetLevel()))
		caster.sakuya04_ability_01_used_count = usedCount
	end
	abilityname[0]="rubick_empty1"
	local i = 1
	if abilityname[2] == nil then abilityname[2]= 0 end
	if b == nil then b = 0 end
	if a == nil then a = 0 end
	--keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))
	if TargetName == "npc_dota_hero_drow_ranger" then return end
	a=a+1
	SwapAbilityName = abilityname[a-1]

	caster:RemoveModifierByName("passive_reisenOld02_attack")
	caster:RemoveModifierByName("passive_aya04_modifier")
	caster:RemoveModifierByName("passive_flandre04_Refresh")
	caster:RemoveModifierByName("modifier_thdots_Remilia04_think_interval")
	caster:RemoveModifierByName("modifier_thdots_medicine03_onattacked")
	caster:RemoveModifierByName("modifier_thdots_komachi_blink")
	caster:RemoveModifierByName("modifier_thdots_kaguya03_mana_regen")
	caster:RemoveModifierByName("modifier_medicine01_arrow")
	caster:RemoveModifierByName("passive_tensi03_attacked")
	caster:RemoveModifierByName("modifier_clown03_passive")
	caster:RemoveModifierByName("modifier_thdots_Utsuho02_mana_regen")
	caster:RemoveModifierByName("ability_reisenold03_animation")
	caster:RemoveModifierByName("ability_reisenold03_modifier")
	caster:RemoveModifierByName("modifier_thdots_reisen03_time")
	caster:RemoveModifierByName("modifier_ability_thdots_shou02")
	caster:RemoveModifierByName("modifier_mystiaEx")
	caster:RemoveModifierByName("modifier_ability_thdots_hatate01")
	caster:RemoveModifierByName("modifier_ability_thdots_nitori03")
	if caster:HasModifier("modifier_kagerou_add_damage") then
		caster:RemoveModifierByName("modifier_kagerou_add_damage")
		print("doit")
	end
	caster:RemoveModifierByName("modifier_ability_thdots_kagerou03")
	caster:RemoveModifierByName("modifier_ability_thdots_chen03")
	caster:RemoveModifierByName("modifier_suwako03_return_mana")
	caster:RemoveModifierByName("modifier_ability_thdots_keine03_passive")
	----------------------------------------------------下面是DOTA2的BUFF
	caster:RemoveModifierByName("modifier_medusa_mana_shield")
	caster:RemoveModifierByName("modifier_leshrac_pulse_nova")
	caster:RemoveModifierByName("modifier_voodoo_restoration_aura")
	
	

	if TargetName == "npc_dota_hero_lina" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)			
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_dota2x_reimu01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_dota2x_reimu02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_dota2x_reimu03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_dota2x_reimu04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_crystal_maiden" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,66)
		end
		if RandomNumber <= 33 then
			AbilityStolenName = "ability_thdots_marisa01"
		elseif RandomNumber > 33 and RandomNumber <= 66 then
			AbilityStolenName = "ability_thdots_marisa02"	
		elseif RandomNumber > 66 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_marisa04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_juggernaut" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,50)
		end
		if RandomNumber > 0 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_youmu01"
		elseif RandomNumber > 50 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_youmu04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_slark" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,66)
		end
		if RandomNumber <= 33 then
			AbilityStolenName = "ability_thdots_aya01"
		elseif RandomNumber > 33 and RandomNumber <= 66 then
			AbilityStolenName = "ability_thdots_aya02"		
		elseif RandomNumber > 66 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_aya04"
			i = 2	
		end
	end

	if TargetName == "npc_dota_hero_earthshaker" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,66)
		end
		if RandomNumber <= 33 then
			AbilityStolenName = "earthshaker_fissure"
		elseif RandomNumber > 33 and RandomNumber <= 66 then
			AbilityStolenName = "ability_thdots_tensi03"
		elseif RandomNumber > 66 and RandomNumber <= 100 then
			AbilityStolenName = "zuus_thundergods_wrath"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_dark_seer" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_byakuren01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_byakuren02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_byakuren03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_byakuren05"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_necrolyte" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,66)
		end
		if RandomNumber <= 33 then
			AbilityStolenName = "death_prophet_carrion_swarm"
		elseif RandomNumber > 33 and RandomNumber <= 66 then
			AbilityStolenName = "bane_nightmare"	
		elseif RandomNumber > 66 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_yuyuko04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_templar_assassin" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_sakuya01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_sakuya02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_sakuya03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_sakuya04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_naga_siren" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,50)
		end
		if RandomNumber <= 50 then
			AbilityStolenName = "naga_siren_mirror_image"
		elseif RandomNumber > 50 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_flandre04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_chaos_knight" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,50)
		end
		if RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_mokou01"
		elseif RandomNumber > 50 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_mokou04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_centaur" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,50)
		end
		if RandomNumber > 0 and RandomNumber <= 50 then
			AbilityStolenName = "centaur_hoof_stomp"
		elseif RandomNumber > 50 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_yugi04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_tidehunter" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,66)
		end
		if RandomNumber <= 33 then
			AbilityStolenName = "tiny_toss"
		elseif RandomNumber > 33 and RandomNumber <= 66 then
			AbilityStolenName = "ability_thdots_suika03"	
		elseif RandomNumber > 66 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_suika04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_life_stealer" then
		AbilityStolenName = "ability_thdots_rumia01"
	end

	if TargetName == "npc_dota_hero_razor" then
			RandomNumber = RandomInt(1,100)
		if RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_iku02"
		elseif RandomNumber > 50 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_ikuEx"
		end
	end

	if TargetName == "npc_dota_hero_sniper" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)			
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_Utsuho01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_Utsuho02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_Utsuho03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_Utsuho04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_silencer" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)			
		else 
			RandomNumber = RandomInt(1,80)
		end
		if RandomNumber <= 20 then
			AbilityStolenName = "disruptor_kinetic_field"
		elseif RandomNumber > 20 and RandomNumber <= 40 then
			AbilityStolenName = "ability_thdots_eirin02"
		elseif RandomNumber > 40 and RandomNumber <= 60 then
			AbilityStolenName = "ability_thdots_eirin03"
		elseif RandomNumber > 60 and RandomNumber <= 80 then
			AbilityStolenName = "ability_thdots_eirinex"	
		elseif RandomNumber > 80 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_eirin04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_furion" then
		RandomNumber = RandomInt(1,100)
		if RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_kaguya01"
		else
			AbilityStolenName = "ability_thdots_kaguya03"
		end
	end

	if TargetName == "npc_dota_hero_mirana" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)			
		else 
			RandomNumber = RandomInt(1,66)
		end
		if RandomNumber <= 33 then
			AbilityStolenName = "ability_thdots_reisenOld02"	
		elseif RandomNumber > 33 and RandomNumber <= 66 then
			AbilityStolenName = "ability_thdots_reisenOld03"
		elseif RandomNumber > 66 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_reisenOld04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_lion" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)			
		else 
			RandomNumber = RandomInt(1,66)
		end
		if RandomNumber <= 33 then
			AbilityStolenName = "ability_thdots_sanae01"
		elseif RandomNumber > 33 and RandomNumber <= 66 then
			AbilityStolenName = "ability_thdots_sanae02"		
		elseif RandomNumber > 66 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_sanae04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_warlock" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)			
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_remilia01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_remilia02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_remilia03"	
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_remilia04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_storm_spirit" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)			
		else 
			RandomNumber = RandomInt(1,66)
		end
		if RandomNumber <= 33 then
			AbilityStolenName = "ability_thdots_shikieiki01"
		elseif RandomNumber > 33 and RandomNumber <= 66 then
			AbilityStolenName = "ability_thdots_shikieiki02"	
		elseif RandomNumber > 66 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_shikieiki04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_bounty_hunter" then
			RandomNumber = RandomInt(1,100)		
		if RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_momiji02"
		elseif RandomNumber > 50 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_momiji03"
		end
	end

	if TargetName == "npc_dota_hero_clinkz" then
			RandomNumber = RandomInt(1,100)		
		if RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_wriggle01"
		elseif RandomNumber > 50 and RandomNumber <= 100 then
			AbilityStolenName = "death_prophet_exorcism"
		end
	end

	if TargetName == "npc_dota_hero_tinker" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)			
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_yumemi01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_yumemi02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_yumemi03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_yumemi04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_axe" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)			
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_cirno01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_cirno02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_cirno03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_cirno04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_zuus" then	
		RandomNumber = RandomInt(1,75)
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_yasaka01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_yasaka02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_yasaka03"		
		end
	end

	if TargetName == "npc_dota_hero_kunkka" then	
		RandomNumber = RandomInt(1,75)
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_minamitsu01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_minamitsu02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_minamitsu03"		
		end
	end

	if TargetName == "npc_dota_hero_obsidian_destroyer" then
		RandomNumber = RandomInt(1,75)
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_yukari01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_yukari02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_yukari03"		
		end
	end

	if TargetName == "npc_dota_hero_puck" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)			
		else 
			RandomNumber = RandomInt(1,80)
		end
		if RandomNumber <= 20 then
			AbilityStolenName = "ability_thdots_ran01"
		elseif RandomNumber > 20 and RandomNumber <= 40 then
			AbilityStolenName = "ability_thdots_ran02"
		elseif RandomNumber > 40 and RandomNumber <= 60 then
			AbilityStolenName = "ability_thdots_ran03"
		elseif RandomNumber > 60 and RandomNumber <= 80 then	
			AbilityStolenName = "ability_thdots_RanEx"
		elseif RandomNumber > 80 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_ran04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_venomancer" then
		RandomNumber = RandomInt(1,100)			
		if RandomNumber <= 33 then
			AbilityStolenName = "ability_thdots_yuuka01"
		elseif RandomNumber > 33 and RandomNumber <= 66 then
			AbilityStolenName = "ability_thdots_yuuka02"
		elseif RandomNumber > 66 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_yuuka03"		
		end
	end

	if TargetName == "npc_dota_hero_visage" then
		AbilityStolenName = "ability_thdots_Margatroid03"
	end

	if TargetName == "npc_dota_hero_huskar" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)			
		else 
			RandomNumber = RandomInt(1,66)
		end
		if RandomNumber <= 33 then
			AbilityStolenName = "ability_thdots_minoriko01"
		elseif RandomNumber > 33 and RandomNumber <= 66 then
			AbilityStolenName = "ability_thdots_minoriko02"
		elseif RandomNumber > 66 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_minoriko04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_phantom_assassin" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)			
		else 
			RandomNumber = RandomInt(1,50)
		end
		if RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_nue02"		
		elseif RandomNumber > 50 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_nue04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_invoker" then
		RandomNumber = RandomInt(1,15)
		PatchouliAbility = {}
		PatchouliAbility[1]="ability_thdots_patchouli_fire_fire"
		PatchouliAbility[2]="ability_thdots_patchouli_fire_water"
		PatchouliAbility[3]="ability_thdots_patchouli_fire_wood"
		PatchouliAbility[4]="ability_thdots_patchouli_fire_metal"
		PatchouliAbility[5]="ability_thdots_patchouli_fire_earth"
		PatchouliAbility[6]="ability_thdots_patchouli_water_water"
		PatchouliAbility[7]="ability_thdots_patchouli_water_wood"
		PatchouliAbility[8]="ability_thdots_patchouli_water_metal"
		PatchouliAbility[9]="ability_thdots_patchouli_water_earth"
		PatchouliAbility[10]="ability_thdots_patchouli_wood_wood"
		PatchouliAbility[11]="ability_thdots_patchouli_wood_metal"
		PatchouliAbility[12]="ability_thdots_patchouli_wood_earth"
		PatchouliAbility[13]="ability_thdots_patchouli_metal_metal"
		PatchouliAbility[14]="ability_thdots_patchouli_metal_earth"
		PatchouliAbility[15]="ability_thdots_patchouli_earth_earth"		
		AbilityStolenName = PatchouliAbility[RandomNumber]
	end

	if TargetName == "npc_dota_hero_elder_titan" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)			
		else 
			RandomNumber = RandomInt(1,50)
		end
		if RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_komachi01"		
		elseif RandomNumber > 50 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_komachi04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_viper" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)			
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_medicine01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_medicine02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_medicine03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_medicine04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_doom_bringer" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_clown01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_clown02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_clown03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_clown04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_lich" then		
		RandomNumber = RandomInt(1,100)	
		if RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_koakuma01"
		elseif RandomNumber > 50 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_koakuma02"		
		end
	end

	if TargetName == "npc_dota_hero_dazzle" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,50)
		end
		if 	RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_lunasa01"
		elseif RandomNumber > 50 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_lunasa04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_dragon_knight" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,90)
		else 
			RandomNumber = RandomInt(1,60)
		end
		if 	RandomNumber <= 30 then
			AbilityStolenName = "ability_thdots_meirin01"
		elseif RandomNumber > 30 and RandomNumber <= 60 then
			AbilityStolenName = "ability_thdots_meirin02"
		elseif RandomNumber > 60 and RandomNumber <= 90 then
			AbilityStolenName = "ability_thdots_meirin04_fix"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_weaver" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,90)
		else 
			RandomNumber = RandomInt(1,60)
		end
		if 	RandomNumber <= 30 then
			AbilityStolenName = "ability_thdots_lyrica01"
		elseif RandomNumber > 30 and RandomNumber <= 60 then
			AbilityStolenName = "ability_thdots_lyrica02"
		elseif RandomNumber > 60 and RandomNumber <= 90 then
			AbilityStolenName = "ability_thdots_lyrica04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_mars" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,90)
		else 
			RandomNumber = RandomInt(1,60)
		end
		if 	RandomNumber <= 30 then
			AbilityStolenName = "ability_thdots_shou01"
		elseif RandomNumber > 30 and RandomNumber <= 60 then
			AbilityStolenName = "ability_thdots_shou02"
		elseif RandomNumber > 60 and RandomNumber <= 90 then
			AbilityStolenName = "ability_thdots_shou04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_luna" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,90)
		else 
			RandomNumber = RandomInt(1,60)
		end
		if 	RandomNumber <= 30 then
			AbilityStolenName = "ability_thdots_child01"
		elseif RandomNumber > 30 and RandomNumber <= 60 then
			AbilityStolenName = "ability_thdots_child02"
		elseif RandomNumber > 60 and RandomNumber <= 90 then
			AbilityStolenName = "ability_thdots_child04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_earth_spirit" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,90)
		else 
			RandomNumber = RandomInt(1,60)
		end
		if 	RandomNumber <= 30 then
			AbilityStolenName = "ability_thdots_Merlin01"
		elseif RandomNumber > 30 and RandomNumber <= 60 then
			AbilityStolenName = "ability_thdots_Merlin02"
		elseif RandomNumber > 60 and RandomNumber <= 90 then
			AbilityStolenName = "ability_thdots_Merlin04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_night_stalker" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_mystia01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_mystia02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_mystiaex"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_mystia04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_vengefulspirit" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,80)
		end
		if RandomNumber <= 20 then
			AbilityStolenName = "ability_thdots_hatate01"
		elseif RandomNumber > 20 and RandomNumber <= 40 then
			AbilityStolenName = "ability_thdots_hatate02"
		elseif RandomNumber > 40 and RandomNumber <= 60 then
			AbilityStolenName = "ability_thdots_hatate03"
		elseif RandomNumber > 60 and RandomNumber <= 80 then
			AbilityStolenName = "ability_thdots_hatateEx"
		elseif RandomNumber > 80 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_hatate04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_riki" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_kogasa01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_kogasa02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_kogasa03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_kogasa04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_gyrocopter" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_tei01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_tei02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_tei03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_tei04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_spectre" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_nitori01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_nitori02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_nitori03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_nitori04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_legion_commander" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_kokoro01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_kokoro02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_kokoro03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_kokoro04"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_phantom_lancer" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,75)
		else 
			RandomNumber = RandomInt(1,50)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_reisen_2_01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_reisen_2_02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_reisen_2_ultimate"
			i = 2
		end
	end
	if TargetName == "npc_dota_hero_witch_doctor" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_hina01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_hina02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_hina03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_hina04"
			i = 2
		end
	end
	if TargetName == "npc_dota_hero_lycan" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_kagerou01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_kagerou02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_kagerou03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_kagerou06"
			i = 2
		end
	end
	if TargetName == "npc_dota_hero_batrider" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_seija01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_seija02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_seija03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_seija04"
			i = 2
		end
	end
	if TargetName == "npc_dota_hero_leshrac" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_lily01_lua"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_lily02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_lily03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_lily04"
			i = 2
		end
	end
	if TargetName == "npc_dota_hero_ursa" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,75)
		else 
			RandomNumber = RandomInt(1,50)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdotsr_Nazrin01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdotsr_Nazrin02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdotsr_Nazrin04"
			i = 2
		end
	end
	if TargetName == "npc_dota_hero_oracle" then
		RandomNumber = RandomInt(1,75)
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdotsr_star01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdotsr_star02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdotsr_star03"
		end
	end
	if TargetName == "npc_dota_hero_sven" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_yorihime_01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_yorihime_02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_yorihime_03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_yorihime_ultimate"
			i = 2
		end
	end
	if TargetName == "npc_dota_hero_rattletrap" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_sunny01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_sunny02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_sunny03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_sunny04"
			i = 2
		end
	end
	if TargetName == "npc_dota_hero_terrorblade" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_chen01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_chen02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_chen03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_chen04"
			i = 2
		end
	end
	if TargetName == "npc_dota_hero_ogre_magi" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_suwako01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_suwako02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_suwako03z"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_suwako04new"
			i = 2
		end
	end

	if TargetName == "npc_dota_hero_bane" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_shinki_01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_shinki_02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_shinki_01"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_shinki_ultimate"
			i = 2
		end
	end
	if TargetName == "npc_dota_hero_skywrath_mage" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_sumireko01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_sumireko02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_sumireko03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_sumireko04"
			i = 2
		end
	end
	if TargetName == "npc_dota_hero_broodmother" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_yamame03"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_yamame03"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_yamame03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_yamame04"
			i = 2
		end
	end
	if TargetName == "npc_dota_hero_nyx_assassin" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_daiyousei01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_daiyousei02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_daiyousei03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_daiyousei04"
			i = 2
		end
	end
	if TargetName == "npc_dota_hero_void_spirit" then
		if caster:GetLevel() >= 6 then
			RandomNumber = RandomInt(1,100)
		else 
			RandomNumber = RandomInt(1,75)
		end
		if RandomNumber <= 25 then
			AbilityStolenName = "ability_thdots_keine01"
		elseif RandomNumber > 25 and RandomNumber <= 50 then
			AbilityStolenName = "ability_thdots_keine02"
		elseif RandomNumber > 50 and RandomNumber <= 75 then
			AbilityStolenName = "ability_thdots_keine03"
		elseif RandomNumber > 75 and RandomNumber <= 100 then
			AbilityStolenName = "ability_thdots_keine04"
			i = 2
		end
	end


	abilityname[a] = AbilityStolenName
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_satori01_time_up", {})
	if caster:HasAbility(AbilityStolenName)==true then
		caster:FindAbilityByName(abilityname[a]):SetHidden(false)
		print("has_same")
	else
		caster:AddAbility(AbilityStolenName)
		keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_satori01_remove", {Duration = keys.Duration})
	end

	ability[a] = caster:FindAbilityByName(AbilityStolenName)
	ability[0] = caster:FindAbilityByName("rubick_empty1")

	if i == 2 then
		AbilityLevel = math.floor(caster:GetLevel()/6) 
		if AbilityLevel > 3 then
			AbilityLevel = 3
		end
	elseif i == 1 then
		AbilityLevel = keys.ability:GetLevel()
	end	
	if (abilityname[a] ~= abilityname[a-1]) then
		caster:SwapAbilities(abilityname[a], SwapAbilityName, true, false)
		ability[a-1]:SetLevel(0)	
	end
	ability[a]:SetLevel(AbilityLevel)
	target:RemoveModifierByName("modifier_thdots_satori01")	
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf", PATTACH_CUSTOMORIGIN, keys.caster)
		ParticleManager:SetParticleControlEnt(effectIndex , 0, keys.caster, 5, "follow_origin", Vector(0,0,0), true)
		ParticleManager:SetParticleControl(effectIndex, 1, keys.caster:GetOrigin())
		ParticleManager:DestroyParticleSystemTime(effectIndex,2)
end

function OnSatori01SpellEnd(keys)
	local caster = keys.caster	
	if Satori01RemoveCount==nil then Satori01RemoveCount = 0 end
	if 	caster:GetAbilityByIndex(19+Satori01RemoveCount)~=nil then 		
		print("remove",caster:GetAbilityByIndex(19+Satori01RemoveCount):GetAbilityName())		
		caster:RemoveAbility(caster:GetAbilityByIndex(19+Satori01RemoveCount):GetAbilityName())
		Satori01RemoveCount=Satori01RemoveCount+1
		if Satori01RemoveCount==7 then Satori01RemoveCount = 0 end
	end
end

function OnSatori01TimeUp(keys)
	local caster=keys.caster
		caster:FindAbilityByName(abilityname[a]):SetHidden(true)
		caster:FindAbilityByName("rubick_empty2"):SetHidden(false)
end

function OnSatori02SpellStart(keys)
	local caster = keys.caster
	local target = keys.target
	local targetPoint = target:GetOrigin()	
	if(caster.sakuya04_cooldown_reset==TRUE)then
		keys.ability:EndCooldown()
		local usedCount = caster.sakuya04_ability_01_used_count + 1
		caster:SetMana(caster:GetMana() - usedCount * 0.25 * keys.ability:GetManaCost(keys.ability:GetLevel()))
		caster.sakuya04_ability_01_used_count = usedCount
	end
	if is_spell_blocked(target) then return end
	local targets = FindUnitsInRadius(
		   caster:GetTeam(),		--caster team
		   targetPoint,				--find position
		   nil,						--find entity
		   keys.Radius,				--find radius
		   DOTA_UNIT_TARGET_TEAM_ENEMY,
		   keys.ability:GetAbilityTargetType(),
		   0, FIND_CLOSEST,
		   false
	)
	for k,v in pairs(targets) do
		keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_thdots_satori02", {Duration = keys.Duration})
		keys.ability:ApplyDataDrivenModifier(caster, v, "modifier_thdots_satori02_think", {Duration = keys.Duration})
		if v:HasModifier("modifier_thdots_satori04") then
		UtilStun:UnitStunTarget( caster, v, keys.Duration)
		end	
	end	
	
end

function OnSatori02SpellThink(keys)
	local caster = keys.caster
	local target = keys.target
	local damage_target = {
		victim = keys.target,
		attacker = caster,
		damage = (keys.ability:GetAbilityDamage() + FindTelentValue(caster,"special_bonus_unique_rubick_3"))/3,
		damage_type = keys.ability:GetAbilityDamageType(), 
	    damage_flags = 0
	}
	UtilStun:UnitStunTarget( caster, target, 0.3)
	UnitDamageTarget(damage_target)
end

anti_bd_modifier_name="modifier_thdots_unit_anti_bd"

function OnSatori03SpellStart(keys)
	local caster = keys.caster
	local target = keys.target
	local MaxNum = keys.MaxNum
	local vec = target:GetOrigin()
	if(caster.sakuya04_cooldown_reset==TRUE)then
		keys.ability:EndCooldown()
		local usedCount = caster.sakuya04_ability_01_used_count + 1
		caster:SetMana(caster:GetMana() - usedCount * 0.25 * keys.ability:GetManaCost(keys.ability:GetLevel()))
		caster.sakuya04_ability_01_used_count = usedCount
	end
	local PetName = target:GetUnitName()
	print(PetName)
	if target:IsAncient()==true and FindTelentValue(caster,"special_bonus_unique_rubick")==0 then 
		 keys.ability:EndCooldown()
		 keys.ability:RefundManaCost()
		 return
	elseif PetName=="npc_thdots_unit_minoriko02_box" then 
		 keys.ability:EndCooldown()
		 keys.ability:RefundManaCost()
		 return
	elseif PetName=="ability_minamitsu_04_ship" then 
		 keys.ability:EndCooldown()
		 keys.ability:RefundManaCost()
		 return
	elseif PetName=="ability_momiji_Spawn_unit" then 
		 keys.ability:EndCooldown()
		 keys.ability:RefundManaCost()
		 return
	elseif PetName=="ability_margatroid03_doll" then 
		 keys.ability:EndCooldown()
		 keys.ability:RefundManaCost()
		 return
	elseif PetName=="npc_dota_suika_03_smallsuika" then 
		 keys.ability:EndCooldown()
		 keys.ability:RefundManaCost()
		 return		 
	elseif PetName=="ability_margatroidex_doll" then 
		 keys.ability:EndCooldown()
		 keys.ability:RefundManaCost()
		 return	 
	elseif (target:GetClassname()=="npc_dota_roshan") then 
		 keys.ability:EndCooldown()
		 keys.ability:RefundManaCost()
		return
	elseif target:HasModifier("modifier_ability_thdots_super_siege") then
		 keys.ability:EndCooldown()
		 keys.ability:RefundManaCost()
		return
	end
	if target:GetOwner()==caster then 
		target:SetHealth(target:GetMaxHealth())
		return
	end
	target:Kill(keys.ability, caster)
	local unit = CreateUnitByName(
			PetName
			,vec
			,false
			,caster
			,caster
			,caster:GetTeam()
		)
	unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true) 
	keys.ability:ApplyDataDrivenModifier(caster, unit, anti_bd_modifier_name, {})
	keys.ability:ApplyDataDrivenModifier(caster, unit, "modifier_thdots_satori03_buff", {Duration = keys.Duration})
	if unit:GetMaxHealth() < keys.MaxHealth then
		unit:SetBaseMaxHealth(keys.MaxHealth)
	end
	if i == nil then i = 1 end
	pet[i] = unit	
	if i > MaxNum then 
		if pet[i-MaxNum] ~=nil and pet[i-MaxNum]:IsNull() == false then 
		pet[i-MaxNum]:ForceKill(false)
		end
	end
	i=i+1
end

function OnSatori04SpellStart(keys)	
	local caster = keys.caster
	local target = keys.target
	caster:EmitSound("Voice_Thdots_Satori.AbilitySatori04")
	if(caster.sakuya04_cooldown_reset==TRUE)then
		keys.ability:EndCooldown()
		local usedCount = caster.sakuya04_ability_01_used_count + 1
		caster:SetMana(caster:GetMana() - usedCount * 0.25 * keys.ability:GetManaCost(keys.ability:GetLevel()))
		caster.sakuya04_ability_01_used_count = usedCount
	end
	if is_spell_blocked(target) then return end
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_satori04", {Duration = keys.Duration}) --特效
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_satori04_think", {Duration = keys.Duration}) --易伤
	local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin()+Vector(0, 0, 100))
		ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin()+Vector(0, 0, 100))
end

function OnSatori04Think(keys)
	local caster = keys.caster
	local target = keys.target
	local distance = GetDistanceBetweenTwoVec2D(target:GetOrigin(),caster:GetOrigin())
	if Satori04Count == nil then Satori04Count = 0 end
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_satori04_bonus_damage", {Duration = keys.Duration})
	if distance <= keys.Radius + FindTelentValue(caster,"special_bonus_unique_rubick_2") then 
		Satori04Count = Satori04Count + 1 
		local effectIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(effectIndex, 0, caster:GetOrigin()+Vector(0, 0, 100))
		ParticleManager:SetParticleControl(effectIndex, 1, target:GetOrigin()+Vector(0, 0, 100))
		if FindTelentValue(caster,"special_bonus_unique_rubick_4")~=0 then
			local stealhp=target:GetMaxHealth()*0.06
			local stealmana=target:GetMaxMana()*0.06
			if target:GetHealth()>stealhp then
				target:SetHealth(target:GetHealth()-stealhp)
				caster:Heal(stealhp,caster)
			else
				caster:Heal(target:GetHealth(),caster)
				target:Kill(keys.ability,caster)
			end
			if target:GetMana()>stealmana then
				target:SetMana(target:GetMana()-stealmana)
				caster:GiveMana(stealmana)
			else
				caster:GiveMana(target:GetMana())
				target:SetMana(0)
			end
		end
	end
	target:SetModifierStackCount("modifier_thdots_satori04_bonus_damage", keys.ability, Satori04Count)	

end

function OnSatori04SpellEnd(keys)
	local caster = keys.caster
	local target = keys.target
	Satori04Count = 0
	target:SetModifierStackCount("modifier_thdots_satori04_bonus_damage", keys.ability, Satori04Count)
	target:RemoveModifierByName("modifier_thdots_satori04_bonus_damage")
end  